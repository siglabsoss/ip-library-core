`timescale 10ps / 10ps

`default_nettype none

module cic_interp_compfir #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph,
    input  wire logic [WIDTH-1:0] i_quad,
    output      logic             o_ready,
    output      logic [WIDTH-1:0] o_inph,
    output      logic [WIDTH-1:0] o_quad,
    output      logic             o_inph_pos_oflow,
    output      logic             o_inph_neg_oflow,
    output      logic             o_quad_pos_oflow,
    output      logic             o_quad_neg_oflow,
    input  wire logic             i_ready,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

localparam integer F_HALF_ORDER = 47;
logic [$clog2(F_HALF_ORDER)-1:0] ready_count;
logic                                    accum_start;
logic                                    accum_finish;

always_ff @(posedge i_clock) begin
    // Counter to determine input pushback
    if (i_reset == 1'b1) begin
        ready_count <= { $clog2(F_HALF_ORDER){ 1'b0 } };
        accum_start <= 1'b0;
        accum_finish <= 1'b0;
    end else if (i_ready == 1'b1) begin
        ready_count <= F_HALF_ORDER-1;
        accum_start <= 1'b1;
        accum_finish <= 1'b0;
    end else if (ready_count > 0) begin
        ready_count <= ready_count - 1;
        accum_start <= 1'b0;
        accum_finish <= ready_count == { { ($clog2(F_HALF_ORDER)-1){ 1'b0 } }, 1'b1 };
    end else begin
        accum_finish <= 1'b0;
    end
end

assign o_ready = i_ready;

logic signed [17:0] inph_coeff_entry_reg0;
logic signed [17:0] quad_coeff_entry_reg0;
logic signed [17:0] coeff_entry_reg0;
logic               accum_start_reg0;
logic               accum_finish_reg0;

always_ff @ (posedge i_clock) begin
    case (ready_count)
    46: begin
        coeff_entry_reg0 <= 18'sb000000000000100000;
    end
    45: begin
        coeff_entry_reg0 <= 18'sb000000000000010000;
    end
    44: begin
        coeff_entry_reg0 <= 18'sb111111111101101100;
    end
    43: begin
        coeff_entry_reg0 <= 18'sb111111111011101111;
    end
    42: begin
        coeff_entry_reg0 <= 18'sb111111111111010000;
    end
    41: begin
        coeff_entry_reg0 <= 18'sb000000000100011001;
    end
    40: begin
        coeff_entry_reg0 <= 18'sb000000000001001101;
    end
    39: begin
        coeff_entry_reg0 <= 18'sb111111111001010110;
    end
    38: begin
        coeff_entry_reg0 <= 18'sb111111111100111111;
    end
    37: begin
        coeff_entry_reg0 <= 18'sb000000001001010001;
    end
    36: begin
        coeff_entry_reg0 <= 18'sb000000000101101101;
    end
    35: begin
        coeff_entry_reg0 <= 18'sb111111110011100101;
    end
    34: begin
        coeff_entry_reg0 <= 18'sb111111110110011000;
    end
    33: begin
        coeff_entry_reg0 <= 18'sb000000010000000100;
    end
    32: begin
        coeff_entry_reg0 <= 18'sb000000001111000100;
    end
    31: begin
        coeff_entry_reg0 <= 18'sb111111101011110101;
    end
    30: begin
        coeff_entry_reg0 <= 18'sb111111101001101010;
    end
    29: begin
        coeff_entry_reg0 <= 18'sb000000011000100111;
    end
    28: begin
        coeff_entry_reg0 <= 18'sb000000011111110110;
    end
    27: begin
        coeff_entry_reg0 <= 18'sb111111100010110000;
    end
    26: begin
        coeff_entry_reg0 <= 18'sb111111010011111110;
    end
    25: begin
        coeff_entry_reg0 <= 18'sb000000100001111000;
    end
    24: begin
        coeff_entry_reg0 <= 18'sb000000111011011000;
    end
    23: begin
        coeff_entry_reg0 <= 18'sb111111011001110101;
    end
    22: begin
        coeff_entry_reg0 <= 18'sb111110110001100010;
    end
    21: begin
        coeff_entry_reg0 <= 18'sb000000101001101111;
    end
    20: begin
        coeff_entry_reg0 <= 18'sb000001100110000010;
    end
    19: begin
        coeff_entry_reg0 <= 18'sb111111010100000001;
    end
    18: begin
        coeff_entry_reg0 <= 18'sb111101111101000100;
    end
    17: begin
        coeff_entry_reg0 <= 18'sb000000101100001001;
    end
    16: begin
        coeff_entry_reg0 <= 18'sb000010100110010111;
    end
    15: begin
        coeff_entry_reg0 <= 18'sb111111010111000010;
    end
    14: begin
        coeff_entry_reg0 <= 18'sb111100101110000110;
    end
    13: begin
        coeff_entry_reg0 <= 18'sb000000100000101000;
    end
    12: begin
        coeff_entry_reg0 <= 18'sb000100000111111001;
    end
    11: begin
        coeff_entry_reg0 <= 18'sb111111110000000010;
    end
    10: begin
        coeff_entry_reg0 <= 18'sb111010110100010001;
    end
    9: begin
        coeff_entry_reg0 <= 18'sb111111110001010110;
    end
    8: begin
        coeff_entry_reg0 <= 18'sb000110100010100101;
    end
    7: begin
        coeff_entry_reg0 <= 18'sb000001000110011101;
    end
    6: begin
        coeff_entry_reg0 <= 18'sb110111101100000010;
    end
    5: begin
        coeff_entry_reg0 <= 18'sb111101010000001110;
    end
    4: begin
        coeff_entry_reg0 <= 18'sb001010101000011011;
    end
    3: begin
        coeff_entry_reg0 <= 18'sb000110000110010100;
    end
    2: begin
        coeff_entry_reg0 <= 18'sb110010101000000100;
    end
    1: begin
        coeff_entry_reg0 <= 18'sb110010010011011101;
    end
    default: begin
        coeff_entry_reg0 <= 18'sb001101111000111101;
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
logic signed [F_LENGTH*WIDTH-1:0] inph_tdl = '0;
logic signed [F_LENGTH*WIDTH-1:0] quad_tdl = '0;
logic signed [WIDTH-1:0]          lhs_inph_reg0;
logic signed [WIDTH-1:0]          lhs_quad_reg0;
logic signed [WIDTH-1:0]          rhs_inph_reg0;
logic signed [WIDTH-1:0]          rhs_quad_reg0;
logic signed [WIDTH-1:0]          mid_inph_reg0;
logic signed [WIDTH-1:0]          mid_quad_reg0;

always_ff @(posedge i_clock) begin
    if (i_ready == 1'b1) begin
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
    46: begin
        lhs_inph_reg0 <= inph_tdl[(0+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(0+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(94+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(94+1)*WIDTH-1-:WIDTH];
    end
    45: begin
        lhs_inph_reg0 <= inph_tdl[(1+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(1+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(93+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(93+1)*WIDTH-1-:WIDTH];
    end
    44: begin
        lhs_inph_reg0 <= inph_tdl[(2+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(2+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(92+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(92+1)*WIDTH-1-:WIDTH];
    end
    43: begin
        lhs_inph_reg0 <= inph_tdl[(3+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(3+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(91+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(91+1)*WIDTH-1-:WIDTH];
    end
    42: begin
        lhs_inph_reg0 <= inph_tdl[(4+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(4+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(90+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(90+1)*WIDTH-1-:WIDTH];
    end
    41: begin
        lhs_inph_reg0 <= inph_tdl[(5+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(5+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(89+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(89+1)*WIDTH-1-:WIDTH];
    end
    40: begin
        lhs_inph_reg0 <= inph_tdl[(6+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(6+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(88+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(88+1)*WIDTH-1-:WIDTH];
    end
    39: begin
        lhs_inph_reg0 <= inph_tdl[(7+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(7+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(87+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(87+1)*WIDTH-1-:WIDTH];
    end
    38: begin
        lhs_inph_reg0 <= inph_tdl[(8+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(8+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(86+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(86+1)*WIDTH-1-:WIDTH];
    end
    37: begin
        lhs_inph_reg0 <= inph_tdl[(9+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(9+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(85+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(85+1)*WIDTH-1-:WIDTH];
    end
    36: begin
        lhs_inph_reg0 <= inph_tdl[(10+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(10+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(84+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(84+1)*WIDTH-1-:WIDTH];
    end
    35: begin
        lhs_inph_reg0 <= inph_tdl[(11+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(11+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(83+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(83+1)*WIDTH-1-:WIDTH];
    end
    34: begin
        lhs_inph_reg0 <= inph_tdl[(12+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(12+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(82+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(82+1)*WIDTH-1-:WIDTH];
    end
    33: begin
        lhs_inph_reg0 <= inph_tdl[(13+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(13+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(81+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(81+1)*WIDTH-1-:WIDTH];
    end
    32: begin
        lhs_inph_reg0 <= inph_tdl[(14+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(14+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(80+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(80+1)*WIDTH-1-:WIDTH];
    end
    31: begin
        lhs_inph_reg0 <= inph_tdl[(15+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(15+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(79+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(79+1)*WIDTH-1-:WIDTH];
    end
    30: begin
        lhs_inph_reg0 <= inph_tdl[(16+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(16+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(78+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(78+1)*WIDTH-1-:WIDTH];
    end
    29: begin
        lhs_inph_reg0 <= inph_tdl[(17+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(17+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(77+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(77+1)*WIDTH-1-:WIDTH];
    end
    28: begin
        lhs_inph_reg0 <= inph_tdl[(18+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(18+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(76+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(76+1)*WIDTH-1-:WIDTH];
    end
    27: begin
        lhs_inph_reg0 <= inph_tdl[(19+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(19+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(75+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(75+1)*WIDTH-1-:WIDTH];
    end
    26: begin
        lhs_inph_reg0 <= inph_tdl[(20+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(20+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(74+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(74+1)*WIDTH-1-:WIDTH];
    end
    25: begin
        lhs_inph_reg0 <= inph_tdl[(21+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(21+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(73+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(73+1)*WIDTH-1-:WIDTH];
    end
    24: begin
        lhs_inph_reg0 <= inph_tdl[(22+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(22+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(72+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(72+1)*WIDTH-1-:WIDTH];
    end
    23: begin
        lhs_inph_reg0 <= inph_tdl[(23+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(23+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(71+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(71+1)*WIDTH-1-:WIDTH];
    end
    22: begin
        lhs_inph_reg0 <= inph_tdl[(24+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(24+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(70+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(70+1)*WIDTH-1-:WIDTH];
    end
    21: begin
        lhs_inph_reg0 <= inph_tdl[(25+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(25+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(69+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(69+1)*WIDTH-1-:WIDTH];
    end
    20: begin
        lhs_inph_reg0 <= inph_tdl[(26+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(26+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(68+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(68+1)*WIDTH-1-:WIDTH];
    end
    19: begin
        lhs_inph_reg0 <= inph_tdl[(27+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(27+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(67+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(67+1)*WIDTH-1-:WIDTH];
    end
    18: begin
        lhs_inph_reg0 <= inph_tdl[(28+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(28+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(66+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(66+1)*WIDTH-1-:WIDTH];
    end
    17: begin
        lhs_inph_reg0 <= inph_tdl[(29+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(29+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(65+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(65+1)*WIDTH-1-:WIDTH];
    end
    16: begin
        lhs_inph_reg0 <= inph_tdl[(30+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(30+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(64+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(64+1)*WIDTH-1-:WIDTH];
    end
    15: begin
        lhs_inph_reg0 <= inph_tdl[(31+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(31+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(63+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(63+1)*WIDTH-1-:WIDTH];
    end
    14: begin
        lhs_inph_reg0 <= inph_tdl[(32+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(32+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(62+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(62+1)*WIDTH-1-:WIDTH];
    end
    13: begin
        lhs_inph_reg0 <= inph_tdl[(33+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(33+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(61+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(61+1)*WIDTH-1-:WIDTH];
    end
    12: begin
        lhs_inph_reg0 <= inph_tdl[(34+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(34+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(60+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(60+1)*WIDTH-1-:WIDTH];
    end
    11: begin
        lhs_inph_reg0 <= inph_tdl[(35+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(35+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(59+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(59+1)*WIDTH-1-:WIDTH];
    end
    10: begin
        lhs_inph_reg0 <= inph_tdl[(36+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(36+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(58+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(58+1)*WIDTH-1-:WIDTH];
    end
    9: begin
        lhs_inph_reg0 <= inph_tdl[(37+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(37+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(57+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(57+1)*WIDTH-1-:WIDTH];
    end
    8: begin
        lhs_inph_reg0 <= inph_tdl[(38+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(38+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(56+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(56+1)*WIDTH-1-:WIDTH];
    end
    7: begin
        lhs_inph_reg0 <= inph_tdl[(39+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(39+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(55+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(55+1)*WIDTH-1-:WIDTH];
    end
    6: begin
        lhs_inph_reg0 <= inph_tdl[(40+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(40+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(54+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(54+1)*WIDTH-1-:WIDTH];
    end
    5: begin
        lhs_inph_reg0 <= inph_tdl[(41+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(41+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(53+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(53+1)*WIDTH-1-:WIDTH];
    end
    4: begin
        lhs_inph_reg0 <= inph_tdl[(42+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(42+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(52+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(52+1)*WIDTH-1-:WIDTH];
    end
    3: begin
        lhs_inph_reg0 <= inph_tdl[(43+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(43+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(51+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(51+1)*WIDTH-1-:WIDTH];
    end
    2: begin
        lhs_inph_reg0 <= inph_tdl[(44+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(44+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(50+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(50+1)*WIDTH-1-:WIDTH];
    end
    1: begin
        lhs_inph_reg0 <= inph_tdl[(45+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(45+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(49+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(49+1)*WIDTH-1-:WIDTH];
    end
    0: begin
        lhs_inph_reg0 <= inph_tdl[(46+1)*WIDTH-1-:WIDTH];
        lhs_quad_reg0 <= quad_tdl[(46+1)*WIDTH-1-:WIDTH];
        rhs_inph_reg0 <= inph_tdl[(48+1)*WIDTH-1-:WIDTH];
        rhs_quad_reg0 <= quad_tdl[(48+1)*WIDTH-1-:WIDTH];
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
    if (i_reset == 1'b1) begin
        inph_accum_reg3 <= '0;
        quad_accum_reg3 <= '0;
    end else if (accum_start_reg2 == 1'b1) begin
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
end

// Perform convergent rounding
localparam integer LOG2_DC_GAIN = 17;
logic signed [WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:0] inph_rounded_result_reg5;
logic signed [WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:0] quad_rounded_result_reg5;

always_ff @(posedge i_clock) begin
    if (i_ready == 1'b1) begin
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
    end else begin
        // In-Phase Saturation Detection
        if (((&inph_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:WIDTH-1]) != 1'b1)
                && ((|inph_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:WIDTH-1]) != 1'b0)) begin
            // Saturation event
            if (inph_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1] == 1'b0) begin
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
        if (((&quad_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:WIDTH-1]) != 1'b1)
                && ((|quad_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1:WIDTH-1]) != 1'b0)) begin
            // Saturation event
            if (quad_rounded_result_reg5[WIDTH+18+MAX_FILTER_GAIN-LOG2_DC_GAIN+1] == 1'b0) begin
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
    end
end

endmodule: cic_interp_compfir

`default_nettype wire
