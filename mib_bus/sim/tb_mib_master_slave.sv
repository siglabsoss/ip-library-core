
`timescale 1s/1ns

module tb_mib_master_slave;


/****** LOCAL PARAMETERS ******/

    localparam logic [3:0] TB_SLAVE_0_MIB_MSN         = 4'h0; // MSN = Most Significant Nibble
    localparam logic [3:0] TB_SLAVE_1_MIB_MSN         = 4'h1; // MSN = Most Significant Nibble
    localparam int         TB_SLAVE_SCRATCH_MEM_DEPTH = 8;    // Number of dwords in each slave device's scratch memory (used for testing MIB reads and writes)
    localparam int         TB_MIB_ACK_TIMEOUT_CLKS    = 32;
    localparam int         TB_CMD_ACK_TIMEOUT_CLKS    = TB_MIB_ACK_TIMEOUT_CLKS/2; // CMD ACK timeout clocks should always be less than MIB ACK timeout clocks




                         
                        

/****** SIGNALS ******/

    logic        tb_clk = 0;
    logic        tb_srst = 0;
	intf_cmd tb_master();
	intf_cmd #(20,32) tb_slave_1();
	intf_cmd #(20,32) tb_slave_2();
    // logic        tb_m_cmd_sel = 0;
    // logic        tb_m_cmd_rd_wr_n = 0;
    // logic [23:0] tb_m_cmd_byte_addr = 24'd0;
    // logic [31:0] tb_m_cmd_wdata = 32'd0;
    // logic        tb_m_cmd_ack;
    // logic [31:0] tb_m_cmd_rdata;
    logic        tb_m_cmd_mib_timeout;

    logic [15:0] tb_m_mib_ad;
    logic        tb_m_mib_ad_high_z;

    /* logic        tb_s0_cmd_sel;
    logic        tb_s0_cmd_rd_wr_n;
    logic [19:0] tb_s0_cmd_byte_addr;
    logic [31:0] tb_s0_cmd_wdata;
    logic        tb_s0_cmd_ack = 0;
    logic [31:0] tb_s0_cmd_rdata = 32'd0; */

    logic        tb_s0_mib_slave_ack;
    logic        tb_s0_mib_slave_ack_high_z;
    logic [15:0] tb_s0_mib_ad;
    logic        tb_s0_mib_ad_high_z;

    logic [31:0] tb_s0_dword_mem[0:TB_SLAVE_SCRATCH_MEM_DEPTH-1];


  /*   logic        tb_s1_cmd_sel;
    logic        tb_s1_cmd_rd_wr_n;
    logic [19:0] tb_s1_cmd_byte_addr;
    logic [31:0] tb_s1_cmd_wdata;
    logic        tb_s1_cmd_ack = 0;
    logic [31:0] tb_s1_cmd_rdata = 32'd0; */

    logic        tb_s1_mib_slave_ack;
    logic        tb_s1_mib_slave_ack_high_z;
    logic [15:0] tb_s1_mib_ad;
    logic        tb_s1_mib_ad_high_z;

    logic [31:0] tb_s1_dword_mem[0:TB_SLAVE_SCRATCH_MEM_DEPTH-1];

    logic        tb_mib_start;
    logic        tb_mib_rd_wr_n;
    wire         tb_mib_slave_ack; // needs to be wire type to allow for multiple drivers
    wire  [15:0] tb_mib_ad;        // needs to be wire type to allow for multiple drivers


/****** TASK & FUNCTIONS ******/

    task cmd_bus_write (input [23:0] waddr, input [31:0] wdata);

        @(posedge tb_clk);

        tb_master.sel       = 1;
        tb_master.rd_wr_n   = 0;
        tb_master.byte_addr = waddr;
        tb_master.wdata     = wdata;

        while (1) begin
            @(posedge tb_clk);
            if (tb_master.ack) begin
                break;
            end
            else if (tb_m_cmd_mib_timeout) begin
                $display("MIB BUS WRITE TIMEOUT!");
                break;
            end
        end

        tb_master.sel = 0;

        $display("CMD BUS WRITE: ADDR = 0x%x, DATA = 0x%X", waddr, wdata);
        
    endtask

    task cmd_bus_read (input [23:0] raddr);

        @(posedge tb_clk);

        tb_master.sel       = 1;
        tb_master.rd_wr_n   = 1;
        tb_master.byte_addr = raddr;

        while (1) begin
            @(posedge tb_clk);
            if (tb_master.ack) begin
                break;
            end
            else if (tb_m_cmd_mib_timeout) begin
                $display("MIB BUS READ TIMEOUT!");
                break;
            end
        end

        tb_master.sel = 0;

        $display("CMD BUS READ: ADDR = 0x%x, DATA = 0x%X", raddr, tb_master.rdata);

    endtask

/****** TEST BENCH ******/

    /* CLOCK & RESET GENERATION */

    initial begin: TB_CLOCK_GEN
        forever #5e-9 tb_clk = ~tb_clk;
    end

    initial begin: TB_RESET_GEN

        int i;

        @(posedge tb_clk);
        tb_srst = 1;

        for (i=0; i < 100; i = i+1) begin
            @(posedge tb_clk);
        end
        tb_srst = 0;
    end


    /* STIMULUS */

    /*
     * Tests:
     *
     * WRITE-TO-WRITE
     * READ-TO-READ
     * WRITE-TO-READ
     * READ-TO-WRITE
     * WRITE TIMEOUT
     * READ TIMEOUT
     */
    initial begin: TB_STIMULUS

        @(negedge tb_srst);
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);

        /* write-to-write */

        $display("MIB S0 WRITE-TO-WRITE");
        cmd_bus_write({TB_SLAVE_0_MIB_MSN, 20'h00000}, 32'h01010202);
        cmd_bus_write({TB_SLAVE_0_MIB_MSN, 20'h00004}, 32'h03030404);

        $display("MIB S1 WRITE-TO-WRITE");
        cmd_bus_write({TB_SLAVE_1_MIB_MSN, 20'h00000}, 32'h11111212);
        cmd_bus_write({TB_SLAVE_1_MIB_MSN, 20'h00004}, 32'h13131414);         

        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);

        /* read-to-read */

        $display("MIB S0 READ-TO-READ");
        cmd_bus_read({TB_SLAVE_0_MIB_MSN, 20'h00000});
        cmd_bus_read({TB_SLAVE_0_MIB_MSN, 20'h00004});

        $display("MIB S1 READ-TO-READ");
        cmd_bus_read({TB_SLAVE_1_MIB_MSN, 20'h00000});
        cmd_bus_read({TB_SLAVE_1_MIB_MSN, 20'h00004});

        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);
        

        /* write-to-read */

        $display("MIB S0 WRITE-TO-READ");
        cmd_bus_write({TB_SLAVE_0_MIB_MSN, 20'h00000}, 32'h05050606);
        cmd_bus_read({TB_SLAVE_0_MIB_MSN, 20'h00000});

        $display("MIB S1 WRITE-TO-READ");
        cmd_bus_write({TB_SLAVE_1_MIB_MSN, 20'h00000}, 32'h15151616);
        cmd_bus_read({TB_SLAVE_1_MIB_MSN, 20'h00000});

        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);

        /* read-to-write */

        $display("MIB S0 READ-TO-WRITE");
        cmd_bus_read({TB_SLAVE_0_MIB_MSN, 20'h00004});
        cmd_bus_write({TB_SLAVE_0_MIB_MSN, 20'h00000}, 32'h07070808);

        $display("MIB S1 READ-TO-WRITE");
        cmd_bus_read({TB_SLAVE_1_MIB_MSN, 20'h00004});
        cmd_bus_write({TB_SLAVE_1_MIB_MSN, 20'h00000}, 32'h17171818);

        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);

        $display("MIB S0 WRITE TIMEOUT");
        cmd_bus_write({TB_SLAVE_0_MIB_MSN, 20'(TB_SLAVE_SCRATCH_MEM_DEPTH*4 + 1)}, 32'h09090a0a);

        for (int i=0; i < TB_MIB_ACK_TIMEOUT_CLKS; i=i+1) begin
            @(posedge tb_clk);
        end

        $display("MIB S0 READ TIMEOUT");
        cmd_bus_read({TB_SLAVE_0_MIB_MSN, 20'(TB_SLAVE_SCRATCH_MEM_DEPTH*4 + 1)});

        for (int i=0; i < TB_MIB_ACK_TIMEOUT_CLKS; i=i+1) begin
            @(posedge tb_clk);
        end

        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);


        $finish;

    end


    mib_master
    #(
      .P_MIB_ACK_TIMEOUT_CLKS(TB_MIB_ACK_TIMEOUT_CLKS)
    )
    MASTER_DUT
    (
        .i_sysclk          (tb_clk), 
        .i_srst            (tb_srst),
		.cmd_slave		   (tb_master),
        /*.i_cmd_sel         (tb_master.sel),
        .i_cmd_rd_wr_n     (tb_m_cmd_rd_wr_n),
        .i_cmd_byte_addr   (tb_m_cmd_byte_addr),
        .i_cmd_wdata       (tb_m_cmd_wdata),
        .o_cmd_ack         (tb_m_cmd_ack),
        .o_cmd_rdata       (tb_m_cmd_rdata), */
        .o_cmd_mib_timeout (tb_m_cmd_mib_timeout),

        .o_mib_start       (tb_mib_start),
        .o_mib_rd_wr_n     (tb_mib_rd_wr_n),
        .i_mib_slave_ack   (tb_mib_slave_ack),
        .o_mib_ad          (tb_m_mib_ad),
        .i_mib_ad          (tb_mib_ad),
        .o_mib_ad_high_z   (tb_m_mib_ad_high_z)
    
    );

    /* MIB master AD bus tri-state */

    assign tb_mib_ad = (~tb_m_mib_ad_high_z) ? tb_m_mib_ad : 16'bzzzz_zzzz_zzzz_zzzz;
    

    /* MIB SLAVE 0 */
    mib_slave
    #(
        .P_SLAVE_MIB_ADDR_MSN(TB_SLAVE_0_MIB_MSN),
        .P_CMD_ACK_TIMEOUT_CLKS(TB_CMD_ACK_TIMEOUT_CLKS)
    )
    SLAVE_0_DUT
    (
        .i_sysclk               (tb_clk), 
        .i_srst                 (tb_srst),
		.cmd_master				(tb_slave_1),
        /* .o_cmd_sel              (tb_s0_cmd_sel),
        .o_cmd_rd_wr_n          (tb_s0_cmd_rd_wr_n),
        .o_cmd_byte_addr        (tb_s0_cmd_byte_addr),
        .o_cmd_wdata            (tb_s0_cmd_wdata),
        .i_cmd_ack              (tb_s0_cmd_ack),
        .i_cmd_rdata            (tb_s0_cmd_rdata), */
    
        .i_mib_start            (tb_mib_start),
        .i_mib_rd_wr_n          (tb_mib_rd_wr_n),
        .o_mib_slave_ack        (tb_s0_mib_slave_ack),
        .o_mib_slave_ack_high_z (tb_s0_mib_slave_ack_high_z),
        .o_mib_ad               (tb_s0_mib_ad),
        .i_mib_ad               (tb_mib_ad),
        .o_mib_ad_high_z        (tb_s0_mib_ad_high_z)
    
    );

    /* MIB slave 0 AD and ACK tri-states */

    assign tb_mib_ad        = (~tb_s0_mib_ad_high_z)        ? tb_s0_mib_ad        : 16'bzzzz_zzzz_zzzz_zzzz;
    assign tb_mib_slave_ack = (~tb_s0_mib_slave_ack_high_z) ? tb_s0_mib_slave_ack : 1'bz;

    /* MIB slave 0 scratch memory */
    initial begin: TB_S0_MEM_INIT
        int i;
        for (i=0; i < TB_SLAVE_SCRATCH_MEM_DEPTH; i = i+1) begin
            tb_s0_dword_mem[i] = {32{1'b0}};
        end
    end

    always @(posedge tb_clk) begin: TB_S0_SCRATCH_MEM

        if (tb_srst) begin
            tb_slave_1.ack   <= 0;
            tb_slave_1.rdata <= 32'd0;
        end else begin

            /* defaults */
            tb_slave_1.ack <= 0;

            // don't respond to commands outside our scratch mem depth
            if ((tb_slave_1.sel == 1'b1) && (tb_slave_1.byte_addr < (TB_SLAVE_SCRATCH_MEM_DEPTH*4))) begin

                @(posedge tb_clk);
                @(posedge tb_clk);
                @(posedge tb_clk);
                tb_slave_1.ack   <= 1;

                if (tb_slave_1.rd_wr_n) begin // read
                    tb_slave_1.rdata <= tb_s0_dword_mem[unsigned'(tb_slave_1.byte_addr[19:2])]; // convert to dword address
                end else begin
                    tb_s0_dword_mem[unsigned'(tb_slave_1.byte_addr[19:2])] <= tb_slave_1.wdata;
                end
            end
        end
    end


    /* MIB SLAVE 1 */
    mib_slave
    #(
        .P_SLAVE_MIB_ADDR_MSN(TB_SLAVE_1_MIB_MSN),
        .P_CMD_ACK_TIMEOUT_CLKS(TB_CMD_ACK_TIMEOUT_CLKS)
    )
    SLAVE_1_DUT
    (
        .i_sysclk               (tb_clk), 
        .i_srst                 (tb_srst),
		
		.cmd_master				(tb_slave_2),
        /* .o_cmd_sel              (tb_s1_cmd_sel),
        .o_cmd_rd_wr_n          (tb_s1_cmd_rd_wr_n),
        .o_cmd_byte_addr        (tb_s1_cmd_byte_addr),
        .o_cmd_wdata            (tb_s1_cmd_wdata),
        .i_cmd_ack              (tb_s1_cmd_ack),
        .i_cmd_rdata            (tb_s1_cmd_rdata), */
    
        .i_mib_start            (tb_mib_start),
        .i_mib_rd_wr_n          (tb_mib_rd_wr_n),
        .o_mib_slave_ack        (tb_s1_mib_slave_ack),
        .o_mib_slave_ack_high_z (tb_s1_mib_slave_ack_high_z),
        .o_mib_ad               (tb_s1_mib_ad),
        .i_mib_ad               (tb_mib_ad),
        .o_mib_ad_high_z        (tb_s1_mib_ad_high_z)
    
    );

    /* MIB slave 1 AD and ACK tri-states */

    assign tb_mib_ad        = (~tb_s1_mib_ad_high_z)        ? tb_s1_mib_ad        : 16'bzzzz_zzzz_zzzz_zzzz;
    assign tb_mib_slave_ack = (~tb_s1_mib_slave_ack_high_z) ? tb_s1_mib_slave_ack : 1'bz;

    /* MIB slave 1 scratch memory */
    initial begin: TB_S1_MEM_INIT
        int i;
        for (i=0; i < TB_SLAVE_SCRATCH_MEM_DEPTH; i = i+1) begin
            tb_s1_dword_mem[i] = {32{1'b0}};
        end
    end

    always @(posedge tb_clk) begin: TB_S1_SCRATCH_MEM

        if (tb_srst) begin
            tb_slave_2.ack   <= 0;
            tb_slave_2.rdata <= 32'd0;
        end else begin

            /* defaults */
            tb_slave_2.ack   <= 0;

            // don't respond to commands outside our scratch mem depth
            if ((tb_slave_2.sel == 1'b1) && (tb_slave_2.byte_addr < (TB_SLAVE_SCRATCH_MEM_DEPTH*4))) begin
                @(posedge tb_clk);
                @(posedge tb_clk);
                @(posedge tb_clk);
                tb_slave_2.ack   <= 1;

                if (tb_slave_2.rd_wr_n) begin // read
                    tb_slave_2.rdata <= tb_s1_dword_mem[unsigned'(tb_slave_2.byte_addr[19:2])]; // convert to dword address
                end else begin
                    tb_s1_dword_mem[unsigned'(tb_slave_2.byte_addr[19:2])] <= tb_slave_2.wdata;
                end
            end
        end
    end


endmodule
