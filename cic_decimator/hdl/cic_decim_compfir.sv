`timescale 10ps / 10ps

`default_nettype none

module cic_decim_compfir #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph,
    input  wire logic [WIDTH-1:0] i_quad,
    input  wire logic             i_valid,
    output      logic             o_ready,
    output      logic [WIDTH-1:0] o_inph,
    output      logic [WIDTH-1:0] o_quad,
    output      logic             o_inph_pos_oflow,
    output      logic             o_inph_neg_oflow,
    output      logic             o_quad_pos_oflow,
    output      logic             o_quad_neg_oflow,
    output      logic             o_valid,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

localparam integer F_HALF_ORDER = 16;
logic [$clog2(F_HALF_ORDER)-1:0] ready_count;
logic                                    accum_start;
logic                                    accum_finish;

always_ff @(posedge i_clock) begin
    // Counter to determine input pushback
    if (i_reset == 1'b1) begin
        ready_count <= { $clog2(F_HALF_ORDER){ 1'b0 } };
        o_ready <= 1'b0;
        accum_start <= 1'b0;
        accum_finish <= 1'b0;
    end else if ((i_valid & o_ready) == 1'b1) begin
        ready_count <= F_HALF_ORDER-1;
        o_ready <= 1'b0;
        accum_start <= 1'b1;
        accum_finish <= 1'b0;
    end else if (ready_count > 0) begin
        ready_count <= ready_count - 1;
        o_ready <= ready_count == { { ($clog2(F_HALF_ORDER)-1){ 1'b0 } }, 1'b1 };
        accum_start <= 1'b0;
        accum_finish <= ready_count == { { ($clog2(F_HALF_ORDER)-1){ 1'b0 } }, 1'b1 };
    end else begin
        accum_finish <= 1'b0;
        o_ready <= ready_count == { { $clog2(F_HALF_ORDER){ 1'b0 } } };
    end
end

logic signed [17:0] inph_coeff_entry_reg0;
logic signed [17:0] quad_coeff_entry_reg0;
logic signed [17:0] coeff_entry_reg0;
logic               accum_start_reg0;
logic               accum_finish_reg0;

always_ff @ (posedge i_clock) begin
    case (ready_count)
    15: begin
        coeff_entry_reg0 <= 18'sb000000000010100011;
    end
    14: begin
        coeff_entry_reg0 <= 18'sb111111110110001011;
    end
    13: begin
        coeff_entry_reg0 <= 18'sb111111111100100001;
    end
    12: begin
        coeff_entry_reg0 <= 18'sb000000100110001111;
    end
    11: begin
        coeff_entry_reg0 <= 18'sb111111010111111100;
    end
    10: begin
        coeff_entry_reg0 <= 18'sb111111001101101010;
    end
    9: begin
        coeff_entry_reg0 <= 18'sb000010011001101100;
    end
    8: begin
        coeff_entry_reg0 <= 18'sb111110111110010111;
    end
    7: begin
        coeff_entry_reg0 <= 18'sb111100010001101010;
    end
    6: begin
        coeff_entry_reg0 <= 18'sb000101110110110110;
    end
    5: begin
        coeff_entry_reg0 <= 18'sb000000110101100011;
    end
    4: begin
        coeff_entry_reg0 <= 18'sb110101000011010110;
    end
    3: begin
        coeff_entry_reg0 <= 18'sb001000100100010111;
    end
    2: begin
        coeff_entry_reg0 <= 18'sb001010011011110000;
    end
    1: begin
        coeff_entry_reg0 <= 18'sb101010100011100100;
    end
    default: begin
        coeff_entry_reg0 <= 18'sb111110000001110101;
    end
    // Implied center coefficient is 1.0 in Q(2,16) format (no multiply needed)
    endcase
    accum_start_reg0 <= accum_start;
    accum_finish_reg0 <= accum_finish;
end

assign inph_coeff_entry_reg0 = coeff_entry_reg0;
assign quad_coeff_entry_reg0 = coeff_entry_reg0;

// Tap Delay Line
localparam integer F_LENGTH = 2 * F_HALF_ORDER + 1;
logic signed [F_LENGTH*WIDTH-1:0] inph_tdl = { (F_LENGTH*WIDTH){ 1'b0 } };
logic signed [F_LENGTH*WIDTH-1:0] quad_tdl = { (F_LENGTH*WIDTH){ 1'b0 } };
logic signed [WIDTH-1:0]          lhs_inph_reg0;
logic signed [WIDTH-1:0]          lhs_quad_reg0;
logic signed [WIDTH-1:0]          rhs_inph_reg0;
logic signed [WIDTH-1:0]          rhs_quad_reg0;
logic signed [WIDTH-1:0]          mid_inph_reg0;
logic signed [WIDTH-1:0]          mid_quad_reg0;

always_ff @(posedge i_clock) begin
    if ((i_valid & o_ready) == 1'b1) begin
        // Tap Delay Line
        inph_tdl[WIDTH-1-:WIDTH] <= i_inph;
        quad_tdl[WIDTH-1-:WIDTH] <= i_quad;
        for(integer TDL_IDX = 1; TDL_IDX < F_LENGTH; TDL_IDX++) begin
            inph_tdl[(TDL_IDX+1)*WIDTH-1-:WIDTH] <= inph_tdl[TDL_IDX*WIDTH-1-:WIDTH];
            quad_tdl[(TDL_IDX+1)*WIDTH-1-:WIDTH] <= quad_tdl[TDL_IDX*WIDTH-1-:WIDTH];
        end

        // Multiply-free delay (remains in this register until ready goes high again)
        mid_inph_reg0 <= inph_tdl[(F_HALF_ORDER)*WIDTH-1-:WIDTH];
        mid_quad_reg0 <= quad_tdl[(F_HALF_ORDER)*WIDTH-1-:WIDTH];
    end

    // Symmetric delays to the preadders
    case (ready_count)
    15: begin
        lhs_inph_reg0 <= inph_tdl[(0+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(0+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(32+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(32+1)*WIDTH-1-:WIDTH];
    end
    14: begin
        lhs_inph_reg0 <= inph_tdl[(1+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(1+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(31+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(31+1)*WIDTH-1-:WIDTH];
    end
    13: begin
        lhs_inph_reg0 <= inph_tdl[(2+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(2+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(30+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(30+1)*WIDTH-1-:WIDTH];
    end
    12: begin
        lhs_inph_reg0 <= inph_tdl[(3+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(3+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(29+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(29+1)*WIDTH-1-:WIDTH];
    end
    11: begin
        lhs_inph_reg0 <= inph_tdl[(4+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(4+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(28+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(28+1)*WIDTH-1-:WIDTH];
    end
    10: begin
        lhs_inph_reg0 <= inph_tdl[(5+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(5+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(27+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(27+1)*WIDTH-1-:WIDTH];
    end
    9: begin
        lhs_inph_reg0 <= inph_tdl[(6+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(6+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(26+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(26+1)*WIDTH-1-:WIDTH];
    end
    8: begin
        lhs_inph_reg0 <= inph_tdl[(7+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(7+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(25+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(25+1)*WIDTH-1-:WIDTH];
    end
    7: begin
        lhs_inph_reg0 <= inph_tdl[(8+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(8+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(24+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(24+1)*WIDTH-1-:WIDTH];
    end
    6: begin
        lhs_inph_reg0 <= inph_tdl[(9+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(9+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(23+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(23+1)*WIDTH-1-:WIDTH];
    end
    5: begin
        lhs_inph_reg0 <= inph_tdl[(10+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(10+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(22+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(22+1)*WIDTH-1-:WIDTH];
    end
    4: begin
        lhs_inph_reg0 <= inph_tdl[(11+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(11+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(21+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(21+1)*WIDTH-1-:WIDTH];
    end
    3: begin
        lhs_inph_reg0 <= inph_tdl[(12+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(12+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(20+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(20+1)*WIDTH-1-:WIDTH];
    end
    2: begin
        lhs_inph_reg0 <= inph_tdl[(13+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(13+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(19+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(19+1)*WIDTH-1-:WIDTH];
    end
    1: begin
        lhs_inph_reg0 <= inph_tdl[(14+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(14+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(18+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(18+1)*WIDTH-1-:WIDTH];
    end
    0: begin
        lhs_inph_reg0 <= inph_tdl[(15+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(15+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(17+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(17+1)*WIDTH-1-:WIDTH];
    end
    endcase
end

// Preadders
logic signed [WIDTH:0]   inph_preadder_reg1;
logic signed [WIDTH:0]   quad_preadder_reg1;
logic signed [17:0]      inph_coeff_entry_reg1;
logic signed [17:0]      quad_coeff_entry_reg1;
logic signed [WIDTH-1:0] mid_inph_reg1;
logic signed [WIDTH-1:0] mid_quad_reg1;
logic                    accum_start_reg1;
logic                    accum_finish_reg1;

always_ff @(posedge i_clock) begin
    inph_preadder_reg1 <= { lhs_inph_reg0[WIDTH-1], lhs_inph_reg0 } + { rhs_inph_reg0[WIDTH-1], rhs_inph_reg0 };
    quad_preadder_reg1 <= { lhs_quad_reg0[WIDTH-1], lhs_quad_reg0 } + { rhs_quad_reg0[WIDTH-1], rhs_quad_reg0 };
    inph_coeff_entry_reg1 <= inph_coeff_entry_reg0;
    quad_coeff_entry_reg1 <= quad_coeff_entry_reg0;
    accum_start_reg1 <= accum_start_reg0;
    accum_finish_reg1 <= accum_finish_reg0;
    // Store middle value before it is wiped out
    if (accum_finish_reg0 == 1'b1) begin
        mid_inph_reg1 <= mid_inph_reg0;
        mid_quad_reg1 <= mid_quad_reg0;
    end
end

// Multiplication
logic signed [WIDTH+18:0] inph_product_reg2;
logic signed [WIDTH+18:0] quad_product_reg2;
logic                     accum_start_reg2;
logic                     accum_finish_reg2;

always_ff @(posedge i_clock) begin
    inph_product_reg2 <= $signed(inph_preadder_reg1) * $signed(inph_coeff_entry_reg1);
    quad_product_reg2 <= $signed(quad_preadder_reg1) * $signed(quad_coeff_entry_reg1);
    accum_start_reg2 <= accum_start_reg1;
    accum_finish_reg2 <= accum_finish_reg1;
end

// Accumulation
localparam integer MAX_FILTER_GAIN = 20;
logic signed [WIDTH+18+MAX_FILTER_GAIN:0] inph_accum_reg3;
logic signed [WIDTH+18+MAX_FILTER_GAIN:0] quad_accum_reg3;
logic                                     accum_finish_reg3;

always_ff @(posedge i_clock) begin
    if (accum_start_reg2 == 1'b1) begin
        inph_accum_reg3 <= inph_product_reg2;
        quad_accum_reg3 <= quad_product_reg2;
    end else begin
        inph_accum_reg3 <= inph_product_reg2 + inph_accum_reg3;
        quad_accum_reg3 <= quad_product_reg2 + quad_accum_reg3;
    end
    accum_finish_reg3 <= accum_finish_reg2;
end

// Add 1*1 to result (implied coefficient)
logic signed [WIDTH+18+MAX_FILTER_GAIN:0] inph_result_reg4;
logic signed [WIDTH+18+MAX_FILTER_GAIN:0] quad_result_reg4;
logic                                     valid_reg4;

always_ff @(posedge i_clock) begin
    if (accum_finish_reg3 == 1'b1) begin
        inph_result_reg4 <= inph_accum_reg3 + {
            { (MAX_FILTER_GAIN + 3){ mid_inph_reg1[WIDTH-1] } },
            mid_inph_reg1,
            17'b0
        };
        quad_result_reg4 <= quad_accum_reg3 + {
            { (MAX_FILTER_GAIN + 3){ mid_quad_reg1[WIDTH-1] } },
            mid_quad_reg1,
            17'b0
        };
    end
    // Valid signal propagation
    if (i_reset == 1'b1) begin
        valid_reg4 <= 1'b0;
    end else begin
        valid_reg4 <= accum_finish_reg3;
    end
end

// Perform convergent rounding
localparam integer LOG2_DC_GAIN = 15;
logic signed [WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:0] inph_rounded_result_reg5;
logic signed [WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:0] quad_rounded_result_reg5;
logic                                                    valid_reg5;

always_ff @(posedge i_clock) begin
    // In-phase rounding
    if (inph_result_reg4[LOG2_DC_GAIN-1:0] == { 1'b1, { (LOG2_DC_GAIN-1){ 1'b0 } } }) begin
        if (inph_result_reg4[LOG2_DC_GAIN] == 1'b1) begin
            // Round down to nearest odd
            inph_rounded_result_reg5 <= {
                inph_result_reg4[WIDTH+18+MAX_FILTER_GAIN],
                inph_result_reg4[WIDTH+18+MAX_FILTER_GAIN:LOG2_DC_GAIN]
            };
        end else begin
            // Round up to nearest odd
            inph_rounded_result_reg5 <= {
                inph_result_reg4[WIDTH+18+MAX_FILTER_GAIN],
                inph_result_reg4[WIDTH+18+MAX_FILTER_GAIN:LOG2_DC_GAIN]
            } + 1'b1;
        end
    end else begin
        // Usual rounding by adding 1/2 and truncating
        inph_rounded_result_reg5 <= {
            inph_result_reg4[WIDTH+18+MAX_FILTER_GAIN],
            inph_result_reg4[WIDTH+18+MAX_FILTER_GAIN:LOG2_DC_GAIN]
        } + inph_result_reg4[LOG2_DC_GAIN-1];
    end

    // Quadrature Rounding
    if (quad_result_reg4[LOG2_DC_GAIN-1:0] == { 1'b1, { (LOG2_DC_GAIN-1){ 1'b0 } } }) begin
        if (quad_result_reg4[LOG2_DC_GAIN] == 1'b1) begin
            // Round down to nearest odd
            quad_rounded_result_reg5 <= {
                quad_result_reg4[WIDTH+18+MAX_FILTER_GAIN],
                quad_result_reg4[WIDTH+18+MAX_FILTER_GAIN:LOG2_DC_GAIN]
            };
        end else begin
            // Round up to nearest odd
            quad_rounded_result_reg5 <= {
                quad_result_reg4[WIDTH+18+MAX_FILTER_GAIN],
                quad_result_reg4[WIDTH+18+MAX_FILTER_GAIN:LOG2_DC_GAIN]
            } + 1'b1;
        end
    end else begin
        // Usual rounding by adding 1/2 and truncating
        quad_rounded_result_reg5 <= {
            quad_result_reg4[WIDTH+18+MAX_FILTER_GAIN],
            quad_result_reg4[WIDTH+18+MAX_FILTER_GAIN:LOG2_DC_GAIN]
        } + quad_result_reg4[LOG2_DC_GAIN-1];
    end

    // Valid signal propagation
    if (i_reset == 1'b1) begin
        valid_reg5 <= 1'b0;
    end else begin
        valid_reg5 <= valid_reg4;
    end
end

// Perform saturation
always_ff @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        o_inph <= { WIDTH{1'b0} };
        o_quad <= { WIDTH{1'b0} };
        o_inph_pos_oflow <= 1'b0;
        o_inph_neg_oflow <= 1'b0;
        o_quad_pos_oflow <= 1'b0;
        o_quad_neg_oflow <= 1'b0;
        o_valid <= 1'b0;
    end else begin
        // In-Phase Saturation Detection
        if (((&inph_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-16+1:WIDTH-1]) != 1'b1)
                && ((|inph_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-16+1:WIDTH-1]) != 1'b0)) begin
            // Saturation event
            if (inph_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-16+1] == 1'b0) begin
                o_inph_pos_oflow <= 1'b1;
                o_inph_neg_oflow <= 1'b0;
                o_inph <= { 1'b0, { (WIDTH-1){ 1'b1 } } };
            end else begin
                o_inph_pos_oflow <= 1'b0;
                o_inph_neg_oflow <= 1'b1;
                o_inph <= { 1'b1, { (WIDTH-1){ 1'b0 } } };
            end
        end else begin
            // No saturation event
            o_inph_pos_oflow <= 1'b0;
            o_inph_neg_oflow <= 1'b0;
            o_inph <= inph_rounded_result_reg5[WIDTH-1:0];
        end

        // Quadrature Saturation Detection
        if (((&quad_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-16+1:WIDTH-1]) != 1'b1)
                && ((|quad_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-16+1:WIDTH-1]) != 1'b0)) begin
            // Saturation event
            if (quad_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-16+1] == 1'b0) begin
                o_quad_pos_oflow <= 1'b1;
                o_quad_neg_oflow <= 1'b0;
                o_quad <= { 1'b0, { (WIDTH-1){ 1'b1 } } };
            end else begin
                o_quad_pos_oflow <= 1'b0;
                o_quad_neg_oflow <= 1'b1;
                o_quad <= { 1'b1, { (WIDTH-1){ 1'b0 } } };
            end
        end else begin
            // No saturation event
            o_quad_pos_oflow <= 1'b0;
            o_quad_neg_oflow <= 1'b0;
            o_quad <= quad_rounded_result_reg5[WIDTH-1:0];
        end

        o_valid <= valid_reg5;
    end
end

endmodule: cic_decim_compfir

`default_nettype wire
