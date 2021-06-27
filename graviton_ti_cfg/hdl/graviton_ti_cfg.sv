/*
 * Module: graviton_ti_cfg
 * 
 * Handles setting the configuration registers of TI parts on Graviton (i.e. ADC, DAC, LMK clock chips)
 * 
 */
module graviton_ti_cfg #(
    parameter P_SYSCLK_DIV     = 100, // divide down i_sysclk so that TI serial interface runs at 10MHz or slower
    parameter P_SIF_ADDR_BITS  = 8,
    parameter P_SIF_DATA_BITS  = 8,
    parameter P_SIF_RD_WR_BITS = 1,
    parameter P_CFG_ROM_WORDS  = 1,
    parameter P_CFG_ROM_FILE   = "cfg_rom_data.txt"
)(
    input      i_sysclk,
    input      i_srst,
    
    /* COMMAND INTERFACE */

    //intf_cmd.slave cmd, // synchronous to i_sysclk
    input [P_SIF_ADDR_BITS:0]  i_cmd_sif_addr_reg,	//msb will be for cmd_sif_start
	input [P_SIF_DATA_BITS-1:0] i_cmd_sif_wdata_reg,
    /* CONFIG CONTROL */

    input      i_cfg_start,
    output reg o_cfg_done,
    
    /* TI Serial Interface (SIF) */

    output reg o_sif_reset_n,
    output     o_sif_sclk,
    output     o_sif_sel_n,
    output     o_sif_sdout
);
    
    /* PARAMETER RANGE CHECKING */
    initial begin
        assert (P_SYSCLK_DIV     >= 1)                          else $fatal(1, "P_SYSCLK_DIV MUST BE GREATER THAN OR EQUAL TO 1!");
        assert (P_SIF_ADDR_BITS  >= 1)                          else $fatal(1, "P_SIF_ADDR_BITS  MUST BE GREATER THAN OR EQUAL TO 1!");
        assert (P_SIF_DATA_BITS  >= 1)                          else $fatal(1, "P_SIF_DATA_BITS MUST BE GREATER THAN OR EQUAL TO 1!");
        assert (P_SIF_RD_WR_BITS >= 0 && P_SIF_RD_WR_BITS <= 1) else $fatal(1, "P_SIF_RD_WR_BITS MUST BE 0 or 1!");
        assert (P_CFG_ROM_WORDS  >= 1)                          else $fatal(1, "P_CFG_ROM_WORDS MUST BE GREATER THAN OR EQUAL TO 1!");
    end
    
    localparam RST_CNTR_BITS     = (P_SYSCLK_DIV > 1) ? $clog2(P_SYSCLK_DIV) : 1;
    localparam CFG_ROM_WORD_BITS = P_SIF_ADDR_BITS + P_SIF_DATA_BITS;
    localparam CFG_ROM_CNTR_BITS = $clog2(P_CFG_ROM_WORDS);
    
    logic [CFG_ROM_WORD_BITS-1:0] cfg_rom [P_CFG_ROM_WORDS]; 

    logic                       sif_load;
    logic                       sif_done;
    logic [P_SIF_ADDR_BITS-1:0] sif_addr;
    logic [P_SIF_DATA_BITS-1:0] sif_data;
    
    logic [RST_CNTR_BITS-1:0]     rst_cntr;
    logic [CFG_ROM_CNTR_BITS-1:0] cfg_rom_cntr;
    
    
    // logic [P_SIF_ADDR_BITS-1:0] cmd_sif_addr_reg;
    // logic [P_SIF_DATA_BITS-1:0] cmd_sif_wdata_reg;
    logic                       cmd_sif_start;
    assign cmd_sif_start = i_cmd_sif_addr_reg[P_SIF_ADDR_BITS];


    typedef enum { 
        IDLE,
        RESET_TI_CHIP, 
        POST_RESET_DELAY,
        LOAD_SIF_SHIFT_REG,
        WAIT_FOR_SIF,
        WAIT_FOR_CMD
    } CFG_FSM_STATES;
    
    CFG_FSM_STATES cfg_fsm_state;
    
    
    /* Config ROM initialization from file */

    initial begin
        $readmemh(P_CFG_ROM_FILE, cfg_rom, 0, P_CFG_ROM_WORDS-1);  
    end


    /* COMMAND INTERFACE */ 
   // 
   // always_ff @(posedge i_sysclk) begin
   //     
   //     if (i_srst) begin
   //         cmd_sif_start <= 0;
   //         cmd.ack       <= 0;
   //     end else begin
   //         
   //         /* defaults */
   //         cmd_sif_start <= 0;
   //         cmd.ack       <= 0;
   //         
   //         if (cfg_fsm_state == WAIT_FOR_CMD && sif_done == 1) begin
   //             cmd.ack <= 1;
   //         end 
   //
   //         if (cmd.sel) begin
   //             cmd_sif_addr_reg <= cmd.byte_addr[(P_SIF_ADDR_BITS-1)+2:2]; // divide byte addr by 4 to get word addr
   //             cmd_sif_wdata_reg <= cmd.wdata[P_SIF_DATA_BITS-1:0];
   //             cmd_sif_start     <= 1;
   //             // don't ack, wait for SIF interface to complete write
   //         end
   //     end
   // end
    
    
    /* TI Config FSM */
    
    always_ff @(posedge i_sysclk) begin
        
        if (i_srst) begin
            o_cfg_done     <= 0;
            o_sif_reset_n  <= 1;
            sif_load       <= 0;
            cfg_fsm_state  <= IDLE;
        end else begin
            
            /* defaults */
            sif_load <= 0;
             
            case (cfg_fsm_state)
                
                IDLE: begin
                    if (i_cfg_start) begin
                        o_cfg_done     <= 0;
                        rst_cntr       <= {RST_CNTR_BITS{1'b0}};
                        o_sif_reset_n  <= 0;
                        cfg_fsm_state  <= RESET_TI_CHIP;
                    end
                end
                
                RESET_TI_CHIP: begin
                    rst_cntr <= rst_cntr + 1;
                    if (rst_cntr == P_SYSCLK_DIV-1) begin
                        rst_cntr      <= {RST_CNTR_BITS{1'b0}};
                        o_sif_reset_n <= 1;
                        cfg_fsm_state <= POST_RESET_DELAY;
                    end
                end
                    
                POST_RESET_DELAY: begin
                    rst_cntr <= rst_cntr + 1;
                    if (rst_cntr == P_SYSCLK_DIV-1) begin
                        cfg_rom_cntr  <= {CFG_ROM_CNTR_BITS{1'b0}};
                        cfg_fsm_state <= LOAD_SIF_SHIFT_REG;
                    end
                end
                
                LOAD_SIF_SHIFT_REG: begin
                    sif_load      <= 1;
                    sif_addr      <= cfg_rom[cfg_rom_cntr][CFG_ROM_WORD_BITS-1:CFG_ROM_WORD_BITS-P_SIF_ADDR_BITS];
                    sif_data      <= cfg_rom[cfg_rom_cntr][P_SIF_DATA_BITS-1:0];
                    cfg_fsm_state <= WAIT_FOR_SIF;
                end
                
                WAIT_FOR_SIF: begin
                    if (sif_done) begin
                        if (cfg_rom_cntr == P_CFG_ROM_WORDS-1) begin
                            o_cfg_done    <= 1;
                            cfg_fsm_state <= WAIT_FOR_CMD;
                        end else begin
                            cfg_rom_cntr  <= cfg_rom_cntr + 1;
                            cfg_fsm_state <= LOAD_SIF_SHIFT_REG;
                        end
                    end
                end
                
                WAIT_FOR_CMD: begin
                    
                    if (cmd_sif_start) begin
                        sif_load <= 1;
                        sif_addr <= i_cmd_sif_addr_reg[P_SIF_ADDR_BITS-1:0];
                        sif_data <= i_cmd_sif_wdata_reg;
                    end
                    
                end
                
                default: begin
                    o_cfg_done     <= 0;
                    o_sif_reset_n  <= 1;
                    sif_load       <= 0;
                    cfg_fsm_state  <= IDLE;
                end
            endcase
        end
    end
    
    
    /* handles shifting out bits to the TI serial interface (SIF) */

    ti_sif #(
        .P_CLK_DIV        (P_SYSCLK_DIV   ),
        .P_SIF_ADDR_BITS  (P_SIF_ADDR_BITS),
        .P_SIF_DATA_BITS  (P_SIF_DATA_BITS),
        .P_SIF_RD_WR_BITS (P_SIF_RD_WR_BITS)
        ) ti_sif (
        .i_clk       (i_sysclk    ), 
        .i_srst      (i_srst      ), 
        .i_sif_load  (sif_load    ), 
        .i_sif_addr  (sif_addr    ), 
        .i_sif_data  (sif_data    ), 
        .o_sif_done  (sif_done    ), 
        .o_sclk      (o_sif_sclk  ), 
        .o_sel_n     (o_sif_sel_n ), 
        .o_sdout     (o_sif_sdout ));


endmodule
