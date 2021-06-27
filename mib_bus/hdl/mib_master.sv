

module mib_master #(
    parameter int P_MIB_ACK_TIMEOUT_CLKS = 32  // This is how many clocks to wait for a slave ACK before concluding that no ACK will ever come :(
)(
    input i_sysclk, // currently cmd and mib interface are synchronous to this clock
    input i_srst,

    /* FMC SLAVE COMMAND INTERFACE (SYNCHRONOUS TO i_sysclk) */
	intf_cmd.slave    cmd_slave,
    output reg        o_cmd_mib_timeout,

    /* MIB INTERFACE (SYNCHRONOUS TO i_sysclk) */

    output reg        o_mib_start = 0,     // master drives this for one clock during address phase 1 
    output reg        o_mib_rd_wr_n,       // 1 = read, 0 = write

    /* put a PULLDOWN on i_mib_slave_ack */

    input             i_mib_slave_ack,     // slave drives this during write phase to ack write data or during read data phase to signal valid read data 

    /* o_mib_ad and i_mib_ad form a bi-directional address/data bus between master and slave */

    input      [15:0] i_mib_ad,            // driven by slave during read data phases (if needed)
    output reg [15:0] o_mib_ad,            // driven by master during address phases and write data phases (if needed)
    output reg        o_mib_ad_high_z = 1  // 1 = tri-state b_mib_ad at top level, 0 = drive it

);
    

/****** LOCAL PARAMETERS ******/


/****** SIGNALS ******/

    logic [15:0] cmd_byte_addr_reg;
    logic [31:0] cmd_wdata_reg;       
    logic        cmd_rd_flag;

    logic [$clog2(P_MIB_ACK_TIMEOUT_CLKS)-1:0] mib_ack_timeout_cntr;
    logic                                      mib_ack_timeout_cntr_en;
    logic                                      mib_ack_timeout_flag;

    logic        mib_slave_ack_reg;
    logic [15:0] mib_ad_reg;

    enum { IDLE,
           ADDR_PHASE_1,
           ADDR_PHASE_2,
           WDATA_PHASE_1,
           WDATA_PHASE_2,
           RDATA_PHASE_1,
           RDATA_PHASE_2,
           MIB_CYCLE_TO_CYCLE_DELAY
         } mib_master_fsm_state;


/****** COMBINATIONAL LOGIC ******/


/****** SEQUENTIAL LOGIC ******/

    always_ff @ (posedge i_sysclk) begin : MIB_SLAVE_ACK_REG
        if (i_srst) begin
            mib_slave_ack_reg <= 0;
        end else begin
            mib_slave_ack_reg <= i_mib_slave_ack;
        end
    end


    always_ff @ (posedge i_sysclk) begin: MIB_AD_REGS
        mib_ad_reg <= i_mib_ad;
    end


    always_ff @ (posedge i_sysclk) begin: MIB_ACK_TIMEOUT_CNTR

        if ((~mib_ack_timeout_cntr_en) | i_srst) begin
            mib_ack_timeout_cntr <= {$bits(mib_ack_timeout_cntr){1'b0}};
        end else begin
            mib_ack_timeout_cntr <= mib_ack_timeout_cntr + 1;
        end
    end


    always_ff @ (posedge i_sysclk) begin : MIB_MASTER_FSM

        if (i_srst) begin

            cmd_slave.ack           <= 0;
            o_mib_start             <= 0;
            o_mib_ad_high_z         <= 1;
            o_cmd_mib_timeout       <= 0;
            mib_ack_timeout_cntr_en <= 0;
            mib_ack_timeout_flag    <= 0;
            mib_master_fsm_state    <= IDLE;

        end else begin

            /* WARNING: 
             * o_mib_start NEEDS TO BE HIGH FOR ONE CLOCK ONLY OTHERWISE SOME OTHER SLAVE MAY MISINTERPRET 
             * THE AD BUS DURING A PHASE BESIDES ADDRESS PHASE 1
             */

            /* defaults */
            o_mib_start             <= 0; 
            o_mib_ad_high_z         <= 1;
            cmd_slave.ack           <= 0;
            o_cmd_mib_timeout       <= 0;
            mib_ack_timeout_cntr_en <= 0;


            case (mib_master_fsm_state)

                /* MIB SLAVE MUST BE ABLE TO HANDLE BACK-TO-BACK ADDRESS & WRITE DATA PHASES */
                IDLE: begin

                    mib_ack_timeout_flag <= 0;

                    if (cmd_slave.sel) begin
                        o_mib_start          <= 1;
                        o_mib_ad             <= {8'h00, cmd_slave.byte_addr[23:16]};
                        o_mib_ad_high_z      <= 0;
                        o_mib_rd_wr_n        <= cmd_slave.rd_wr_n;
                        cmd_byte_addr_reg    <= cmd_slave.byte_addr[15:0];
                        cmd_rd_flag          <= cmd_slave.rd_wr_n;
                        cmd_wdata_reg        <= cmd_slave.wdata;
                        mib_master_fsm_state <= ADDR_PHASE_1;
                    end
                end

                ADDR_PHASE_1: begin

                    o_mib_ad_high_z      <= 0;
                    o_mib_ad             <= cmd_byte_addr_reg; // lower 16-bits of address
                    mib_master_fsm_state <= ADDR_PHASE_2;

                end

                ADDR_PHASE_2: begin

                    if (cmd_rd_flag) begin 
                        mib_master_fsm_state <= RDATA_PHASE_1;
                    end else begin
                        o_mib_ad_high_z      <= 0;
                        o_mib_ad             <= cmd_wdata_reg[31:16]; // upper 16-bits of write data
                        mib_master_fsm_state <= WDATA_PHASE_1;
                    end

                end

                WDATA_PHASE_1: begin

                    o_mib_ad_high_z      <= 0;
                    o_mib_ad             <= cmd_wdata_reg[15:0]; // lower 16-bits of write data
                    mib_master_fsm_state <= WDATA_PHASE_2;

                end

                WDATA_PHASE_2: begin

                    mib_ack_timeout_cntr_en <= 1;

                    if (mib_slave_ack_reg) begin // slave can pause MIB bus in order to complete its internal command bus write
                        mib_ack_timeout_flag <= 0;
                        mib_master_fsm_state <= MIB_CYCLE_TO_CYCLE_DELAY;
                    end 
                    else if (mib_ack_timeout_cntr == P_MIB_ACK_TIMEOUT_CLKS-1) begin // but it better not pause it for too long!
                        mib_ack_timeout_flag  <= 1;
                        mib_master_fsm_state  <= MIB_CYCLE_TO_CYCLE_DELAY;
                    end

                end

                RDATA_PHASE_1: begin

                    mib_ack_timeout_cntr_en <= 1;

                    if (mib_slave_ack_reg) begin // slave can pause the MIB bus in order to complete its internal command bus read
                        cmd_slave.rdata[31:16]   <= mib_ad_reg;
                        mib_ack_timeout_flag <= 0;
                        mib_master_fsm_state <= RDATA_PHASE_2;
                    end 
                    else if (mib_ack_timeout_cntr == P_MIB_ACK_TIMEOUT_CLKS-1) begin // but it better not pause it for too long!
                        mib_ack_timeout_flag  <= 1;
                        mib_master_fsm_state  <= MIB_CYCLE_TO_CYCLE_DELAY;
                    end

                end

                /* MIB SLAVE MUST BE ABLE TO HANDLE BACK-TO-BACK READ DATA PHASES (it shouldn't ack until it's ready) */ 
                RDATA_PHASE_2: begin
                    
                    cmd_slave.rdata[15:0]    <= mib_ad_reg;
                    mib_master_fsm_state <= MIB_CYCLE_TO_CYCLE_DELAY;

                end

                MIB_CYCLE_TO_CYCLE_DELAY: begin // use this state to provide additional delay between successive MIB cycles (this probably isn't needed at all though)

                    mib_master_fsm_state <= IDLE;

                    if (~mib_ack_timeout_flag) begin // ack if we didn't timeout, otherwise do nothing (timeout will then propagate upstream)
                        cmd_slave.ack <= 1;
                    end else begin
                        o_cmd_mib_timeout <= 1; // let whomever instantiated us know that a timeout occurred.
                    end

                end

                default: begin
                    mib_master_fsm_state <= IDLE;
                end
    
            endcase

        end

    end

endmodule
