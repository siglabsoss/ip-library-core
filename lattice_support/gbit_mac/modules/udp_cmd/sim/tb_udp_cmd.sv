/*
 * Module: tb_udp_cmd
 * 
 */
 
`include "ethernet_support_pkg.sv"
`include "udp_cmd_pkg.sv"

`default_nettype none
 
module tb_udp_cmd;
    
    localparam GBIT_MAC_DIRECT_MODE = 0;
    localparam bit [47:0] HOST_MAC  = 48'h000102030405;
    
    /* DUT SIGNALS */

    logic        i_rxmac_clk;
    logic        i_rxmac_srst;
    logic        o_port_fifo_rd;
    logic        i_port_fifo_byte_vld;
    logic        i_port_fifo_last_byte;
    logic [ 7:0] i_port_fifo_byte;
    logic        i_cmd_clk;
    logic        i_cmd_srst;
    logic        i_txmac_clk;
    logic        i_txmac_srst;
    logic        o_eth_avail;
    logic        o_eth_eof;
    logic        o_eth_byte_vld;
    logic [ 7:0] o_eth_byte;
    logic        i_eth_byte_rd;
    logic [47:0] i_host_mac;
    logic        o_runt_udp_cmd;
    
    
    /* TEST BENCH SIGNALS */    

    intf_cmd  #(.ADDR_BITS(UDP_CMD_ADDR_BITS-MIB_SEL_BITS), .DATA_BITS(8*UDP_CMD_DATA_BYTES)) cmd[2**MIB_SEL_BITS]();
    
    localparam UDP_CMD_TOT_BYTES = UDP_SEQ_NUM_BYTES + MSG_ID_BYTES + UDP_CMD_ADDR_BYTES + UDP_CMD_DATA_BYTES;
    
    logic       tb_port_fifo_wren = 0;
    logic [8:0] tb_port_fifo_wdata;
    logic       tb_port_fifo_full;
    string      tb_test_str;
    
    // NOTE: BIG ENDIAN FORMAT
    logic [0:UDP_SEQ_NUM_BYTES-2]                    [8:0] tb_udp_runt_cmd             = {9'h0aa, 9'h0bb, 9'h0cc};                                                                                                // unknown runt udp command (i.e. one with incomplete sequence number)
    logic [0:UDP_SEQ_NUM_BYTES-1]                    [8:0] tb_udp_unknown_short_cmd    = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd};                                                                                        // unknown short udp command (i.e. one with a complete squence number only)
    logic [0:UDP_SEQ_NUM_BYTES+MSG_ID_BYTES-1]       [8:0] tb_udp_known_short_cmd      = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd, {1'b0, REG_WRITE_REQ}};                                                                 // known short udp command (i.e. complete sequence number and MSG_ID, but no address
    logic [0:UDP_CMD_TOT_BYTES-UDP_CMD_DATA_BYTES-1] [8:0] tb_udp_no_wdata_cmd         = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd, {1'b0, REG_WRITE_REQ}, 9'h000, 9'h001, 9'h002, 9'h003};                                 // UDP Reg write command with missing wdata
    logic [0:UDP_CMD_TOT_BYTES-1]                    [8:0] tb_udp_good_write_cmd       = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd, {1'b0, REG_WRITE_REQ}, 9'h002, 9'h000, 9'h000, 9'h000, 9'h0de, 9'h0ad, 9'h0be, 9'h0ef}; // valid UDP Reg write command
    logic [0:UDP_CMD_TOT_BYTES-UDP_CMD_DATA_BYTES-1] [8:0] tb_udp_good_read_cmd        = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd, {1'b0, REG_READ_REQ}, 9'h002, 9'h000, 9'h000, 9'h000};                                  // valid UDP Reg read command
    logic [0:UDP_CMD_TOT_BYTES-UDP_CMD_DATA_BYTES-1] [8:0] tb_udp_good_read_no_ack_cmd = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd, {1'b0, REG_READ_REQ}, 9'h000, 9'h000, 9'h000, 9'h000};                                  // valid UDP Reg read command, but to an address that won't respond (test ACK timeout of DUT)
    logic [0:UDP_CMD_TOT_BYTES-1]                    [8:0] tb_udp_unknown_good_cmd     = {9'h0aa, 9'h0bb, 9'h0cc, 9'h0dd, {1'b0, MSG_UNKNOWN}, 9'h000, 9'h001, 9'h002, 9'h003, 9'h0de, 9'h0ad, 9'h0be, 9'h0ef};   // valid UDP command with unsupported command type
    
    localparam EXPECTED_UDP_PKT_CNT = 8; // i.e. we expect the above commands to produce this many UDP packets 
    int unsigned tb_pkt_cntr = 0;
    int unsigned tb_pkt_rx_cntr = 0;

    logic [47:0] tb_src_mac;
    logic [47:0] tb_dest_mac;
    logic [15:0] tb_eth_type;
    logic [ 3:0] tb_ipv4_ver;
    logic [ 3:0] tb_ipv4_ihl;
    logic [ 5:0] tb_ipv4_dscp;
    logic [ 1:0] tb_ipv4_ecn;
    logic [15:0] tb_ipv4_tot_len;
    logic [15:0] tb_ipv4_ident;
    logic [ 2:0] tb_ipv4_flags;
    logic [12:0] tb_ipv4_frag_off;
    logic [ 7:0] tb_ipv4_ttl;
    logic [ 7:0] tb_ipv4_proto;
    logic [15:0] tb_ipv4_hdr_checksum;
    logic [31:0] tb_ipv4_src_ip;
    logic [31:0] tb_ipv4_dest_ip;
    logic [15:0] tb_udp_src_port;
    logic [15:0] tb_udp_dest_port;
    logic [15:0] tb_udp_len;
    logic [15:0] tb_udp_checksum;
    logic [ 7:0] tb_udp_data [1472];
    
    logic        tb_consume_eth_frame;
    logic [31:0] tb_ipv4_hdr_checksum_sum;
    

    
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
        i_cmd_clk = 0;
        forever #20ns i_cmd_clk = ~i_cmd_clk;
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

    initial begin
        i_cmd_srst = 0;
        @(posedge i_cmd_clk);
        i_cmd_srst = 1;
        repeat (5) @(posedge i_cmd_clk); // assert for 1/4 as long as i_rxmac_srst and i_txmac_srst due to this clock being much slower
        i_cmd_srst = 0;
    end
    

    /*
     * 
     * ERROR REPORTING COUNTING
     * 
     */
    
    // NOTE: DUE TO ETHERNET FRAME PADDING IT'S NOT POSSIBLE TO GET WHAT I CALL A RUNT UDP PACKET
    
//    int tb_runt_udp_cmd_cntr = 0;
//    always_ff @(posedge i_rxmac_clk) begin
//        if (o_runt_udp_cmd) begin
//            tb_runt_udp_cmd_cntr++;
//        end
//    end
    

    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        
        cmd[0].ack <= 0; // for timeout testing

        
        @(negedge i_rxmac_srst);
        repeat (100) @(posedge i_rxmac_clk);

        // TEST: Valid UDP Reg Write 
        
        tb_test_str = "Valid UDP Reg Write";
        
        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<UDP_CMD_TOT_BYTES) begin
                tb_port_fifo_wdata <= tb_udp_good_write_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);
        
        // TEST: Valid UDP Reg Read

        tb_test_str = "Valid UDP Reg Read";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<(UDP_CMD_TOT_BYTES-UDP_CMD_DATA_BYTES)) begin
                tb_port_fifo_wdata <= tb_udp_good_read_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);

        // TEST: Valid UDP Reg Read, No ACK

        tb_test_str = "Valid UDP Reg Read No ACK";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<(UDP_CMD_TOT_BYTES-UDP_CMD_DATA_BYTES)) begin
                tb_port_fifo_wdata <= tb_udp_good_read_no_ack_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);
        
        // TEST: Runt command

        tb_test_str = "Runt Command";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<(UDP_SEQ_NUM_BYTES-1)) begin
                tb_port_fifo_wdata <= tb_udp_runt_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);
        
        
        // TEST: Short unknown command

        tb_test_str = "Short Unknown Command";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<UDP_SEQ_NUM_BYTES) begin
                tb_port_fifo_wdata <= tb_udp_unknown_short_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);
        
        // TEST: Short known command

        tb_test_str = "Short Known Command";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<(UDP_SEQ_NUM_BYTES+MSG_ID_BYTES)) begin
                tb_port_fifo_wdata <= tb_udp_known_short_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);
        
        // TEST: No write data

        tb_test_str = "Reg Write Command wo/Data";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<(UDP_CMD_TOT_BYTES-UDP_CMD_DATA_BYTES)) begin
                tb_port_fifo_wdata <= tb_udp_no_wdata_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);

        // TEST: Unsupported UDP Command

        tb_test_str = "Unsupported UDP Command";

        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin
            if (i<UDP_CMD_TOT_BYTES) begin
                tb_port_fifo_wdata <= tb_udp_unknown_good_cmd[i];
            end else begin
                tb_port_fifo_wdata <= (i == ETH_FRAME_MIN_BYTES-1) ? 9'h100 : 0;
            end
            tb_port_fifo_wren  <= 1;
            @(posedge i_rxmac_clk);
        end
        
        tb_port_fifo_wren <= 0;
        @(posedge i_rxmac_clk);
        
        tb_test_str = "DONE!";
        
        repeat (1000) @(posedge i_rxmac_clk);
        
//        if (tb_runt_udp_cmd_cntr != 1) begin
//            $error("DUT failed to report Runt UDP command!");
//            $display("<<<TB_FAILURE>>>");
//            $finish();
//        end

        if (tb_pkt_cntr != EXPECTED_UDP_PKT_CNT) begin
            $error("DUT only created %d UDP packets.  Expected %d", tb_pkt_cntr, EXPECTED_UDP_PKT_CNT);
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        
        $display("<<<TB_SUCCESS>>>");
        $finish();
    end
    
    /*
     * 
     * Stores incoming UDP commands for consumption by the DUT just like the udp_pkt_router would.
     * 
     */
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (4096), 
        .DEPTH_AFULL     (4095), 
        .WIDTH           (9), 
        .FAMILY          ("ECP5U"), 
        .IMPLEMENTATION  ("EBR"),
        .SIM_MODE        (1)
        ) UDP_PORT_FIFO (
        .clk             (i_rxmac_clk), 
        .rst             (i_rxmac_srst), 
        .wren            (tb_port_fifo_wren), 
        .wdata           (tb_port_fifo_wdata), 
        .full            (tb_port_fifo_full), 
        .afull           (), 
        .rden            (o_port_fifo_rd), 
        .rdata           ({i_port_fifo_last_byte, i_port_fifo_byte}),
        .rdata_vld       (i_port_fifo_byte_vld));
    
    assign i_host_mac = HOST_MAC;
    
    udp_cmd #(
        .BIG_ENDIAN             (1), 
        .CMD_ACK_TIMEOUT_CLKS   (8), 
        .HOST_IP                ({8'd10, 8'd0, 8'd0, 8'd0}), 
        .HOST_PORT              (16'd0), 
        .LOCAL_MAC              ({8'h0a, 8'h0b, 8'h0c, 8'h0d, 8'h0e, 8'h0f}), 
        .LOCAL_IP               ({8'd10, 8'd0, 8'd0, 8'd1}), 
        .LOCAL_PORT             (16'd1), 
        .FAMILY                 ("ECP5U"), 
        .GBIT_MAC_DIRECT_MODE   (GBIT_MAC_DIRECT_MODE), 
        .SIM_MODE               (1)
        ) DUT (.*);
    
    // Attach slave modules to all select lines except for index 0.  Index 0 will be used to test ACK timeout
    generate
        genvar i;
        for(i=1; i<(2**MIB_SEL_BITS); i++) begin
            cmd_slave cmd_slave (
                .i_sysclk  (i_cmd_clk), 
                .i_srst    (i_cmd_srst), 
                .cmd       (cmd[i]));
        end
    endgenerate
    
    
    /*
     * 
     * READS OUT ETHERNET II FRAMES WITH UDP PAYLOADS FROM THE DUT AND CHECKS THAT CERTAIN FIELDS ARE SET CORRECTLY, INCLUDING THE IPv4 HEADER CHECKSUM.
     * 
     */
    
    initial begin: TB_UDP_PKT_READER
        
        int pkt_rd_byte_cntr;
        int i;
        i_eth_byte_rd        <= 0;
        tb_consume_eth_frame <= 0;
        
        while (1) begin
            @(posedge i_txmac_clk);
            
            if (tb_consume_eth_frame) begin // currently reading a packet
                 
                // consumes all the bytes of the udp packet
                case (pkt_rd_byte_cntr) inside
                    
                    [0:0]  : ; // do nothing, this is just here for timing alignment
                    [1:6]  : tb_dest_mac <= {tb_dest_mac[39:0], o_eth_byte};
                    [7:12] : tb_src_mac  <= {tb_src_mac[39:0], o_eth_byte};
                    [13:14]: tb_eth_type <= {tb_eth_type[7:0], o_eth_byte};
                    [15:15]: begin
                        tb_ipv4_ver <= o_eth_byte[7:4];
                        tb_ipv4_ihl <= o_eth_byte[3:0];
                    end
                    [16:16]: begin
                        tb_ipv4_dscp <= o_eth_byte[7:2];
                        tb_ipv4_ecn  <= o_eth_byte[1:0];
                    end
                    [17:18]: tb_ipv4_tot_len <= {tb_ipv4_tot_len[7:0], o_eth_byte};
                    [19:20]: tb_ipv4_ident   <= {tb_ipv4_ident[7:0], o_eth_byte};
                    [21:21]: begin
                        tb_ipv4_flags          <= o_eth_byte[7:5];
                        tb_ipv4_frag_off[12:8] <= o_eth_byte[4:0];
                    end
                    [22:22]: tb_ipv4_frag_off[7:0] <= o_eth_byte;
                    [23:23]: tb_ipv4_ttl           <= o_eth_byte;
                    [24:24]: tb_ipv4_proto         <= o_eth_byte;
                    [25:26]: tb_ipv4_hdr_checksum  <= {tb_ipv4_hdr_checksum[7:0], o_eth_byte};
                    [27:30]: tb_ipv4_src_ip        <= {tb_ipv4_src_ip[23:0], o_eth_byte};
                    [31:34]: tb_ipv4_dest_ip       <= {tb_ipv4_dest_ip[23:0], o_eth_byte};
                    [35:36]: tb_udp_src_port       <= {tb_udp_src_port[7:0], o_eth_byte};
                    [37:38]: tb_udp_dest_port      <= {tb_udp_dest_port[7:0], o_eth_byte};
                    [39:40]: tb_udp_len            <= {tb_udp_len[7:0], o_eth_byte};
                    [41:42]: tb_udp_checksum       <= {tb_udp_checksum[7:0], o_eth_byte};
                    [43:1514]: begin

                        if (GBIT_MAC_DIRECT_MODE) begin
                            if (pkt_rd_byte_cntr == tb_ipv4_tot_len + 13) begin // we should've issued the right number of ethernet frame byte read requests at this point
                                i_eth_byte_rd <= 0;
                            end
                        end else begin
                            if (pkt_rd_byte_cntr == tb_ipv4_tot_len + 14) begin
                                i_eth_byte_rd <= 0;
                            end
                        end
                        
                        if (GBIT_MAC_DIRECT_MODE) begin
                            if ((pkt_rd_byte_cntr == tb_ipv4_tot_len + 14) && (o_eth_eof != 1)) begin
                                $fatal(1, "DUT failed to assert End-of-Packet Flag along with last byte of the UDP packet!");
                            end
                        end else begin
                            if ((pkt_rd_byte_cntr == tb_ipv4_tot_len + 15) && (o_eth_eof != 1)) begin
                                $fatal(1, "DUT failed to assert End-of-Packet Flag along with last byte of the UDP packet!");
                            end
                        end 
                         
                        tb_udp_data[pkt_rd_byte_cntr-43] <= o_eth_byte;
                    
                        if (o_eth_eof) begin
                        
                            tb_pkt_cntr++;
                        
                            tb_consume_eth_frame <= 0;
                            tb_pkt_rx_cntr++;
                        
                            tb_ipv4_hdr_checksum_sum = {16'd0, tb_ipv4_ver, tb_ipv4_ihl, tb_ipv4_dscp, tb_ipv4_ecn} + {16'd0, tb_ipv4_tot_len}                 + 
                                                       {16'd0, tb_ipv4_ident}                                       + {16'd0, tb_ipv4_flags, tb_ipv4_frag_off} + 
                                                       {16'd0, tb_ipv4_ttl, tb_ipv4_proto}                          + {16'd0, tb_ipv4_hdr_checksum}            + 
                                                       {16'd0, tb_ipv4_src_ip[31:16]}                               + {16'd0, tb_ipv4_src_ip[15:0]}            + 
                                                       {16'd0, tb_ipv4_dest_ip[31:16]}                              + {16'd0, tb_ipv4_dest_ip[15:0]};
                                                       
                            tb_ipv4_hdr_checksum_sum = {16'd0, tb_ipv4_hdr_checksum_sum[31:16]} + {16'd0, tb_ipv4_hdr_checksum_sum[15:0]};
                            tb_ipv4_hdr_checksum_sum = {16'd0, ~tb_ipv4_hdr_checksum_sum[15:0]};
                            
                            if (tb_eth_type != 16'h0800)                  $fatal(1, "EtherType != IPv4!");
                            if (tb_ipv4_ver != 4'h4)                      $fatal(1, "IPv4 Version != 4!");
                            if (tb_ipv4_ihl != 5)                         $fatal(1, "IPv4 IHL != 5!");
                            if (tb_ipv4_dscp != 0)                        $fatal(1, "IPv4 DSCP != 0!");
                            if (tb_ipv4_ecn != 0)                         $fatal(1, "IPv4 ECN != 0!");
                            if (tb_ipv4_tot_len != pkt_rd_byte_cntr - 14) $fatal(1, "IPv4 Total Length (%d bytes) Does Not Match Packet Length (%d bytes)!", tb_ipv4_tot_len, pkt_rd_byte_cntr-14);
                            if (tb_ipv4_ident != 0)                       $fatal(1, "IPv4 Identification != 0!");
                            if (tb_ipv4_flags != 0)                       $fatal(1, "IPv4 Flags != 0!");
                            if (tb_ipv4_frag_off != 0)                    $fatal(1, "IPv4 Fragment Offset != 0!");
                            if (tb_ipv4_proto != 8'h11)                   $fatal(1, "IPv4 Protocol != UDP!");
                            if (tb_ipv4_hdr_checksum_sum != 0)            $fatal(1, "IPv4 Header Checksum is BAD!");
                            
                            $display("Ethernet II Frame Info:");
                            $display("Destination MAC ADDR: %H:%H:%H:%H:%H:%H", tb_dest_mac[47:40], tb_dest_mac[39:32], tb_dest_mac[31:24], tb_dest_mac[23:16], tb_dest_mac[15:8], tb_dest_mac[7:0]);
                            $display("Source MAC ADDR     : %H:%H:%H:%H:%H:%H", tb_src_mac[47:40], tb_src_mac[39:32], tb_src_mac[31:24], tb_src_mac[23:16], tb_src_mac[15:8], tb_src_mac[7:0]);
                            $display("EtherType:          : %H", tb_eth_type);
                            $display("IPv4 Version        : %0d", tb_ipv4_ver);
                            $display("IPv4 Total Length   : %0d", tb_ipv4_tot_len);
                            $display("IPv4 TTL            : %0d", tb_ipv4_ttl);
                            $display("IPv4 Protocol       : %H", tb_ipv4_proto);
                            $display("IPv4 Checksum       : %H", tb_ipv4_hdr_checksum);
                            $display("IPv4 Source IP      : %0d.%0d.%0d.%0d", tb_ipv4_src_ip[31:24], tb_ipv4_src_ip[23:16], tb_ipv4_src_ip[15:8], tb_ipv4_src_ip[7:0]);
                            $display("IPv4 Destination IP : %0d.%0d.%0d.%0d", tb_ipv4_dest_ip[31:24], tb_ipv4_dest_ip[23:16], tb_ipv4_dest_ip[15:8], tb_ipv4_dest_ip[7:0]);
                        
                        end
                    end
                    default: begin
                        $fatal(1, "TOO MANY BYTES IN ETHERNET FRAME!");  
                    end
                    
                endcase

                pkt_rd_byte_cntr++;

            end else begin
                if (o_eth_avail) begin
                    $display("New Ethernet II Frame with UDP Payload!");
                    pkt_rd_byte_cntr      = (GBIT_MAC_DIRECT_MODE) ? 0 : 1; // to align timing with read to output delay of the Ethernet Frame output FIFO in the DUT
                    tb_consume_eth_frame <= 1;
                    i_eth_byte_rd        <= 1;
                end
            end
        end
    end

endmodule


`default_nettype wire