
module mib_slave #(
    parameter bit [3:0] P_SLAVE_MIB_ADDR_MSN   = 4'h0, // each slave on the MIB bus gets a unique MIB Address Most Significant Nibble  
    parameter int       P_CMD_ACK_TIMEOUT_CLKS = 16    // This is how many clocks to wait for a CMD ACK before concluding that no ACK will ever come (SHOULD MAKE SMALLER THAN MIB BUS ACK TIMEOUT!)
)(
    input             i_sysclk, // currently cmd and mib interface are synchronous to this clock
    input             i_srst,

    /* LOCAL COMMAND INTERFACE (SYNCHRONOUS TO i_sysclk) */
	intf_cmd.master   cmd_master,

    /* MIB INTERFACE (SYNCHRONOUS TO i_sysclk) */

    input             i_mib_start,            // from master, starts a mib transaction
    input             i_mib_rd_wr_n,          // 1 = read, 0 = write
    output reg        o_mib_slave_ack = 0,    // slave drives this during read data phases (if it's the target) (MAKE SURE THIS IS PULLED LOW AT MASTER)
    output reg        o_mib_slave_ack_high_z = 1,

    /* o_mib_ad and i_mib_ad form a bi-directional address/data bus between master and slave */

    input      [15:0] i_mib_ad,               // driven by slave during read data phases (if needed)
    output reg [15:0] o_mib_ad,               // driven by master during address phases and write data phases (if needed)
    output reg        o_mib_ad_high_z = 1     // 1 = tri-state b_mib_ad at top level, 0 = drive it

);

/****** LOCAL PARAMETERS ******/


/****** SIGNALS ******/

    logic        mib_start_reg;
    logic        mib_rd_wr_n_reg;
    logic        mib_rd_flag;
    logic [15:0] mib_ad_reg;
    logic        mib_addr_hit_flag;

    logic [15:0] cmd_rdata_reg;   

    logic [$clog2(P_CMD_ACK_TIMEOUT_CLKS)-1:0] cmd_ack_timeout_cntr;
    logic                                      cmd_ack_timeout_cntr_en;

    typedef enum { IDLE,
           ADDR_PHASE_2,
           WDATA_PHASE_1,
           WDATA_PHASE_2,
           BUS_TURN_AROUND_DELAY,
           RDATA_PHASE_2,
           WAIT_FOR_CMD_ACK 
         } mib_slave_state;
mib_slave_state mib_slave_fsm_state;

/****** COMBINATIONAL LOGIC ******/

    assign mib_addr_hit_flag = (mib_ad_reg[7:4] == P_SLAVE_MIB_ADDR_MSN) ? 1'b1 : 1'b0; 


/****** SEQUENTIAL LOGIC ******/

    always_ff @ (posedge i_sysclk) begin: MIB_START_REG
        
        if (i_srst) begin
            mib_start_reg <= 0;
        end else begin
            mib_start_reg <= i_mib_start;
        end
    end


    always_ff @ (posedge i_sysclk) begin: MIB_RD_WR_N_REG
        mib_rd_wr_n_reg <= i_mib_rd_wr_n;
    end


    always_ff @ (posedge i_sysclk) begin: MIB_AD_REGS
        mib_ad_reg      <= i_mib_ad;
    end


    always_ff @ (posedge i_sysclk) begin: CMD_ACK_TIMEOUT_CNTR

        if ((~cmd_ack_timeout_cntr_en) | i_srst) begin
            cmd_ack_timeout_cntr <= {$bits(cmd_ack_timeout_cntr){1'b0}};
        end else begin
            cmd_ack_timeout_cntr <= cmd_ack_timeout_cntr + 1;
        end
    end


    always_ff @ (posedge i_sysclk) begin: MIB_SLAVE_FSM

        if (i_srst) begin

            o_mib_slave_ack         <= 0;
            o_mib_slave_ack_high_z  <= 1; // mib master or external resistor should pull down o_mib_slave_ack
            cmd_master.sel          <= 0;
            cmd_ack_timeout_cntr_en <= 0;
            mib_slave_fsm_state     <= IDLE;

        end else begin

            /* defaults */
            o_mib_slave_ack         <= 0;
            o_mib_slave_ack_high_z  <= 1;
            o_mib_ad_high_z         <= 1;
            cmd_master.sel          <= 0;
            cmd_ack_timeout_cntr_en <= 0;

            case (mib_slave_fsm_state)

                /* this is also address phase 1 */
                IDLE: begin

                    if (mib_start_reg & mib_addr_hit_flag) begin
                        cmd_master.byte_addr[19:16] <= mib_ad_reg[3:0]; // upper 4-bits of MIB address
                        mib_rd_flag                 <= mib_rd_wr_n_reg;
                        mib_slave_fsm_state         <= ADDR_PHASE_2;
                    end

                end

                /* MIB SLAVE MUST BE ABLE TO HANDLE BACK-TO-BACK ADDRESS PHASES */
                ADDR_PHASE_2: begin

                    cmd_master.byte_addr[15:0] <= mib_ad_reg;
                    cmd_master.rd_wr_n         <= mib_rd_flag;

                    if (mib_rd_flag) begin
                        cmd_master.sel          <= 1;
                        cmd_ack_timeout_cntr_en <= 1;
                        mib_slave_fsm_state     <= WAIT_FOR_CMD_ACK;
                    end else begin
                        mib_slave_fsm_state <= WDATA_PHASE_1;
                    end

                end

                /* MIB SLAVE MUST BE ABLE TO STORE BACK-TO-BACK WRITE DATA PHASE */
                WDATA_PHASE_1: begin

                    cmd_master.wdata[31:16]  <= mib_ad_reg;
                    mib_slave_fsm_state <= WDATA_PHASE_2;

                end

                WDATA_PHASE_2: begin

                    cmd_master.wdata[15:0]  <= mib_ad_reg;
                    cmd_master.sel          <= 1;
                    cmd_ack_timeout_cntr_en <= 1;
                    mib_slave_fsm_state     <= WAIT_FOR_CMD_ACK;

                end
                
                /* also RDATA_PHASE_1 */
                WAIT_FOR_CMD_ACK: begin

                    cmd_ack_timeout_cntr_en <= 1;

                    if (cmd_master.ack) begin

                        o_mib_slave_ack        <= 1;
                        o_mib_slave_ack_high_z <= 0;
                        mib_slave_fsm_state    <= IDLE;

                        if (mib_rd_flag) begin
                            o_mib_ad            <= cmd_master.rdata[31:16];
                            o_mib_ad_high_z     <= 0;
                            cmd_rdata_reg       <= cmd_master.rdata[15:0];
                            mib_slave_fsm_state <= RDATA_PHASE_2;
                        end

                    end 
                    else if (cmd_ack_timeout_cntr == P_CMD_ACK_TIMEOUT_CLKS-1) begin // don't ACK on MIB bus if we don't get a cmd bus ACK.  MIB master will timeout and signal back to higher level module of the MIB/CMD bus failure
                        mib_slave_fsm_state <= IDLE;
                    end 

                end

                RDATA_PHASE_2: begin

                    o_mib_slave_ack        <= 1; // doesn't really matter if you continue to drive this here since the master will assume that the next rdata phase follows the first
                    o_mib_slave_ack_high_z <= 0; // ditto
                    o_mib_ad_high_z        <= 0;
                    o_mib_ad               <= cmd_rdata_reg;
                    mib_slave_fsm_state    <= IDLE;

                end

                default: begin
                    mib_slave_fsm_state <= IDLE;
                end

            endcase

        end

    end

endmodule
