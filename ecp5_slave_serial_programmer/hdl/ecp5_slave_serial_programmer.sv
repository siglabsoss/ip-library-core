/*
 *
 * Slave serial programmer for programming lattice ECP5 in slave serial mode.
 *
 * It expects to be fed one byte at a time and will ACK each byte after it
 * shifts it out to the FPGA being programmed. 
 * 
 * It keeps track of the number of bytes it has been fed and knows when it's
 * done.
 *
 *
 */

module ecp5_slave_serial_programmer
#(
    parameter integer P_CONFIG_BYTES = 1024 // Number of bytes that constitute a full FPGA programming file (i.e. bit or mcs file)
)
(
    /* USER INTERFACE */
    
    input            i_clk,                 // NOTE: this clock should be less than or equal to 100MHz to avoid slave serial programming timing violations
    input            i_srst,                // synchronous reset
    input            i_start,               // 1 = start programming 
    input            i_byte_vld,
    input      [7:0] i_byte,
    output reg       o_byte_ack = 0,
    output reg       o_idle,                // 1 = slave serial programming fsm is idle and ready to program the FPGA
    output reg       o_fpga_status_vld = 0, // 1 = slave serial programming fsm has finished programming the FPGA and the o_fpga_cfg_err and o_fpga_programmed status signals are valid
    output reg       o_fpga_cfg_err = 0,    // indicates that a configuration error occurred during programming (see page 7 of ECP5 sysCONFIG data sheet, TN1260) 
    output reg       o_fpga_programmed = 0,

    /* FPGA PROGRAMMING INTERFACE */

    input            i_init_n,              // driven by INITN of FPGA being programmed
    input            i_done,                // driven by DONE of FPGA being programmed
    output reg       o_mclk,                // drives CCLK of FPGA being programmed 
    output reg       o_prog_n,              // drives PROGRAMN of FPGA being programmed
    output reg       o_dout_high_z,         // drives tri-state enable of output buffer that sources DI (1 = tri-state, 0 = enable buffer)
    output reg       o_dout                 // drives DI of FPGA being programmed

); 


/****** LOCAL PARAMETERS ******/


    /* Number of system clocks to use for meeting minimum timing requirements of the slave serial interface.  Currently that applies to the
     * PROGRAMN assertion duration and post config wake up clocks.  
     *
     * WARNING: This is set according to the assumption that i_clk is 100MHz or less!
     *
     */
    localparam TIMING_CNTR_CLKS   = 1024;  

    localparam BYTE_CNTR_BITS     = $clog2(P_CONFIG_BYTES); 
    localparam TIMING_CNTR_BITS   = $clog2(TIMING_CNTR_CLKS);



/****** SIGNALS ******/

    logic [BYTE_CNTR_BITS-1:0]   byte_cntr        = {BYTE_CNTR_BITS{1'b0}};
    logic [TIMING_CNTR_BITS-1:0] timing_cntr      = {TIMING_CNTR_BITS{1'b0}};
    logic                  [1:0] init_n_regs;
    logic                  [1:0] done_regs;
    logic                        init_n_asserted; 
    logic                        done_asserted;
    logic                  [6:0] dout_reg;
    logic                  [2:0] dout_shift_cntr  = 3'b000;


    enum {IDLE,
          ASSERT_PROG_N,
          WAIT_FOR_INIT_N_DEASSERT,
          READ_BYTE,
          SHIFT_BYTE_OUT,
          ISSUE_WAKE_UP_CLOCKS,
          CHECK_INIT_N_AND_DONE
         } ecp5_ss_fsm_state;



/****** COMBINATIONAL LOGIC ******/

    assign init_n_asserted = &(~init_n_regs);
    assign done_asserted   = &done_regs;


/****** SEQUENTIAL LOGIC ******/


    always_ff @ (posedge i_clk) begin
        init_n_regs <= {init_n_regs[0], i_init_n};
        done_regs   <= {done_regs[0], i_done};
    end


    /*
     * FSM Operation:
     *
     * 1. Wait for start command
     * 2. Assert o_prog_n
     * 3. Wait for i_init_n to assert
     * 4. Wait for i_init_n to deassert
     * 5. Read in bytes and shift them out 
     * 6. Check i_init_n for CRC error
     * 7. Check i_done for programming finish
     *
     */
    
    always_ff @ (posedge i_clk) begin : ECP5_SLAVE_SERIAL_PROG_FSM

        /* Defaults */

        o_byte_ack <= 0;

        if (i_srst) begin

            o_idle            <= 1;
            o_byte_ack        <= 0;
            o_fpga_status_vld <= 0;
            o_fpga_cfg_err    <= 0;
            o_fpga_programmed <= 0;
            o_prog_n          <= 1;
            o_mclk            <= 0;
            o_dout_high_z     <= 1;
            o_dout            <= 0;
            ecp5_ss_fsm_state <= IDLE;
        
        end else begin

            case (ecp5_ss_fsm_state)

                IDLE: begin

                    o_idle <= 1;

                    if (i_start) begin
                        o_idle            <= 0;
                        o_fpga_status_vld <= 0;
                        o_fpga_cfg_err    <= 0;
                        o_fpga_programmed <= 0;
                        o_prog_n          <= 0;
                        byte_cntr         <= {BYTE_CNTR_BITS{1'b0}};
                        timing_cntr       <= {TIMING_CNTR_BITS{1'b0}};
                        ecp5_ss_fsm_state <= ASSERT_PROG_N;
                    end
                end

                /* Asserts PROGRAMN for at least the minimum assertion time */
                ASSERT_PROG_N: begin

                    timing_cntr <= timing_cntr + 1;

                    if (timing_cntr == (TIMING_CNTR_CLKS - 1)) begin
                        o_prog_n          <= 1;
                        ecp5_ss_fsm_state <= WAIT_FOR_INIT_N_DEASSERT;
                    end
                end

                /* Waits for slave FPGA to deassert INITN marking that the FPGA has cleared its internal memory */
                WAIT_FOR_INIT_N_DEASSERT: begin
                    
                    if (~init_n_asserted) begin
                        o_dout_high_z     <= 0;
                        byte_cntr         <= {BYTE_CNTR_BITS{1'b0}};
                        ecp5_ss_fsm_state <= READ_BYTE;
                    end

                end

                /* Reads in the next configuration byte from the user */
                READ_BYTE: begin
                    
                    if (i_byte_vld) begin
                        o_byte_ack        <= 1;
                        dout_shift_cntr   <= 3'b000;
                        o_dout            <= i_byte[7];
                        dout_reg          <= i_byte[6:0];
                        ecp5_ss_fsm_state <= SHIFT_BYTE_OUT;
                    end
                end

                /* Shifts out the current byte to the slave FPGA */
                SHIFT_BYTE_OUT: begin

                    if (o_mclk) begin

                        o_dout          <= dout_reg[6];
                        dout_reg        <= dout_reg << 1;
                        dout_shift_cntr <= dout_shift_cntr + 1;
                        o_mclk          <= 0;

                        /* see if we're done shifting out the current byte and whether or not that's the last byte */
                        if (dout_shift_cntr == 3'b111) begin

                            if (byte_cntr == (P_CONFIG_BYTES - 1)) begin
                                timing_cntr       <= {TIMING_CNTR_BITS{1'b0}};
                                ecp5_ss_fsm_state <= ISSUE_WAKE_UP_CLOCKS; 
                            end else begin
                                ecp5_ss_fsm_state <= READ_BYTE;
                            end

                            byte_cntr <= byte_cntr + 1;
                        end

                    end else begin
                        o_mclk <= 1;
                    end
                end

                /* Issues wake up clock cycles to the slave FPGA's CCLK input to complete the programming process */
                ISSUE_WAKE_UP_CLOCKS: begin

                    o_dout_high_z <= 1;

                    if (o_mclk) begin

                        timing_cntr <= timing_cntr + 1;
                        o_mclk      <= 0;

                        if (timing_cntr == (TIMING_CNTR_CLKS - 1)) begin
                            ecp5_ss_fsm_state <= CHECK_INIT_N_AND_DONE;
                        end

                    end else begin
                        o_mclk <= 1;
                    end

                end

                /* Checks that INITN is deasserted and that DONE is asserted.  
                 *
                 * INITN asserted means a programming error occurred (see page 7 of ECP5 sysCONFIG data sheet, TN1260)
                 *
                 * DONE deasserted likely means the sync sequence was never found in the bit stream (i.e. the Flash that the bitstream was
                 * read from wasn't programmed correctly or that there weren't enough start/wake up clocks issued to the FPGA after the bitstream
                 * was shifted in.
                 */
                CHECK_INIT_N_AND_DONE: begin

                    o_fpga_status_vld <= 1;

                    if (init_n_asserted) begin
                        o_fpga_cfg_err <= 1;
                    end

                    if (done_asserted) begin
                        o_fpga_programmed <= 1;
                    end

                    ecp5_ss_fsm_state <= IDLE;

                end

                default: begin
                    ecp5_ss_fsm_state <= IDLE;
                end

            endcase
        end
    end

endmodule
