
`timescale 1s / 1ns

module tb_ecp5_slave_serial_programmer;

/****** LOCAL PARAMETERS ******/

    localparam TB_CONFIG_BYTES = 8;

    localparam time T_INITL = 55e-9; // max INITN low time from ECP5 family data sheet
    localparam time T_DPPINT = 70e-9; // max PROGRAMN low to INITN low time from ECP5 family data sheet
    

/****** SIGNALS ******/


    logic       tb_clk = 0;
    logic       tb_srst = 0;

    logic       tb_start = 0;
    logic       tb_byte_vld = 0;
    logic [7:0] tb_byte = 0;
    logic       tb_byte_ack;
    logic       tb_idle;
    logic       tb_fpga_status_vld;
    logic       tb_fpga_cfg_err;
    logic       tb_fpga_programmed;
    
    logic       tb_init_n = 1;
    logic       tb_done = 1;
    logic       tb_prog_n;
    logic       tb_mclk;
    logic       tb_mclk_reg;
    logic       tb_dout_high_z;
    logic       tb_dout_high_z_reg;
    logic       tb_dout;
    logic       tb_dout_reg;

    logic       tb_fpga_ss_mclk;
    logic       tb_fpga_ss_din;

    enum {NORMAL_PROGRAM, INITN_ERR, DONE_ERR} tb_test_case;



    /* CLOCK & RESET GENERATION */

    initial begin: TB_CLOCK_GEN
        forever #5e-9 tb_clk = ~tb_clk;
    end

    integer i;
    initial begin: TB_RESET_GEN

        @(posedge tb_clk);
        tb_srst = 1;

        for (i=0; i < 100; i = i+1) begin
            @(posedge tb_clk);
        end
        tb_srst = 0;
    end

    integer tb_bytes_presented = 0;
    initial begin: TB_STIMULUS

        $printtimescale();

        tb_test_case = NORMAL_PROGRAM;

        @(negedge tb_srst);
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);

        tb_start = 1;

        @(posedge tb_clk);

        tb_start = 0;

        while (tb_bytes_presented < TB_CONFIG_BYTES) begin

            @(posedge tb_clk);
            
            tb_byte_vld = 1;
            tb_byte = tb_bytes_presented;

            @(negedge tb_byte_ack);

            tb_bytes_presented = tb_bytes_presented + 1;

        end

        @(posedge tb_clk);

        tb_byte_vld = 0;


        wait (tb_idle);

        #1e-6

        $finish;

    end


    // TODO: Implement the timing checks
    
    /* SLAVE SERIAL INTERFACE TIMING CHECKS */


    /* SLAVE SERIAL DUMMY FPGA */

    integer tb_bytes_rx = 0;
    integer tb_bits_rx = 0;
    integer tb_wake_up_clks_rx = 0;
    always @(posedge tb_fpga_ss_mclk, tb_prog_n) begin: TB_SLAVE_SERIAL_DUMMY_FPGA

        /* configuration initialization */
        if (~tb_prog_n) begin
            #T_DPPINT; 
            tb_bits_rx = 0;
            tb_bytes_rx = 0;
            tb_wake_up_clks_rx = 0;
            tb_init_n = 0;
            tb_done = 0;
        end else if (tb_prog_n & ~tb_init_n) begin
            #T_INITL;
            tb_init_n = 1;
        end else begin
            tb_bits_rx = tb_bits_rx + 1;
            if (tb_bits_rx == 8) begin
                tb_bytes_rx = tb_bytes_rx + 1;
                tb_bits_rx = 0;
            end

            if (tb_bytes_rx == TB_CONFIG_BYTES) begin
                case (tb_test_case)
    
                    NORMAL_PROGRAM: begin
                        tb_init_n = 1;
                        tb_done = 1;
                    end

                    INITN_ERR: begin
                        tb_init_n = 0;
                        tb_done = 0;
                    end

                    DONE_ERR: begin
                        tb_init_n = 1;
                        tb_done = 0;
                    end
                endcase
            end
        end
    end

    /* register & tri-state for fpga programming interface signals */
    always_ff @(posedge tb_clk) begin
        if (tb_srst) begin
            tb_mclk_reg        <= 0;
            tb_dout_high_z_reg <= 0;
            tb_dout_reg        <= 0;
        end else begin
            tb_mclk_reg        <= tb_mclk;
            tb_dout_high_z_reg <= tb_dout_high_z;
            tb_dout_reg        <= tb_dout;
        end
    end

    assign tb_fpga_ss_mclk = tb_mclk_reg;
    assign tb_fpga_ss_din  = (~tb_dout_high_z_reg) ? tb_dout_reg : 1'bz;


    /* DUT */

    ecp5_slave_serial_programmer #(.P_CONFIG_BYTES(TB_CONFIG_BYTES))  // Flash size in bytes
        DUT
        (
            /* USER INTERFACE */
            
            .i_clk(tb_clk),
            .i_srst(tb_srst),          
            .i_start(tb_start),
            .i_byte_vld(tb_byte_vld),
            .i_byte(tb_byte),
            .o_byte_ack(tb_byte_ack),
            .o_idle(tb_idle),
            .o_fpga_status_vld(tb_fpga_status_vld),
            .o_fpga_cfg_err(tb_fpga_cfg_err),
            .o_fpga_programmed(tb_fpga_programmed),
        
            /* FPGA PROGRAMMING INTERFACE */
        
            .i_init_n(tb_init_n),
            .i_done(tb_done),
            .o_mclk(tb_mclk),
            .o_prog_n(tb_prog_n),
            .o_dout_high_z(tb_dout_high_z),
            .o_dout(tb_dout)
        );


endmodule
