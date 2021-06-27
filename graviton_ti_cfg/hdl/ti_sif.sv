/*
 * Module: ti_sif
 * 
 * Only supports writes to TI SIF registers currently
 * 
 */
module ti_sif #(
    
    parameter P_CLK_DIV        = 100, // set this to divide down i_clk to 10MHz or slower
    parameter P_SIF_ADDR_BITS  = 8,
    parameter P_SIF_DATA_BITS  = 8,
    parameter P_SIF_RD_WR_BITS = 1
)(
        
    input                            i_clk,
    input                            i_srst,
    
    input                            i_sif_load,
    input      [P_SIF_ADDR_BITS-1:0] i_sif_addr,
    input      [P_SIF_DATA_BITS-1:0] i_sif_data,
    output reg                       o_sif_done,
    
    output reg                       o_sclk,
    output reg                       o_sel_n,
    output reg                       o_sdout

);

    /* PARAMETER RANGE CHECKING */
    initial begin
        assert (P_CLK_DIV        >= 1)                          else $fatal(1, "P_CLK_DIV MUST BE GREATER THAN OR EQUAL TO 1!");
        assert (P_SIF_ADDR_BITS  >= 1)                          else $fatal(1, "P_SIF_ADDR_BITS  MUST BE GREATER THAN OR EQUAL TO 1!");
        assert (P_SIF_DATA_BITS  >= 1)                          else $fatal(1, "P_SIF_DATA_BITS MUST BE GREATER THAN OR EQUAL TO 1!");
        assert (P_SIF_RD_WR_BITS >= 0 && P_SIF_RD_WR_BITS <= 1) else $fatal(1, "P_SIF_RD_WR_BITS MUST BE 0 or 1!");
    end

    localparam CLK_CNTR_BITS   = (P_CLK_DIV > 1) ? $clog2(P_CLK_DIV) : 1;
    localparam SHIFT_REG_BITS  = P_SIF_RD_WR_BITS + P_SIF_ADDR_BITS + P_SIF_DATA_BITS; 
    localparam SHIFT_CNTR_BITS = $clog2(SHIFT_REG_BITS) + 1; // extra bit to avoid counter wrap around issues

    logic [CLK_CNTR_BITS-1:0]     sif_clk_cntr;
    logic                         sif_clk;       
    logic                         sif_clk_reg;
    logic                         sif_clk_redge; 
    logic                         sif_clk_fedge; 
    logic [SHIFT_REG_BITS-1:0]    sif_shift_reg;
    logic [SHIFT_CNTR_BITS-1:0]   sif_shift_cntr;
    logic                         sif_sclk;
    logic                         sif_sel_n;
    logic                         sif_sdout;
    
    enum {
        IDLE,
        SYNC_TO_FEDGE,
        SHIFT
    } sif_fsm_state;
    
    
    /*
     *  Counter to divide down the provided clock so we don't run the SIF interface too fast (10MHz is its max)
     */
    
    always_ff @(posedge i_clk) begin
        if (i_srst) begin
            sif_clk       <= 0;
            sif_clk_reg   <= 0;
            sif_clk_cntr  <= {CLK_CNTR_BITS{1'b0}};
        end else begin
            sif_clk_cntr <= sif_clk_cntr + 1;
            sif_clk_reg  <= sif_clk;
            if (sif_clk_cntr == (P_CLK_DIV - 1)) begin
                sif_clk      <= ~sif_clk;
                sif_clk_cntr <= {CLK_CNTR_BITS{1'b0}};
            end
        end
    end
            
    assign sif_clk_redge = sif_clk     & ~sif_clk_reg;
    assign sif_clk_fedge = sif_clk_reg & ~sif_clk;
    
    /*
     * SIF shift register FSM
     */
    
    always_ff @(posedge i_clk) begin
        
        if (i_srst) begin
            
            sif_sclk      <= 0;
            sif_sel_n     <= 1;
            o_sif_done    <= 0;
            sif_fsm_state <= IDLE;
            
        end else begin
            
            /* defaults */
            o_sif_done <= 0;
            
            case (sif_fsm_state)
                
                IDLE: begin

                    sif_sclk  <= 0;
                    sif_sel_n <= 1;
                    
                    if (i_sif_load) begin
                        if (P_SIF_RD_WR_BITS == 1) begin
                            sif_shift_reg  <= {1'b0, i_sif_addr, i_sif_data}; // currently we only support sif writes
                        end else begin
                            sif_shift_reg  <= {i_sif_addr, i_sif_data}; 
                        end
                        sif_shift_cntr <= {SHIFT_CNTR_BITS{1'b0}};
                        sif_fsm_state  <= SYNC_TO_FEDGE;
                    end
                end
                
                SYNC_TO_FEDGE: begin
                    
                    if (sif_clk_fedge) begin
                        sif_sel_n     <= 0;
                        sif_sdout     <= sif_shift_reg[SHIFT_REG_BITS-1];
                        sif_shift_reg <= {sif_shift_reg[SHIFT_REG_BITS-2:0], 1'b0};
                        sif_fsm_state <= SHIFT;
                    end
                end
                
                SHIFT: begin
                    
                    if (sif_clk_redge) begin
                        sif_sclk       <= 1;
                        sif_shift_cntr <= sif_shift_cntr + 1; 
                    end
                    
                    if (sif_clk_fedge) begin
                        sif_sclk      <= 0;
                        sif_sdout     <= sif_shift_reg[SHIFT_REG_BITS-1];
                        sif_shift_reg <= {sif_shift_reg[SHIFT_REG_BITS-2:0], 1'b0};
                        
                        if (sif_shift_cntr == SHIFT_REG_BITS) begin
                            sif_sel_n     <= 1;
                            o_sif_done    <= 1;
                            sif_fsm_state <= IDLE;
                        end
                    end
                    
                end
                
                default: begin
                    sif_fsm_state <= IDLE;
                    sif_sel_n     <= 1;
                    sif_sclk      <= 0;
                end
            endcase
        end
    end
    
    /*
     * Re-register the SIF interface signals because Lattice doesn't like IO registers having resets for whatever reason.
     */
    
    always_ff @(posedge i_clk) begin
        o_sclk  <= sif_sclk;
        o_sel_n <= sif_sel_n;
        o_sdout <= sif_sdout;
    end

endmodule
