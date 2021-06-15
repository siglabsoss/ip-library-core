/**
 * Module: tb_udp_packetizer
 * 
 */
 
`include "ethernet_support_pkg.sv"

`default_nettype none
 
module tb_udp_packetizer;
    
    localparam   TB_NUM_ETH_FRAME_BUFFERS = 1;
    localparam   TB_SEQ_NUM_BYTES         = 4;
    localparam   TB_META_DATA_BYTES       = 4;
    localparam   TB_GBIT_MAC_DIRECT_MODE  = 1;

    localparam   TB_FRAME_FIFO_DEPTH      = 2**($clog2(TB_NUM_ETH_FRAME_BUFFERS * ETH_FRAME_MAX_BYTES));
    localparam   TB_FRAME_FIFO_AFULL_LVL  = TB_FRAME_FIFO_DEPTH - ETH_FRAME_MAX_BYTES;
    
    
    /* DUT SIGNALS */
    
    logic        i_txmac_clk = 0;
    logic        i_txmac_srst = 0;

    logic        i_start = 0;
    logic        o_start_ack;
    logic        o_done;
    logic        i_data_byte_vld = 0;
    logic [ 7:0] i_data_byte;
    logic        o_data_byte_rd;
    
    logic [47:0] i_dest_mac;
    logic [31:0] i_dest_ip;
    logic [15:0] i_dest_port; 
    logic [47:0] i_src_mac;
    logic [31:0] i_src_ip;
    logic [15:0] i_src_port;  
    logic [15:0] i_udp_payload_bytes;

    logic                              i_seq_num_prsnt = 0;
    logic [(8*TB_SEQ_NUM_BYTES)-1:0]   i_seq_num;
    logic                              i_meta_data_prsnt = 0;
    logic [(8*TB_META_DATA_BYTES)-1:0] i_meta_data;

    logic        o_eth_avail;
    logic        o_eth_eof;
    logic        o_eth_byte_vld;
    logic [ 7:0] o_eth_byte;
    logic        i_eth_byte_rd = 0;
    

    /* TEST BENCH SIGNALS */

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
    
    string       tb_test_str;
    logic        tb_consume_eth_frame;
    logic [31:0] tb_ipv4_hdr_checksum_sum;
    logic [7:0]  tb_data_byte;
    logic [(8*TB_SEQ_NUM_BYTES)-1:0] tb_seq_num;
    
    
    int tb_pkt_rx_cntr = 0;
    int tb_pkt_tx_cntr = 0;
    

//    PUR PUR_INST (.PUR (~i_txmac_srst));
//    GSR GSR_INST (.GSR (~i_txmac_srst));

    initial begin: TB_CLOCK_GEN
        forever #4 i_txmac_clk = ~i_txmac_clk;
    end
    
    initial begin: TB_RESET_GEN
        @(posedge i_txmac_clk);
        i_txmac_srst <= 1;
        repeat (10) @(posedge i_txmac_clk);
        i_txmac_srst <= 0;
    end
    

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

                        if (pkt_rd_byte_cntr == tb_ipv4_tot_len + 13) begin // we should've issued the right number of ethernet frame byte read requests at this point
                            i_eth_byte_rd <= 0;
                        end
                        
                        if ((pkt_rd_byte_cntr == tb_ipv4_tot_len + 14) && (o_eth_eof != 1)) begin
                            $fatal(1, "DUT failed to assert End-of-Packet Flag along with last byte of the UDP packet!");
                        end 
                         
                        tb_udp_data[pkt_rd_byte_cntr-43] <= o_eth_byte;
                    
                        if (o_eth_eof) begin
                        
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
                    pkt_rd_byte_cntr   = 0; // to align timing with read to output delay of the Ethernet Frame output FIFO in the DUT
                    tb_consume_eth_frame <= 1;
                    i_eth_byte_rd        <= 1;
                end
            end
        end
    end
    
    initial begin: TB_UDP_PKT_WRITER
        int i;
        int j;
        
        @(negedge i_txmac_srst);
        repeat (5) @(posedge i_txmac_clk);

        
        /* 
         * TEST:  BACK-TO-BACK UDP PACKET CREATION OF MANY SMALL PACKETS.
         * 
         * With TB_NUM_ETH_FRAME_BUFFERS set to 1 the UDP packet output FIFO in the DUT should have 2KBytes of space.  Therefore, we'll request packetizing of 3000 100 byte UDP packets
         * which will result in 3000 142 byte Ethernet Frames being created totaling 426,000 bytes.  I found I needed this in order to get the almost full flag of the FIFO to assert.
         * 
         */

        tb_test_str = "BACK2BACK SMALL";
        
        j = 0;
        i = 0;
        tb_data_byte = 0;
        
        while (j < 3000) begin

            @(posedge i_txmac_clk);
            i_start             <= 1;
            i_dest_mac          <= 48'h010203040506; 
            i_src_mac           <= 48'h0a0b0c0d0e0f; 
            i_dest_ip           <= 32'hc0a80102; // 192.168.1.2
            i_src_ip            <= 32'hc0a80101; // 192.168.1.1
            i_src_port          <= 16'hc350;     // 50,000
            i_dest_port         <= 16'hc351;     // 50,001
            i_udp_payload_bytes <= 16'd100;
            i_data_byte_vld     <= 1;
            i_data_byte         <= tb_data_byte;
            tb_data_byte        <= tb_data_byte + 1;
        
            while (o_start_ack == 0) begin
                @(posedge i_txmac_clk);
            end

            i_start <= 0;
            tb_pkt_tx_cntr++;
            
            while (i < 100) begin
                @(posedge i_txmac_clk);
                if (o_data_byte_rd & i_data_byte_vld) begin
                    i++;
                    i_data_byte  <= tb_data_byte;
                    tb_data_byte <= tb_data_byte + 1;
                end
            end
            
            i = 0;
            j++;
            
        end
        
        i_data_byte_vld <= 0;


        /* 
         * TEST:  NON BACK-TO-BACK UDP PACKET CREATION OF MANY SMALL PACKETS.
         * 
         * Same as previous test, but the packet creation requests aren't back-to-back.
         * 
         */
        
        repeat (100) @(posedge i_txmac_clk);

        tb_test_str = "NON-BACK2BACK SMALL";

        j = 0;
        i = 0;
        tb_data_byte = 0;
        
        while (j < 20) begin

            @(posedge i_txmac_clk);
            i_start             <= 1;
            i_dest_mac          <= 48'h010203040506; 
            i_src_mac           <= 48'h0a0b0c0d0e0f; 
            i_dest_ip           <= 32'hc0a80104; // 192.168.1.4
            i_src_ip            <= 32'hc0a80103; // 192.168.1.3
            i_src_port          <= 16'hc352;     // 50,002
            i_dest_port         <= 16'hc353;     // 50,003
            i_udp_payload_bytes <= 16'd100;
            i_data_byte_vld     <= 1;
            i_data_byte         <= tb_data_byte;
            tb_data_byte        <= tb_data_byte + 1;
        
            while (o_start_ack == 0) begin
                @(posedge i_txmac_clk);
            end
            
            tb_pkt_tx_cntr++;
            
            i_start <= 0;
            
            while (i < 100) begin
                @(posedge i_txmac_clk);
                if (o_data_byte_rd) begin
                    i++;
                    i_data_byte <= tb_data_byte;
                    tb_data_byte   <= tb_data_byte + 1;
                end
            end
            
            i_data_byte_vld <= 0;
            
            repeat (10) @(posedge i_txmac_clk);
            
            i = 0;
            j++;
            
        end


        /* 
         * TEST:  BACK-TO-BACK UDP PACKET CREATION OF MANY MAX SIZE PACKETS.
         * 
         * With the MTU fixed at 1500 bytes this means the maximum data payload of the UDP packet is 1472 bytes, so this is what we're sending
         * 
         */
        
        repeat (100) @(posedge i_txmac_clk);

        tb_test_str = "BACK2BACK MAX SIZE";

        j = 0;
        i = 0;
        tb_data_byte = 0;
        
        while (j < 100) begin

            @(posedge i_txmac_clk);
            i_start             <= 1;
            i_dest_mac          <= 48'h010203040506; 
            i_src_mac           <= 48'h0a0b0c0d0e0f; 
            i_dest_ip           <= 32'hc0a80106; // 192.168.1.6
            i_src_ip            <= 32'hc0a80105; // 192.168.1.5
            i_src_port          <= 16'hc354;     // 50,004
            i_dest_port         <= 16'hc355;     // 50,005
            i_udp_payload_bytes <= 16'd1472;
            i_data_byte_vld     <= 1;
            i_data_byte         <= tb_data_byte;
            tb_data_byte        <= tb_data_byte + 1;
        
            while (o_start_ack == 0) begin
                @(posedge i_txmac_clk);
            end
            
            tb_pkt_tx_cntr++;
            
            i_start <= 0;
            
            while (i < 1472) begin
                @(posedge i_txmac_clk);
                if (o_data_byte_rd) begin
                    i++;
                    i_data_byte <= tb_data_byte;
                    tb_data_byte   <= tb_data_byte + 1;
                end
            end
            
            i = 0;
            j++;
            
        end
        
        i_data_byte_vld <= 0;


        /* 
         * TEST:  BACK-TO-BACK UDP PACKET CREATION OF MANY MAX SIZE PACKETS WITH SEQUENCE NUMBERS
         * 
         * With the MTU fixed at 1500 bytes this means the maximum data payload of the UDP packet is 1472 bytes, so this is what we're sending
         * 
         */
        
        repeat (2000) @(posedge i_txmac_clk);
        
        tb_test_str = "BACK2BACK SEQ NUM";

        j = 0;
        i = 0;
        tb_data_byte = 0;
        tb_seq_num = 0;
        
        while (j < 100) begin

            @(posedge i_txmac_clk);
            i_start             <= 1;
            i_dest_mac          <= 48'h010203040506; 
            i_src_mac           <= 48'h0a0b0c0d0e0f; 
            i_dest_ip           <= 32'hc0a80108; // 192.168.1.8
            i_src_ip            <= 32'hc0a80106; // 192.168.1.7
            i_src_port          <= 16'hc356;     // 50,006
            i_dest_port         <= 16'hc357;     // 50,007
            i_udp_payload_bytes <= 16'd1472;
            i_seq_num_prsnt     <= 1;
            i_seq_num           <= tb_seq_num;
            tb_seq_num          <= tb_seq_num + 1;
            i_data_byte_vld     <= 1;
            i_data_byte         <= tb_data_byte;
            tb_data_byte        <= tb_data_byte + 1;
        
            while (o_start_ack == 0) begin
                @(posedge i_txmac_clk);
            end
            
            tb_pkt_tx_cntr++;
            
            i_start <= 0;
            
            while (i < 1468) begin // 1468 since 4-byte sequence number is present
                @(posedge i_txmac_clk);
                if (o_data_byte_rd) begin
                    i++;
                    i_data_byte  <= tb_data_byte;
                    tb_data_byte <= tb_data_byte + 1;
                end
            end
            
            i = 0;
            j++;
            
        end
        
        i_data_byte_vld <= 0;
        i_seq_num_prsnt <= 0;


        /* 
         * TEST:  BACK-TO-BACK UDP PACKET CREATION OF MANY MAX SIZE PACKETS WITH SEQUENCE NUMBERS & META DATA
         * 
         * With the MTU fixed at 1500 bytes this means the maximum data payload of the UDP packet is 1472 bytes, so this is what we're sending
         * 
         */
        
        repeat (2000) @(posedge i_txmac_clk);
        
        tb_test_str = "BACK2BACK SEQ NUM & META DATA";

        j = 0;
        i = 0;
        tb_data_byte = 0;
        tb_seq_num = 0;
        
        while (j < 100) begin

            @(posedge i_txmac_clk);
            i_start             <= 1;
            i_dest_mac          <= 48'h010203040506; 
            i_src_mac           <= 48'h0a0b0c0d0e0f; 
            i_dest_ip           <= 32'hc0a8010a; // 192.168.1.10
            i_src_ip            <= 32'hc0a80109; // 192.168.1.9
            i_src_port          <= 16'hc358;     // 50,008
            i_dest_port         <= 16'hc359;     // 50,009
            i_udp_payload_bytes <= 16'd1472;
            i_seq_num_prsnt     <= 1;
            i_seq_num           <= tb_seq_num;
            tb_seq_num          <= tb_seq_num + 1;
            i_meta_data_prsnt   <= 1;
            i_meta_data         <= 'hdeadbeef;
            i_data_byte_vld     <= 1;
            i_data_byte         <= tb_data_byte;
            tb_data_byte        <= tb_data_byte + 1;
        
            while (o_start_ack == 0) begin
                @(posedge i_txmac_clk);
            end
            
            tb_pkt_tx_cntr++;
            
            i_start <= 0;
            
            while (i < 1464) begin // 1464 since 4-byte sequence number is present and 4-byte meta data is present
                @(posedge i_txmac_clk);
                if (o_data_byte_rd) begin
                    i++;
                    i_data_byte  <= tb_data_byte;
                    tb_data_byte <= tb_data_byte + 1;
                end
            end
            
            i = 0;
            j++;
            
        end
        
        i_data_byte_vld   <= 0;
        i_seq_num_prsnt   <= 0;
        i_meta_data_prsnt <= 0;


        /* 
         * TEST:  BACK-TO-BACK UDP PACKET CREATION OF MANY MAX SIZE PACKETS WITH META DATA ONLY
         * 
         * With the MTU fixed at 1500 bytes this means the maximum data payload of the UDP packet is 1472 bytes, so this is what we're sending
         * 
         */
        
        repeat (2000) @(posedge i_txmac_clk);
        
        tb_test_str = "BACK2BACK META DATA ONLY";

        j = 0;
        i = 0;
        tb_data_byte = 0;
        tb_seq_num = 0;
        
        while (j < 100) begin

            @(posedge i_txmac_clk);
            i_start             <= 1;
            i_dest_mac          <= 48'h010203040506; 
            i_src_mac           <= 48'h0a0b0c0d0e0f; 
            i_dest_ip           <= 32'hc0a8010c; // 192.168.1.12
            i_src_ip            <= 32'hc0a8010b; // 192.168.1.11
            i_src_port          <= 16'hc35a;     // 50,010
            i_dest_port         <= 16'hc35b;     // 50,011
            i_udp_payload_bytes <= 16'd1472;
            i_seq_num_prsnt     <= 0;
            i_seq_num           <= '0;
//            i_seq_num           <= tb_seq_num;
//            tb_seq_num          <= tb_seq_num + 1;
            i_meta_data_prsnt   <= 1;
            i_meta_data         <= 'hdeadbeef;
            i_data_byte_vld     <= 1;
            i_data_byte         <= tb_data_byte;
            tb_data_byte        <= tb_data_byte + 1;
        
            while (o_start_ack == 0) begin
                @(posedge i_txmac_clk);
            end
            
            tb_pkt_tx_cntr++;
            
            i_start <= 0;
            
            while (i < 1468) begin // 1468 since 4-byte meta data is present
                @(posedge i_txmac_clk);
                if (o_data_byte_rd) begin
                    i++;
                    i_data_byte  <= tb_data_byte;
                    tb_data_byte <= tb_data_byte + 1;
                end
            end
            
            i = 0;
            j++;
            
        end
        
        i_data_byte_vld   <= 0;
        i_seq_num_prsnt   <= 0;
        i_meta_data_prsnt <= 0;

        repeat (20000) @(posedge i_txmac_clk);
        
        if (tb_pkt_tx_cntr == tb_pkt_rx_cntr) begin 
            $display("<<<TB_SUCCESS>>>");
            $display("TEST DONE.  SENT %0d PACKETS, RECEIVED %0d PACKETS", tb_pkt_tx_cntr, tb_pkt_rx_cntr);
        end else begin
            $display("DID NOT RECEIVE ALL PACKETS THAT WERE SENT!");
            $display("<<<TB_FAILURE>>>");
            $display("Received %0d, Sent %0d", tb_pkt_rx_cntr, tb_pkt_tx_cntr);
        end

        $finish();
        
    end
    
    udp_packetizer #(
        .NUM_ETH_FRAME_BUFFERS (TB_NUM_ETH_FRAME_BUFFERS), 
        .SEQ_NUM_BYTES        (TB_SEQ_NUM_BYTES),                    
        .META_DATA_BYTES      (TB_META_DATA_BYTES),
        .GBIT_MAC_DIRECT_MODE (TB_GBIT_MAC_DIRECT_MODE),
        .SIM_MODE             (1)
        ) DUT (.*);

endmodule

`default_nettype wire 
