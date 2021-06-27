/*
 * Module: eth_frame_router
 * 
 * Routes Ethernet II Frames extracted from the Lattice Gbit MAC IP core to various queues based on the EtherType field.
 * 
 * Supported EtherTypes are: IPv4 (0x0800), and ARP (0x0806) (NOTE: MUST BE IPv4 ARP OVER ETHERNET).
 * Any other EtherType is dropped on the floor and a flag is raised.
 * 
 * MODULE ASSUMPTIONS:
 * 
 * * Lattice Gbit MAC IP is configured to Discard the FCS of the Ethernet II frame.
 * * Lattice Gbit MAC IP is configured to drop control frames (e.g. Pause) internal to the MAC and not pass them to this module.
 * * Lattice Gbit MAC IP is configured to NOT receive short frames (i.e. frames shorter than 64-bytes)
 * 
 */
 
`include "ethernet_support_pkg.sv"
 
module eth_frame_router #(
        
    parameter int unsigned CBUF_MAX_ETH_FRAME_DEPTH = 6, // Number of maximum sized Ethernet frames that can be simultaneously stored in the circular buffer
    parameter int unsigned IPV4_PKT_FIFO_PKT_DEPTH  = 4, // Number of maximum sized IPv4 packets that can be simultaneously stored in the output FIFO
    parameter int unsigned ARP_PKT_FIFO_PKT_DEPTH   = 2, // Number of maximum sized ARP packets that can be simultaneously stored in the output FIFO
    parameter bit          SIM_MODE                 = 0
        
)(

    /* LATTICE Gbit ETH MAC RX INTERFACE */
    input        i_rxmac_clk,
    input        i_rxmac_srst, // synchronous to i_rxmac_clk
    input        i_rx_write,
    input        i_rx_eof,
    input        i_rx_error,
    input [ 7:0] i_rx_dbout,
    input        i_rx_stat_en,
    input [31:0] i_rx_stat_vector,
    
    /* IPv4 OUTPUT PACKET INTERFACE */
    output [7:0] o_ipv4_pkt_byte,
    output       o_ipv4_pkt_byte_vld,
    output       o_ipv4_pkt_last_byte,
    input        i_ipv4_pkt_byte_rd,
    
    /* ARP OUTPUT PACKET INTERFACE */
    output [7:0] o_arp_pkt_byte,
    output       o_arp_pkt_byte_vld,
    output       o_arp_pkt_last_byte,
    input        i_arp_pkt_byte_rd,
    
    /* ERROR REPORTING */

    // IF ANY OF THESE ERRORS OCCUR YOU'LL NEED TO RESET THIS MODULE TO RECOVER AND CLEAR THE ERROR
    output reg   o_eth_frame_circ_buf_overflow, 
    output reg   o_ipv4_pkt_fifo_overflow,
    output reg   o_arp_pkt_fifo_overflow,
    // THESE ERROR STATUS SIGNALS GET ASSERTED FOR ONE CLOCK IF THEIR RESPECTIVE ERROR OCCURS.  YOU NEED EXTERNAL LOGIC TO KEEP TRACK OF THESE ERRORS IF DESIRED.
    output reg   o_eth_frame_long_frame_error,
    output reg   o_eth_frame_short_frame_error,
    output reg   o_eth_frame_ipg_error,
    output reg   o_eth_frame_crc_error,
    output reg   o_eth_frame_vlan_error,
    output reg   o_unsupported_eth_type_error

    // output [7:0] snap_cbuf_rd_fsm_state,
    // output [7:0] snap_cbuf_wr_fsm_state


);
    
    localparam integer CBUF_BYTES                 = CBUF_MAX_ETH_FRAME_DEPTH * (MTU_BYTES + ETH_TYPE_BYTES);
    localparam integer CBUF_BYTES_POW2            = 2**$clog2(CBUF_BYTES);
    localparam integer CBUF_ADDR_BITS             = $clog2(CBUF_BYTES_POW2);
    
    localparam integer IPV4_PKT_BUFFER_BYTES_MAX  = IPV4_PKT_FIFO_PKT_DEPTH * MTU_BYTES;
    localparam integer IPV4_PKT_BUFFER_BYTES_POW2 = 2**$clog2(IPV4_PKT_BUFFER_BYTES_MAX);         // next higher power of 2
    
    localparam integer ARP_PKT_BUFFER_BYTES       = ARP_PKT_FIFO_PKT_DEPTH * ETH_FRAME_MIN_BYTES; // ARP packets for IPv4 over Ethernet are 28 bytes, but they get padded to meet the min Ethernet frame size.
    localparam integer ARP_PKT_BUFFER_BYTES_POW2  = 2**$clog2(ARP_PKT_BUFFER_BYTES);              // next higher power of 2
    

    logic [8:0]                cbuf_ram [CBUF_BYTES_POW2] /* synthesis syn_ramstyle="block_ram" */;
    logic [8:0]                cbuf_din;
    logic [8:0]                cbuf_dout;
    logic [CBUF_ADDR_BITS-1:0] cbuf_waddr;      
    logic [CBUF_ADDR_BITS-1:0] cbuf_raddr;
    logic [CBUF_ADDR_BITS-1:0] cbuf_head;       // the location at which to write the next valid ethernet frame byte into the cbuf, only gets moved after a valid new ethernet frame has been fully written into the cbuf
    logic [CBUF_ADDR_BITS-1:0] cbuf_waddr_next; // the location at which to write the next valid ethernet frame byte into the cbuf
    logic [CBUF_ADDR_BITS-1:0] cbuf_tail;       // the location at which to read the next byte of a valid ethernet frame from the cbuf
    logic                      cbuf_wren;
    logic                      cbuf_empty;     // happens after resetting the cbuf or after reading the last valid ethernet frame byte in the cbuf
    
    // logic [7:0]                snap_cbuf_rd_fsm_state;
    // logic [7:0]                snap_cbuf_wr_fsm_state;

    enum {
        WAIT_FOR_NEXT_ETH_FRAME,
        SKIP_MAC_ADDRS,
        CONSUME_ETH_FRAME
    } cbuf_wr_fsm_state;
    
    logic [3:0] mac_addr_cntr; // counts how many MAC address bytes have been pulled out of the ethernet mac     
    
    enum {
        WAIT_FOR_NEW_FRAME,
        READ_ETHTYPE_0,
        READ_ETHTYPE_1,
        CHECK_ETHERTYPE,
        WAIT_FOR_ARP_PKT_FIFO_SPACE,
        ROUTE_ARP_PKT,
        WAIT_FOR_IPV4_PKT_FIFO_SPACE,
        ROUTE_IPV4_PKT,
        SKIP_PKT
    } cbuf_rd_fsm_state;

    // assign snap_cbuf_rd_fsm_state = cbuf_rd_fsm_state;
    // assign snap_cbuf_wr_fsm_state = cbuf_wr_fsm_state;
    
    logic [15:0] ethtype;
    logic        fatal_error;
    

    logic [8:0] arp_pkt_fifo_din;
    logic       arp_pkt_fifo_wren;
    logic       arp_pkt_fifo_full;
    logic       arp_pkt_fifo_afull;

    logic [8:0] ipv4_pkt_fifo_din;
    logic       ipv4_pkt_fifo_wren;
    logic       ipv4_pkt_fifo_full;
    logic       ipv4_pkt_fifo_afull;
    
    
    /* NEW ETHERNET FRAME CIRCULAR BUFFER */
    
    always_ff @(posedge i_rxmac_clk) begin
        if (cbuf_wren) begin
            cbuf_ram[cbuf_waddr] <= cbuf_din;
        end

//        cbuf_dout <= cbuf_ram[cbuf_raddr];
    end
    
    assign cbuf_dout = cbuf_ram[cbuf_raddr];
    
    // cbuff overflow and empty logic
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_eth_frame_circ_buf_overflow <= 0;
            cbuf_empty                    <= 1;
        end else begin
            
            if ( (cbuf_wren == 1) && (cbuf_waddr == cbuf_raddr) && (cbuf_empty == 0) ) begin // wrote to our tail when we weren't empty!
                o_eth_frame_circ_buf_overflow <= 1;
            end
            
            if (cbuf_tail == cbuf_head) begin 
                cbuf_empty <= 1;
            end else begin
                cbuf_empty <= 0;
            end
        end
    end

`ifdef VERILATE_DEF
logic [CBUF_ADDR_BITS-1:0] cbuf_fill_level;
always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            cbuf_fill_level <= 0;
        end else begin
            cbuf_fill_level <= cbuf_head - cbuf_tail;
        end
    end
`endif
    
    /*
     * FATAL ERROR MONITORING.  IF A "FATAL" ERROR OCCURS THE USER WILL NEED TO RESET THIS MODULE.
     */
    
    assign fatal_error = o_eth_frame_circ_buf_overflow | o_ipv4_pkt_fifo_overflow | o_arp_pkt_fifo_overflow;

    
    /* 
     * Consumes new ethernet frames from the MAC and writes them into the circular buffer.  
     * If a frame turns out to have an error then the cbuf write head pointer remains in its current location.  If a frame is good then the cbuf write head pointer is moved to the
     * location of the last byte of the good frame. 
     */ 
    always_ff @(posedge i_rxmac_clk) begin: CBUF_WR_FSM
        
        if (i_rxmac_srst | fatal_error) begin
            cbuf_wr_fsm_state             <= WAIT_FOR_NEXT_ETH_FRAME;
            cbuf_wren                     <= 0;
            cbuf_waddr                    <= '0;
            cbuf_head                     <= '0;
            cbuf_waddr_next               <= '0;
            mac_addr_cntr                 <= 4'd0;
            o_eth_frame_long_frame_error  <= 0;
            o_eth_frame_short_frame_error <= 0;
            o_eth_frame_ipg_error         <= 0;
            o_eth_frame_crc_error         <= 0;
            o_eth_frame_vlan_error        <= 0;
        end else begin
            
            /* defaults */
            cbuf_wren                     <= 0;
            o_eth_frame_long_frame_error  <= 0;
            o_eth_frame_short_frame_error <= 0;
            o_eth_frame_ipg_error         <= 0;
            o_eth_frame_crc_error         <= 0;
            o_eth_frame_vlan_error        <= 0;
            
            case (cbuf_wr_fsm_state)
                
                WAIT_FOR_NEXT_ETH_FRAME: begin
                    if (i_rx_write) begin
                        mac_addr_cntr     <= mac_addr_cntr + 1;
                        cbuf_wr_fsm_state <= SKIP_MAC_ADDRS;
                    end
                end
                
                SKIP_MAC_ADDRS: begin
                    if (i_rx_write) begin
                        mac_addr_cntr <= mac_addr_cntr + 1;
                        if (mac_addr_cntr == 4'd11) begin // last MAC address byte from the ethernet mac
                            cbuf_wr_fsm_state <= CONSUME_ETH_FRAME;
                        end
                    end
                end
                
                CONSUME_ETH_FRAME: begin
                    
                    mac_addr_cntr <= 4'd0;
                    
                    if (i_rx_write) begin // the first time this is seen in this state it should correspond to the first byte of the EtherType coming out of the ethernet mac
                        
                        /* normal operation assignments */
                        cbuf_din        <= {i_rx_eof, i_rx_dbout};
                        cbuf_wren       <= 1;
                        cbuf_waddr      <= cbuf_waddr_next;
                        cbuf_waddr_next <= cbuf_waddr_next + 1;
                        
                        if (i_rx_eof) begin // note: this signal qualifies the rx error signal from the lattice gbit eth mac.  it also appears to qualify the rx stat vector even though technically the rx stat en signals is for that.

                            cbuf_wr_fsm_state <= WAIT_FOR_NEXT_ETH_FRAME; // error or not we're done writing this ethernet frame into the cbuf
                            
                            // check for anything that might be wrong with this packet
                            if (i_rx_error == 1 || {i_rx_stat_vector[31:30], i_rx_stat_vector[26:24], i_rx_stat_vector[22], i_rx_stat_vector[20:16]} != 12'd0 ) begin

                                cbuf_waddr_next <= cbuf_head; // let's pretend like this frame never was written into our buffer
                                
                                // error reporting
                                o_eth_frame_long_frame_error  <= i_rx_stat_vector[31];
                                o_eth_frame_short_frame_error <= i_rx_stat_vector[30];
                                o_eth_frame_crc_error         <= i_rx_stat_vector[25];
                                o_eth_frame_vlan_error        <= i_rx_stat_vector[16];
                            end else begin
                                o_eth_frame_ipg_error <= i_rx_stat_vector[29]; // this isn't really a reason to ignore the frame.  too many of these and we'll overflow the cbuf, but let's not make a big deal over the occasional one
                                cbuf_head             <= cbuf_waddr_next + 1;  // safe to update cbuf head since there were no problems with the packet
                            end
                        end
                    end
                end
            endcase
        end
    end

    
    /*
     * Reads bytes of an Ethernet frame from the circular buffer and shoves the frame into the appropriate output FIFO.  The EtherType is NOT written into the output FIFO.
     */ 
    
    always_ff @(posedge i_rxmac_clk) begin: CBUF_RD_FSM
        
        if (i_rxmac_srst | fatal_error) begin
            cbuf_rd_fsm_state            <= WAIT_FOR_NEW_FRAME;
            cbuf_raddr                   <= '0;
            cbuf_tail                    <= '0; 
            o_unsupported_eth_type_error <= 0;
        end else begin
            
            /* defaults */
            arp_pkt_fifo_wren            <= 0;
            ipv4_pkt_fifo_wren           <= 0;
            o_unsupported_eth_type_error <= 0;
            
            case (cbuf_rd_fsm_state)
                
                WAIT_FOR_NEW_FRAME: begin
                    
                    if (cbuf_tail != cbuf_head) begin // cbuf head has moved so there's a new ethernet frame
                        cbuf_raddr        <= cbuf_tail;
                        cbuf_tail         <= cbuf_tail + 1; // ok to move tail along since only valid packets (i.e. those without errors, not necessarily supported packets) should make it into the circular buffer
                        cbuf_rd_fsm_state <= READ_ETHTYPE_0;
                    end
                end
                
                READ_ETHTYPE_0: begin
                    ethtype[15:8]     <= cbuf_dout[7:0];
                    cbuf_raddr        <= cbuf_tail;
                    cbuf_tail         <= cbuf_tail + 1; 
                    cbuf_rd_fsm_state <= READ_ETHTYPE_1;
                end
                
                /*
                 * NOTE: Keep reading the next byte since there's no way we're at the end of the packet yet so it doesn't matter if this is a
                 *       supported or unsupported EtherType.
                 */
                READ_ETHTYPE_1: begin
                    ethtype[7:0]      <= cbuf_dout[7:0];
//                    cbuf_raddr        <= cbuf_tail;
//                    cbuf_tail         <= cbuf_tail + 1; 
                    cbuf_rd_fsm_state <= CHECK_ETHERTYPE;
                end
                
                CHECK_ETHERTYPE: begin
                    
                    case (ethtype)
                        
                        ETH_TYPE_ARP: begin
                            
                            if (~arp_pkt_fifo_afull) begin // room for at least one more full size ARP packet
                                cbuf_raddr        <= cbuf_tail;
                                cbuf_tail         <= cbuf_tail + 1; 
                                cbuf_rd_fsm_state <= ROUTE_ARP_PKT;
                            end else begin
                                cbuf_rd_fsm_state <= WAIT_FOR_ARP_PKT_FIFO_SPACE;
                            end
                        end
                        
                        ETH_TYPE_IPV4: begin
                            if (~ipv4_pkt_fifo_afull) begin // room for at least one more full size IPv4 packet
                                cbuf_raddr        <= cbuf_tail;
                                cbuf_tail         <= cbuf_tail + 1; 
                                cbuf_rd_fsm_state <= ROUTE_IPV4_PKT;
                            end else begin
                                cbuf_rd_fsm_state <= WAIT_FOR_IPV4_PKT_FIFO_SPACE;
                            end
                        end
                        
                        default: begin
                            // Flag unsupported packet and skip over it. Since Ethernet frames are required to be 64-bytes minimum and
                            o_unsupported_eth_type_error <= 1;
                            cbuf_raddr                   <= cbuf_tail;
                            cbuf_tail                    <= cbuf_tail + 1; 
                            cbuf_rd_fsm_state            <= SKIP_PKT;
                        end
                    endcase
                    
                end
                
                WAIT_FOR_ARP_PKT_FIFO_SPACE: begin
                    
                    if (~arp_pkt_fifo_afull) begin
                        cbuf_raddr        <= cbuf_tail;
                        cbuf_tail         <= cbuf_tail + 1; 
                        cbuf_rd_fsm_state <= ROUTE_ARP_PKT;
                    end
                end 
                 
                ROUTE_ARP_PKT: begin
                    
                    // note: all packet bytes are present in the cbuf so we can just keep on reading from the cbuf and writing into the output fifo until we reach the end of the packet
                    arp_pkt_fifo_wren <= 1;
                    arp_pkt_fifo_din  <= cbuf_dout;
                    
                    if (cbuf_dout[8] != 1) begin // not the end-of-frame
                        cbuf_raddr <= cbuf_tail;
                        cbuf_tail  <= cbuf_tail + 1; 
                    end else begin
                        cbuf_rd_fsm_state <= WAIT_FOR_NEW_FRAME;
                    end
                end

                WAIT_FOR_IPV4_PKT_FIFO_SPACE: begin
                    
                    if (~ipv4_pkt_fifo_afull) begin
                        cbuf_raddr        <= cbuf_tail;
                        cbuf_tail         <= cbuf_tail + 1; 
                        cbuf_rd_fsm_state <= ROUTE_IPV4_PKT;
                    end
                end
                
                ROUTE_IPV4_PKT: begin

                    // note: all packet bytes are present in the cbuf so we can just keep on reading from the cbuf and writing into the output fifo until we reach the end of the packet
                    ipv4_pkt_fifo_wren <= 1;
                    ipv4_pkt_fifo_din  <= cbuf_dout;
                    
                    if (cbuf_dout[8] != 1) begin // not the end-of-frame
                        cbuf_raddr      <= cbuf_tail;
                        cbuf_tail       <= cbuf_tail + 1; 
                    end else begin
                        cbuf_rd_fsm_state <= WAIT_FOR_NEW_FRAME;
                    end
                end

                SKIP_PKT: begin // just read remaining bytes of unsupported packet from cbuf
                    if (cbuf_dout[8] != 1) begin
                        cbuf_raddr      <= cbuf_tail;
                        cbuf_tail       <= cbuf_tail + 1; 
                    end else begin
                        cbuf_rd_fsm_state <= WAIT_FOR_NEW_FRAME;
                    end
                end
            endcase
        end
    end
    
    

    /* ARP PACKET FIFO AND SUPPORINTG LOGIC */
    
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (ARP_PKT_BUFFER_BYTES_POW2), 
        .DEPTH_AFULL     (ARP_PKT_BUFFER_BYTES-ETH_FRAME_MIN_BYTES), 
        .WIDTH           (9), 
        .FAMILY          ("ECP5U"), 
        .IMPLEMENTATION  ("LUT"), // yes LUT is on purpose.  keep this FIFO small (shouldn't be a problem since ARP packets are small and we shouldn't be getting a lot of them ever)
        .SIM_MODE        (SIM_MODE)
        ) ARP_PKT_FIFO (
        .clk             (i_rxmac_clk), 
        .rst             (i_rxmac_srst), 
        .wren            (arp_pkt_fifo_wren), 
        .wdata           (arp_pkt_fifo_din), 
        .full            (arp_pkt_fifo_full), 
        .afull           (arp_pkt_fifo_afull),
        .rden            (i_arp_pkt_byte_rd), 
        .rdata           ({o_arp_pkt_last_byte, o_arp_pkt_byte}), 
        .rdata_vld       (o_arp_pkt_byte_vld));

    // monitor for arp fifo overflow and pulse the error flag it if it occurs
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_arp_pkt_fifo_overflow <= 0;
        end else begin
            if (arp_pkt_fifo_wren & arp_pkt_fifo_full) begin
                o_arp_pkt_fifo_overflow <= 1;
            end
        end
    end
    

    /* IPV4 PACKET FIFO AND SUPPORTING LOGIC */
    
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (IPV4_PKT_BUFFER_BYTES_POW2), 
        .DEPTH_AFULL     (IPV4_PKT_BUFFER_BYTES_MAX-MTU_BYTES), 
        .WIDTH           (9), 
        .FAMILY          ("ECP5U"), 
        .IMPLEMENTATION  ("EBR"),
        .SIM_MODE        (SIM_MODE)
        ) IPV4_PKT_FIFO (
        .clk             (i_rxmac_clk), 
        .rst             (i_rxmac_srst), 
        .wren            (ipv4_pkt_fifo_wren), 
        .wdata           (ipv4_pkt_fifo_din), 
        .full            (ipv4_pkt_fifo_full), 
        .afull           (ipv4_pkt_fifo_afull), 
        .rden            (i_ipv4_pkt_byte_rd), 
        .rdata           ({o_ipv4_pkt_last_byte, o_ipv4_pkt_byte}), 
        .rdata_vld       (o_ipv4_pkt_byte_vld));
    
    // monitor for ipv4 fifo overflow and pulse the error flag it if it occurs
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_ipv4_pkt_fifo_overflow <= 0;
        end else begin
            if (ipv4_pkt_fifo_wren & ipv4_pkt_fifo_full) begin
                o_ipv4_pkt_fifo_overflow <= 1;
            end
        end
    end

// assign arp_pkt_fifo_full = 0;
// assign arp_pkt_fifo_afull = 0;
// assign ipv4_pkt_fifo_full = 0;
// assign ipv4_pkt_fifo_afull = 0;

endmodule