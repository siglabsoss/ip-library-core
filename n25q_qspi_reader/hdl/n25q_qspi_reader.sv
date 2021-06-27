/*
 *
 * Simple module for reading user specified number of bytes from a Micron N25Q or MT25Q based NOR flash memory.
 * This module will put the NOR flash in Quad-SPI Mode and then read out the specified number of bytes.
 * 
 * The following memory densities are supported: 16Mbit, 32Mbit, 64Mbit, 128Mbit, 256Mbit, 512Mbit, and 1Gbit.
 * 
 * 2Gbit and 4Gbit memory densities can be supported by expanding the 256Mbit die boundary crossing check logic.
 * That said, the N25Q only comes in densities up to 1Gbit and the MT25Q has a different internal die architecture that makes reading the
 * how flash memory a lot easier.  Therefore, if you want to support 2Gbit and 4Gbit densities you're probably better off making a new module
 * that only supports the MT25Q series.
 *
 *
 * WARNING: KEEP THE INPUT CLOCK AT 108MHz OR SLOWER OR RISK VIOLATING FLASH TIMING PARAMETERS.
 * 
 * WARNING: THE START ADDRESS AND THE NUMBER OF BYTES TO READ SHOULDN'T GO PAST THE END OF THE MEMORY.
 *
 * TODO: ADD TIMING PARAMETERS TO ALLOW FOR FASTER CLOCKS.  THIS IS A LOW PRIORITY.
 *
 */

module n25q_qspi_reader #(
    parameter int unsigned P_256MBIT_OR_LARGER = 0 // 0 for flash densities <= 128Mbit flash and 1 for flashes densities >= 256Mbit
)(
    /* USER INTERFACE */
    
    input                                         i_clk,
    input                                         i_srst,               // synchronous reset
    input                                         i_rd_start,           // 1 = start reading
    input      [(24+(8*P_256MBIT_OR_LARGER))-1:0] i_rd_start_byte_addr, // byte address to start reading bytes from
    input      [(24+(8*P_256MBIT_OR_LARGER))-1:0] i_rd_num_bytes,       // number of bytes to read 
    input                                         i_rd_pause,           // 1 = hold off reading of additional bytes (i.e. tie to FIFO full)
    output reg                                    o_rd_busy,
    output reg                                    o_rd_byte_vld,
    output reg [7:0]                              o_rd_byte,

    /* QSPI INTERFACE */

    output reg                                    o_qspi_clk,
    output reg                                    o_qspi_sel_n,
    output reg                                    o_qspi_d0_high_z,
    input                                         i_qspi_d3,
    input                                         i_qspi_d2,
    input                                         i_qspi_d1,
    input                                         i_qspi_d0,
    output                                        o_qspi_d0

);
    
    /* PARAMETER RANGE CHECKS */
    
    initial begin
        assert ((P_256MBIT_OR_LARGER == 0) || (P_256MBIT_OR_LARGER == 1)) else $fatal(0, "Error! P_256MBIT_OR_LARGER MUST BE EITHER 0 (128Mbit FLASH OR SMALLER) OR 1 (256Mbit FLASH OR LARGER)");
    end


    /****** LOCAL PARAMETERS ******/

    localparam SPI_ADDR_BITS           = (P_256MBIT_OR_LARGER) ? 32 : 24;
    localparam SPI_CMD_BITS            = 8;
    localparam SPI_CMD_DATA_BITS       = 8;
    localparam SPI_DOUT_MAX_BITS       = SPI_CMD_BITS + SPI_CMD_DATA_BITS + SPI_ADDR_BITS;
    localparam SPI_DOUT_CNTR_BITS      = $clog2(SPI_DOUT_MAX_BITS);
    localparam SPI_CLK_CYCLE_CNTR_BITS = 4; // see datasheet, max count = "1111" binary

    /* FLASH CHIP COMMANDS */

    localparam logic [SPI_CMD_BITS - 1:0] RESET_ENABLE_CMD                = 8'h66;
    localparam logic [SPI_CMD_BITS - 1:0] RESET_MEMORY_CMD                = 8'h99;
    localparam logic [SPI_CMD_BITS - 1:0] WRITE_ENABLE_CMD                = 8'h06;
    localparam logic [SPI_CMD_BITS - 1:0] WRITE_VOLATILE_CONFIG_REG_CMD   = 8'h81;
    localparam logic [SPI_CMD_BITS - 1:0] WRITE_EVOLATILE_CONFIG_REG_CMD  = 8'h61; // enhanced volatile config reg write command
    localparam logic [SPI_CMD_BITS - 1:0] QUAD_OUTPUT_FAST_READ_CMD       = 8'h6b;
    localparam logic [SPI_CMD_BITS - 1:0] QUAD_OUTPUT_FAST_4BYTE_READ_CMD = 8'h6c; // use instead of QUAD_OUTPUT_FAST_READ_CMD when flash density > 128Mbit
    localparam logic [SPI_CMD_BITS - 1:0] ENTER_4BYTE_ADDRESS_MODE_CMD    = 8'hb7; // issue this after setting volatile config regs when flash density > 128Mbit (requires write enable command to be issued prior to this command)


    /* 
     * These values for the volatile and enhanced volatile configuration registers
     * should put the device into its default state regardless of how the non-volatile
     * counterpart registers were set.
     *
     */ 

    localparam logic [7:0] VOLATILE_CONFIG_REG_VAL  = 8'b1000_1_0_11;   // Dummy clocks, XIP, Rsrvd, Wrap
    localparam logic [7:0] EVOLATILE_CONFIG_REG_VAL = 8'b1_1_1_0_1_111; // Quad IO, Dual IO, Rsrvd (N25Q) or DTR (MT25Q), Reset/Hold, Vpp Accel (N25Q) or Rsrvd (MT25Q), Output drive strength


    /****** SIGNALS ******/


    logic [SPI_ADDR_BITS - 1:0] rd_byte_addr_reg;
    logic [SPI_ADDR_BITS - 1:0] rd_num_bytes_reg;

    logic rd_start_reg;   // used to create rising edge pulse
    logic rd_start_pulse;

    typedef enum {
        IDLE, 
        ISSUE_RESET_ENABLE_CMD, 
        ISSUE_RESET_MEMORY_CMD, 
        ISSUE_WRITE_ENABLE_CMD,             // must be done prior to writing the volatile config reg, enhanced volatile config reg, and entering 4-byte address mode
        NON_READ_DESELECT_DELAY,
        SOFTWARE_RESET_RECOVERY_DELAY,
        WRITE_VOLATILE_CONFIG_REG,
        WRITE_EVOLATILE_CONFIG_REG,         // enhanced volatile config reg
        ISSUE_ENTER_4BYTE_ADDRESS_MODE_CMD, // only needed when the flash density is > 128Mbit (write enable command must be issued prior to issuing this command)
        ISSUE_QUAD_OUTPUT_FAST_RD_CMD,
        ISSUE_DUMMY_CYCLE_CLOCKS,
        READ_HIGH_NIBBLE,
        READ_LOW_NIBBLE,
        POST_READ_DESELECT_DELAY
    } flash_rd_fsm_states_t;

    flash_rd_fsm_states_t flash_rd_fsm_state;
    flash_rd_fsm_states_t flash_rd_fsm_next_state;
    flash_rd_fsm_states_t flash_rd_fsm_next_next_state;

    logic [3:0] qspi_din_regs;


    // for flash read fsm
    logic [SPI_DOUT_MAX_BITS       - 1:0] flash_dout_reg;
    logic [SPI_DOUT_MAX_BITS       - 1:0] flash_dout_next_reg;
    logic [SPI_DOUT_MAX_BITS       - 1:0] flash_dout_next_next_reg;
    logic [SPI_DOUT_CNTR_BITS      - 1:0] flash_dout_cntr;
    logic [SPI_ADDR_BITS           - 1:0] flash_byte_cntr; 
    logic [SPI_CLK_CYCLE_CNTR_BITS - 1:0] flash_clk_cycle_cntr;
    logic                               die_crossing_flag; 

 
    /****** COMBINATIONAL LOGIC ******/


    assign rd_start_pulse = i_rd_start & ~rd_start_reg;

    assign o_qspi_d0 = flash_dout_reg[SPI_DOUT_MAX_BITS - 1];


    /****** SEQUENTIAL LOGIC ******/


    always_ff @ (posedge i_clk) begin
        rd_start_reg <= i_rd_start;
    end

    always_ff @ (posedge i_clk) begin
        qspi_din_regs <= {i_qspi_d3, i_qspi_d2, i_qspi_d1, i_qspi_d0};
    end


    /*
     * FSM Operation:
     *
     * 1. Wait for read start command
     * 2. Reset the flash
     * 3. Issue Write Enable command
     * 4. Write volatile and enhanced volatile configuration registers to put flash into known state
     * 5. Issue quad output fast read command (4-byte when flash density > 128Mbit, otherwise 3-byte)
     * 6. Read out requested number of bytes, presenting each one to the user, until a 256Mbit die boundary is hit or all bytes are read.  If a 256Mbit die boundary is hit then go back to step 5.
     *
     */
    
    always_ff @ (posedge i_clk) begin : FLASH_RD_FSM

        if (i_srst) begin
            o_rd_byte_vld      <= 0;
            o_rd_byte          <= 8'h0;
            o_rd_busy          <= 0;
            o_qspi_clk         <= 0;
            o_qspi_sel_n       <= 1;
            o_qspi_d0_high_z   <= 1;
            die_crossing_flag  <= 0;
            flash_rd_fsm_state <= IDLE;
        
        end else begin

            case (flash_rd_fsm_state)

                IDLE: begin

                    o_rd_busy       <= 0;
                    o_qspi_sel_n    <= 1;
                    flash_byte_cntr <= '0;
            
                    if ( (rd_start_pulse == 1) && (i_rd_num_bytes != 0) ) begin

                        rd_byte_addr_reg    <= i_rd_start_byte_addr;
                        rd_num_bytes_reg    <= i_rd_num_bytes;
                        o_rd_busy           <= 1;
                        o_qspi_sel_n        <= 0;
                        o_qspi_d0_high_z    <= 0;
                        flash_dout_reg      <= {RESET_ENABLE_CMD, {(SPI_DOUT_MAX_BITS-SPI_CMD_BITS){1'b0}}};
                        flash_dout_cntr     <= '0;
                        flash_rd_fsm_state  <= ISSUE_RESET_ENABLE_CMD;

                    end
                end


                /* sends the reset enable command to the flash */
                ISSUE_RESET_ENABLE_CMD: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS - 1)) begin
                            o_qspi_sel_n            <= 1;
                            flash_clk_cycle_cntr    <= '0;
                            flash_dout_next_reg     <= {RESET_MEMORY_CMD, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS){1'b0}}};
                            flash_rd_fsm_state      <= NON_READ_DESELECT_DELAY;
                            flash_rd_fsm_next_state <= ISSUE_RESET_MEMORY_CMD;
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end


                /* 
                 * Ensures that the minimum deselect time after nonRead command (tshsl2) is met.
                 *
                 * NOTE: ASSUMES THAT INPUT CLOCK IS RESTRICTED ACCORDING TO COMMENTS AT TOP OF FILE
                 *
                 */
                NON_READ_DESELECT_DELAY: begin

                    flash_clk_cycle_cntr <= flash_clk_cycle_cntr + 1;
                    flash_dout_cntr      <= '0;
                    flash_dout_reg       <= flash_dout_next_reg;

                    if (flash_clk_cycle_cntr == {SPI_CLK_CYCLE_CNTR_BITS{1'b1}}) begin
                        o_qspi_sel_n       <= 0;
                        flash_rd_fsm_state <= flash_rd_fsm_next_state; 
                    end
                end


                /* sends the reset memory command to the flash */
                ISSUE_RESET_MEMORY_CMD: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS - 1)) begin
                            o_qspi_sel_n         <= 1;
                            flash_clk_cycle_cntr <= {SPI_CLK_CYCLE_CNTR_BITS{1'b0}};
                            flash_rd_fsm_state   <= SOFTWARE_RESET_RECOVERY_DELAY;
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end


                /* 
                 * Ensures that the minimum software reset recovery time (tshsl3) is met.
                 *
                 * NOTE: ASSUMES THAT INPUT CLOCK IS RESTRICTED ACCORDING TO COMMENTS AT TOP OF FILE
                 *
                 */
                SOFTWARE_RESET_RECOVERY_DELAY: begin

                    flash_clk_cycle_cntr <= flash_clk_cycle_cntr + 1;

                    if (flash_clk_cycle_cntr == {SPI_CLK_CYCLE_CNTR_BITS{1'b1}}) begin
                        o_qspi_sel_n                 <= 0;
                        flash_dout_cntr              <= '0;
                        flash_dout_next_next_reg     <= {WRITE_VOLATILE_CONFIG_REG_CMD, VOLATILE_CONFIG_REG_VAL, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS - SPI_CMD_DATA_BITS){1'b0}}};
                        flash_rd_fsm_next_next_state <= WRITE_VOLATILE_CONFIG_REG;
                        flash_dout_reg               <= {WRITE_ENABLE_CMD, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS){1'b0}}};
                        flash_rd_fsm_state           <= ISSUE_WRITE_ENABLE_CMD; 
                    end
                end


                /* sends the write enable command to the flash */
                ISSUE_WRITE_ENABLE_CMD: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS - 1)) begin
                            o_qspi_sel_n            <= 1;
                            flash_clk_cycle_cntr    <= '0;
                            flash_dout_next_reg     <= flash_dout_next_next_reg;
                            flash_rd_fsm_next_state <= flash_rd_fsm_next_next_state;
                            flash_rd_fsm_state      <= NON_READ_DESELECT_DELAY;
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end


                /* writes the volatile configuration register of the flash */
                WRITE_VOLATILE_CONFIG_REG: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS + SPI_CMD_DATA_BITS - 1)) begin
                            o_qspi_sel_n                 <= 1;
                            flash_clk_cycle_cntr         <= '0;
                            flash_dout_next_next_reg     <= {WRITE_EVOLATILE_CONFIG_REG_CMD, EVOLATILE_CONFIG_REG_VAL, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS - SPI_CMD_DATA_BITS){1'b0}}};
                            flash_rd_fsm_next_next_state <= WRITE_EVOLATILE_CONFIG_REG;
                            flash_dout_next_reg          <= {WRITE_ENABLE_CMD, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS){1'b0}}};
                            flash_rd_fsm_next_state      <= ISSUE_WRITE_ENABLE_CMD;
                            flash_rd_fsm_state           <= NON_READ_DESELECT_DELAY;
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end


                /* writes enhanced the volatile configuration register of the flash */
                WRITE_EVOLATILE_CONFIG_REG: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS + SPI_CMD_DATA_BITS - 1)) begin
                            
                            /* defaults for when flash density <= 128Mbit */
                            o_qspi_sel_n            <= 1;
                            flash_clk_cycle_cntr    <= '0; 
                            flash_dout_next_reg     <= {QUAD_OUTPUT_FAST_READ_CMD, rd_byte_addr_reg, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS - SPI_ADDR_BITS){1'b0}}}; // 128Mbit or smaller flash so issue regular 3-byte quad output fast read command
                            flash_rd_fsm_next_state <= ISSUE_QUAD_OUTPUT_FAST_RD_CMD;
                            flash_rd_fsm_state      <= NON_READ_DESELECT_DELAY;
                            
                            /* for when flash density > 128Mbit */
                            if (P_256MBIT_OR_LARGER) begin
                                flash_dout_next_next_reg     <= {ENTER_4BYTE_ADDRESS_MODE_CMD, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS){1'b0}}};
                                flash_dout_next_reg          <= {WRITE_ENABLE_CMD, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS){1'b0}}};
                                flash_rd_fsm_next_next_state <= ISSUE_ENTER_4BYTE_ADDRESS_MODE_CMD;
                                flash_rd_fsm_next_state      <= ISSUE_WRITE_ENABLE_CMD;
                            end
                                
                                
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end
                
                
                /* issues the enter 4-byte address mode command to the flash (only needed when the flash density is > 128Mbit) */
                ISSUE_ENTER_4BYTE_ADDRESS_MODE_CMD: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS - 1)) begin
                            o_qspi_sel_n            <= 1;
                            flash_clk_cycle_cntr    <= '0;
                            flash_dout_next_reg     <= {QUAD_OUTPUT_FAST_4BYTE_READ_CMD, rd_byte_addr_reg, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS - SPI_ADDR_BITS){1'b0}}}; // 256Mbit or larger flash so issue 4-byte quad output fast read command
                            flash_rd_fsm_next_state <= ISSUE_QUAD_OUTPUT_FAST_RD_CMD;
                            flash_rd_fsm_state      <= NON_READ_DESELECT_DELAY;
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end
                    

                /* issues the quad output fast read command + address to the flash */
                ISSUE_QUAD_OUTPUT_FAST_RD_CMD: begin
                    
                    die_crossing_flag <= 0;

                    if (o_qspi_clk) begin

                        o_qspi_clk      <= 0;
                        flash_dout_reg  <= flash_dout_reg << 1;
                        flash_dout_cntr <= flash_dout_cntr + 1;

                        if (flash_dout_cntr == (SPI_CMD_BITS + SPI_ADDR_BITS - 1)) begin
                            o_qspi_d0_high_z     <= 1;
                            flash_clk_cycle_cntr <= '0;
                            flash_rd_fsm_state   <= ISSUE_DUMMY_CYCLE_CLOCKS;
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end

                /* issues dummy cycle clocks to the flash */
                ISSUE_DUMMY_CYCLE_CLOCKS: begin

                    if (o_qspi_clk) begin

                        o_qspi_clk <= 0;

                        /* see datasheet Quad Output Fast and 4-Byte Quad Output Fast commands and their respective notes */
                        if (flash_clk_cycle_cntr == 4'h8) begin 
                            flash_rd_fsm_state <= READ_HIGH_NIBBLE;
                        end

                    end else begin
                        o_qspi_clk           <= 1;
                        flash_clk_cycle_cntr <= flash_clk_cycle_cntr + 1;
                    end
                end


                /*
                 * Captures the upper 4-bits of the incoming byte from the flash.
                 *
                 * NOTE: FLASH PRESENTS DATA ON FALLING EDGE OF SPI CLOCK (i.e. on the falling edge of the last dummy clock)
                 *
                 * SEE READ MEMORY OPERATIONS TIMING SECTION IN DATASHEET
                 *
                 */
                READ_HIGH_NIBBLE: begin

                    flash_clk_cycle_cntr <= '0; 

                    /* make sure that i_rd_pause and o_rd_byte_vld didn't simultaneously go high */
                    if ((~i_rd_pause) | (~o_rd_byte_vld)) begin 

                        o_rd_byte_vld <= 0;

                        if (o_qspi_clk) begin
                            o_qspi_clk         <= 0;
                            o_rd_byte[7:4]     <= qspi_din_regs; 
                            flash_rd_fsm_state <= READ_LOW_NIBBLE;
                        end else begin
                            
                            if (flash_byte_cntr == rd_num_bytes_reg) begin // done!
                                o_qspi_sel_n            <= 1;
                                flash_rd_fsm_next_state <= IDLE;
                                flash_rd_fsm_state      <= POST_READ_DESELECT_DELAY;
                                
                            // de-select the flash and issue another quad output fast read command because we've hit the end of the current 256Mbit die
                            end else if (die_crossing_flag) begin 
                                o_qspi_sel_n            <= 1;
                                flash_dout_next_reg     <= {QUAD_OUTPUT_FAST_4BYTE_READ_CMD, rd_byte_addr_reg, {(SPI_DOUT_MAX_BITS - SPI_CMD_BITS - SPI_ADDR_BITS){1'b0}}}; // 256Mbit or larger flash so issue 4-byte quad output fast read command
                                flash_rd_fsm_next_state <= ISSUE_QUAD_OUTPUT_FAST_RD_CMD;
                                flash_rd_fsm_state      <= POST_READ_DESELECT_DELAY;
                            end else begin
                                o_qspi_clk <= 1;
                            end

                        end
                    end
                end

                /* 
                 * captures the lower 4-bits of the incoming byte from the flash and
                 * presents the completed byte to the user.
                 */
                READ_LOW_NIBBLE: begin
                    
                    if (o_qspi_clk) begin

                        o_qspi_clk         <= 0;
                        o_rd_byte[3:0]     <= qspi_din_regs; 
                        o_rd_byte_vld      <= 1;
                        die_crossing_flag  <= 0;
                        flash_byte_cntr    <= flash_byte_cntr + 1;
                        rd_byte_addr_reg   <= rd_byte_addr_reg + 1;
                        flash_rd_fsm_state <= READ_HIGH_NIBBLE;

                        /* check for 256Mbit die crossing (i.e. we're reading the last byte of the current 256Mbit die) */
                        if (P_256MBIT_OR_LARGER) begin
                            if ( (rd_byte_addr_reg == 32'h01ffffff) || (rd_byte_addr_reg == 32'h03ffffff) || (rd_byte_addr_reg == 32'h05ffffff) ) begin
                                die_crossing_flag <= 1;
                            end
                        end

                    end else begin
                        o_qspi_clk <= 1;
                    end
                end

                /* 
                 * Lets the Flash cool off for a second after that blazing fast read.
                 *
                 * I found that the Micron N25Qxxx flash model wouldn't recognize the next Reset Enable command
                 * if the flash chip select wasn't deasserted for long enough after reading the last byte. 
                 *
                 * NOTE: ASSUMES THAT INPUT CLOCK IS RESTRICTED ACCORDING TO COMMENTS AT TOP OF FILE
                 *
                 */
                POST_READ_DESELECT_DELAY: begin

                    flash_clk_cycle_cntr <= flash_clk_cycle_cntr + 1;
                    flash_dout_cntr      <= '0;
                    flash_dout_reg       <= flash_dout_next_reg;

                    if (flash_clk_cycle_cntr == {SPI_CLK_CYCLE_CNTR_BITS{1'b1}}) begin
                        flash_rd_fsm_state <= flash_rd_fsm_next_state; 
                        
                        if (flash_rd_fsm_next_state == ISSUE_QUAD_OUTPUT_FAST_RD_CMD) begin
                            o_qspi_d0_high_z <= 0;
                            o_qspi_sel_n     <= 0;
                        end
                    end
                end

                
                default: begin
                    flash_rd_fsm_state <= IDLE; 
                end

            endcase
        end
    end

endmodule