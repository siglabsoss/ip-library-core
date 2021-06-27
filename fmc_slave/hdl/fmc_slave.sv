

module fmc_slave
#(
    parameter real SYS_CLK_T_SECS           = 10e-9, // period of the system clock (seconds) 
    parameter real STM32F_HCLK_T_SECS       = 10e-9, // period of stm32f microcontroller's hclk (seconds)
    parameter int  FMC_ADDR_SETUP_HCLKS     = 15,    // number of hclks used for FMC address setup
    parameter int  FMC_DATA_SETUP_HCLKS     = 15,    // number of hclks used for FMC data setup
    parameter int  FMC_BUS_TURN_HCLKS       = 15,    // number of hclks used for bus turnaround time during asynchronous read
    parameter int  FMC_CMD_ACK_TIMEOUT_CLKS = 64     // This is how many clocks to wait for a CMD ACK before concluding that no ACK will ever come (SHOULD MAKE LARGER THAN MIB MASTER ACK TIMEOUT!)
)
(
    /* SYSTEM INPUTS */

    input i_sys_clk,
    input i_sys_rst,

    /* INTERNAL COMMAND AND CONTROL INTERFACE (SYNCHRONOUS TO SYSTEM CLOCK) */

    output reg        o_cmd_sel,         // fpga command bus valid
    output reg        o_cmd_rd_wr_n,     // fpga command bus read write_n 
    output reg [25:0] o_cmd_byte_addr,   // fpga command bus address (1 extra bit more than FMC address to accommodate word to byte address translation)
    output reg [31:0] o_cmd_wdata,       // fpga command bus write data
    input             i_cmd_ack,         // fpga command bus command acknowledge
    input      [31:0] i_cmd_rdata,       // fpga command bus read data
    output reg        o_cmd_timeout,     // no response from downstream command bus target

    /* FMC INTERFACE (ASYNCHRONOUS, N PREFIX == ACTIVE LOW!) */

    input  [24:0]     i_fmc_a,         // address bus
    input  [15:0]     i_fmc_d,         // data bus (bi-directional input)
    output [15:0]     o_fmc_d,         // data bus (bi-directional output)
    output            o_fmc_d_high_z,  // data bus output tri-state
    input             i_fmc_ne1,       // chip select (active low), doesn't toggle between consecutive accesses
    input             i_fmc_noe,       // output enable (active low)
    input             i_fmc_nwe,       // write enable (active low)
    output            o_fmc_nwait      /* synthesis syn_keep=1 */ // wait (active low)
 
);

    /* FUNCTIONS */
    

    /* LOCAL PARAMETERS */


    localparam FMC_IN_REG_STAGES = 3; // number of register stages for clocking in async FMC chipselect, output enable, and write enable signals (i_fmc_ne1, i_fmc_noe, i_fmc_nwe)

    localparam integer FMC_ADDR_SETUP_SYS_CLKS = int'((FMC_ADDR_SETUP_HCLKS * STM32F_HCLK_T_SECS) / SYS_CLK_T_SECS) - FMC_IN_REG_STAGES + 1; // corrected for ne1 input reg delay
    localparam integer FMC_DATA_SETUP_SYS_CLKS = int'((FMC_DATA_SETUP_HCLKS * STM32F_HCLK_T_SECS) / SYS_CLK_T_SECS) - FMC_IN_REG_STAGES + 1; // corrected for ne1 input reg delay and divided by two to capture data at center of data window
    localparam integer FMC_BUS_TURN_SYS_CLKS   = int'((FMC_BUS_TURN_HCLKS   * STM32F_HCLK_T_SECS) / SYS_CLK_T_SECS) - FMC_IN_REG_STAGES + 1; // corrected for ne1 input reg delay
    localparam integer TCTNR_BITS              = $clog2(FMC_ADDR_SETUP_SYS_CLKS + FMC_DATA_SETUP_SYS_CLKS + FMC_BUS_TURN_SYS_CLKS);


    /* VARIABLES & WIRES */

    logic [$clog2(FMC_CMD_ACK_TIMEOUT_CLKS)-1:0] cmd_ack_timeout_cntr;
    logic                                        cmd_ack_timeout_cntr_en;
    logic                                        cmd_ack_timeout_flag;

    // ASYNC INPUT REGS FOR FMC INTERFACE
    reg [24:0]                  fmc_a_reg;                                // address input registers
    reg [15:0]                  fmc_d_reg;                                // data input registers
    reg [FMC_IN_REG_STAGES-1:0] fmc_noe_regs = {FMC_IN_REG_STAGES{1'b1}}; // output enable input registers
    reg [FMC_IN_REG_STAGES-1:0] fmc_nwe_regs = {FMC_IN_REG_STAGES{1'b1}}; // write enable input registers
    reg [FMC_IN_REG_STAGES-1:0] fmc_ne1_regs = {FMC_IN_REG_STAGES{1'b1}}; // chip select input registers 
    reg                         fmc_nwait_reg = 1; 

    // COMMAND & CONTROL BUS REGS
    reg [25:0] cmd_addr_reg; // 1 extra bit to account for word address to byte address translation
    reg [31:0] cmd_wdata_reg;
    reg [31:0] cmd_rdata_reg = {32{1'b0}};
    reg        cmd_rd_flag;

    // CONFIG FMC SLAVE FSM STATES
    enum {IDLE, 
          FMC_ADDR_PHASE,
          FMC_WDATA_ADDR_PHASE_2, 
          FMC_WDATA_PHASE_1,
          FMC_END_WDATA_PHASE_1,
          FMC_WDATA_PHASE_2,
          FMC_RDATA_PHASE_1,
          FMC_RDATA_PHASE_2,
          ISSUE_CMD
         } fmc_slave_fsm_state;

    reg                  timing_cntr_en = 1'b0;
    reg [TCTNR_BITS-1:0] timing_cntr    = {TCTNR_BITS{1'b0}};


    wire cs_fedge_pulse;     // internal chipselect falling edge pulse
    wire cs_redge_pulse;     // internal chipselect rising edge pulse
    wire out_en_fedge_pulse; // internal output enanble falling edge pulse
    wire out_en_redge_pulse; // internal output enanble rising edge pulse
    wire wr_en_fedge_pulse;  // internal write enable falling edge pulse
    wire wr_en_redge_pulse;  // internal write enable rising edge pulse


    /* COMBINATIONAL LOGIC */

    assign cs_fedge_pulse =  fmc_ne1_regs[FMC_IN_REG_STAGES-1] & ~fmc_ne1_regs[FMC_IN_REG_STAGES-2]; // generate 1-clock pulse signaling we've been selected 
    assign cs_redge_pulse = ~fmc_ne1_regs[FMC_IN_REG_STAGES-1] &  fmc_ne1_regs[FMC_IN_REG_STAGES-2]; // generate 1-clock pulse signaling we've been de-selected

    assign out_en_fedge_pulse = fmc_noe_regs[FMC_IN_REG_STAGES-1] & ~fmc_noe_regs[FMC_IN_REG_STAGES-2];
    assign out_en_redge_pulse = ~fmc_noe_regs[FMC_IN_REG_STAGES-1] & fmc_noe_regs[FMC_IN_REG_STAGES-2];

    assign wr_en_fedge_pulse = fmc_nwe_regs[FMC_IN_REG_STAGES-1] & ~fmc_nwe_regs[FMC_IN_REG_STAGES-2];
    assign wr_en_redge_pulse = ~fmc_nwe_regs[FMC_IN_REG_STAGES-1] & fmc_nwe_regs[FMC_IN_REG_STAGES-2];

    assign o_fmc_d        = cmd_rdata_reg[15:0];
    assign o_fmc_d_high_z = fmc_noe_regs[0];

    assign o_fmc_nwait = fmc_nwait_reg;


    /* SEQUENTIAL LOGIC */

    // async control inputs from FMC 
    always_ff @(posedge i_sys_clk) begin : FMC_ASYNC_CTRL_INPUT_REGS

        int i;

        fmc_noe_regs[0] <= i_fmc_noe;
        fmc_nwe_regs[0] <= i_fmc_nwe;
        fmc_ne1_regs[0] <= i_fmc_ne1; // registered a couple of times to generate falling and rising edge pulses

        for (i = 1; i < FMC_IN_REG_STAGES; i = i + 1) begin
            fmc_ne1_regs[i] <= fmc_ne1_regs[i-1]; 
            fmc_noe_regs[i] <= fmc_noe_regs[i-1];
            fmc_nwe_regs[i] <= fmc_nwe_regs[i-1];
        end
    end
    
    // async address and data inputs from FMC 
    always_ff @(posedge i_sys_clk) begin : FMC_ASYNC_ADDR_DATA_INPUT_REGS
        fmc_a_reg <= i_fmc_a;
        fmc_d_reg <= i_fmc_d;
    end

    // count system clocks to keep track of setup and bus turn-around times
    always_ff @(posedge i_sys_clk) begin : FMC_ASYNC_TIMING_COUNTER
        if (timing_cntr_en == 1'b1) begin
            timing_cntr <= timing_cntr + 1; 
        end
        else begin
            timing_cntr <= {TCTNR_BITS{1'b0}}; 
        end
    end

    always_ff @ (posedge i_sys_clk) begin: ACK_TIMEOUT_CNTR

        if ((~cmd_ack_timeout_cntr_en) | i_sys_rst) begin
            cmd_ack_timeout_cntr <= {$bits(cmd_ack_timeout_cntr){1'b0}};
        end else begin
            cmd_ack_timeout_cntr <= cmd_ack_timeout_cntr + 1;
        end
    end


    // CONFIG FMC SLAVE FSM
    always_ff @(posedge i_sys_clk) begin : FMC_SLAVE_FSM

        if (i_sys_rst) begin

            fmc_nwait_reg           <= 1;
            timing_cntr_en          <= 0;
            o_cmd_sel               <= 0;
            o_cmd_rd_wr_n           <= 0;
            o_cmd_byte_addr         <= {26{1'b0}};
            o_cmd_wdata             <= {32{1'b0}};
            o_cmd_timeout           <= 0;
            cmd_rd_flag             <= 0;
            cmd_addr_reg            <= {26{1'b0}};
            cmd_wdata_reg           <= {32{1'b0}};
            cmd_ack_timeout_cntr_en <= 0;
            cmd_ack_timeout_flag    <= 0;
            fmc_slave_fsm_state     <= IDLE;

        end
        else begin

            // Defaults
            fmc_nwait_reg           <= 1; 
            timing_cntr_en          <= 0;
            o_cmd_sel               <= 0;
            o_cmd_timeout           <= 0;
            cmd_ack_timeout_cntr_en <= 0;

            case (fmc_slave_fsm_state) 
                
                IDLE: begin

                    cmd_ack_timeout_flag <= 0;
                    
                    if (cs_fedge_pulse) begin

                        /* 
                         *  NOTE: Use FMC_NOE to determine if write or read instead of FMC_NWE.  NWE gets asserted at the end of the address phase,
                         *        counter to what's shown in STM32F76xx & STM32F77xx reference manual (RM0410), which causes a race condition at this point.
                         *        NOE however, seems to assert as indicated in the reference manual.
                         */
                        if (~fmc_noe_regs[0]) begin
                            fmc_nwait_reg <= 0; // immediately assert wait in the case that it's an FMC read 
                            cmd_rd_flag   <= 1;
                        end
                        else begin
                            cmd_rd_flag <= 0;
                        end

                        timing_cntr_en      <= 1;
                        fmc_slave_fsm_state <= FMC_ADDR_PHASE;

                    end

                end

                /* captures the fmc address on the first fmc cycle */
                FMC_ADDR_PHASE: begin

                    timing_cntr_en <= 1;

                    if (cmd_rd_flag) begin
                        fmc_nwait_reg <= 0; // continue to assert wait until we've processed the read transaction
                    end
                    
                    /*
                     * NOTE: Address setup is divided by 2 so we sample in the middle of the address phase.  During eval board prototyping
                     *       I encountered glitches on the FMC data bus when too many data lines changed from high-to-low or low-to-high.  These
                     *       glitches coupled onto the address bus and would cause the wrong address to be sampled at the end of the address setup phase,
                     *       which is when the data bus transitions to start the data setup phase.  If FMC_ADDR_SETUP_HCLKS is large enough then this divide
                     *       by 2 should still leave plenty of setup time for the FMC address.  Similar reasoning applies for the FMC_DATA_SETUP_SYS_CLKS being
                     *       divided by two, although I didn't/haven't encountered a similar problem on the data bus yet.
                     */
                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS/2) begin // fmc addr and control signals should be valid by now 
                        cmd_addr_reg <= {fmc_a_reg, 1'b0}; // convert from WORD address to byte address
                    end

                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS) begin // end of address setup phase 

                        if (cmd_rd_flag) begin // fmc read 
                            fmc_slave_fsm_state <= ISSUE_CMD;
                        end
                        else begin // fmc write
                            fmc_slave_fsm_state <= FMC_WDATA_PHASE_1;
                        end

                    end
                end

                /* captures first cycle of write data */
                FMC_WDATA_PHASE_1: begin

                    timing_cntr_en <= 1;

                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS + (FMC_DATA_SETUP_SYS_CLKS/2)) begin // fmc write data should be valid by now 
                        cmd_wdata_reg[15:0] <= fmc_d_reg; // undo little endian swap
                    end

                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS + FMC_DATA_SETUP_SYS_CLKS) begin // end of data setup phase 
                        fmc_slave_fsm_state <= FMC_END_WDATA_PHASE_1;
                    end

                end

                /* 
                 * Releases wait to finish the fmc write data phase 1 and waits for fmc write data phase 2 to begin.
                 * You need to assert wait immediately since the second fmc write data phase is where we actually write data
                 * to the slave fpgas.
                 */
                FMC_END_WDATA_PHASE_1: begin
                    
                    /* wait released and timing counter reset by default assignments at top of always block */

                    /* FMC Master doesn't de-assert chip select (i_fmc_ne1) in between write data phases.  Instead it de-asserts and re-asserts write enable (i_fmc_nwe). */
                    if (wr_en_fedge_pulse) begin
                        fmc_nwait_reg       <= 0; // immediately assert wait for second write data phase since we now need to actually process the write transaction
                        timing_cntr_en      <= 1;
                        fmc_slave_fsm_state <= FMC_WDATA_ADDR_PHASE_2;
                    end

                end

                /* dummy state to wait out address setup during second fmc write cycle */
                FMC_WDATA_ADDR_PHASE_2: begin

                    fmc_nwait_reg  <= 0; // continue to assert wait until we've processed the write transaction
                    timing_cntr_en <= 1;
                    
                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS) begin // end of address setup phase
                        fmc_slave_fsm_state <= FMC_WDATA_PHASE_2;                
                    end

                end

                /* captures second cycle of fmc write data */
                FMC_WDATA_PHASE_2: begin

                    fmc_nwait_reg  <= 0; // continue to assert wait until we've processed the transaction
                    timing_cntr_en <= 1;

                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS + (FMC_DATA_SETUP_SYS_CLKS/2)) begin // data should be valid in the input regs by now
                        cmd_wdata_reg[31:16] <= fmc_d_reg; // undo little endian
                    end

                    if (timing_cntr == FMC_ADDR_SETUP_SYS_CLKS + FMC_DATA_SETUP_SYS_CLKS) begin // end of data setup phase
                        fmc_slave_fsm_state  <= ISSUE_CMD;
                    end

                end

                /* presents the first portion of read data (upper 16-bits) to the FMC interface */
                FMC_RDATA_PHASE_1: begin

                    /* 
                     * Read data is already being driven on the bus.  Release wait signal (handled by default assignment) and wait for output enable (i_fmc_noe) to
                     * de-assert and re-assert.
                     */
                    if (out_en_fedge_pulse) begin
                        cmd_rdata_reg       <= cmd_rdata_reg >> 16;
                        fmc_slave_fsm_state <= FMC_RDATA_PHASE_2;
                    end

                end

                /* presents the second portion of read data (lower 16-bits) to the FMC interface */
                FMC_RDATA_PHASE_2: begin

                    /* read data is already being driven on the bus, just release wait signal (handled by default assignment) and wait for chip select to de-assert */
                    if (cs_redge_pulse) begin
                        fmc_slave_fsm_state <= IDLE;

                        if (cmd_ack_timeout_flag) begin
                            o_cmd_timeout <= 1;
                        end
                    end

                end

                /* issues fmc command to the command and control bus and waits for ack */
                ISSUE_CMD: begin

                    fmc_nwait_reg           <= 0; // continue to assert wait until we've processed the transaction
                    cmd_ack_timeout_cntr_en <= 1;
                    o_cmd_rd_wr_n           <= cmd_rd_flag;
                    o_cmd_byte_addr         <= cmd_addr_reg;
                    o_cmd_wdata             <= cmd_wdata_reg;

                    if (i_cmd_ack == 1'b1 || cmd_ack_timeout_cntr == (FMC_CMD_ACK_TIMEOUT_CLKS-1)) begin 

                        // we still have to complete the read data phase regardless of whether we got an ack or a nack since the FMC interface is really targeting a memory, a nack makes no sense

                        if (cmd_rd_flag) begin // read command (don't assert timeout yet since that will interrupt the processor, we'll complete the read transaction first and then interrupt)
                            cmd_rdata_reg       <= i_cmd_rdata;
                            fmc_slave_fsm_state <= FMC_RDATA_PHASE_1;
                        end else begin
                            fmc_slave_fsm_state <= IDLE;

                            // we're done with the FMC write transaction so we can interrupt the processor right away
                            if (cmd_ack_timeout_cntr == (FMC_CMD_ACK_TIMEOUT_CLKS-1)) begin
                                o_cmd_timeout <= 1;
                            end
                        end

                        // this if statement must come after the if statement checking the cmd_rd_flag in order to override the cmd_rdata_reg assignment
                        if (cmd_ack_timeout_cntr == (FMC_CMD_ACK_TIMEOUT_CLKS-1)) begin
                            cmd_ack_timeout_flag <= 1;
                            cmd_rdata_reg        <= 32'heeee_eeee;
                        end

                    end else begin
                        o_cmd_sel <= 1;
                    end
                end

                default: begin
                    fmc_slave_fsm_state <= IDLE;
                end
    
            endcase 
        end
    end

endmodule
