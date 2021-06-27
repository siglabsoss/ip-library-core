
`timescale 1s / 100ps // delay value specified in seconds with 100 ps resolution

module tb_fmc_slave;

    localparam real    SYS_CLK_T_SECS   = 9.23e-9; // system clock period (seconds)
    localparam real    HCLK_T_SECS      = 62.5e-9;  // STM32F microcontroller clock period (seconds)
    localparam integer ADDR_SETUP_HCLKS = 15;    // number of hclks to use for fmc address setup time (valid range = 0 to 15)
    localparam integer DATA_SETUP_HCLKS = 15;    // number of hclks to use for fmc data setup time (valid range = 4 to 256 (4 is min to allow for nwait detection by stm32f))
    localparam integer BUS_TURN_HCLKS   = 15;    // number of hclks to use for fmc bus turnaround time (valid range = 0 to 15)

    localparam real ADDR_SETUP_TIME         = HCLK_T_SECS * ADDR_SETUP_HCLKS;
    localparam real DATA_SETUP_TIME         = HCLK_T_SECS * DATA_SETUP_HCLKS;
    localparam real BUS_TURN_TIME           = HCLK_T_SECS * BUS_TURN_HCLKS;

    // These localparam values were determined from logic analyzer observation of the Nucleo-F767ZI eval board's FMC interface.  Not sure how universal they are.
    localparam real FMC_TRANS_TO_TRANS_SECS = 1e-6;   // duration between FMC bus transactions 
    localparam real OUT_EN_PULSE_SECS       = 50e-9;  // duration that FMC de-asserts output enable before re-asserting it for second read data phase 
    localparam real WR_EN_PULSE_SECS        = 100e-9; // duration that FMC de-asserts write enable before re-asserting it for second write data phase

    task fmc_write (input [25:0] waddr, input [31:0] wdata); 

        // Since the fmc interface is wired for 16-bit data it takes 2 fmc write transactions per 32-bit write.
        // The FMC interface does NOT de-assert the chip select/enable in between write transactions, but rather de-asserts and re-asserts the write enable signal. 

        $display("FMC WRITE (ADDR = 0x%h, DATA = 0x%h)", waddr, wdata);

        /* cycle 1 */
        tb_fmc_a = waddr[25:1]; tb_fmc_ne1 = 1'b0; tb_fmc_noe = 1'b1;
        #ADDR_SETUP_TIME;
        tb_fmc_master_oe = 1'b1; tb_fmc_nwe = 1'b0; tb_fmc_master_d_reg = wdata[15:0]; // little endian
        #DATA_SETUP_TIME;
        if (tb_fmc_nwait == 1'b0) begin
            wait (tb_fmc_nwait); // delay extra time in slave is asserting nwait
            #(4*HCLK_T_SECS);
        end
        tb_fmc_nwe = 1'b1; tb_fmc_master_oe = 1'b0; // keep chip select/enable asserted between write data phases and only pulse write enable
        #WR_EN_PULSE_SECS;

        /* cycle 2 */
        tb_fmc_a = waddr[25:1] + 1; tb_fmc_ne1 = 1'b0; tb_fmc_noe = 1'b1;
        #ADDR_SETUP_TIME;
        tb_fmc_master_oe = 1'b1; tb_fmc_nwe = 1'b0; tb_fmc_master_d_reg = wdata[31:16]; // little endian
        #DATA_SETUP_TIME;
        if (tb_fmc_nwait == 1'b0) begin
            wait (tb_fmc_nwait); // delay extra time in slave is asserting nwait
            #(4*HCLK_T_SECS);
        end
        tb_fmc_ne1 = 1'b1; tb_fmc_nwe = 1'b1; tb_fmc_master_oe = 1'b0;
        #FMC_TRANS_TO_TRANS_SECS;


    endtask

    task fmc_read (input  [25:0] raddr); //, input nwait, output [25:0] a, output ne1, output noe, output nwe, input [15:0] d);

        reg [31:0] rdata;

        // Since the fmc interface is wired for 16-bit data it takes 2 fmc read transactions per 32-bit read.
        // The FMC interface does NOT de-assert the chip select/enable in between read transactions, but rather de-asserts and re-asserts the output enable signal. 

        /* cycle 1 */
        tb_fmc_a = raddr[25:1]; tb_fmc_ne1 = 1'b0; tb_fmc_nwe = 1'b1; tb_fmc_noe = 1'b0; tb_fmc_master_oe = 1'b0;
        #ADDR_SETUP_TIME;
        #DATA_SETUP_TIME;
        if (tb_fmc_nwait == 1'b0) begin
            wait (tb_fmc_nwait); // delay extra time in slave is asserting nwait
            #(4*HCLK_T_SECS);
        end
        tb_fmc_noe = 1'b1; // only de-assert output enable between read phases, keep chip select/enable asserted
        rdata[15:0] = tb_fmc_d; // little endian
        #OUT_EN_PULSE_SECS;

        /* cycle 2 */
        tb_fmc_a = raddr[25:1] + 1; tb_fmc_ne1 = 1'b0; tb_fmc_nwe = 1'b1; tb_fmc_noe = 1'b0; tb_fmc_master_oe = 1'b0;
        #ADDR_SETUP_TIME;
        #DATA_SETUP_TIME;
        if (tb_fmc_nwait == 1'b0) begin
            wait (tb_fmc_nwait); // delay extra time in slave is asserting nwait
            #(4*HCLK_T_SECS);
        end
        tb_fmc_ne1 = 1'b1; tb_fmc_noe = 1'b1;
        rdata[31:16] = tb_fmc_d; // little endian

        $display("FMC READ (ADDR = 0x%h, RDATA = 0x%h)", raddr, rdata);

        #FMC_TRANS_TO_TRANS_SECS;

    endtask

    reg         tb_sys_clk = 1'b0;
    reg         tb_sys_rst = 1'b0;
    reg         tb_cmd_ack = 1'b0;
    reg  [31:0] tb_cmd_rdata = {32{1'b0}};
    wire        tb_cmd_vld;   
    wire        tb_cmd_rd_wr_n;
    wire [25:0] tb_cmd_addr;   
    wire [31:0] tb_cmd_wdata;   
    reg  [31:0] tb_cmd_dummy_reg;

    reg  [24:0] tb_fmc_a = {25{1'b0}};
    reg  [15:0] tb_fmc_master_d_reg = {16{1'b0}};
    wire [15:0] tb_fmc_d;
    wire [15:0] tb_fmc_slave_d;
    wire        tb_fmc_slave_d_high_z;
    reg         tb_fmc_ne1 = 1'b1;
    reg         tb_fmc_noe = 1'b1;
    reg         tb_fmc_nwe = 1'b1;
    wire        tb_fmc_nwait;
    reg         tb_fmc_master_oe = 1'b0;

    reg [32*8-1:0] tb_test_stage_str;


    // system clock generation
    initial begin
        forever #(SYS_CLK_T_SECS/2.0) tb_sys_clk = ~tb_sys_clk;
    end

    /*
     *
     * FOUR TEST SCENARIOS:
     *     1. BACK-TO-BACK WRITES
     *     2. BACK-TO-BACK READS
     *     3. WRITE FOLLOWED BY READ
     *     4. READ FOLLOWED BY WRITE
     *
     */

    initial begin : STIMULUS
        #100e-9;
        // BACK-TO-BACK WRITES
        tb_test_stage_str = "WRITE-WRITE TEST";
        fmc_write(26'h0000000, 32'hdeadbeef);
        fmc_write(26'h0000004, 32'hcafebabe);
        #100e-9;
        // BACK-TO-BACK READS
        tb_test_stage_str = "READ-READ TEST";
        fmc_read(26'h0000008);
        fmc_read(26'h000000c);
        #100e-9;
        // WRITE FOLLOWED BY READ
        tb_test_stage_str = "WRITE-READ TEST";
        fmc_write(26'h0000010, 32'habcdabcd);
        fmc_read(26'h0000014);
        #100e-9;
        // READ FOLLOWED BY WRITE
        tb_test_stage_str = "READ-WRITE TEST";
        fmc_read(26'h0000018);
        fmc_write(26'h000001c, 32'ha5a5a5a5);
        #100e-9;
        $finish;
    end


    // dummy command and control module
    always @ (posedge tb_cmd_vld) begin

        // delay a few clocks before ack'ing to mimic delay from reading/writing to external fpga
        @(posedge tb_sys_clk);
        @(posedge tb_sys_clk);
        @(posedge tb_sys_clk);

        tb_cmd_ack <= 1;

        if (tb_cmd_rd_wr_n == 1) begin // read
            $display("COMMAND & CONTROL READ (ADDR: 0x%h, RDATA: 0x%h)", tb_cmd_addr, tb_cmd_dummy_reg);
            tb_cmd_rdata <= tb_cmd_dummy_reg;
        end
        else begin
            $display("COMMAND & CONTROL WRITE (ADDR: 0x%h, WDATA: 0x%h)", tb_cmd_addr, tb_cmd_wdata);
            tb_cmd_dummy_reg <= tb_cmd_wdata;
        end

        @(posedge tb_sys_clk);
        tb_cmd_ack <= 0;

    end


    assign tb_fmc_d = (tb_fmc_master_oe)       ? tb_fmc_master_d_reg : 16'bz;
    assign tb_fmc_d = (~tb_fmc_slave_d_high_z) ? tb_fmc_slave_d      : 16'bz;


    fmc_slave #(.SYS_CLK_T_SECS(SYS_CLK_T_SECS),
                .STM32F_HCLK_T_SECS(HCLK_T_SECS),
                .FMC_ADDR_SETUP_HCLKS(ADDR_SETUP_HCLKS),
                .FMC_DATA_SETUP_HCLKS(DATA_SETUP_HCLKS),
                .FMC_BUS_TURN_HCLKS(BUS_TURN_HCLKS)
               )
               DUT (.i_sys_clk(tb_sys_clk),
                    .i_sys_rst(tb_sys_rst),
                    .i_cmd_ack(tb_cmd_ack),
                    .i_cmd_rdata(tb_cmd_rdata),
                    .o_cmd_sel(tb_cmd_vld),
                    .o_cmd_rd_wr_n(tb_cmd_rd_wr_n),
                    .o_cmd_byte_addr(tb_cmd_addr),
                    .o_cmd_wdata(tb_cmd_wdata),
                    .i_fmc_a(tb_fmc_a),
                    .i_fmc_d(tb_fmc_d),
                    .o_fmc_d(tb_fmc_slave_d),
                    .o_fmc_d_high_z(tb_fmc_slave_d_high_z),
                    .i_fmc_ne1(tb_fmc_ne1),
                    .i_fmc_noe(tb_fmc_noe),
                    .i_fmc_nwe(tb_fmc_nwe),
                    .o_fmc_nwait(tb_fmc_nwait)
                  );

                  

endmodule
