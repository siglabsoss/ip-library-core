/*
 * Module: udp_packetizer
 * 
 * This module creates Ethernet II Frames with UDP payloads.  It can either feed the Lattice Gbit MAC Tx interface directly (if it's the only Tx source) or feed the
 * mac_tx_arbiter module.
 * 
 * This module creates complete Ethernet II Frames before signaling to the downstream logic that it is ready.  This is necessary when feeding the Lattice Gbit MAC directly
 * and beneficial when feeding the mac_tx_arbiter since if the source providing the UDP data is slow this would result in an unacceptably long grant time given to this module
 * by the mac_tx_arbiter, which in turn could back up other sources waiting to send Ethernet frames out of the Gbit MAC.
 * 
 * NOTES:
 *     * Feed this module with a first-word-fall-through style FIFO or equivalent logic.  It expects that the simultaneous assertion of i_data_byte_vld and o_data_byte_rd means that i_data_byte has been consumed.
 *     * If a UDP sequence number is present it will appear as the first X number of bytes in the UDP payload (X = SEQ_NUM_BYTES parameter).
 *     * If UDP meta data is present it will appear as the next Y bytes after the UDP sequence number (if present) in the UDP payload or as the first Y bytes (if no sequence number present) in the UDP payload (Y = META_DATA_BYTES parameter).
 * 
 * WARNINGS:
 *     * It is the responsibility of the source providing the UDP payload data to NOT provide more bytes than allowed by MTU size being operated under (MTU size is specified in ethernet_suppor_pkg.sv).
 *  
 */
 
`include "ethernet_support_pkg.sv"

`default_nettype none
 
module udp_packetizer #(

    parameter int unsigned NUM_ETH_FRAME_BUFFERS   = 4, // Specifies the number of full size Ethernet II Frames that can be buffered by this block at any one time (more smaller frames can be buffered than this number)
    parameter int unsigned SEQ_NUM_BYTES           = 4, // Specifies the number of bytes used for UDP sequence numbers
    parameter bit          SEQ_NUM_LITTLE_ENDIAN   = 1, // Set to 1 to send the lowest numbered bits out first, 0 to send the highest numbered out first
    parameter int unsigned META_DATA_BYTES         = 4, // Specifies the number of bytes used for UDP meta data
    parameter bit          META_DATA_LITTLE_ENDIAN = 1, // Set to 1 to send the lowest numbered bits out first, 0 to send the highest numbered out first
    parameter bit          GBIT_MAC_DIRECT_MODE    = 0, // Set to: 0 when this module is connected to the mac_tx_arbiter, 1 when connected directly to the LATTICE GBIT MAC Tx interface 
    parameter bit          SIM_MODE                = 0  // set to one if simulating since Lattice's pmi_fifo_dc behavioral model incorrectly errors out complaining that "sync" resetmode isn't supported for ECP5

)(

    input             i_txmac_clk,
    input             i_txmac_srst,
        
    /* USER DATA */
    input             i_start,           // indicates that the user has data bytes ready to be packetized into a UDP packet.
    output reg        o_start_ack,       // acknowledges i_start.  this could be tied to the read enable of the FIFO feeding the Ethernet and UDP Meta data ports below for instance
    output reg        o_done,            // indicates that the packetizer has completed creating the current packet
    input             i_data_byte_vld,   // indicates that the user is supplying a valid byte of UDP payload data (data is considered consumed when i_data_byte_vld = 1 and o_data_byte_rd = 1)
    input      [ 7:0] i_data_byte,
    output reg        o_data_byte_rd,    // tie this to the read enable of your FIFO for instance. 
    
    /* ETHERNET FRAME, IPv4, AND UDP PACKET HEADER DATA (VALIDATED BY i_start) */
    input      [47:0] i_dest_mac,
    input      [31:0] i_dest_ip,
    input      [15:0] i_dest_port, 
    input      [47:0] i_src_mac,
    input      [31:0] i_src_ip,
    input      [15:0] i_src_port,  
    input      [15:0] i_udp_payload_bytes,  // Number of data bytes for this udp packet (USER MUST INCLUDE THE BYTES OF SEQUENCE NUMBER AND METADATA IF PRESENT)

    /* UDP SEQUENCE NUMBER AND META DATA */
    input                                i_seq_num_prsnt,   // If asserted then the value present on i_seq_num is put as the first of the UDP payload.  If not asserted the i_seq_num is ignored.
    input      [(8*SEQ_NUM_BYTES)-1:0]   i_seq_num,
    input                                i_meta_data_prsnt, // If asserted then the value present on i_meta_data is put as the first bytes of the UDP payload (following the sequence number if it's present).  If not asserted then i_meta_data is ignored.
    input      [(8*META_DATA_BYTES)-1:0] i_meta_data, 

    /* ETHERNET FRAME WITH UDP PACKET PAYLOAD */
    output            o_eth_avail,       // indicates a full Ethernett II Frame with UDP payload is available for downstream consumption from the output FIFO (CONNECT THIS TO tx_fifoavail and tx_fifoempty OF LATTICE GBIT MAC IN DIRECT CONNECT MODE)
    output            o_eth_eof,         // end of current Ethernet II Frame
    output            o_eth_byte_vld,    // NOT USED IN LATTICE GBIT MAC DIRECT CONNECT MODE
    output     [ 7:0] o_eth_byte, 
    input             i_eth_byte_rd,

    /* ETHERNET FIFO OVERFLOW FLAGS */
    output            o_fifo_full,
    output            o_fifo_afull

);
    
    /* PARAMETER RANGE CHECKING */
    initial begin
        assert (NUM_ETH_FRAME_BUFFERS >= 1 && NUM_ETH_FRAME_BUFFERS <= 10) else $fatal(1, "NUM_ETH_FRAME_BUFFERS MUST BE IN THE RANGE [1:10]!"); 
        assert (GBIT_MAC_DIRECT_MODE == 0  || GBIT_MAC_DIRECT_MODE == 1  ) else $fatal(1, "GBIT_MAC_DIRECT_MODE MUST BE 0 OR 1!");
        assert (SEQ_NUM_BYTES >= 1         && SEQ_NUM_BYTES <= 65508     ) else $fatal(1, "SEQ_NUM_BYTES MUST BE IN THE RANGE [1:65508]!"); // 65508 = 65536 - 8 udp header bytes - 20 IPv4 header bytes
        assert (META_DATA_BYTES >= 1       && META_DATA_BYTES <= 65508   ) else $fatal(1, "META_DATA_BYTES MUST BE IN THE RANGE [1:65508]!"); // 65508 = 65536 - 8 udp header bytes - 20 IPv4 header bytes
        assert (SEQ_NUM_BYTES + META_DATA_BYTES <= 65508                 ) else $fatal(1, "SEQ_NUM_BYTES + META_DATA_BYTES MUST BE < 65509!");
    end    
    
    
    localparam FRAME_FIFO_DEPTH      = 2**($clog2(NUM_ETH_FRAME_BUFFERS * ETH_FRAME_MAX_BYTES));
    localparam FRAME_FIFO_AFULL_LVL  = FRAME_FIFO_DEPTH - ETH_FRAME_MAX_BYTES;
    localparam FRAME_AVAIL_CNTR_BITS = $clog2( int'( (1.0 * FRAME_FIFO_DEPTH) / (1.0 * ETH_FRAME_MIN_BYTES) ) ); // int' casting rounds, so 3.5 --> 4 and NOT 3
    
    //synthesis translate_off
    
    initial begin
        $display("Sizes for udp_packetizer");
        $display("FRAME_FIFO_DEPTH      : %0d", FRAME_FIFO_DEPTH);
        $display("FRAME_FIFO_AFULL_LVL  : %0d", FRAME_FIFO_AFULL_LVL);
        $display("FRAME_AVAIL_CNTR_BITS : %0d", FRAME_AVAIL_CNTR_BITS);
        $display("");
    end
    
    //synthesis translate_on
    
    logic       eth_fifo_empty;
    logic       eth_fifo_wren;
    logic       eth_fifo_rden;
    logic       eth_fifo_full;
    logic       eth_fifo_afull;
    logic [8:0] eth_fifo_din;
    logic [8:0] eth_fifo_dout;
    logic [8:0] eth_fifo_dout_reg_0; // for direct connect mode
    logic [8:0] eth_fifo_dout_reg_1; // for direct connect mode
    logic       eth_fifo_dout_vld;
    
    logic [103:0]                     eth_frame_hdr_reg;
    logic [ 31:0]                     src_ip_reg;
    logic [ 31:0]                     dest_ip_reg;
    logic [159:0]                     ipv4_hdr_reg;
    logic [ 15:0]                     ipv4_total_length;
    logic [ 15:0]                     ipv4_total_length_reg;
    logic [ 15:0]                     udp_total_length;
    logic [ 15:0]                     udp_total_length_reg;
    logic [ 63:0]                     udp_hdr_reg;
    logic [  4:0]                     hdr_byte_cntr;        // keeps track of how many bytes we've written of either the Ethernet Frame Header or the IPv4 header (so we don't have a ton of states dedicated to writing each of those bytes)
    logic [ 15:0]                     udp_byte_cntr;        // keeps track of how many udp payload bytes we've written into the frame FIFO.
    logic                             seq_num_prsnt_reg;
    logic [(8*SEQ_NUM_BYTES)-1:0]     seq_num_reg;
    logic                             meta_data_prsnt_reg;
    logic [(8*META_DATA_BYTES)-1:0]   meta_data_reg;
    logic [ 15:0]                     udp_payload_bytes;
    logic [FRAME_AVAIL_CNTR_BITS-1:0] eth_frame_avail_cntr; // keeps tabs on how many complete udp packets are sitting in the packet output FIFO.
    
    
    enum { WAIT_FOR_DATA,
           WRITE_ETH_FRAME_HDR,
           WRITE_IPV4_HDR,
           WRITE_UDP_PKT_HDR,
           WRITE_UDP_SEQ_NUM,
           WRITE_UDP_META_DATA,
           WRITE_UDP_PAYLOAD_DATA
    } udp_pktzr_fsm_state;
    
    enum { IDLE,
           IPV4_HDR_CHECKSUM_COMP_STAGE_0,
           IPV4_HDR_CHECKSUM_COMP_STAGE_1,
           IPV4_HDR_CHECKSUM_COMP_STAGE_2,
           IPV4_HDR_CHECKSUM_COMP_STAGE_3
    } ipv4_hdr_checksum_fsm_state;

    logic [ 31:0]                   ipv4_hdr_checksum_accum_0;
    logic [ 31:0]                   ipv4_hdr_checksum_accum_1;
    logic [ 31:0]                   ipv4_hdr_checksum_accum_2;
    logic [ 31:0]                   ipv4_hdr_checksum_accum_3;
    logic [ 31:0]                   ipv4_hdr_checksum_accum_4;
    logic [ 31:0]                   ipv4_hdr_checksum_accum_5;
    logic [ 31:0]                   ipv4_hdr_checksum_accum_6;
    logic [ 15:0]                   ipv4_hdr_checksum_accum_7;
    logic [ 15:0]                   ipv4_hdr_checksum;
    logic                           ipv4_hdr_checksum_comp_start;
           
           
    
    /*
     * 
     * IPv4 HEADER CHECKSUM CALCULATION FSM
     * 
     * THIS NEEDS TO COMPLETE IN TIME TO BE WRITTEN INTO THE OUTPUT UDP PACKET FIFO (i.e. it should be ready in 12 or fewer clocks after starting the computation in order to work with the design the way it currently is structured) 
     * THIS REQUIREMENT IS CURRENTLY GARUANTEED BY DESIGN.
     * 
     * NOTE: THE IDENTIFICATION, FLAGS, AND FRAGMENT OFFSET FIELDS ARE CURRENTLY ALWAYS ZERO SO THEY'RE NOT USED IN THIS CHECKSUM COMPUTATION.
     * 
     */
    
    assign ipv4_total_length = i_udp_payload_bytes + 16'h001c; // add 28 bytes for IPv4 header (20) and UDP header (8) in addition to the number of data bytes in the UDP payload
    assign udp_total_length  = i_udp_payload_bytes + 16'h0008;
    
    always_ff @(posedge i_txmac_clk) begin
        
        if (i_txmac_srst) begin
            ipv4_hdr_checksum_fsm_state <= IDLE;
        end else begin
            
            case (ipv4_hdr_checksum_fsm_state)
                
                IDLE: begin
                    if (ipv4_hdr_checksum_comp_start) begin
                        ipv4_hdr_checksum_accum_0   <= 32'h00004500 + {16'h0000, ipv4_total_length_reg};
                        ipv4_hdr_checksum_accum_1   <= {16'h0000, 8'hff, IPV4_PROTO_UDP}; // header checksum is zero for calculation
                        ipv4_hdr_checksum_accum_2   <= {16'h0000, src_ip_reg[31:16]} + {16'h0000, src_ip_reg[15:0]};
                        ipv4_hdr_checksum_accum_3   <= {16'h0000, dest_ip_reg[31:16]} + {16'h0000, dest_ip_reg[15:0]};
                        ipv4_hdr_checksum_fsm_state <= IPV4_HDR_CHECKSUM_COMP_STAGE_0;
                    end
                end
                
                IPV4_HDR_CHECKSUM_COMP_STAGE_0: begin
                    ipv4_hdr_checksum_accum_4 <= ipv4_hdr_checksum_accum_0 + ipv4_hdr_checksum_accum_1;
                    ipv4_hdr_checksum_accum_5 <= ipv4_hdr_checksum_accum_2 + ipv4_hdr_checksum_accum_3;
                    ipv4_hdr_checksum_fsm_state <= IPV4_HDR_CHECKSUM_COMP_STAGE_1;
                end
                
                IPV4_HDR_CHECKSUM_COMP_STAGE_1: begin
                    ipv4_hdr_checksum_accum_6 <= ipv4_hdr_checksum_accum_4 + ipv4_hdr_checksum_accum_5;
                    ipv4_hdr_checksum_fsm_state <= IPV4_HDR_CHECKSUM_COMP_STAGE_2;
                end
                
                IPV4_HDR_CHECKSUM_COMP_STAGE_2: begin
                    ipv4_hdr_checksum_accum_7 <= ipv4_hdr_checksum_accum_6[31:16] + ipv4_hdr_checksum_accum_6[15:0];
                    ipv4_hdr_checksum_fsm_state <= IPV4_HDR_CHECKSUM_COMP_STAGE_3;
                end
                
                IPV4_HDR_CHECKSUM_COMP_STAGE_3: begin
                    ipv4_hdr_checksum           <= ~ipv4_hdr_checksum_accum_7;
                    ipv4_hdr_checksum_fsm_state <= IDLE;
                end
                        
                
            endcase
            
        end
        
    end
    
    
    /*
     * 
     * UDP PACKETIZER FSM
     * 
     */
    
    always_ff @(posedge i_txmac_clk) begin: UDP_PKTZR_FSM
        
        if (i_txmac_srst) begin
            o_start_ack                  <= 0;
            o_done                       <= 0;
            o_data_byte_rd               <= 0;
            eth_fifo_wren                <= 0;
            ipv4_hdr_checksum_comp_start <= 0;
            udp_pktzr_fsm_state          <= WAIT_FOR_DATA;
        end else begin
            
            /* defaults */
            o_start_ack                  <= 0;
            o_done                       <= 0;
            o_data_byte_rd               <= 0;
            eth_fifo_wren                <= 0;
            ipv4_hdr_checksum_comp_start <= 0;
            
            case (udp_pktzr_fsm_state) 
                
                WAIT_FOR_DATA: begin
                    
                    if (i_start & ~eth_fifo_afull) begin // wait until there's new data to packetize and we have room to store it
                        o_start_ack                  <= 1;
                        eth_frame_hdr_reg            <= {i_dest_mac[39:0], i_src_mac, ETH_TYPE_IPV4};
                        src_ip_reg                   <= i_src_ip;
                        dest_ip_reg                  <= i_dest_ip;
                        ipv4_hdr_reg                 <= {16'h4500, ipv4_total_length, 32'h00000000, 8'hff, IPV4_PROTO_UDP, 16'h0000, i_src_ip, i_dest_ip};
                        ipv4_total_length_reg        <= ipv4_total_length;
                        udp_hdr_reg                  <= {i_src_port, i_dest_port, udp_total_length, 16'h0000}; // no udp checksum at the moment (or likely ever)
                        udp_payload_bytes            <= i_udp_payload_bytes;
                        seq_num_prsnt_reg            <= i_seq_num_prsnt;
                        seq_num_reg                  <= i_seq_num;
                        meta_data_prsnt_reg          <= i_meta_data_prsnt;
                        meta_data_reg                <= i_meta_data;
                        udp_total_length_reg         <= udp_total_length;
                        eth_fifo_wren                <= 1;
                        eth_fifo_din                 <= {1'b0, i_dest_mac[47:40]}; 
                        hdr_byte_cntr                <= 5'd1;
                        ipv4_hdr_checksum_comp_start <= 1;
                        udp_pktzr_fsm_state          <= WRITE_ETH_FRAME_HDR;
                    end
                end
                
                WRITE_ETH_FRAME_HDR: begin

                    eth_fifo_wren     <= 1;
                    eth_fifo_din      <= {1'b0, eth_frame_hdr_reg[103:96]};
                    hdr_byte_cntr     <= hdr_byte_cntr + 1;
                    eth_frame_hdr_reg <= {eth_frame_hdr_reg[95:0], 8'h00};
                    
                    if (hdr_byte_cntr == 5'd13) begin
                        hdr_byte_cntr       <= 5'd1;
                        ipv4_hdr_reg[79:64] <= ipv4_hdr_checksum; // fill in actual ipv4 header checksum which should be ready by now
                        udp_pktzr_fsm_state <= WRITE_IPV4_HDR;
                    end
                end
                
                
                WRITE_IPV4_HDR: begin
                    
                    eth_fifo_wren <= 1;
                    eth_fifo_din  <= {1'b0, ipv4_hdr_reg[159:152]};
                    hdr_byte_cntr <= hdr_byte_cntr + 1;
                    ipv4_hdr_reg  <= {ipv4_hdr_reg[151:0], 8'h00};
                    
                    if (hdr_byte_cntr == 5'd20) begin
                        hdr_byte_cntr       <= 5'd1;
                        udp_pktzr_fsm_state <= WRITE_UDP_PKT_HDR;
                    end
                    
                end

                
                WRITE_UDP_PKT_HDR: begin
                    
                    eth_fifo_wren <= 1;
                    eth_fifo_din  <= {1'b0, udp_hdr_reg[63:56]};
                    hdr_byte_cntr <= hdr_byte_cntr + 1;
                    udp_hdr_reg   <= {udp_hdr_reg[55:0], 8'h00};

                    if (hdr_byte_cntr == 5'd8) begin
                        udp_byte_cntr  <= 16'd1;
                        if (seq_num_prsnt_reg) begin
                            udp_pktzr_fsm_state <= WRITE_UDP_SEQ_NUM;
                        end else if (meta_data_prsnt_reg) begin
                            udp_pktzr_fsm_state <= WRITE_UDP_META_DATA;
                        end else begin
                            o_data_byte_rd      <= 1;
                            udp_pktzr_fsm_state <= WRITE_UDP_PAYLOAD_DATA;
                        end
                    end
                end

                
                WRITE_UDP_SEQ_NUM: begin
                
                    /* defaults */
                    eth_fifo_wren     <= 1;
                    eth_fifo_din[8]   <= 0;
                    eth_fifo_din[7:0] <= (SEQ_NUM_LITTLE_ENDIAN) ? seq_num_reg[7:0] : seq_num_reg[$bits(seq_num_reg)-1:($bits(seq_num_reg)-8)];
                    seq_num_reg       <= (SEQ_NUM_LITTLE_ENDIAN) ? seq_num_reg >> 8 : seq_num_reg << 8;
                    udp_byte_cntr     <= udp_byte_cntr + 1;
                    
                    if (udp_byte_cntr == SEQ_NUM_BYTES) begin
                        if (udp_byte_cntr == udp_payload_bytes) begin // for some reason they only wanted to send the sequence number
                            o_done              <= 1;
                            eth_fifo_din[8]     <= 1; // override default behavior
                            udp_pktzr_fsm_state <= WAIT_FOR_DATA;
                        end else if (meta_data_prsnt_reg) begin
                            udp_pktzr_fsm_state <= WRITE_UDP_META_DATA;
                        end else begin 
                            o_data_byte_rd      <= 1;
                            udp_pktzr_fsm_state <= WRITE_UDP_PAYLOAD_DATA;
                        end
                    end
                end
                
                
                WRITE_UDP_META_DATA: begin

                    /* defaults */
                    eth_fifo_wren     <= 1;
                    eth_fifo_din[8]   <= 0;
                    eth_fifo_din[7:0] <= (META_DATA_LITTLE_ENDIAN) ? meta_data_reg[7:0] : meta_data_reg[$bits(meta_data_reg)-1:($bits(meta_data_reg)-8)];
                    meta_data_reg     <= (META_DATA_LITTLE_ENDIAN) ? meta_data_reg >> 8 : meta_data_reg << 8;
                    udp_byte_cntr     <= udp_byte_cntr + 1;

                    if ( ( (seq_num_prsnt_reg == 0) && (udp_byte_cntr == META_DATA_BYTES) ) || ( (seq_num_prsnt_reg == 1) && (udp_byte_cntr == (SEQ_NUM_BYTES + META_DATA_BYTES) ) ) ) begin
                        if (udp_byte_cntr == udp_payload_bytes) begin // for some reason they only wanted to send the sequence number and meta data
                            o_done              <= 1;
                            eth_fifo_din[8]     <= 1; // override default behavior
                            udp_pktzr_fsm_state <= WAIT_FOR_DATA;
                        end else begin 
                            o_data_byte_rd      <= 1;
                            udp_pktzr_fsm_state <= WRITE_UDP_PAYLOAD_DATA;
                        end
                    end
                end

                    
                WRITE_UDP_PAYLOAD_DATA: begin
                    
                    o_data_byte_rd <= 1;
                    
                    if (i_data_byte_vld & o_data_byte_rd) begin
                        eth_fifo_wren     <= 1;
                        eth_fifo_din[8]   <= (udp_byte_cntr == udp_payload_bytes) ? 1'b1 : 1'b0;
                        eth_fifo_din[7:0] <= i_data_byte;
                        udp_byte_cntr     <= udp_byte_cntr + 1;
                        
                        if (udp_byte_cntr == udp_payload_bytes) begin
                            o_done              <= 1;
                            o_data_byte_rd      <= 0;
                            udp_pktzr_fsm_state <= WAIT_FOR_DATA;
                        end
                    end
                end
                
            endcase
            
        end
    end
    
    assign o_fifo_full  = eth_fifo_full;
    assign o_fifo_afull = eth_fifo_afull;
    
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (FRAME_FIFO_DEPTH    ), 
        .DEPTH_AFULL     (FRAME_FIFO_AFULL_LVL), 
        .WIDTH           (9                   ), 
        .FAMILY          ("ECP5U"             ), 
        .IMPLEMENTATION  ("EBR"               ),
        .SIM_MODE        (SIM_MODE            )
        ) eth_frame_fifo (
        .clk             (i_txmac_clk         ), 
        .rst             (i_txmac_srst        ), 
        .wren            (eth_fifo_wren       ), 
        .wdata           (eth_fifo_din        ), 
        .full            (eth_fifo_full       ), 
        .afull           (eth_fifo_afull      ), 
        .rden            (eth_fifo_rden       ), 
        .rdata           (eth_fifo_dout       ), 
        .rdata_vld       (eth_fifo_dout_vld   ));
    
    assign eth_fifo_empty = ~eth_fifo_dout_vld;
    assign eth_fifo_rden  = i_eth_byte_rd; 

    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            eth_fifo_dout_reg_0 <= '0;
            eth_fifo_dout_reg_1 <= '0;
        end else begin
            eth_fifo_dout_reg_0 <= eth_fifo_dout;
            eth_fifo_dout_reg_1 <= eth_fifo_dout_reg_0;
        end
    end
    
    // need to delay data and eof by 1 clock if directly connected to Lattice Gbit MAC (see Lattice IPUG51 Transmission Waveforms)
    generate
        if (GBIT_MAC_DIRECT_MODE) begin
            assign o_eth_eof  = eth_fifo_dout_reg_0[8] & ~eth_fifo_dout_reg_1[8]; // one clock wide pulse
            assign o_eth_byte = eth_fifo_dout_reg_0[7:0];
        end else begin
            assign o_eth_eof  = eth_fifo_dout[8] & ~eth_fifo_dout_reg_0[8];  // one clock wide pulse
            assign o_eth_byte = eth_fifo_dout[7:0];
        end 
    endgenerate
                
    assign o_eth_byte_vld  = eth_fifo_dout_vld; // NOT USED BY LATTICE GBIT MAC SO NO NEED TO ANYTHING SPECIAL IF GBIT_MAC_DIRECT_MODE = 1
    assign o_eth_avail     = |eth_frame_avail_cntr & ~eth_fifo_empty; 
    

    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            eth_frame_avail_cntr <= '0;
        end else begin

            // NOTE: THE ORDER OF THESE IF STATEMENTS IS CRITICAL

            if (eth_fifo_din[8] & eth_fifo_wren) begin // end of packet marker written into output fifo so there's now another full udp packet ready to be consumed
                eth_frame_avail_cntr <= eth_frame_avail_cntr + 1;
            end
            
            if (eth_fifo_dout[8] & eth_fifo_dout_vld & eth_fifo_rden) begin // end of packet mark read out of output fifo so there's now one fewer udp packets ready to be consumed
                eth_frame_avail_cntr <= eth_frame_avail_cntr - 1;
            end
            
            if (eth_fifo_din[8] & eth_fifo_wren & eth_fifo_dout[8] & eth_fifo_dout_vld & eth_fifo_rden) begin // simultaneous packet read out of fifo and new one written into fifo
                eth_frame_avail_cntr <= eth_frame_avail_cntr;
            end
        end
    end
    

endmodule

`default_nettype wire 