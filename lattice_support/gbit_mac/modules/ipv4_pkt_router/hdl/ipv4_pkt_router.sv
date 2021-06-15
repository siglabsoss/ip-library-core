/*
 * Module: ipv4_pkt_router
 * 
 * Routes IPv4 packets based on the protocol field to the corresponding output port for downstream consumption.
 * 
 * WARNING: THE IPV4 HEADER IS REMOVED IN THE CURRENT IMPLEMENTATION.
 * 
 * This module is intended to consume IPv4 packets from the eth_frame_router module.
 * 
 * This module only offers buffering of one max size IPv4 packet payload.  Additional buffering is done in the eth_frame_router module.
 * 
 * Supported IPv4 Protocols are: UDP (0x11) and ICMP (0x01) 
 * Any other Protocol is dropped on the floor and an error flag is pulsed.
 * 
 * MODULE ASSUMPTIONS:
 * 
 * * Complete IPv4 packets are fed into this module and the total IPv4 packet size is no more that the MTU size.
 * * IPv4 packet bytes are fed into this module from a first-word-fall-through FIFO or logic with the same such behavior.
 * 
 */
 
`include "ethernet_support_pkg.sv"
 
module ipv4_pkt_router (

    input        i_rxmac_clk,
    input        i_rxmac_srst, // synchronous to i_rxmac_clk

    /* ETH_FRAME_ROUTER IPv4 PACKET INTERFACE */ 
    input [7:0] i_ipv4_pkt_byte,
    input       i_ipv4_pkt_byte_vld,
    input       i_ipv4_pkt_last_byte,
    output      o_ipv4_pkt_byte_rd,

    /* UDP OUTPUT PACKET INTERFACE */
    output [7:0] o_udp_pkt_byte,
    output       o_udp_pkt_byte_vld,
    output       o_udp_pkt_last_byte,
    input        i_udp_pkt_byte_rd,
    
    /* ICMP OUTPUT PACKET INTERFACE */
    output [7:0] o_icmp_pkt_byte,
    output       o_icmp_pkt_byte_vld,
    output       o_icmp_pkt_last_byte,
    input        i_icmp_pkt_byte_rd,

    /* ERROR REPORTING */
    // IF ANY OF THESE ERRORS OCCUR YOU'LL NEED TO RESET THIS MODULE TO RECOVER AND CLEAR THE ERROR
    output reg   o_udp_pkt_fifo_overflow,
    output reg   o_icmp_pkt_fifo_overflow,
    // THESE ERROR STATUS SIGNALS GET ASSERTED FOR ONE CLOCK IF THEIR RESPECTIVE ERROR OCCURS.  YOU NEED EXTERNAL LOGIC TO KEEP TRACK OF THESE ERRORS IF DESIRED.
    output reg   o_unsupported_ipv4_protocol 
);
    
    localparam PKT_FIFO_BYTES_POW2 = 2**$clog2(IPV4_PAYLOAD_MAX_BYTES);
    
    logic [8:0] udp_pkt_fifo_din;
    logic [8:0] udp_pkt_fifo_dout;
    logic       udp_pkt_fifo_wren;
    logic       udp_pkt_fifo_full;
    logic       udp_pkt_fifo_afull;

    logic [8:0] icmp_pkt_fifo_din;
    logic [8:0] icmp_pkt_fifo_dout;
    logic       icmp_pkt_fifo_wren;
    logic       icmp_pkt_fifo_full;
    logic       icmp_pkt_fifo_afull;
    
    logic       fatal_error;
    
    enum {
        WAIT_FOR_PKT,
        SKIP_TO_PROTOCOL,
        SKIP_REMAINING_HDR,
        SKIP_PKT,
        WAIT_FOR_PKT_FIFO_EMPTY,
        ROUTE_UDP,
        ROUTE_ICMP
    } pkt_route_fsm_state;
        
        
    logic [$clog2(IPV4_HDR_BYTES)-1:0] ipv4_hdr_byte_cnt;
    logic [7:0]                        ipv4_proto;
    logic                              ipv4_pkt_byte_rd;
    
    
    /*
     * FATAL ERROR MONITORING.  IF A "FATAL" ERROR OCCURS THE USER WILL NEED TO RESET THIS MODULE.
     * 
     * NOTE: THIS SHOULDN'T EVER HAPPEN AS I DON'T WRITE TO ANY FIFO UNTIL IT'S EMPTY, BUT I PUT MONITORING LOGIC IN
     *       JUST IN CASE I SCREWED UP.  IF THIS MODULE RUNS OUT OF ROOM THE OVERFLOW CONDITION WILL GET PUSHED UP STREAM.
     */
    
    assign fatal_error = o_udp_pkt_fifo_overflow | o_icmp_pkt_fifo_overflow;
    

    /* PACKET ROUTING FSM */
    
//    assign o_ipv4_pkt_byte_rd = ipv4_pkt_byte_rd & ~(i_ipv4_pkt_last_byte & i_ipv4_pkt_byte_vld); // avoid issuing a read request at the last valid byte of the current packet
    assign o_ipv4_pkt_byte_rd = ipv4_pkt_byte_rd;
    
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst | fatal_error) begin
            udp_pkt_fifo_wren           <= 0;
            icmp_pkt_fifo_wren          <= 0;
            ipv4_pkt_byte_rd            <= 0;
            o_unsupported_ipv4_protocol <= 0;
            pkt_route_fsm_state         <= WAIT_FOR_PKT;
        end else begin
            
            /* defaults */
            ipv4_pkt_byte_rd            <= 0;
            udp_pkt_fifo_wren           <= 0;
            icmp_pkt_fifo_wren          <= 0;
            o_unsupported_ipv4_protocol <= 0;
            
            case (pkt_route_fsm_state)
                
                WAIT_FOR_PKT: begin 

                    ipv4_hdr_byte_cnt <= '0;

                    if (i_ipv4_pkt_byte_vld) begin // there's at least 1 byte of the next IPv4 packet available
                        pkt_route_fsm_state <= SKIP_TO_PROTOCOL;
                    end
                end
                
                SKIP_TO_PROTOCOL: begin

                    ipv4_pkt_byte_rd <= 1;
                    
                    if (ipv4_pkt_byte_rd & i_ipv4_pkt_byte_vld) begin
                        ipv4_hdr_byte_cnt <= ipv4_hdr_byte_cnt + 1;
                    end

                    if ( (i_ipv4_pkt_byte_vld == 1) && (ipv4_hdr_byte_cnt == IPV4_HDR_PROTO_BYTE_NUM) ) begin

                        ipv4_proto <= i_ipv4_pkt_byte;

                        if ((i_ipv4_pkt_byte != IPV4_PROTO_UDP) && (i_ipv4_pkt_byte != IPV4_PROTO_ICMP)) begin
                            o_unsupported_ipv4_protocol <= 1;
                            pkt_route_fsm_state         <= SKIP_PKT;
                        end else begin
                            pkt_route_fsm_state <= SKIP_REMAINING_HDR;
                        end
                    end
                end

                SKIP_REMAINING_HDR: begin
                        
                    ipv4_pkt_byte_rd <= 1;

                    if (ipv4_pkt_byte_rd & i_ipv4_pkt_byte_vld) begin
                        ipv4_hdr_byte_cnt <= ipv4_hdr_byte_cnt + 1;
                    end

                    if ( (i_ipv4_pkt_byte_vld == 1) && (ipv4_hdr_byte_cnt == IPV4_HDR_LAST_BYTE_NUM) ) begin

                        if (ipv4_proto == IPV4_PROTO_UDP) begin
                            if (~udp_pkt_fifo_afull) begin 
                                pkt_route_fsm_state <= ROUTE_UDP;
                            end else begin
                                ipv4_pkt_byte_rd    <= 0;
                                pkt_route_fsm_state <= WAIT_FOR_PKT_FIFO_EMPTY;
                            end
                        end
                        
                        if (ipv4_proto == IPV4_PROTO_ICMP) begin
                            if (~icmp_pkt_fifo_afull) begin 
                                pkt_route_fsm_state <= ROUTE_ICMP;
                            end else begin
                                ipv4_pkt_byte_rd    <= 0;
                                pkt_route_fsm_state <= WAIT_FOR_PKT_FIFO_EMPTY;
                            end
                        end

                    end

                end
                    
                SKIP_PKT: begin
                        
                    ipv4_pkt_byte_rd <= 1;
                
                    if (ipv4_pkt_byte_rd & i_ipv4_pkt_byte_vld & i_ipv4_pkt_last_byte) begin
                        ipv4_pkt_byte_rd    <= 0;
                        pkt_route_fsm_state <= WAIT_FOR_PKT;
                    end
                end
                    
                WAIT_FOR_PKT_FIFO_EMPTY: begin
                    
                    case (ipv4_proto)

                        IPV4_PROTO_UDP: begin
                            if (~udp_pkt_fifo_afull) begin
                                ipv4_pkt_byte_rd    <= 1;
                                pkt_route_fsm_state <= ROUTE_UDP;
                            end
                        end
                        IPV4_PROTO_ICMP: begin
                            if (~icmp_pkt_fifo_afull) begin
                                ipv4_pkt_byte_rd    <= 1;
                                pkt_route_fsm_state <= ROUTE_ICMP;
                            end
                        end
                        default: begin
                            pkt_route_fsm_state <= WAIT_FOR_PKT; // we should never hit this
                        end
                    endcase
                end
                
                ROUTE_UDP: begin
                    
                    ipv4_pkt_byte_rd <= 1;
                    
                    if ( ipv4_pkt_byte_rd & i_ipv4_pkt_byte_vld ) begin
                        udp_pkt_fifo_wren <= 1;
                        udp_pkt_fifo_din  <= {i_ipv4_pkt_last_byte, i_ipv4_pkt_byte};
                        if (i_ipv4_pkt_last_byte) begin
                            ipv4_pkt_byte_rd    <= 0;
                            pkt_route_fsm_state <= WAIT_FOR_PKT;
                        end
                    end
                end
                    
                ROUTE_ICMP: begin
                    
                    ipv4_pkt_byte_rd <= 1;
                    
                    if (ipv4_pkt_byte_rd & i_ipv4_pkt_byte_vld) begin
                        icmp_pkt_fifo_wren <= 1;
                        icmp_pkt_fifo_din  <= {i_ipv4_pkt_last_byte, i_ipv4_pkt_byte};
                        if (i_ipv4_pkt_last_byte) begin
                            ipv4_pkt_byte_rd    <= 0;
                            pkt_route_fsm_state <= WAIT_FOR_PKT;
                        end
                    end
                end

            endcase
            
        end
    end
    

    /* UDP PACKET FIFO AND SUPPORTING LOGIC */
    
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (PKT_FIFO_BYTES_POW2), 
        .DEPTH_AFULL     (PKT_FIFO_BYTES_POW2-IPV4_PAYLOAD_MAX_BYTES), 
        .WIDTH           (9), 
        .FAMILY          ("ECP5U"), 
        .IMPLEMENTATION  ("EBR")
        ) UDP_PKT_FIFO (
        .clk             (i_rxmac_clk), 
        .rst             (i_rxmac_srst), 
        .wren            (udp_pkt_fifo_wren), 
        .wdata           (udp_pkt_fifo_din), 
        .full            (udp_pkt_fifo_full), 
        .afull           (udp_pkt_fifo_afull), 
        .rden            (i_udp_pkt_byte_rd), 
        .rdata           ({o_udp_pkt_last_byte, o_udp_pkt_byte}), 
        .rdata_vld       (o_udp_pkt_byte_vld));
    
    // monitor for udp pkt fifo overflow and pulse the error flag it if it occurs
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_udp_pkt_fifo_overflow <= 0;
        end else begin
            if (udp_pkt_fifo_wren & udp_pkt_fifo_full) begin
                o_udp_pkt_fifo_overflow <= 1;
            end
        end
    end
    

    /* ICMP PACKET FIFO AND SUPPORTING LOGIC */
    
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (PKT_FIFO_BYTES_POW2), 
        .DEPTH_AFULL     (PKT_FIFO_BYTES_POW2-IPV4_PAYLOAD_MAX_BYTES), 
        .WIDTH           (9), 
        .FAMILY          ("ECP5U"), 
        .IMPLEMENTATION  ("EBR")
    ) ICMP_PKT_FIFO (
        .clk             (i_rxmac_clk), 
        .rst             (i_rxmac_srst), 
        .wren            (icmp_pkt_fifo_wren), 
        .wdata           (icmp_pkt_fifo_din), 
        .full            (icmp_pkt_fifo_full), 
        .afull           (icmp_pkt_fifo_afull), 
        .rden            (i_icmp_pkt_byte_rd), 
        .rdata           ({o_icmp_pkt_last_byte, o_icmp_pkt_byte}), 
        .rdata_vld       (o_icmp_pkt_byte_vld));
    
    // monitor for icmp pkt fifo overflow and pulse the error flag it if it occurs
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_icmp_pkt_fifo_overflow <= 0;
        end else begin
            if (icmp_pkt_fifo_wren & icmp_pkt_fifo_full) begin
                o_icmp_pkt_fifo_overflow <= 1;
            end
        end
    end
    
endmodule