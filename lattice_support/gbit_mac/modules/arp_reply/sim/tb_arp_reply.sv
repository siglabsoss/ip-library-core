/*
 * Module: tb_arp_reply
 * 
 */
 
`include "ethernet_support_pkg.sv"

`default_nettype none
 
module tb_arp_reply;
    
    task emit_arp_pkt (input byte apkt []);
        int unsigned i;
        i=0;
        while (i<($size(apkt)-1)) begin
            @(posedge i_rxmac_clk);
            i_arp_pkt_byte_vld <= 1;
            if (o_arp_pkt_byte_rd & i_arp_pkt_byte_vld) begin
                i++;
            end
            i_arp_pkt_byte      <= apkt[i];
            i_arp_pkt_last_byte <= (i == ($size(apkt)-1)) ? 1 : 0;
        end
        @(posedge i_rxmac_clk);
        while (~o_arp_pkt_byte_rd) begin
            @(posedge i_rxmac_clk);
        end
        i_arp_pkt_byte_vld  <= 0;
        i_arp_pkt_last_byte <= 0;
    endtask
    
    /* DUT SIGNALS */

    logic        i_rxmac_clk;
    logic        i_rxmac_srst; 
    logic [ 7:0] i_arp_pkt_byte;
    logic        i_arp_pkt_byte_vld = 0;
    logic        i_arp_pkt_last_byte = 0;
    logic        o_arp_pkt_byte_rd;
    logic        i_txmac_clk;
    logic        i_txmac_srst;
    logic        o_eth_eof;
    logic        o_eth_byte_vld;    
    logic [ 7:0] o_eth_byte; 
    logic        i_eth_byte_rd;
    logic [47:0] o_host_mac_tx;  // host MAC address learned from ARP request, synchronous to i_txmac_clk
    logic        o_host_mac_tx_vld;
    logic        o_arp_pkt_wrong_ip_addr; 
    logic        o_arp_pkt_bad_htype;
    logic        o_arp_pkt_bad_ptype;
    logic        o_arp_pkt_bad_hlen;
    logic        o_arp_pkt_bad_plen;
    logic        o_arp_pkt_bad_oper;
    logic        o_arp_pkt_short;

    /* TEST BENCH SIGNALS */    
    
    localparam bit [0:5] [7:0] TB_MAC               = {8'd0, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5};
    localparam bit [0:3] [7:0] TB_IP                = {8'd10, 8'd0, 8'd0, 8'd1};
    localparam bit [0:5] [7:0] DUT_MAC              = {8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 8'd11};
    localparam bit [0:3] [7:0] DUT_IP               = {8'd10, 8'd0, 8'd0, 8'd2};
    localparam                 FAMILY               = "ECP5U";             
    localparam                 EXPECTED_ARP_PKT_CNT = 4; // i.e. we expect the DUT to produce this many ARP reply packets 
    
    byte tb_good_arp_no_pad [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]};
    byte tb_good_arp_pad    [0:45] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    byte tb_bad_htype_arp   [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1]+8'd1, ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]};
    byte tb_bad_ptype_arp   [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1]+8'd1, ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]};
    byte tb_bad_hlen_arp    [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN+8'd1, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]};
    byte tb_bad_plen_arp    [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN+8'd1, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]};
    byte tb_bad_oper_arp    [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1]+8'd1, TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]};
    byte tb_wrong_ip_arp    [0:27] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2], DUT_IP[3]+8'd1};
    byte tb_bad_length_arp  [0:26] = '{ARP_HTYPE[0], ARP_HTYPE[1], ARP_PTYPE[0], ARP_PTYPE[1], ARP_HLEN, ARP_PLEN, ARP_OPER_REQ[0], ARP_OPER_REQ[1], TB_MAC[0], TB_MAC[1], TB_MAC[2], TB_MAC[3], TB_MAC[4], TB_MAC[5], TB_IP[0], TB_IP[1], TB_IP[2], TB_IP[3], 0, 0, 0, 0, 0, 0, DUT_IP[0], DUT_IP[1], DUT_IP[2]};

    logic [47:0] tb_dest_mac;
    logic [47:0] tb_src_mac;
    logic [15:0] tb_eth_type;
    logic [15:0] tb_arp_htype;
    logic [15:0] tb_arp_ptype;
    logic [ 7:0] tb_arp_hlen;
    logic [ 7:0] tb_arp_plen;
    logic [15:0] tb_arp_oper;
    logic [47:0] tb_arp_sha;
    logic [31:0] tb_arp_spa;
    logic [47:0] tb_arp_tha;
    logic [31:0] tb_arp_tpa;
    logic        tb_consume_eth_frame;

    int unsigned tb_pkt_rx_cntr     = 0;
    int unsigned tb_bad_htype_cntr  = 0;
    int unsigned tb_bad_ptype_cntr  = 0;
    int unsigned tb_bad_hlen_cntr   = 0;
    int unsigned tb_bad_plen_cntr   = 0;
    int unsigned tb_bad_oper_cntr   = 0;
    int unsigned tb_wrong_ip_cntr   = 0;
    int unsigned tb_short_cntr      = 0;

    /*
     * 
     * CLOCK & RESET GENERATION
     * 
     */
    
    initial begin
        i_rxmac_clk = 0;
        forever #4ns i_rxmac_clk = ~i_rxmac_clk;
    end

    initial begin
        i_txmac_clk = 0;
        forever #4ns i_txmac_clk = ~i_txmac_clk;
    end
    
    initial begin
        i_rxmac_srst = 0;
        @(posedge i_rxmac_clk);
        i_rxmac_srst = 1;
        repeat (100) @(posedge i_rxmac_clk);
        i_rxmac_srst = 0;
    end

    initial begin
        i_txmac_srst = 0;
        @(posedge i_txmac_clk);
        i_txmac_srst = 1;
        repeat (100) @(posedge i_txmac_clk);
        i_txmac_srst = 0;
    end

    

    /*
     * 
     * ERROR REPORTING COUNTING
     * 
     */
    
    always_ff @(posedge i_rxmac_clk) begin
        tb_bad_htype_cntr  <= (o_arp_pkt_bad_htype)     ? tb_bad_htype_cntr  + 1 : tb_bad_htype_cntr;
        tb_bad_ptype_cntr  <= (o_arp_pkt_bad_ptype)     ? tb_bad_ptype_cntr  + 1 : tb_bad_ptype_cntr;
        tb_bad_hlen_cntr   <= (o_arp_pkt_bad_hlen)      ? tb_bad_hlen_cntr   + 1 : tb_bad_hlen_cntr;
        tb_bad_plen_cntr   <= (o_arp_pkt_bad_plen)      ? tb_bad_plen_cntr   + 1 : tb_bad_plen_cntr;
        tb_bad_oper_cntr   <= (o_arp_pkt_bad_oper)      ? tb_bad_oper_cntr   + 1 : tb_bad_oper_cntr;
        tb_wrong_ip_cntr   <= (o_arp_pkt_wrong_ip_addr) ? tb_wrong_ip_cntr   + 1 : tb_wrong_ip_cntr;
        tb_short_cntr      <= (o_arp_pkt_short)         ? tb_short_cntr + 1 : tb_short_cntr;
    end
    

    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        
        @(negedge i_rxmac_clk);
        
        repeat(100) @(posedge i_rxmac_clk);
        
        emit_arp_pkt(tb_good_arp_no_pad);
        emit_arp_pkt(tb_good_arp_pad);
        emit_arp_pkt(tb_bad_htype_arp);
        emit_arp_pkt(tb_bad_ptype_arp);
        emit_arp_pkt(tb_bad_hlen_arp);
        emit_arp_pkt(tb_bad_plen_arp);
        emit_arp_pkt(tb_bad_oper_arp);
        emit_arp_pkt(tb_wrong_ip_arp);
        emit_arp_pkt(tb_bad_length_arp);
        emit_arp_pkt(tb_good_arp_pad);
        emit_arp_pkt(tb_good_arp_no_pad);

        repeat(1000) @(posedge i_rxmac_clk);
        
        if (tb_bad_htype_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF ARP PACKETS WITH BAD HTYPE FIELD!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (tb_bad_ptype_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF ARP PACKETS WITH BAD PTYPE FIELD!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (tb_bad_hlen_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF ARP PACKETS WITH BAD HLEN FIELD!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (tb_bad_plen_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF ARP PACKETS WITH BAD PLEN FIELD!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (tb_bad_oper_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF ARP PACKETS WITH BAD OPER FIELD!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (tb_wrong_ip_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF ARP PACKETS WITH WRONG TPA FIELD!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (tb_short_cntr != 1) begin
            $error("DUT FAILED TO REPORT CORRECT NUMBER OF SHORT ARP PACKETS!");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        
        if (tb_pkt_rx_cntr != EXPECTED_ARP_PKT_CNT) begin
            $error("DUT FAILED TO GENERATE THE EXPECTED NUMBER (%d) OF ARP REPLY PACKETS", EXPECTED_ARP_PKT_CNT);
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        
        if (o_host_mac_tx_vld != 1) begin
            $error("DUT FAILED TO INDICATE THAT THE HOST MAC ADDRESS HAD BEEN LEARNED");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end

        if (o_host_mac_tx != TB_MAC) begin
            $error("DUT FAILED TO CORRECTLY REPORT THE HOST MAC ADDRESS AFTER LEARNING IT, EXPECTED: 0x%h RECEIVED: 0x%h", TB_MAC, o_host_mac_tx); 
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        
        $display("<<<TB_SUCCESS>>>");
        $finish();
    end
    
    /*
     * 
     * READS OUT ETHERNET II FRAMES WITH ARP PAYLOADS AND CHECKS THAT THE FIELDS ARE CORRECTLY SET 
     * 
     */ 
    
    initial begin: TB_UDP_PKT_READER
        
        int pkt_rd_byte_cntr;
        int i;
        i_eth_byte_rd        <= 0;
        tb_consume_eth_frame <= 0;
        
        while (1) begin
            @(posedge i_txmac_clk);
            
            if ((tb_consume_eth_frame == 1 && o_eth_byte_vld == 1) || (pkt_rd_byte_cntr == 42)) begin // currently reading a packet
                 
                // consumes all the bytes of the udp packet
                case (pkt_rd_byte_cntr) inside
                    
                    [0:5]  : tb_dest_mac  <= {tb_dest_mac[39:0], o_eth_byte};
                    [6:11] : tb_src_mac   <= {tb_src_mac[39:0], o_eth_byte};
                    [12:13]: tb_eth_type  <= {tb_eth_type[7:0], o_eth_byte};
                    [14:15]: tb_arp_htype <= {tb_arp_htype[7:0], o_eth_byte}; 
                    [16:17]: tb_arp_ptype <= {tb_arp_ptype[7:0], o_eth_byte};
                    [18:18]: tb_arp_hlen  <= o_eth_byte;
                    [19:19]: tb_arp_plen  <= o_eth_byte;
                    [20:21]: tb_arp_oper  <= {tb_arp_oper[7:0], o_eth_byte};
                    [22:27]: tb_arp_sha   <= {tb_arp_sha[39:0], o_eth_byte};
                    [28:31]: tb_arp_spa   <= {tb_arp_spa[23:0], o_eth_byte};
                    [32:37]: tb_arp_tha   <= {tb_arp_tha[39:0], o_eth_byte};
                    [38:41]: begin 
                        
                        tb_arp_tpa <= {tb_arp_tpa[23:0], o_eth_byte};

                        if (pkt_rd_byte_cntr == 41) begin
                            i_eth_byte_rd <= 0;
                        end
                        
                        if ((pkt_rd_byte_cntr == 41) && (o_eth_eof != 1)) begin
                            $fatal(1, "DUT failed to assert End-of-Packet Flag along with last byte of the ARP packet!");
                        end
                        
                    end
                    [42:42]: begin
                         
                        tb_consume_eth_frame <= 0;
                        tb_pkt_rx_cntr++;
                        
                        if (tb_dest_mac  != TB_MAC)       begin $display("<<<TB_FAILURE>>>"); $fatal(1, "Destination MAC != TB_MAC"); end
                        if (tb_src_mac   != DUT_MAC)      begin $display("<<<TB_FAILURE>>>"); $fatal(1, "Source MAC != DUT_MAC"); end
                        if (tb_eth_type  != ETH_TYPE_ARP) begin $display("<<<TB_FAILURE>>>"); $fatal(1, "EtherType: 0x%H, Expected: 0x%H", tb_eth_type, ETH_TYPE_ARP); end
                        if (tb_arp_htype != ARP_HTYPE)    begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP HTYPE: 0x%H, Expected: 0x%H", tb_arp_htype, ARP_HTYPE); end
                        if (tb_arp_ptype != ARP_PTYPE)    begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP PTYPE: 0x%H, Expected: 0x%H", tb_arp_ptype, ARP_PTYPE); end
                        if (tb_arp_hlen  != ARP_HLEN)     begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP HLEN: 0x%H, Expected: 0x%H", tb_arp_hlen, ARP_HLEN); end
                        if (tb_arp_plen  != ARP_PLEN)     begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP PLEN: 0x%H, Expected: 0x%H", tb_arp_plen, ARP_PLEN); end
                        if (tb_arp_oper  != ARP_OPER_REP) begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP OPER: 0x%H, Expected: 0x%H (Reply)", tb_arp_oper, ARP_OPER_REP); end
                        if (tb_arp_sha   != DUT_MAC)      begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP SHA: 0x%H, Expected: 0x%H", tb_arp_sha, DUT_MAC); end
                        if (tb_arp_spa   != DUT_IP)       begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP SPA: 0x%H, Expected: 0x%H", tb_arp_spa, DUT_IP); end
                        if (tb_arp_tha   != TB_MAC)       begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP THA: 0x%H, Expected: 0x%H", tb_arp_tha, TB_MAC); end
                        if (tb_arp_tpa   != TB_IP)        begin $display("<<<TB_FAILURE>>>"); $fatal(1, "ARP TPA: 0x%H, Expected: 0x%H", tb_arp_tpa, TB_IP); end
                        
                        $display("");
                        $display("Ethernet II Frame Info:");
                        $display("Destination MAC ADDR: %H:%H:%H:%H:%H:%H", tb_dest_mac[47:40], tb_dest_mac[39:32], tb_dest_mac[31:24], tb_dest_mac[23:16], tb_dest_mac[15:8], tb_dest_mac[7:0]);
                        $display("Source MAC ADDR     : %H:%H:%H:%H:%H:%H", tb_src_mac[47:40], tb_src_mac[39:32], tb_src_mac[31:24], tb_src_mac[23:16], tb_src_mac[15:8], tb_src_mac[7:0]);
                        $display("EtherType:          : %H", tb_eth_type);
                        $display("ARP Packet Info:");
                        $display("HTYPE: 0x%H", tb_arp_htype);
                        $display("PTYPE: 0x%H", tb_arp_ptype);
                        $display("HLEN: 0x%H", tb_arp_hlen);
                        $display("PLEN: 0x%H", tb_arp_plen);
                        $display("OPER: 0x%H", tb_arp_oper);
                        $display("SHA: %H:%H:%H:%H:%H:%H", tb_arp_sha[47:40], tb_arp_sha[39:32], tb_arp_sha[31:24], tb_arp_sha[23:16], tb_arp_sha[15:8], tb_arp_sha[7:0]);
                        $display("SPA: %d.%d.%d.%d", tb_arp_spa[31:24], tb_arp_spa[23:16], tb_arp_spa[15:8], tb_arp_spa[7:0]);
                        $display("THA: %H:%H:%H:%H:%H:%H", tb_arp_tha[47:40], tb_arp_tha[39:32], tb_arp_tha[31:24], tb_arp_tha[23:16], tb_arp_tha[15:8], tb_arp_tha[7:0]);
                        $display("TPA: %d.%d.%d.%d", tb_arp_tpa[31:24], tb_arp_tpa[23:16], tb_arp_tpa[15:8], tb_arp_tpa[7:0]);
                        $display("");
                        
                    end

                    default: begin
                        $fatal(1, "TOO MANY BYTES IN ETHERNET FRAME!");  
                    end
                    
                endcase

                pkt_rd_byte_cntr++;

            end else begin
                if (o_eth_byte_vld) begin
                    $display("New Ethernet II Frame with ARP Payload!");
                    pkt_rd_byte_cntr      = 0; 
                    tb_consume_eth_frame <= 1;
                    i_eth_byte_rd        <= 1;
                end
            end
        end
    end
    
    arp_reply #(
        .LOCAL_MAC             (DUT_MAC), 
        .LOCAL_IP              (DUT_IP), 
        .FAMILY                (FAMILY), 
        .SIM_MODE              (1)
        ) DUT (.*);

endmodule


`default_nettype wire