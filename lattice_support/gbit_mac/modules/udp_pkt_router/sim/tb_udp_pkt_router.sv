/*
 * Module: tb_udp_pkt_router
 * 
 * TODO: Add module documentation
 */
 
`include "ethernet_support_pkg.sv"
 
module tb_udp_pkt_router;
    
    localparam                           TB_NUM_PORTS = 3;
    localparam [0:TB_NUM_PORTS-1] [15:0] TB_PORTS     = {16'd10000, 16'd12000, 16'd14000};
    localparam                    [15:0] TB_SRC_PORT  = 16'd1;
    localparam                    [15:0] TB_X_PORT    = 16'd2; // make sure this isn't listed int TB_PORTS anywhere
    
    /* DUT SIGNALS */

    logic                          i_rxmac_clk;
    logic                          i_rxmac_srst; 
    logic [0:TB_NUM_PORTS-1]       o_port_last_byte; 
    logic [0:TB_NUM_PORTS-1]       o_port_byte_vld;
    logic [0:TB_NUM_PORTS-1] [7:0] o_port_byte; 
    logic [0:TB_NUM_PORTS-1]       i_port_byte_rd = '0;
    logic                    [7:0] i_udp_pkt_byte;
    logic                          i_udp_pkt_byte_vld = 0;
    logic                          i_udp_pkt_last_byte = 0;
    logic                          o_udp_pkt_byte_rd;
    logic [TB_NUM_PORTS-1:0]       o_port_fifo_overflow;
    logic                          o_unsupported_dest_port;

    
    /* TEST BENCH SIGNALS */    

    byte payload_data [UDP_PAYLOAD_MAX_BYTES];
    byte payload_dword [4] = '{8'haa, 8'hbb, 8'hcc, 8'hdd};
    UDP_PKT_T udp_pkt_port_0;
    UDP_PKT_T udp_pkt_port_1;
    UDP_PKT_T udp_pkt_port_2;
    UDP_PKT_T udp_pkt_port_x; // invalid port packet
    UDP_PKT_T udp_pkt_port_hdr; // header only

    byte port_0_data_cap [$size(payload_data)];
    byte port_1_data_cap [$size(payload_data)];
    byte port_2_data_cap [$size(payload_dword)];
    
    int unsigned port_0_data_cap_err;
    int unsigned port_1_data_cap_err;
    int unsigned port_2_data_cap_err;

    int unsigned dest_port_err_cnt = 0;

    
    /* 
     * 
     * TASKS 
     * 
     */

    /*
     * Mimics the emission of a of a UDP packet from the IPv4 packet router
     */
    task emit_udp_pkt (UDP_PKT_T pkt);
    
        int unsigned i;
        int unsigned TOT_PKT_BYTES; 
        byte data [];
        
        TOT_PKT_BYTES = $size(pkt.payload) + 8; // + 8 for UDP header
            
        data = new[TOT_PKT_BYTES];

        assert ($size(pkt.payload) <= UDP_PAYLOAD_MAX_BYTES) else $fatal(0, "Error! UDP payload exceeds maximum size.  Payload bytes %d, Max Size %d", $size(pkt.payload), UDP_PAYLOAD_MAX_BYTES);
        
        // copy packet into data byte array
        data[0:7] = '{pkt.src_port[0], pkt.src_port[1], pkt.dest_port[0], pkt.dest_port[1], pkt.length[0], pkt.length[1], pkt.checksum[0], pkt.checksum[1]};
        for (i=0; i<$size(pkt.payload); i++) begin
            data[i+8] = pkt.payload[i];
        end

        @(posedge i_rxmac_clk);
        @(posedge i_rxmac_clk);
        @(posedge i_rxmac_clk);
        
        // emit packet (mimic first-word-fall-through operation)
        i = 0;
        @(posedge i_rxmac_clk);
        i_udp_pkt_byte_vld  <= 1;
        i_udp_pkt_byte      <= data[i];
        i_udp_pkt_last_byte <= 0;
        while (i < TOT_PKT_BYTES) begin
            @(posedge i_rxmac_clk);
            if (o_udp_pkt_byte_rd) begin
                i++;
                if (~i_udp_pkt_last_byte) begin
                    i_udp_pkt_byte <= data[i];
                    if (i == TOT_PKT_BYTES-1) begin
                        i_udp_pkt_last_byte <= 1;
                    end
                end else begin
                    i_udp_pkt_byte_vld  <= 0;
                    i_udp_pkt_last_byte <= 0;
                end
            end 
        end
        
    endtask


    /*
     * PORT INDEX 0 DATA OUTPUT CAPTURE AND CHECK
     */
    
    initial begin
        int unsigned i = 0;
        port_0_data_cap_err = 0;
        forever begin
            @(posedge i_rxmac_clk);
            if (i_port_byte_rd[0] & o_port_byte_vld[0]) begin
                port_0_data_cap[i] = o_port_byte[0];
                i++;
                if (o_port_last_byte[0]) begin
                    if (i != $size(payload_data)) begin
                        port_0_data_cap_err++;
                        $error("Error! Captured UDP payload from UDP port index 0 was too small");
                    end else begin
                        for (int j=0; j<i; j++) begin
                            if (port_0_data_cap[j] != payload_data[j]) begin
                                $error("Error! Captured UDP payload byte 0x%h from UDP port index 0 doesn't match expected payload byte 0x%h", port_0_data_cap[j], payload_data[j]);
                                port_0_data_cap_err++;
                            end
                        end
                    end
                    i = 0;
                end
            end
        end
    end
    

    /*
     * PORT INDEX 1 DATA OUTPUT CAPTURE AND CHECK
     */
    
    initial begin
        int unsigned i = 0;
        port_1_data_cap_err = 0;
        forever begin
            @(posedge i_rxmac_clk);
            if (i_port_byte_rd[1] & o_port_byte_vld[1]) begin
                port_1_data_cap[i] = o_port_byte[1];
                i++;
                if (o_port_last_byte[1]) begin
                    if (i != $size(payload_data)) begin
                        port_1_data_cap_err++;
                        $error("Error! Captured UDP payload from UDP port index 1 was too small");
                    end else begin
                        for (int j=0; j<i; j++) begin
                            if (port_1_data_cap[j] != payload_data[j]) begin
                                $error("Error! Captured UDP payload byte 0x%h from UDP port index 1 doesn't match expected payload byte 0x%h", port_1_data_cap[j], payload_data[j]);
                                port_1_data_cap_err++;
                            end
                        end
                    end
                    i = 0;
                end
            end
        end
    end


    /*
     * PORT INDEX 2 DATA OUTPUT CAPTURE AND CHECK
     */
    
    initial begin
        int unsigned i = 0;
        port_2_data_cap_err = 0;
        forever begin
            @(posedge i_rxmac_clk);
            if (i_port_byte_rd[2] & o_port_byte_vld[2]) begin
                port_2_data_cap[i] = o_port_byte[2];
                i++;
                if (o_port_last_byte[2]) begin
                    if (i != $size(payload_dword)) begin
                        port_2_data_cap_err++;
                        $error("Error! Captured UDP payload from UDP port index 2 was too small");
                    end else begin
                        for (int j=0; j<i; j++) begin
                            if (port_2_data_cap[j] != payload_dword[j]) begin
                                $error("Error! Captured UDP payload byte 0x%h from UDP port index 2 doesn't match expected payload byte 0x%h", port_2_data_cap[j], payload_data[j]);
                                port_2_data_cap_err++;
                            end
                        end
                    end
                    i = 0;
                end
            end
        end
    end
    
    /*
     * 
     * UDP PACKET CREATION 
     * 
     */
     
     
     initial begin
         for (int unsigned i=1; i<=($size(payload_data)); i++) begin
             payload_data[i-1] = 8'(i);      
         end
         udp_pkt_port_0   = create_udp_pkt(.src_port(TB_SRC_PORT), .dest_port(TB_PORTS[0]), .payload(payload_data));
         udp_pkt_port_1   = create_udp_pkt(.src_port(TB_SRC_PORT), .dest_port(TB_PORTS[1]), .payload(payload_data));
         udp_pkt_port_2   = create_udp_pkt(.src_port(TB_SRC_PORT), .dest_port(TB_PORTS[2]), .payload(payload_dword));
         udp_pkt_port_hdr = create_udp_pkt(.src_port(TB_SRC_PORT), .dest_port(TB_PORTS[2]), .payload('{}));
         udp_pkt_port_x   = create_udp_pkt(.src_port(TB_SRC_PORT), .dest_port(TB_X_PORT),   .payload(payload_data));
     end
     
         
    
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
        int i;
        @(posedge i_rxmac_clk);
        i_rxmac_srst = 1;
        repeat (100) @(posedge i_rxmac_clk);
        i_rxmac_srst = 0;
    end
    
    /*
     * 
     * ERROR REPORTING COUNTING
     * 
     */
    
    always @(posedge i_rxmac_clk) begin
        if (o_unsupported_dest_port) begin
            dest_port_err_cnt++;
        end
    end
    

    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin

        
        @(negedge i_rxmac_srst);
        repeat (100) @(posedge i_rxmac_clk);

        // TEST 1: BACK-TO-BACK UDP TO PORT INDEX 0
        emit_udp_pkt(udp_pkt_port_0);
        
        @(posedge i_rxmac_clk);
        i_port_byte_rd[0] <= 1;

        emit_udp_pkt(udp_pkt_port_0);

        repeat (10) @(posedge i_rxmac_clk);

        // TEST 2: PADDED UDP TO PORT INDEX 2
        emit_udp_pkt(udp_pkt_port_2);

        @(posedge i_rxmac_clk);
        i_port_byte_rd[2] <= 1;

        repeat (10) @(posedge i_rxmac_clk);

        // TEST 3: HEADER ONLY UDP TO PORT INDEX 2
        emit_udp_pkt(udp_pkt_port_hdr);

        repeat (10) @(posedge i_rxmac_clk);

        // TEST 4: BACK-TO-BACK UDP TO PORT INDEX 1
        emit_udp_pkt(udp_pkt_port_1);

        @(posedge i_rxmac_clk);
        i_port_byte_rd[1] <= 1;

        emit_udp_pkt(udp_pkt_port_1);

        repeat (10) @(posedge i_rxmac_clk);

        // TEST 5: BACK-TO-BACK UDP TO INVALID PORT
        emit_udp_pkt(udp_pkt_port_x);
        emit_udp_pkt(udp_pkt_port_x);

        repeat (10000) @(posedge i_rxmac_clk);
    
        if (dest_port_err_cnt != 2) begin 
            $error("Error!  DUT failed to report invalid UDP port");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end
        if (port_0_data_cap_err != 0) begin 
            $error("Error!  DUT failed to send all Port 0 payload bytes");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end 
        if (port_1_data_cap_err != 0) begin 
            $error("Error!  DUT failed to send all Port 1 payload bytes");
            $display("<<<TB_FAILURE>>>");
            $finish();
        end 

        $display("<<<TB_SUCCESS>>>");
        $finish();
    end
     
    udp_pkt_router #(.P_NUM_PORTS(TB_NUM_PORTS), .P_PORTS(TB_PORTS), .SIM_MODE(1'b1)) DUT (.*);

endmodule


