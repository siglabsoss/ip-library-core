/*
 * Module: tb_eth_frame_router
 * 
 * TODO: Add module documentation
 */
 
`include "ethernet_support_pkg.sv"
 
module tb_eth_frame_router;
    
    /* DUT SIGNALS */

    logic        i_rxmac_clk = 0;
    logic        i_rxmac_srst = 0; 
    logic        i_rx_write = 0;
    logic        i_rx_eof = 0;
    logic        i_rx_error = 0;
    logic [ 7:0] i_rx_dbout = 0;
    logic        i_rx_stat_en = 0;
    logic [31:0] i_rx_stat_vector = 0;
    logic [ 7:0] o_ipv4_pkt_byte;
    logic        o_ipv4_pkt_byte_vld;
    logic        o_ipv4_pkt_last_byte;
    logic        i_ipv4_pkt_byte_rd;
    logic [ 7:0] o_arp_pkt_byte;
    logic        o_arp_pkt_byte_vld;
    logic        o_arp_pkt_last_byte;
    logic        i_arp_pkt_byte_rd;
    logic        o_eth_frame_circ_buf_overflow;
    logic        o_eth_frame_long_frame_error;
    logic        o_eth_frame_short_frame_error;
    logic        o_eth_frame_ipg_error;
    logic        o_eth_frame_crc_error;
    logic        o_eth_frame_vlan_error;
    logic        o_unsupported_eth_type_error;
    logic        o_ipv4_pkt_fifo_overflow;
    logic        o_arp_pkt_fifo_overflow;
    
    /* TEST BENCH SIGNALS */    

    int unsigned err_report_cnt = 0;
    int unsigned ipv4_pkt_err_cnt = 0;
    int unsigned arp_pkt_err_cnt = 0;

    byte ipv4_pkt_cap_buf [MTU_BYTES];

    ETH_II_FRAME_T tb_udp_frame;
    ETH_II_FRAME_T tb_arp_frame;
    ETH_II_FRAME_T tb_unsupported_ethtype_frame;
    
    bit [0:5] [7:0] tb_dest_mac  = {8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66};
    bit [0:3] [7:0] tb_dest_ip   = {8'h01, 8'h02, 8'h03, 8'h04};
    bit [0:1] [7:0] tb_dest_port = {8'h00, 8'h01};
    bit [0:5] [7:0] tb_src_mac   = {8'haa, 8'hbb, 8'hcc, 8'hdd, 8'hee, 8'hff};
    bit [0:3] [7:0] tb_src_ip    = {8'h01, 8'h02, 8'h03, 8'h05};
    bit [0:1] [7:0] tb_src_port  = {8'h00, 8'h02};
    
    byte tb_udp_data [UDP_PAYLOAD_MAX_BYTES];
    
    parameter TB_CBUF_ETH_FRAME_DEPTH = 4;
    parameter TB_IPV4_PKT_FIFO_PKT_DEPTH = 5;
    parameter TB_ARP_PKT_FIFO_PKT_DEPTH = 5;
    parameter TB_NUM_UDP_PKTS_FOR_OVERFLOW = int'(2**$clog2((TB_IPV4_PKT_FIFO_PKT_DEPTH + TB_CBUF_ETH_FRAME_DEPTH) * ETH_FRAME_MAX_BYTES) / (1.0 * MTU_BYTES)); // NOTE: this assumes max sized UDP packets.  
    
    
    /*
     * 
     *  UDP FRAME GENERATION 
     * 
     */
    
    initial begin
        int i;
        for (i=0; i<UDP_PAYLOAD_MAX_BYTES; i++) begin
            tb_udp_data[i] = i;
        end

        tb_udp_frame = create_ipv4_udp_frame ( tb_dest_mac, tb_dest_ip, tb_dest_port, tb_src_mac, tb_src_ip, tb_src_port, tb_udp_data);
        tb_unsupported_ethtype_frame = create_unsupported_ethtype_frame();
        
//        $display("SRC MAC: %h:%h:%h:%h:%h:%h", tb_udp_frame.src_mac[0], tb_udp_frame.src_mac[1], tb_udp_frame.src_mac[2], tb_udp_frame.src_mac[3], tb_udp_frame.src_mac[4], tb_udp_frame.src_mac[5]);
//        $display("DEST MAC: %h:%h:%h:%h:%h:%h", tb_udp_frame.dest_mac[0], tb_udp_frame.dest_mac[1], tb_udp_frame.dest_mac[2], tb_udp_frame.dest_mac[3], tb_udp_frame.dest_mac[4], tb_udp_frame.dest_mac[5]);
//        $display("EthType: %h%h", tb_udp_frame.eth_type[0], tb_udp_frame.eth_type[1]);
//        for (i=0; i<MTU_BYTES; i+=2) $display("Data: %h%h", tb_udp_frame.payload[i], tb_udp_frame.payload[i+1]);
    end
    
    /*
     * 
     * CLOCK GENERATION
     * 
     */
    
    initial begin
        forever #4ns i_rxmac_clk = ~i_rxmac_clk;
    end
    
    int unsigned vlan_err_cnt = 0;
    int unsigned crc_err_cnt = 0;
    int unsigned ipg_err_cnt = 0;
    int unsigned short_frame_err_cnt = 0;
    int unsigned long_frame_err_cnt = 0;
    
    always @(posedge i_rxmac_clk) begin
        if (o_eth_frame_vlan_error) vlan_err_cnt++;
        if (o_eth_frame_crc_error) crc_err_cnt++;
        if (o_eth_frame_ipg_error) ipg_err_cnt++;
        if (o_eth_frame_short_frame_error) short_frame_err_cnt++;
        if (o_eth_frame_long_frame_error) long_frame_err_cnt++;
    end
    
    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        int unsigned i;

        @(posedge i_rxmac_clk);
        i_ipv4_pkt_byte_rd <= 0;
        i_arp_pkt_byte_rd  <= 0;
        i_rxmac_srst       <= 1; // need reset here so we can reset DUT after triggering an error condition
        for (i=0; i < 100; i++) begin
            @(posedge i_rxmac_clk);
        end
        i_rxmac_srst <= 0;
        @(negedge i_rxmac_srst);
        for (i=0; i<100; i++) @(posedge i_rxmac_clk);
        
        // TEST 1: CBUF OVERFLOW DUE TO UDP PACKETS
        
        for (i=0; i<TB_NUM_UDP_PKTS_FOR_OVERFLOW; i++) begin
            emit_gbit_mac_frame (0,0,0,0,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
        end
        
        if (~o_eth_frame_circ_buf_overflow) begin
            err_report_cnt++;
            $error("Error!  DUT did not correctly assert circular buffer overflow flag.");
        end
        
        @(posedge i_rxmac_clk);
        i_rxmac_srst       <= 1; 
        for (i=0; i < 100; i++) begin
            @(posedge i_rxmac_clk);
        end
        i_rxmac_srst <= 0;

        for (i=0; i<1000; i++) @(posedge i_rxmac_clk);
        
        // TEST 2: CBUF OVERFLOW DUE TO ARP PACKETS
        
        // TODO: IMPLEMENT THIS (DON'T FORGET TO RESET THE DUT AFTERWARDS)
        
        // TEST 3: TEST ETHERNET FRAME ERRORS OF INTEREST THAT COULD POSSIBLY COME FROM THE ETHERNET MAC
        
        emit_gbit_mac_frame (1,0,0,0,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
        if (!vlan_err_cnt) begin $error ("Error! DUT failed to asser vlan error flag in response to vlan error status from MAC"); err_report_cnt++; end
        emit_gbit_mac_frame (0,1,0,0,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
        if (!crc_err_cnt) begin $error ("Error! DUT failed to asser crc error flag in response to crc error status from MAC"); err_report_cnt++; end
        emit_gbit_mac_frame (0,0,1,0,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector); // note: ipg violation doesn't result in ignoring the packet
        if (!ipg_err_cnt) begin $error ("Error! DUT failed to asser ipg error flag in response to ipg error status from MAC"); err_report_cnt++; end
        emit_gbit_mac_frame (0,0,0,1,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
        if (!short_frame_err_cnt) begin $error ("Error! DUT failed to asser short frame error flag in response to short frame error status from MAC"); err_report_cnt++; end
        emit_gbit_mac_frame (0,0,0,0,1, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
        if (!long_frame_err_cnt) begin $error ("Error! DUT failed to asser long frame error flag in response to long frame error status from MAC"); err_report_cnt++; end

        for (i=0; i < 1000; i++) @(posedge i_rxmac_clk);
        
        // TEST 4: UNSUPPORTED ETHTYPE

        emit_gbit_mac_frame (0,0,0,0,0, IPG_BYTES, tb_unsupported_ethtype_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);

        for (i=0; i<1000; i++) @(posedge i_rxmac_clk);
        
        // TEST 5: PAUSING FOR FIFO AFULL AND THEN RESUMING

        for (i=0; i<TB_NUM_UDP_PKTS_FOR_OVERFLOW; i++) begin
            emit_gbit_mac_frame (0,0,0,0,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
            if (DUT.ipv4_pkt_fifo_afull) begin
                emit_gbit_mac_frame (0,0,0,0,0, IPG_BYTES, tb_udp_frame, i_rxmac_clk, i_rx_write, i_rx_dbout, i_rx_eof, i_rx_error, i_rx_stat_en, i_rx_stat_vector);
                i_ipv4_pkt_byte_rd <= 1;
            end
        end
        
        for (i=0; i<100000; i++) @(posedge i_rxmac_clk);
        
        if ((err_report_cnt != 0) || (ipv4_pkt_err_cnt != 0) || (arp_pkt_err_cnt != 0)) begin
            $error("DUT testing failed with %d reporting errors, %d IPv4 packet errors, and %d ARP packet errors!", err_report_cnt, ipv4_pkt_err_cnt, arp_pkt_err_cnt);
            $display("<<<TB_FAILURE>>>");
        end else begin
            $display("<<<TB_SUCCESS>>>");
        end
        
        $finish();
    end
    
    // captures and validates IPv4 packets from the DUT 
    initial begin
        int unsigned i = 0;
        int unsigned j = 0;
        byte ipv4_pkt [];
        
        forever begin
            @(posedge i_rxmac_clk);
            if (o_ipv4_pkt_byte_vld & i_ipv4_pkt_byte_rd) begin
                ipv4_pkt_cap_buf[i] = o_ipv4_pkt_byte;
                i++;
                
                if (o_ipv4_pkt_last_byte) begin
                    ipv4_pkt = new[i];
                    for (j=0; j<i; j++) begin ipv4_pkt[j] = ipv4_pkt_cap_buf[j]; end
                    if (check_ipv4_pkt(ipv4_pkt)) ipv4_pkt_err_cnt++;
                    i = 0;
                end
            end
        end
    end


    eth_frame_router #(
        .CBUF_MAX_ETH_FRAME_DEPTH(TB_CBUF_ETH_FRAME_DEPTH), 
        .IPV4_PKT_FIFO_PKT_DEPTH(TB_IPV4_PKT_FIFO_PKT_DEPTH), 
        .ARP_PKT_FIFO_PKT_DEPTH(TB_ARP_PKT_FIFO_PKT_DEPTH),
        .SIM_MODE(1)
    ) DUT (.*);

endmodule


