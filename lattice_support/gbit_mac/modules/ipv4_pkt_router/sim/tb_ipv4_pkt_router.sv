/*
 * Module: tb_ipv4_pkt_router
 * 
 * TODO: Add module documentation
 */
 
`include "ethernet_support_pkg.sv"
 
module tb_ipv4_pkt_router;
    
    /* DUT SIGNALS */

    logic       i_rxmac_clk;
    logic       i_rxmac_srst; // synchronous to i_rxmac_clk
    logic [7:0] i_ipv4_pkt_byte;
    logic       i_ipv4_pkt_byte_vld;
    logic       i_ipv4_pkt_last_byte;
    logic       o_ipv4_pkt_byte_rd;
    logic       o_udp_pkt_byte_rdy;
    logic [7:0] o_udp_pkt_byte;
    logic       o_udp_pkt_byte_vld;
    logic       o_udp_pkt_last_byte;
    logic       i_udp_pkt_byte_rd;
    logic       o_icmp_pkt_byte_rdy;
    logic [7:0] o_icmp_pkt_byte;
    logic       o_icmp_pkt_byte_vld;
    logic       o_icmp_pkt_last_byte;
    logic       i_icmp_pkt_byte_rd;
    logic       o_udp_pkt_fifo_overflow;
    logic       o_icmp_pkt_fifo_overflow;
    logic       o_unsupported_ipv4_protocol;

    
    /* TEST BENCH SIGNALS */    

    
    /*
     * 
     *  IPv4 & ICMP PACKET GENERATION 
     * 
     */
    
    /*
     * 
     * CLOCK & RESET GENERATION
     * 
     */
    
    initial begin
        forever #4ns i_rxmac_clk = ~i_rxmac_clk;
    end
    
    initial begin
        int i;
        @(posedge i_rxmac_clk);
        i_rxmac_srst = 1;
        repeat (100) @(posedge i_rxmac_clk);
        i_rxmac_srst = 0;
    end

    
    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        
        // TEST 1: CBUF OVERFLOW DUE TO UDP PACKETS
        
        $finish();
    end
    
    ipv4_pkt_router DUT (.*);

endmodule


