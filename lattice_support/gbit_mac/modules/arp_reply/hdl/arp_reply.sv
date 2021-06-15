/*
 * Module: arp_reply
 * 
 * Consumes IPv4 Ethernet ARP Packets that have been queued by the eth_frame_router and generates the appropriate response. 
 * 
 * NOTES:
 *     * There is no o_eth_avail output since the entire Ethernet II Frame into the ARP_RESP_FIFO is written on back-to-back clock cycles with no gaps.  This means this module won't tie up the mac_tx_arbiter
 *       for long periods of time and hence there's no need to only request a grant from the mac_tx_arbiter when a whole Ethernet II Frame has been queued.
 *     * This module should be connected to the Lattice Gbit MAC IP core's Tx interface via the mac_tx_arbiter due their being no o_eth_avail signal.  Technically o_eth_byte_vld could be used since it shouldn't
 *       drop low until the entire Ethernet II Frame has been consumed byte the Gbit MAC IP, but I don't guarantee this especially given the clock-domain-crossing taking place in the ARP_RESP_FIFO.
 *     
 * WARNINGS:
 *     * THIS MODULE SUPPORTS IPv4 ETHERNET BASED ARP PACKETS ONLY (i.e. the ARP packet must have 28 bytes)
 *     * MAKE SURE TO CONFIGURE THE LATTICE GBIT MAC IP CORE TO ACCEPT BROADCAST FRAMES.
 *     * MAKE SURE TO CONFIGURE THE LATTICE GBIT MAC IP CORE TO STRIP OFF THE ETHERNET FRAME CHECK SEQUENCE (FCS)
 * 
 */
 
 
`include "ethernet_support_pkg.sv"

`default_nettype none

module arp_reply #(
    parameter bit [47:0] LOCAL_MAC = {8'd0, 8'd1, 8'd2, 8'd3},     // MAC address of the ETH FPGA 
    parameter bit [31:0] LOCAL_IP  = {8'd192, 8'd168, 8'd2, 8'd3}, // IP address of the ETH FPGA
    parameter            FAMILY    = "ECP5U",                      // Specifies which Lattice FPGA family this module is being used in.
    parameter bit        SIM_MODE  = 0                             // Set to 1 if simulating this module
)(

    /* ETH_FRAME_ROUTER ARP INTERFACE */ 
    input             i_rxmac_clk,
    input             i_rxmac_srst,         // synchronous to i_rxmac_clk
    input      [ 7:0] i_arp_pkt_byte,
    input             i_arp_pkt_byte_vld,
    input             i_arp_pkt_last_byte,
    output reg        o_arp_pkt_byte_rd,

    /* MAC_TX_ARBITER INTERFACE (FOR COMMAND REPLIES) */
    input             i_txmac_clk,
    input             i_txmac_srst,      // synchronous to i_txmac_clk
    output            o_eth_eof,         // end of current Ethernet II Frame
    output            o_eth_byte_vld,    // indicates that bytes of an Ethernet II Frame with an ARP reply are ready to be passed to the mac_tx_arbiter
    output     [ 7:0] o_eth_byte, 
    input             i_eth_byte_rd,
    output reg [47:0] o_host_mac_tx,  // host MAC address learned from ARP request, synchronous to i_txmac_clk
    output reg        o_host_mac_tx_vld,
    
    /* STATUS & ERROR REPORTING (SYNCHRONOUS TO i_rxmac_clk) */
    
    output reg     o_arp_pkt_wrong_ip_addr, // not an error, just indicates that the ARP packet wasn't for us
    output reg     o_arp_pkt_bad_htype,
    output reg     o_arp_pkt_bad_ptype,
    output reg     o_arp_pkt_bad_hlen,
    output reg     o_arp_pkt_bad_plen,
    output reg     o_arp_pkt_bad_oper,
    output reg     o_arp_pkt_short // pulsed for one i_rxmac_clk clock cycle if an ARP packet is received that isn't exactly 28 bytes
);
    
    enum {
        WAIT_FOR_ARP_PKT,
        CONSUME_ARP_PKT,
        CONSUME_PAD_BYTES,
        CHECK_ARP_PKT_FIELDS,
        QUEUE_ARP_RESP
    } arp_fsm_state;
    
    logic [$clog2(28)-1:0] arp_pkt_byte_cntr; // ARP packets on IPv4 over Ethernet are 28 bytes
    logic [223:0]          arp_rx_pkt;        // holds the entire ARP packet currently be processed (28 bytes)
    logic [377:0]          arp_rep_eth_frame; // holds the entire ARP reply Ethernet II Frame (9 * (28 bytes for ARP + 14 bytes for Ethernet II Frame header))
    
    // used for "aliases" of arp_rx_pkt
    logic [15:0] arp_htype;
    logic [15:0] arp_ptype;
    logic [ 7:0] arp_hlen;
    logic [ 7:0] arp_plen;
    logic [15:0] arp_oper;
    logic [47:0] arp_sha;
    logic [31:0] arp_spa;
    logic [47:0] arp_tha;
    logic [31:0] arp_tpa;
    
    logic       arp_resp_fifo_wren;
    logic [8:0] arp_resp_fifo_wdata;
    logic       arp_resp_fifo_full;
    logic       arp_resp_fifo_afull;
    logic       arp_resp_fifo_rden;
    logic [8:0] arp_resp_fifo_rdata;
    logic       arp_resp_fifo_rdata_vld;

    logic        host_mac_cdc_fifo_wren;
    logic [47:0] host_mac_cdc_fifo_wdata;
    logic        host_mac_cdc_fifo_rden;
    logic [47:0] host_mac_cdc_fifo_rdata;
    logic        host_mac_cdc_fifo_rdata_vld;
    

    // "aliases" of arp_rx_pkt
    assign arp_htype = arp_rx_pkt[223:208];
    assign arp_ptype = arp_rx_pkt[207:192];
    assign arp_hlen  = arp_rx_pkt[191:184];
    assign arp_plen  = arp_rx_pkt[183:176];
    assign arp_oper  = arp_rx_pkt[175:160];
    assign arp_sha   = arp_rx_pkt[159:112];
    assign arp_spa   = arp_rx_pkt[111:80];
    assign arp_tha   = arp_rx_pkt[ 79:32];
    assign arp_tpa   = arp_rx_pkt[ 31:0];
    
    always_ff @(posedge i_rxmac_clk) begin
        
        if (i_rxmac_srst) begin

            arp_resp_fifo_wren      <= 0;
            host_mac_cdc_fifo_wren  <= 0;
            o_arp_pkt_byte_rd       <= 0;
            o_arp_pkt_wrong_ip_addr <= 0;
            o_arp_pkt_bad_htype     <= 0;
            o_arp_pkt_bad_ptype     <= 0;
            o_arp_pkt_bad_hlen      <= 0;
            o_arp_pkt_bad_plen      <= 0;
            o_arp_pkt_bad_oper      <= 0;
            o_arp_pkt_short         <= 0;
            arp_fsm_state           <= WAIT_FOR_ARP_PKT;
            
        end else begin
            
            /* defaults */
            arp_resp_fifo_wren      <= 0;
            host_mac_cdc_fifo_wren  <= 0;
            o_arp_pkt_wrong_ip_addr <= 0;
            o_arp_pkt_bad_htype     <= 0;
            o_arp_pkt_bad_ptype     <= 0;
            o_arp_pkt_bad_hlen      <= 0;
            o_arp_pkt_bad_plen      <= 0;
            o_arp_pkt_bad_oper      <= 0;
            o_arp_pkt_short         <= 0;
            
            case (arp_fsm_state)
                
                WAIT_FOR_ARP_PKT: begin
                    arp_pkt_byte_cntr <= '0;
                    if (i_arp_pkt_byte_vld & ~arp_resp_fifo_afull) begin
                        o_arp_pkt_byte_rd <= 1;
                        arp_fsm_state     <= CONSUME_ARP_PKT;
                    end
                end
                
                CONSUME_ARP_PKT: begin
                    if (i_arp_pkt_byte_vld) begin // o_arp_pkt_byte_rd already asserted, so this completes the handshaking
                        arp_pkt_byte_cntr <= arp_pkt_byte_cntr + 1;
                        arp_rx_pkt       <= {arp_rx_pkt[(28*8)-9:0], i_arp_pkt_byte};
                        
                        if (arp_pkt_byte_cntr == ($clog2(28))'(27)) begin // should have received the entire ARP packet by now 
                            
                            if (i_arp_pkt_last_byte) begin // I guess there are no pad bytes
                                o_arp_pkt_byte_rd <= 0;
                                arp_fsm_state     <= CHECK_ARP_PKT_FIELDS;
                            end else begin
                                arp_fsm_state     <= CONSUME_PAD_BYTES;
                            end
                        end else begin
                            if (i_arp_pkt_last_byte) begin // last byte asserted before we received the entire ARP packet!
                                o_arp_pkt_byte_rd <= 0;
                                o_arp_pkt_short   <= 1;
                                arp_fsm_state     <= WAIT_FOR_ARP_PKT;
                            end
                        end
                    end
                end
                
                CONSUME_PAD_BYTES: begin
                    
                    if (i_arp_pkt_byte_vld & i_arp_pkt_last_byte) begin // o_arp_pkt_byte_rd already asserted, so this completes the handshaking of the last pad byte
                        o_arp_pkt_byte_rd <= 0;
                        arp_fsm_state     <= CHECK_ARP_PKT_FIELDS;
                    end
                end
                
                CHECK_ARP_PKT_FIELDS: begin
                    
                    // assume fields are valid and that this ARP is for our IP address.  Correct if not the case.
                    arp_fsm_state     <= QUEUE_ARP_RESP;
                    arp_rep_eth_frame <= {{1'b0, arp_sha[47:40]},   {1'b0, arp_sha[39:32]},   {1'b0, arp_sha[31:24]},   {1'b0, arp_sha[23:16]},   {1'b0, arp_sha[15:8]},    {1'b0, arp_sha[7:0]},
                                          {1'b0, LOCAL_MAC[47:40]}, {1'b0, LOCAL_MAC[39:32]}, {1'b0, LOCAL_MAC[31:24]}, {1'b0, LOCAL_MAC[23:16]}, {1'b0, LOCAL_MAC[15:8]},  {1'b0, LOCAL_MAC[7:0]}, 
                                          {1'b0, ETH_TYPE_ARP[0]},  {1'b0, ETH_TYPE_ARP[1]},  {1'b0, ARP_HTYPE[0]},     {1'b0, ARP_HTYPE[1]},     {1'b0, ARP_PTYPE[0]},     {1'b0, ARP_PTYPE[1]}, 
                                          {1'b0, ARP_HLEN},         {1'b0, ARP_PLEN},         {1'b0, ARP_OPER_REP[0]},  {1'b0, ARP_OPER_REP[1]},  {1'b0, LOCAL_MAC[47:40]}, {1'b0, LOCAL_MAC[39:32]}, 
                                          {1'b0, LOCAL_MAC[31:24]}, {1'b0, LOCAL_MAC[23:16]}, {1'b0, LOCAL_MAC[15:8]},  {1'b0, LOCAL_MAC[7:0]},   {1'b0, LOCAL_IP[31:24]},  {1'b0, LOCAL_IP[23:16]},  
                                          {1'b0, LOCAL_IP[15:8]},   {1'b0, LOCAL_IP[7:0]},    {1'b0, arp_sha[47:40]},   {1'b0, arp_sha[39:32]},   {1'b0, arp_sha[31:24]},   {1'b0, arp_sha[23:16]},
                                          {1'b0, arp_sha[15:8]},    {1'b0, arp_sha[7:0]},     {1'b0, arp_spa[31:24]},   {1'b0, arp_spa[23:16]},   {1'b0, arp_spa[15:8]},    {1'b1, arp_spa[7:0]}};
                    
                    if (arp_tpa != LOCAL_IP) begin // not an error, just not an ARP for us
                        o_arp_pkt_wrong_ip_addr <= 1;
                        arp_fsm_state           <= WAIT_FOR_ARP_PKT;
                    end
                    
                    if (arp_htype != ARP_HTYPE) begin
                        o_arp_pkt_bad_htype <= 1;
                        arp_fsm_state       <= WAIT_FOR_ARP_PKT;
                    end
                    
                    if (arp_ptype != ARP_PTYPE) begin
                        o_arp_pkt_bad_ptype <= 1;
                        arp_fsm_state       <= WAIT_FOR_ARP_PKT;
                    end
                    
                    if (arp_hlen != ARP_HLEN) begin
                        o_arp_pkt_bad_hlen <= 1;
                        arp_fsm_state      <= WAIT_FOR_ARP_PKT;
                    end
                    
                    if (arp_plen != ARP_PLEN) begin
                        o_arp_pkt_bad_plen <= 1;
                        arp_fsm_state      <= WAIT_FOR_ARP_PKT;
                    end
                    
                    if (arp_oper != ARP_OPER_REQ) begin
                        o_arp_pkt_bad_oper <= 1;
                        arp_fsm_state      <= WAIT_FOR_ARP_PKT;
                    end
                    
                end
                
                QUEUE_ARP_RESP: begin
                    arp_resp_fifo_wren  <= 1;
                    arp_resp_fifo_wdata <= arp_rep_eth_frame[377:369];
                    arp_rep_eth_frame   <= arp_rep_eth_frame << 9;
                    
                    if (arp_rep_eth_frame[377]) begin // eof bit set which means last byte was just written into the fifo

                        // also queue learned host mac address so that Ethernet Tx modules can use it for sending Ethernet II Frames
                        host_mac_cdc_fifo_wren  <= 1;
                        host_mac_cdc_fifo_wdata <= arp_sha;
                        arp_fsm_state           <= WAIT_FOR_ARP_PKT;
                    end
                end
                
            endcase
        end
    end
    
`ifndef VERILATE_DEF
    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH        (128), // enough for 3 full Ethernet II frames with ARP payloads (full Ethernet II Frame = 28 + 14 bytes).
        .WR_DEPTH_AFULL  (128-42), 
        .WR_WIDTH        (9), // extra bit for eof flag
        .RD_WIDTH        (9), 
        .FAMILY          (FAMILY), 
        .IMPLEMENTATION  ("EBR"), 
        .RESET_MODE      ("sync"), 
        .WORD_SWAP       (0),  // doesn't matter because write and read widths are the same
        .SIM_MODE        (SIM_MODE)
        ) ARP_RESP_FIFO (
        .wrclk           (i_rxmac_clk             ), 
        .wrclk_rst       (i_rxmac_srst            ), 
        .rdclk           (i_txmac_clk             ), 
        .rdclk_rst       (i_txmac_srst            ), 
        .wren            (arp_resp_fifo_wren      ), 
        .wdata           (arp_resp_fifo_wdata     ), 
        .full            (arp_resp_fifo_full      ), 
        .afull           (arp_resp_fifo_afull     ), 
        .rden            (arp_resp_fifo_rden      ), 
        .rdata           (arp_resp_fifo_rdata     ), 
        .rdata_vld       (arp_resp_fifo_rdata_vld ));

`else

    fwft_sc_fifo #(
         .DEPTH        (128), // number of locations in the fifo
         .WIDTH        (9), // address width
         .ALMOST_FULL  (128-42) // number of locations for afull to be active
         ) ARP_RESP_FIFO (
        .clk          (i_rxmac_clk),
        .rst          (i_rxmac_srst),
        .wren         (arp_resp_fifo_wren),
        .wdata        (arp_resp_fifo_wdata),
        .full         (arp_resp_fifo_full),
        .o_afull      (arp_resp_fifo_afull),
        .rden         (arp_resp_fifo_rden),
        .rdata        (arp_resp_fifo_rdata),
        .rdata_vld    (arp_resp_fifo_rdata_vld));

`endif

    assign o_eth_byte_vld     = arp_resp_fifo_rdata_vld;
    assign o_eth_byte         = arp_resp_fifo_rdata[7:0];
    assign o_eth_eof          = arp_resp_fifo_rdata[8];
    assign arp_resp_fifo_rden = i_eth_byte_rd;
    

`ifndef VERILATE_DEF
    // brings Host MAC address learned from ARP request into the i_txmac_clk domain so that it no longer needs to be hard coded at FPGA build time
    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH        (4), 
        .WR_DEPTH_AFULL  (3), 
        .WR_WIDTH        (48), 
        .RD_WIDTH        (48), 
        .FAMILY          (FAMILY), 
        .IMPLEMENTATION  ("LUT"), 
        .RESET_MODE      ("sync"), 
        .WORD_SWAP       (0), 
        .SIM_MODE        (SIM_MODE       )
        ) HOST_MAC_CDC_FIFO (
        .wrclk           (i_rxmac_clk                 ), 
        .wrclk_rst       (i_rxmac_srst                ), 
        .rdclk           (i_txmac_clk                 ), 
        .rdclk_rst       (i_txmac_srst                ), 
        .wren            (host_mac_cdc_fifo_wren      ), 
        .wdata           (host_mac_cdc_fifo_wdata     ), 
        .full            (), 
        .afull           (), 
        .rden            (host_mac_cdc_fifo_rden      ), 
        .rdata           (host_mac_cdc_fifo_rdata     ), 
        .rdata_vld       (host_mac_cdc_fifo_rdata_vld ));

`else

    fwft_sc_fifo #(
         .DEPTH        (4), // number of locations in the fifo
         .WIDTH        (48), // address width
         .ALMOST_FULL  (3) // number of locations for afull to be active
         ) HOST_MAC_CDC_FIFO (
        .clk          (i_rxmac_clk),
        .rst          (i_rxmac_srst),
        .wren         (host_mac_cdc_fifo_wren),
        .wdata        (host_mac_cdc_fifo_wdata),
        .full         (),
        .o_afull      (),
        .rden         (host_mac_cdc_fifo_rden),
        .rdata        (host_mac_cdc_fifo_rdata),
        .rdata_vld    (host_mac_cdc_fifo_rdata_vld));

`endif
    
    assign host_mac_cdc_fifo_rden = host_mac_cdc_fifo_rdata_vld; // always read this fifo as new data comes in
    
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            o_host_mac_tx_vld <= 0; // host mac is invalid right after reset
        end else begin
            if (host_mac_cdc_fifo_rdata_vld) begin
                o_host_mac_tx_vld <= 1; // valid for all time (even though it could change with another ARP request) after the first valid ARP request is received
                o_host_mac_tx     <= host_mac_cdc_fifo_rdata;
            end
        end
    end

endmodule

`default_nettype wire