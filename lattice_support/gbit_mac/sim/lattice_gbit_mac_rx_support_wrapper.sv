/**
 * Module: lattice_gbit_mac_rx_support_wrapper
 * 
 * Wraps all the Lattice Gbit MAC Rx support blocks to make the top level test bench instantiation cleaner.
 * 
 */
 
`default_nettype none 
 
module lattice_gbit_mac_rx_support_wrapper #(
        
    parameter integer                  CBUF_MAX_ETH_FRAME_DEPTH = 4, // Number of maximum sized Ethernet frames that can be simultaneously stored in the circular buffer
    parameter integer                  IPV4_PKT_FIFO_PKT_DEPTH  = 5, // Number of maximum sized IPv4 packets that can be simultaneously stored in the output FIFO
    parameter integer                  ARP_PKT_FIFO_PKT_DEPTH   = 5,  // Number of maximum sized ARP packets that can be simultaneously stored in the output FIFO
    parameter integer                  P_NUM_PORTS              = 2,
    parameter [0:P_NUM_PORTS-1] [15:0] P_PORTS                  = {16'd50000, 16'd60000} // i.e. port 50,000 would correspond to router output interface 0

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
    
    /* DAC DATAT INTERFACE */
    input         i_sys_clk,
    input         i_sys_srst,
    input         i_dac_data_rd,
    output        o_dac_data_parity,
    output [31:0] o_dac_data,

    /* ERROR REPORTING */

    // IF ANY OF THESE ERRORS OCCUR YOU'LL NEED TO RESET THIS MODULE TO RECOVER AND CLEAR THE ERROR
    output o_eth_frame_circ_buf_overflow, 
    output o_ipv4_pkt_fifo_overflow,
    output o_arp_pkt_fifo_overflow,
    output o_udp_pkt_fifo_overflow,
    output o_icmp_pkt_fifo_overflow,
    output [P_NUM_PORTS-1:0]  o_port_fifo_overflow,
    output o_dac_fifo_overflow,
    // THESE ERROR STATUS SIGNALS GET ASSERTED FOR ONE CLOCK IF THEIR RESPECTIVE ERROR OCCURS.  YOU NEED EXTERNAL LOGIC TO KEEP TRACK OF THESE ERRORS IF DESIRED.
    output o_eth_frame_long_frame_error,
    output o_eth_frame_short_frame_error,
    output o_eth_frame_ipg_error,
    output o_eth_frame_crc_error,
    output o_eth_frame_vlan_error,
    output o_unsupported_eth_type_error,
    output o_unsupported_ipv4_protocol,
    output o_unsupported_dest_port,
    output o_dac_fifo_underflow,
    output o_udp_seq_num_error
        
);

    /* IPv4 OUTPUT PACKET INTERFACE */
    logic [7:0] o_ipv4_pkt_byte;
    logic       o_ipv4_pkt_byte_vld;
    logic       o_ipv4_pkt_last_byte;
    logic       i_ipv4_pkt_byte_rd;
    
    /* ARP OUTPUT PACKET INTERFACE */
    logic [7:0] o_arp_pkt_byte;
    logic       o_arp_pkt_byte_vld;
    logic       o_arp_pkt_last_byte;
    logic       i_arp_pkt_byte_rd;

    /* UDP OUTPUT PACKET INTERFACE */
    logic [7:0] o_udp_pkt_byte;
    logic       o_udp_pkt_byte_vld;
    logic       o_udp_pkt_last_byte;
    logic       i_udp_pkt_byte_rd;
    
    /* ICMP OUTPUT PACKET INTERFACE */
    logic [7:0] o_icmp_pkt_byte;
    logic       o_icmp_pkt_byte_vld;
    logic       o_icmp_pkt_last_byte;
    logic       i_icmp_pkt_byte_rd = 0;
    
    /* UDP PKT ROUTER INTERFACE */
    logic [0:P_NUM_PORTS-1]       o_port_last_byte; 
    logic [0:P_NUM_PORTS-1]       o_port_byte_vld;
    logic [0:P_NUM_PORTS-1] [7:0] o_port_byte; 
    logic [0:P_NUM_PORTS-1]       i_port_byte_rd;

    
    eth_frame_router #(
        .CBUF_MAX_ETH_FRAME_DEPTH       (CBUF_MAX_ETH_FRAME_DEPTH      ), 
        .IPV4_PKT_FIFO_PKT_DEPTH        (IPV4_PKT_FIFO_PKT_DEPTH       ), 
        .ARP_PKT_FIFO_PKT_DEPTH         (ARP_PKT_FIFO_PKT_DEPTH        )
    ) eth_frame_router (.*);

    
    ipv4_pkt_router ipv4_pkt_router (
        .i_ipv4_pkt_byte              (o_ipv4_pkt_byte             ), 
        .i_ipv4_pkt_byte_vld          (o_ipv4_pkt_byte_vld         ), 
        .i_ipv4_pkt_last_byte         (o_ipv4_pkt_last_byte        ), 
        .o_ipv4_pkt_byte_rd           (i_ipv4_pkt_byte_rd          ), 
        .*);
    
    udp_pkt_router #(
        .P_NUM_PORTS              (P_NUM_PORTS             ), 
        .P_PORTS                  (P_PORTS                 )
        ) udp_pkt_router (
        .i_udp_pkt_byte           (o_udp_pkt_byte          ), 
        .i_udp_pkt_byte_vld       (o_udp_pkt_byte_vld      ), 
        .i_udp_pkt_last_byte      (o_udp_pkt_last_byte     ), 
        .o_udp_pkt_byte_rd        (i_udp_pkt_byte_rd       ), 
        .*);
    
    
    eth_dac_data_rx eth_dac_data_rx (
        .o_udp_port_fifo_rd          (i_port_byte_rd[0]   ),
        .i_udp_port_fifo_byte_vld    (o_port_byte_vld[0]  ),
        .i_udp_port_fifo_last_byte   (o_port_last_byte[0] ),
        .i_udp_port_fifo_byte        (o_port_byte[0]      ),
        .*);
    


endmodule

`default_nettype wire