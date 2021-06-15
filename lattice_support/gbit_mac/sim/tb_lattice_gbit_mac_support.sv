/*
 * Module: tb_lattice_gbit_mac_support 
 * 
 * Top level simulation of Lattice Gbit MAC Support blocks operating in cascade.
 * 
 * NOTE: THIS TEST BENCH MAINLY FOCUSES ON STANDARD OPERATION.  MODULE STRESS TESTING AND CORNER CASE HANDLING IS DONE IN THE PER MODULE SIMULATIONS/TEST BENCHES.
 * 
 */
 
`include "ethernet_support_pkg.sv"
 
module tb_lattice_gbit_mac_support;

    localparam                    [15:0] TB_SRC_PORT  = 16'd50001;
    localparam                    [47:0] TB_SRC_MAC   = {8'haa, 8'haa, 8'haa, 8'haa, 8'haa, 8'haa};
    localparam                    [31:0] TB_SRC_IP    = {8'hcc, 8'hcc, 8'hcc, 8'hcc};
    localparam                    [47:0] TB_DEST_MAC  = {8'hbb, 8'hbb, 8'hbb, 8'hbb, 8'hbb, 8'hbb};
    localparam                    [31:0] TB_DEST_IP   = {8'hdd, 8'hdd, 8'hdd, 8'hdd};
    localparam                           TB_UDP_NUM_PORTS = 2;
    localparam [0:TB_UDP_NUM_PORTS-1] [15:0] TB_UDP_PORTS     = {16'd50000, 16'd60000}; // use 0 for DAC data, 1 for CMD and CTRL
    
    /* DUT SIGNALS */

    /* LATTICE Gbit ETH MAC RX INTERFACE */
    logic        i_rxmac_clk = 0;
    logic        i_rxmac_srst = 0; 
    logic        i_rx_write = 0;
    logic        i_rx_eof = 0;
    logic        i_rx_error = 0;
    logic [ 7:0] i_rx_dbout = 0;
    logic        i_rx_stat_en = 0;
    logic [31:0] i_rx_stat_vector = 0;

    /* DAC FIFO INTERFACES */

    logic        i_sys_clk = 0;
    logic        i_sys_srst = 0;
    logic        i_dac_data_rd = 0;
    logic        o_dac_data_parity;
    logic [31:0] o_dac_data;

    /* ERROR REPORTING */

    // IF ANY OF THESE ERRORS OCCUR YOU'LL NEED TO RESET THIS MODULE TO RECOVER AND CLEAR THE ERROR
    logic                   o_eth_frame_circ_buf_overflow; 
    logic                   o_ipv4_pkt_fifo_overflow;
    logic                   o_arp_pkt_fifo_overflow;
    logic                   o_udp_pkt_fifo_overflow;
    logic                   o_icmp_pkt_fifo_overflow;
    logic [TB_UDP_NUM_PORTS-1:0] o_port_fifo_overflow;
    // THESE ERROR STATUS SIGNALS GET ASSERTED FOR ONE CLOCK IF THEIR RESPECTIVE ERROR OCCURS.  YOU NEED EXTERNAL LOGIC TO KEEP TRACK OF THESE ERRORS IF DESIRED.
    logic                   o_eth_frame_long_frame_error;
    logic                   o_eth_frame_short_frame_error;
    logic                   o_eth_frame_ipg_error;
    logic                   o_eth_frame_crc_error;
    logic                   o_eth_frame_vlan_error;
    logic                   o_unsupported_eth_type_error;
    logic                   o_unsupported_ipv4_protocol;
    logic                   o_unsupported_dest_port;
    logic                   o_dac_fifo_overflow;
    logic                   o_dac_fifo_underflow;
    logic                   o_udp_seq_num_error;
 
    
    /* TEST BENCH SIGNALS */    
    
    ETH_II_FRAME_T DAC_DATA_ETH_FRAME;
    ETH_II_FRAME_T CMD_CTRL_ETH_FRAME;
    
    /*
     * 
     * DATA GENERATION
     * 
     */
    
//    initial begin
//        
//        byte dac_data [UDP_PAYLOAD_MAX_BYTES];
//        byte cmd_ctrl_data [11]; // 11 bytes = Seq. Number (2 bytes) + Message ID (1 byte) + Address (4 bytes) + Data (4 bytes)
//        
//        for (int i=0; i<UDP_PAYLOAD_MAX_BYTES; i++) begin
//            dac_data[i] = byte'(i);
//            if (i<11) begin
//                cmd_ctrl_data[i] = byte'(i);
//            end
//        end
//        
//        DAC_DATA_ETH_FRAME = create_ipv4_udp_frame(
//                .dest_mac (TB_DEST_MAC), .dest_ip(TB_DEST_IP), .dest_port (TB_UDP_PORTS[0]),
//                .src_mac  (TB_SRC_MAC),  .src_ip (TB_SRC_IP),  .src_port  (TB_SRC_PORT),
//                .data     (dac_data));
//
//        CMD_CTRL_ETH_FRAME = create_ipv4_udp_frame(
//                .dest_mac (TB_DEST_MAC), .dest_ip(TB_DEST_IP), .dest_port (TB_UDP_PORTS[1]),
//                .src_mac  (TB_SRC_MAC),  .src_ip (TB_SRC_IP),  .src_port  (TB_SRC_PORT),
//                .data     (cmd_ctrl_data));
//        
//    end
        
    
    /*
     * 
     * CLOCK & RESET GENERATION
     * 
     * NOTE: I GENERATE RESET SEPARATELY FROM THE STIMULUS IN THIS CASE SINCE I DON'T CURRENTLY DO ANYTHING THAT WOULD CAUSE A FATAL ERROR IN ANY OF THE MODULES.
     *       FATAL ERROR TESTING HAPPENS IN THE INDIVIDUAL MODULE SIMULATIONS.
     * 
     */
    
    initial begin
        forever #4ns i_rxmac_clk = ~i_rxmac_clk;
    end

    initial begin
        forever #4ns i_sys_clk = ~i_sys_clk;
    end
    
    initial begin
        @(posedge i_rxmac_clk);
        i_rxmac_srst <= 1;
        repeat (100) @(posedge i_rxmac_clk);
        i_rxmac_srst <= 0;
    end
    
    initial begin
        @(posedge i_sys_clk);
        i_sys_srst <= 1;
        repeat (100) @(posedge i_sys_clk);
        i_sys_srst <= 0;
    end
    
    /*
     * 
     * ERROR MONITORING AND REPORTING
     * 
     */
    
    int unsigned vlan_err_cnt = 0;
    int unsigned crc_err_cnt = 0;
    int unsigned ipg_err_cnt = 0;
    int unsigned short_frame_err_cnt = 0;
    int unsigned long_frame_err_cnt = 0;
    int unsigned unsupported_eth_type_err_cnt = 0;
    int unsigned unsupported_ipv4_proto_cnt = 0;
    int unsigned unsupported_dest_port_cnt = 0;
    int unsigned dac_fifo_overflow_cnt = 0;
    int unsigned dac_fifo_underflow_cnt = 0;
    int unsigned udp_seq_num_error_cnt = 0;
    
    always @(posedge i_rxmac_clk) begin
        // fatal errors, should never occur
        if (o_eth_frame_circ_buf_overflow) $fatal(0, "Ethernet Frame Router Circular Buffer overflow ocurred");
        if (o_ipv4_pkt_fifo_overflow)      $fatal(0, "IPv4 Packet FIFO overflow ocurred");
        if (o_arp_pkt_fifo_overflow)       $fatal(0, "ARP Packet FIFO overflow ocurred");
        if (o_udp_pkt_fifo_overflow)       $fatal(0, "UDP Packet FIFO overflow ocurred");
        if (o_icmp_pkt_fifo_overflow)      $fatal(0, "ICMP Packet FIFO overflow ocurred");
        if (|o_port_fifo_overflow)         $fatal(0, "UDP Port FIFO overflow ocurred");
        if (o_dac_fifo_overflow)           $fatal(0, "DAC Data FIFO overflow ocurred");

    
        // non-fatal errors, just count and print a message
        if (o_eth_frame_vlan_error)        begin $error("VLAN error reported by DUT"); vlan_err_cnt++; end
        if (o_eth_frame_crc_error)         begin $error("CRC error reported by DUT"); crc_err_cnt++; end
        if (o_eth_frame_ipg_error)         begin $error("IPG error reported by DUT"); ipg_err_cnt++; end
        if (o_eth_frame_short_frame_error) begin $error("Short Frame error reported by DUT"); short_frame_err_cnt++; end
        if (o_eth_frame_long_frame_error)  begin $error("Long Frame error reported by DUT"); long_frame_err_cnt++; end
        if (o_unsupported_eth_type_error)  begin $error("Unsupported EtherType reported by DUT"); unsupported_eth_type_err_cnt++; end
        if (o_unsupported_ipv4_protocol)   begin $error("Unsupported IPv4 Protocol reported by DUT"); unsupported_ipv4_proto_cnt++; end
        if (o_unsupported_dest_port)       begin $error("Unsupported UDP Port reported by DUT"); unsupported_dest_port_cnt++; end
    end
    
    always @(posedge i_sys_clk) begin
        if (o_dac_fifo_underflow)          begin $error("DAC Data FIFO underflow reported by DUT"); dac_fifo_underflow_cnt++; end
        if (o_udp_seq_num_error)           begin $error("DAC Data FIFO reported UDP sequence number error"); udp_seq_num_error_cnt++; end
    end
    
    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        
        byte dac_data[UDP_PAYLOAD_MAX_BYTES];
        bit [31:0] seq_num = 0;
        
        @(negedge i_rxmac_srst);
        
        repeat (100) @(posedge i_rxmac_clk);
        
        DUT_RX.i_port_byte_rd[1] <= 1; // temporary until we add cmd and ctrl port processing modules
        
        // emit DAC data at some rate

            // make new data
//            dac_data[0:3] = '{seq_num[31:24], seq_num[23:16], seq_num[15:8], seq_num[7:0]};
//            for (bit [31:0] i=0; i<UDP_PAYLOAD_MAX_BYTES/4; i++) begin
//                dac_data[(i*4+4)] = i[31:24];
//                dac_data[(i*4+5)] = i[23:16];
//                dac_data[(i*4+6)] = i[15:8];
//                dac_data[(i*4+7)] = i[7:0];
//            end
//            seq_num++;
        
        repeat (10) begin
            
            // make new data
            dac_data[0:3] = '{seq_num[31:24], seq_num[23:16], seq_num[15:8], seq_num[7:0]};
            for (int i=4; i<UDP_PAYLOAD_MAX_BYTES; i++) begin
                dac_data[i] = byte'(i-4);
            end
            seq_num++;

            DAC_DATA_ETH_FRAME = create_ipv4_udp_frame(
                    .dest_mac (TB_DEST_MAC), .dest_ip(TB_DEST_IP), .dest_port (TB_UDP_PORTS[0]),
                    .src_mac  (TB_SRC_MAC),  .src_ip (TB_SRC_IP),  .src_port  (TB_SRC_PORT),
                    .data     (dac_data));
            
            emit_gbit_mac_frame(
                .frame          (DAC_DATA_ETH_FRAME), 
                .rxmac_clk      (i_rxmac_clk), 
                .rx_write       (i_rx_write), 
                .rx_dbout       (i_rx_dbout), 
                .rx_eof         (i_rx_eof), 
                .rx_error       (i_rx_error), 
                .rx_stat_en     (i_rx_stat_en), 
                .rx_stat_vector (i_rx_stat_vector));
            
            repeat (458750) @(posedge i_rxmac_clk); // this gap per packet results in100K 32-bit samples per second
//            repeat (459750) @(posedge i_rxmac_clk); // this gap per packet results in100K 32-bit samples per second
        end

//        repeat (50) begin
//            emit_gbit_mac_frame(
//                .frame          (CMD_CTRL_ETH_FRAME), 
//                .rxmac_clk      (i_rxmac_clk), 
//                .rx_write       (i_rx_write), 
//                .rx_dbout       (i_rx_dbout), 
//                .rx_eof         (i_rx_eof), 
//                .rx_error       (i_rx_error), 
//                .rx_stat_en     (i_rx_stat_en), 
//                .rx_stat_vector (i_rx_stat_vector)
//            );
//
//            emit_gbit_mac_frame(
//                .frame          (DAC_DATA_ETH_FRAME), 
//                .rxmac_clk      (i_rxmac_clk), 
//                .rx_write       (i_rx_write), 
//                .rx_dbout       (i_rx_dbout), 
//                .rx_eof         (i_rx_eof), 
//                .rx_error       (i_rx_error), 
//                .rx_stat_en     (i_rx_stat_en), 
//                .rx_stat_vector (i_rx_stat_vector)
//            );
//            
//        end
        
        repeat (100000) @(posedge i_rxmac_clk);
        $display("<<<TB_SUCCESS>>>");
        $finish();
    end
    
    // consume dac data at a specified rate
    initial begin
        @(negedge i_sys_srst);
        
        while (~DUT_RX.eth_dac_data_rx.dac_data_vld_pipe_2) begin
            @(posedge i_sys_clk);
        end
        
        forever begin
            @(posedge i_sys_clk);
            i_dac_data_rd <= 1;
            @(posedge i_sys_clk);
            i_dac_data_rd <= 0;
            repeat (1248) @(posedge i_sys_clk);
        end
    end
    
    lattice_gbit_mac_rx_support_wrapper #(.P_NUM_PORTS(TB_UDP_NUM_PORTS), .P_PORTS(TB_UDP_PORTS)) DUT_RX (.*);

endmodule


