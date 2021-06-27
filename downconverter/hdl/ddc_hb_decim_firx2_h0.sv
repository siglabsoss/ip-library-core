`timescale 10ps / 10ps

`default_nettype none

module ddc_hb_decim_firx2_h0 #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_quad_data,
    input  wire logic [WIDTH-1:0] i_inph_delay_data,
    input  wire logic [WIDTH-1:0] i_quad_delay_data,
    input  wire logic             i_valid,
    output      logic [WIDTH-1:0] o_inph_data,
    output      logic [WIDTH-1:0] o_quad_data,
    output      logic             o_valid,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

// Tap delay line registers

logic signed [WIDTH-1:0]       inph_tdl0_reg0;
logic signed [WIDTH-1:0]       quad_tdl0_reg0;

logic signed [WIDTH-1:0]       inph_tdl0_reg1;
logic signed [WIDTH-1:0]       quad_tdl0_reg1;

logic signed [WIDTH-1:0]       inph_tdl0_reg2;
logic signed [WIDTH-1:0]       quad_tdl0_reg2;

logic signed [WIDTH-1:0]       inph_tdl0_reg3;
logic signed [WIDTH-1:0]       quad_tdl0_reg3;

logic signed [WIDTH-1:0]       inph_tdl0_reg4;
logic signed [WIDTH-1:0]       quad_tdl0_reg4;

logic signed [WIDTH-1:0]       inph_tdl0_reg5;
logic signed [WIDTH-1:0]       quad_tdl0_reg5;

logic signed [WIDTH-1:0]       inph_tdl0_reg6;
logic signed [WIDTH-1:0]       quad_tdl0_reg6;

logic signed [WIDTH-1:0]       inph_tdl0_reg7;
logic signed [WIDTH-1:0]       quad_tdl0_reg7;

logic signed [WIDTH-1:0]       inph_tdl1_reg0;
logic signed [WIDTH-1:0]       quad_tdl1_reg0;

logic signed [WIDTH-1:0]       inph_tdl1_reg1;
logic signed [WIDTH-1:0]       quad_tdl1_reg1;

logic signed [WIDTH-1:0]       inph_tdl1_reg2;
logic signed [WIDTH-1:0]       quad_tdl1_reg2;

logic signed [WIDTH-1:0]       inph_tdl1_reg3;
logic signed [WIDTH-1:0]       quad_tdl1_reg3;

logic valid0_reg0;

always_ff @ (posedge i_clock) begin
    // Tap delay line for polyphase component zero
    if (i_valid == 1'b1) begin
        inph_tdl0_reg0 <= i_inph_data;
        quad_tdl0_reg0 <= i_quad_data;
        inph_tdl0_reg1 <= inph_tdl0_reg0;
        quad_tdl0_reg1 <= quad_tdl0_reg0;
        inph_tdl0_reg2 <= inph_tdl0_reg1;
        quad_tdl0_reg2 <= quad_tdl0_reg1;
        inph_tdl0_reg3 <= inph_tdl0_reg2;
        quad_tdl0_reg3 <= quad_tdl0_reg2;
        inph_tdl0_reg4 <= inph_tdl0_reg3;
        quad_tdl0_reg4 <= quad_tdl0_reg3;
        inph_tdl0_reg5 <= inph_tdl0_reg4;
        quad_tdl0_reg5 <= quad_tdl0_reg4;
        inph_tdl0_reg6 <= inph_tdl0_reg5;
        quad_tdl0_reg6 <= quad_tdl0_reg5;
        inph_tdl0_reg7 <= inph_tdl0_reg6;
        quad_tdl0_reg7 <= quad_tdl0_reg6;
    end
    // Tap delay line for polyphase component one (delay + shift)
    if (i_valid == 1'b1) begin
        inph_tdl1_reg0 <= i_inph_delay_data;
        quad_tdl1_reg0 <= i_quad_delay_data;
        inph_tdl1_reg1 <= inph_tdl1_reg0;
        quad_tdl1_reg1 <= quad_tdl1_reg0;
        inph_tdl1_reg2 <= inph_tdl1_reg1;
        quad_tdl1_reg2 <= quad_tdl1_reg1;
        inph_tdl1_reg3 <= inph_tdl1_reg2;
        quad_tdl1_reg3 <= quad_tdl1_reg2;
    end
    // Compute an output for this input
    valid0_reg0 <= i_valid;
end


logic signed [WIDTH-1:0] inph_term_reg0;
logic signed [WIDTH-1:0] quad_term_reg0;

logic signed [WIDTH-1:0] inph_term_reg1;
logic signed [WIDTH-1:0] quad_term_reg1;

logic signed [WIDTH-1:0] inph_term_reg2;
logic signed [WIDTH-1:0] quad_term_reg2;

logic signed [WIDTH-1:0] inph_term_reg3;
logic signed [WIDTH-1:0] quad_term_reg3;

logic signed [WIDTH-1:0] inph_term_reg4;
logic signed [WIDTH-1:0] quad_term_reg4;

logic signed [WIDTH-1:0] inph_term_reg5;
logic signed [WIDTH-1:0] quad_term_reg5;

logic signed [WIDTH-1:0] inph_term_reg6;
logic signed [WIDTH-1:0] quad_term_reg6;

logic signed [WIDTH-1:0] inph_term_reg7;
logic signed [WIDTH-1:0] quad_term_reg7;

logic signed [WIDTH:0] inph_sum_reg0;
logic signed [WIDTH:0] quad_sum_reg0;

logic signed [WIDTH:0] inph_sum_reg1;
logic signed [WIDTH:0] quad_sum_reg1;

logic signed [WIDTH:0] inph_sum_reg2;
logic signed [WIDTH:0] quad_sum_reg2;

logic signed [WIDTH:0] inph_sum_reg3;
logic signed [WIDTH:0] quad_sum_reg3;

logic signed [18+WIDTH:0] inph_prod_reg0;
logic signed [18+WIDTH:0] quad_prod_reg0;

logic signed [18+WIDTH:0] inph_prod_reg1;
logic signed [18+WIDTH:0] quad_prod_reg1;

logic signed [18+WIDTH:0] inph_prod_reg2;
logic signed [18+WIDTH:0] quad_prod_reg2;

logic signed [18+WIDTH:0] inph_prod_reg3;
logic signed [18+WIDTH:0] quad_prod_reg3;


logic signed [WIDTH-1:0] inph_del_reg0;
logic signed [WIDTH-1:0] quad_del_reg0;

logic signed [WIDTH-1:0] inph_del_reg1;
logic signed [WIDTH-1:0] quad_del_reg1;

logic signed [WIDTH-1:0] inph_del_reg2;
logic signed [WIDTH-1:0] quad_del_reg2;

logic signed [WIDTH-1:0] inph_del_reg3;
logic signed [WIDTH-1:0] quad_del_reg3;

logic valid1_reg0;
logic valid1_reg1;
logic valid1_reg2;
logic valid1_reg3;

always_ff @ (posedge i_clock) begin
    // Preadders for E0(z)
    if (i_valid == 1'b1) begin
        inph_term_reg0 <= i_inph_data;
        quad_term_reg0 <= i_quad_data;
    end

    inph_term_reg1 <= inph_tdl0_reg1;
    quad_term_reg1 <= quad_tdl0_reg1;

    inph_term_reg2 <= inph_tdl0_reg2;
    quad_term_reg2 <= quad_tdl0_reg2;

    inph_term_reg3 <= inph_tdl0_reg3;
    quad_term_reg3 <= quad_tdl0_reg3;

    inph_term_reg4 <= inph_tdl0_reg4;
    quad_term_reg4 <= quad_tdl0_reg4;

    inph_term_reg5 <= inph_tdl0_reg5;
    quad_term_reg5 <= quad_tdl0_reg5;

    inph_term_reg6 <= inph_tdl0_reg6;
    quad_term_reg6 <= quad_tdl0_reg6;

    inph_term_reg7 <= inph_tdl0_reg7;
    quad_term_reg7 <= quad_tdl0_reg7;

    // Preadder addition
    inph_sum_reg0 <= { inph_term_reg0[WIDTH-1], inph_term_reg0 } + { inph_term_reg7[WIDTH-1], inph_term_reg7 };
    quad_sum_reg0 <= { quad_term_reg0[WIDTH-1], quad_term_reg0 } + { quad_term_reg7[WIDTH-1], quad_term_reg7 };

    inph_sum_reg1 <= { inph_term_reg1[WIDTH-1], inph_term_reg1 } + { inph_term_reg6[WIDTH-1], inph_term_reg6 };
    quad_sum_reg1 <= { quad_term_reg1[WIDTH-1], quad_term_reg1 } + { quad_term_reg6[WIDTH-1], quad_term_reg6 };

    inph_sum_reg2 <= { inph_term_reg2[WIDTH-1], inph_term_reg2 } + { inph_term_reg5[WIDTH-1], inph_term_reg5 };
    quad_sum_reg2 <= { quad_term_reg2[WIDTH-1], quad_term_reg2 } + { quad_term_reg5[WIDTH-1], quad_term_reg5 };

    inph_sum_reg3 <= { inph_term_reg3[WIDTH-1], inph_term_reg3 } + { inph_term_reg4[WIDTH-1], inph_term_reg4 };
    quad_sum_reg3 <= { quad_term_reg3[WIDTH-1], quad_term_reg3 } + { quad_term_reg4[WIDTH-1], quad_term_reg4 };

    inph_prod_reg0 <= $signed(18'sb111111111000100110) * $signed(inph_sum_reg0);
    quad_prod_reg0 <= $signed(18'sb111111111000100110) * $signed(quad_sum_reg0);

    inph_prod_reg1 <= $signed(18'sb000000111011101010) * $signed(inph_sum_reg1);
    quad_prod_reg1 <= $signed(18'sb000000111011101010) * $signed(quad_sum_reg1);

    inph_prod_reg2 <= $signed(18'sb111011111001001101) * $signed(inph_sum_reg2);
    quad_prod_reg2 <= $signed(18'sb111011111001001101) * $signed(quad_sum_reg2);

    inph_prod_reg3 <= $signed(18'sb010011010010100010) * $signed(inph_sum_reg3);
    quad_prod_reg3 <= $signed(18'sb010011010010100010) * $signed(quad_sum_reg3);


    // Pipeline delays for E1(z)
    inph_del_reg0 <= inph_tdl1_reg3;
    quad_del_reg0 <= quad_tdl1_reg3;

    inph_del_reg1 <= inph_del_reg0;
    quad_del_reg1 <= quad_del_reg0;

    inph_del_reg2 <= inph_del_reg1;
    quad_del_reg2 <= quad_del_reg1;

    inph_del_reg3 <= inph_del_reg2;
    quad_del_reg3 <= quad_del_reg2;

    valid1_reg0 <= valid0_reg0;
    valid1_reg1 <= valid1_reg0;
    valid1_reg2 <= valid1_reg1;
    valid1_reg3 <= valid1_reg2;
end


logic signed [53:0] inph_accum0_reg0;
logic signed [53:0] quad_accum0_reg0;

logic signed [53:0] inph_accum0_reg1;
logic signed [53:0] quad_accum0_reg1;

logic signed [WIDTH-1:0] inph_del_reg4;
logic signed [WIDTH-1:0] quad_del_reg4;

logic valid1_reg4;

always_ff @ (posedge i_clock) begin
    // Adder trees for FIR filter
    inph_accum0_reg0 <= inph_prod_reg0 + inph_prod_reg1;
    quad_accum0_reg0 <= quad_prod_reg0 + quad_prod_reg1;

    inph_accum0_reg1 <= inph_prod_reg2 + inph_prod_reg3;
    quad_accum0_reg1 <= quad_prod_reg2 + quad_prod_reg3;

    inph_del_reg4 <= inph_del_reg3;
    quad_del_reg4 <= quad_del_reg3;

    valid1_reg4 <= valid1_reg3;
end



logic signed [53:0] inph_accum1_reg0;
logic signed [53:0] quad_accum1_reg0;

logic signed [WIDTH-1:0] inph_del_reg5;
logic signed [WIDTH-1:0] quad_del_reg5;

logic valid1_reg5;

always_ff @ (posedge i_clock) begin
    // Adder trees for FIR filter
    inph_accum1_reg0 <= inph_accum0_reg0 + inph_accum0_reg1;
    quad_accum1_reg0 <= quad_accum0_reg0 + quad_accum0_reg1;

    inph_del_reg5 <= inph_del_reg4;
    quad_del_reg5 <= quad_del_reg4;

    valid1_reg5 <= valid1_reg4;
end

logic signed [53:0] concatenated_inph_delay;
logic signed [53:0] concatenated_quad_delay;
logic signed [53:0] inph_output_reg;
logic signed [53:0] quad_output_reg;

logic valid2_reg0;

always_ff @ (posedge i_clock) begin
    concatenated_inph_delay = {
        {(54-17-WIDTH){inph_del_reg5[WIDTH-1]}},
        inph_del_reg5,
        1'b1, // For round half-up algorithm
        16'b0
    };
    concatenated_quad_delay = {
        {(54-17-WIDTH){quad_del_reg5[WIDTH-1]}},
        quad_del_reg5,
        1'b1, // For round half-up algorithm
        16'b0
    };
    inph_output_reg <= inph_accum1_reg0 + concatenated_inph_delay;
    quad_output_reg <= quad_accum1_reg0 + concatenated_quad_delay;

    valid2_reg0 <= valid1_reg5;
end

always_ff @ (posedge i_clock) begin
    if (valid2_reg0 == 1'b1) begin
        if ($signed(inph_output_reg[53:WIDTH+18-1]) > 0) begin
            o_inph_data <= {1'b0, {(WIDTH-1){1'b1}}};
        end else if ($signed(inph_output_reg[53:WIDTH+18-1]) < -1) begin
            o_inph_data <= {1'b1, {(WIDTH-1){1'b0}}};
        end else begin
            o_inph_data <= inph_output_reg[WIDTH+18-1:18];
        end
        if ($signed(quad_output_reg[53:WIDTH+18-1]) > 0) begin
            o_quad_data <= {1'b0, {(WIDTH-1){1'b1}}};
        end else if ($signed(quad_output_reg[53:WIDTH+18-1]) < -1) begin
            o_quad_data <= {1'b1, {(WIDTH-1){1'b0}}};
        end else begin
            o_quad_data <= quad_output_reg[WIDTH+18-1:18];
        end
    end

    o_valid <= valid2_reg0;
end

endmodule: ddc_hb_decim_firx2_h0

`default_nettype wire
