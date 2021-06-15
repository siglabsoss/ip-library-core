/*
 * Module: udp_pkt_router
 * 
 * Consumes UDP Packets that have been queued by the ipv4_pkt_router module and routes them to various queues depending on their destination port queues.
 * If a UDP packet comes in with a destination port that's not specified in the P_PORTS parameter then it is dicarded and an error flag is pulsed high
 * for one clock cycle.
 * 
 * This module only offers buffering of one max size UDP payload.  Additional buffering is done in the eth_frame_router module.
 * 
 * NOTE: THE UDP HEADER IS REMOVED IN THE CURRENT IMPLEMENTATION.
 * 
 * 
 */
 
/* verilator lint_off LITENDIAN */
 
`include "ethernet_support_pkg.sv"

module udp_pkt_router #(
        
    parameter int unsigned                 P_NUM_PORTS = 2,
    parameter bit [0:P_NUM_PORTS-1] [15:0] P_PORTS     = {16'd50000, 16'd60000}, // i.e. port 50,000 would correspond to router output interface 0
    parameter bit                          SIM_MODE    = 0                       // Needed because of issue with Lattice pmi_fifo_dc macro not correctly supporting "sync" resetmode in simulation
        
)
(
    input                              i_rxmac_clk,
    input                              i_rxmac_srst, // synchronous to i_rxmac_clk

    /* ROUTER OUTPUT INTERFACES */    
    output     [0:P_NUM_PORTS-1]       o_port_last_byte, 
    output reg [0:P_NUM_PORTS-1]       o_port_byte_vld,
    output     [0:P_NUM_PORTS-1] [7:0] o_port_byte, 
    input      [0:P_NUM_PORTS-1]       i_port_byte_rd,
    
    /* IPV4 PACKET ROUTER UDP OUTPUT INTERFACE */
    
    input                        [7:0] i_udp_pkt_byte,
    input                              i_udp_pkt_byte_vld,
    input                              i_udp_pkt_last_byte,
    output                             o_udp_pkt_byte_rd,

    /* ERROR REPORTING */
    // IF ANY OF THESE ERRORS OCCUR YOU'LL NEED TO RESET THIS MODULE TO RECOVER AND CLEAR THE ERROR
    output reg [0:P_NUM_PORTS-1]       o_port_fifo_overflow,
    // THESE ERROR STATUS SIGNALS GET ASSERTED FOR ONE CLOCK IF THEIR RESPECTIVE ERROR OCCURS.  YOU NEED EXTERNAL LOGIC TO KEEP TRACK OF THESE ERRORS IF DESIRED.
    output reg                         o_unsupported_dest_port
);
    
    localparam PORT_FIFO_BYTES_POW2 = 2**$clog2(UDP_PAYLOAD_MAX_BYTES); // FIFOs are all sized to store up to one max size UDP payload.
    localparam PORT_FIFO_INDEX_BITS = $clog2(P_NUM_PORTS);
    
    logic [0:P_NUM_PORTS-1] [8:0] port_fifo_din;
    logic [0:P_NUM_PORTS-1] [8:0] port_fifo_dout;
    logic [0:P_NUM_PORTS-1]       port_fifo_wren;
    logic [0:P_NUM_PORTS-1]       port_fifo_afull;
    logic [0:P_NUM_PORTS-1]       port_fifo_full;
    
    logic                         fatal_error;
    
    enum {
        WAIT_FOR_NEXT_PKT,
        SKIP_SRC_PORT_MSB,
        SKIP_SRC_PORT_LSB,
        STORE_DEST_PORT_MSB,
        STORE_DEST_PORT_LSB,
        STORE_LENGTH_MSB,
        STORE_LENGTH_LSB,
        SKIP_CHECKSUM_MSB,
        SKIP_CHECKSUM_LSB,
        SKIP_PAYLOAD_OR_PAD_BYTES,
        WAIT_FOR_PORT_FIFO_AFULL_LOW,
        ROUTE_PAYLOAD
    } udp_pkt_router_fsm_state;
    
    logic [15:0]                     dest_port;
    logic                            dest_port_vld;
    logic [15:0]                     pkt_length;
    logic [15:0]                     rx_byte_cntr;
    logic [PORT_FIFO_INDEX_BITS-1:0] port_fifo_index; 
    logic                            udp_pkt_byte_rd; 
    
    
    assign fatal_error = |o_port_fifo_overflow; // if any of the port FIFOs overflows we'll halt operation until a reset occurs.
    
    
    /*
     * sets the port fifo index based on the destination port of the current udp packet
     */
    
    always_ff @(posedge i_rxmac_clk) begin
        
        if (i_rxmac_srst) begin
            dest_port_vld   <= 0;
            port_fifo_index <= '0;
        end else begin
            
            /* defaults */
            dest_port_vld <= 0;
            
            for(int unsigned i=0; i<P_NUM_PORTS; i++) begin
                if (dest_port == P_PORTS[i]) begin
                    port_fifo_index <= PORT_FIFO_INDEX_BITS'(i);
                    dest_port_vld   <= 1;
                end
            end
        end
    end
    
    
//    assign o_udp_pkt_byte_rd = udp_pkt_byte_rd & ~(i_udp_pkt_last_byte & i_udp_pkt_byte_vld); // avoid issuing a read request at the last valid byte of the current packet
    assign o_udp_pkt_byte_rd = udp_pkt_byte_rd;

    always_ff @(posedge i_rxmac_clk) begin: UDP_PKT_ROUTER_FSM
        
        if (i_rxmac_srst | fatal_error) begin // if a fatal error occurs we'll need to be reset externally to continue
            port_fifo_wren           <= '0; 
            udp_pkt_byte_rd          <= 0;
            o_unsupported_dest_port  <= 0;
            udp_pkt_router_fsm_state <= WAIT_FOR_NEXT_PKT;
        end else begin
            
            /* defaults */
            udp_pkt_byte_rd         <= 0;
            o_unsupported_dest_port <= 0;
            port_fifo_wren          <= '0;
            
            case (udp_pkt_router_fsm_state)

                
                WAIT_FOR_NEXT_PKT: begin
                    if (i_udp_pkt_byte_vld) begin
                       udp_pkt_byte_rd          <= 1; 
                       rx_byte_cntr             <= 'd1;
                       udp_pkt_router_fsm_state <= SKIP_SRC_PORT_MSB;
                    end
                end

                
                SKIP_SRC_PORT_MSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= SKIP_SRC_PORT_LSB;
                    end
                end


                SKIP_SRC_PORT_LSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= STORE_DEST_PORT_MSB;
                    end
                end

                
                STORE_DEST_PORT_MSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        dest_port[15:8]          <= i_udp_pkt_byte;
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= STORE_DEST_PORT_LSB;
                    end
                end


                STORE_DEST_PORT_LSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        dest_port[7:0]           <= i_udp_pkt_byte;
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= STORE_LENGTH_MSB;
                    end
                end


                STORE_LENGTH_MSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        pkt_length[15:8]         <= i_udp_pkt_byte;
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= STORE_LENGTH_LSB;
                    end
                end


                STORE_LENGTH_LSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        pkt_length[7:0]          <= i_udp_pkt_byte;
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= SKIP_CHECKSUM_MSB;
                    end
                end


                SKIP_CHECKSUM_MSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin
                        rx_byte_cntr             <= rx_byte_cntr + 1;
                        udp_pkt_router_fsm_state <= SKIP_CHECKSUM_LSB;
                    end
                end


                SKIP_CHECKSUM_LSB: begin
                    udp_pkt_byte_rd <= 1;
                    if (i_udp_pkt_byte_vld) begin

                        rx_byte_cntr <= rx_byte_cntr + 1;
                        
                        if (rx_byte_cntr == pkt_length) begin // for some reason someone sent us a UDP datagram that was just the header
                            if (i_udp_pkt_last_byte) begin
                                udp_pkt_byte_rd          <= 0;
                                udp_pkt_router_fsm_state <= WAIT_FOR_NEXT_PKT;
                            end else begin
                                udp_pkt_router_fsm_state <= SKIP_PAYLOAD_OR_PAD_BYTES;
                            end
                        end else if (~dest_port_vld) begin // UDP datagram for a port we don't support
                            o_unsupported_dest_port  <= 1;
                            udp_pkt_router_fsm_state <= SKIP_PAYLOAD_OR_PAD_BYTES;
                        end else begin
                            if (port_fifo_afull[port_fifo_index] == 0) begin
                                udp_pkt_router_fsm_state <= ROUTE_PAYLOAD;
                            end else begin
                                udp_pkt_byte_rd          <= 0;
                                udp_pkt_router_fsm_state <= WAIT_FOR_PORT_FIFO_AFULL_LOW;
                            end
                        end
                    end
                end
                
                // skips payloads of udp packets destined for a port we don't support or udp packets that have pad bytes
                SKIP_PAYLOAD_OR_PAD_BYTES: begin 
                    udp_pkt_byte_rd <= 1;
                    
                    if (udp_pkt_byte_rd & i_udp_pkt_byte_vld & i_udp_pkt_last_byte) begin
                        udp_pkt_byte_rd          <= 0;
                        udp_pkt_router_fsm_state <= WAIT_FOR_NEXT_PKT;
                    end
                end

                
                WAIT_FOR_PORT_FIFO_AFULL_LOW: begin
                    if (port_fifo_afull[port_fifo_index] == 0) begin
                        udp_pkt_byte_rd          <= 1;
                        udp_pkt_router_fsm_state <= ROUTE_PAYLOAD;
                    end
                end

                
                ROUTE_PAYLOAD: begin
                    
                    udp_pkt_byte_rd <= 1;
                        
                    if (udp_pkt_byte_rd & i_udp_pkt_byte_vld) begin
                        
                        /* defaults */
                        port_fifo_wren[port_fifo_index] <= 1;
                        port_fifo_din[port_fifo_index]  <= {i_udp_pkt_last_byte, i_udp_pkt_byte};
                        rx_byte_cntr                    <= rx_byte_cntr + 1;
                        
                        if (rx_byte_cntr == pkt_length) begin
                            if (i_udp_pkt_last_byte) begin // i.e. no pad bytes
                                udp_pkt_byte_rd          <= 0;
                                udp_pkt_router_fsm_state <= WAIT_FOR_NEXT_PKT;
                            end else begin
                                port_fifo_din[port_fifo_index] <= {1'b1, i_udp_pkt_byte}; // need to force last byte flag since it's not being presented by the upstream module yet due to pad bytes
                                udp_pkt_router_fsm_state       <= SKIP_PAYLOAD_OR_PAD_BYTES;
                            end
                        end else if (i_udp_pkt_last_byte) begin // case where we received fewer bytes than we were told we'd receive
                            udp_pkt_byte_rd          <= 0;
                            udp_pkt_router_fsm_state <= WAIT_FOR_NEXT_PKT;
                        end
                    end
                end
                
            endcase;
        end
    end
            
    
    generate
        genvar i;
        for (i=0; i<P_NUM_PORTS; i++) begin : PORT_FIFOS
            
            pmi_fifo_sc_fwft_v1_0 #(
                .DEPTH           (PORT_FIFO_BYTES_POW2), 
                .DEPTH_AFULL     (PORT_FIFO_BYTES_POW2-UDP_PAYLOAD_MAX_BYTES), 
                .WIDTH           (9), 
                .FAMILY          ("ECP5U"), 
                .IMPLEMENTATION  ("EBR"),
                .RESET_MODE      ("sync"),   
                .SIM_MODE        (SIM_MODE) 
                ) pmi_fifo_sc_fwft_v1_0 (
                .clk             (i_rxmac_clk), 
                .rst             (i_rxmac_srst), 
                .wren            (port_fifo_wren[i]), 
                .wdata           (port_fifo_din[i]), 
                .full            (port_fifo_full[i]), 
                .afull           (port_fifo_afull[i]), 
                .rden            (i_port_byte_rd[i]), 
                .rdata           ({o_port_last_byte[i], o_port_byte[i]}), 
                .rdata_vld       (o_port_byte_vld[i]));
            
            // monitor for port fifo overflow and pulse the error flag it if it occurs
            always_ff @(posedge i_rxmac_clk) begin
                if (i_rxmac_srst) begin
                    o_port_fifo_overflow[i] <= 0;
                end else begin
                    if (port_fifo_wren[i] & port_fifo_full[i]) begin
                        o_port_fifo_overflow[i] <= 1;
                    end
                end
            end
        end
    endgenerate

endmodule


/* verilator lint_on LITENDIAN */