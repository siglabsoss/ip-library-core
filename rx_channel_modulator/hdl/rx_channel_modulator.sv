`timescale 10ps / 10ps

`default_nettype none

module rx_channel_modulator #(
    parameter integer WIDTH = 16,
    parameter integer NUM_CHANNELS = 4096
) (
    // Input Sample Interface
    input  wire logic [WIDTH-1:0] i_inph,
    input  wire logic [WIDTH-1:0] i_quad,
    input  wire logic             i_valid,
    // Phase Accumulator Increment
    input  wire logic [12-1:0]    i_phase_inc,
    input  wire logic             i_phase_inc_valid,
    // Output Sample Interface
    output      logic [WIDTH-1:0] o_inph,
    output      logic [WIDTH-1:0] o_quad,
    output      logic             o_inph_oflow,
    output      logic             o_quad_oflow,
    output      logic             o_valid,
    // Clock and Reset
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

logic [18-1:0] dds_cosine_data;
logic [18-1:0] dds_sine_data;

rx_chmod_dds rx_chmod_dds_inst (
    .i_phase_inc      (i_phase_inc      ),
    .i_phase_inc_valid(i_phase_inc_valid),
    .o_cosine_data    (dds_cosine_data  ),
    .o_sine_data      (dds_sine_data    ),
    .i_ready          (i_valid          ),
    .i_clock          (i_clock          ),
    .i_reset          (i_reset          ));

logic signed [WIDTH-1:0]    inph_reg0;
logic signed [WIDTH-1:0]    quad_reg0;
logic signed [17:0]         cos_reg0;
logic signed [17:0]         sin_reg0;
logic                       valid_reg0;

logic signed [WIDTH+18-1:0] inph_cos_reg1;
logic signed [WIDTH+18-1:0] inph_sin_reg1;
logic signed [WIDTH-1:0]    quad_reg1;
logic signed [17:0]         cos_reg1;
logic signed [17:0]         sin_reg1;
logic                       valid_reg1;

logic signed [WIDTH+18-1:0] inph_cos_reg2;
logic signed [WIDTH+18-1:0] inph_sin_reg2;
logic signed [WIDTH+18-1:0] quad_cos_reg2;
logic signed [WIDTH+18-1:0] quad_sin_reg2;
logic                       valid_reg2;

logic signed [WIDTH+18:0] inph_reg3;
logic signed [WIDTH+18:0] quad_reg3;
logic                     valid_reg3;

always_ff @(posedge i_clock) begin
    // Valid pipeline (reset-controlled)
    if (i_reset == 1'b1) begin
        valid_reg0 <= 1'b0;
        valid_reg1 <= 1'b0;
        valid_reg2 <= 1'b0;
        valid_reg3 <= 1'b0;
        o_valid <= 1'b0;
    end else begin
        valid_reg0 <= i_valid;
        valid_reg1 <= valid_reg0;
        valid_reg2 <= valid_reg1;
        valid_reg3 <= valid_reg2;
        o_valid <= valid_reg3;
    end

    // Stage 0
    if (i_valid == 1'b1) begin
        inph_reg0 <= i_inph;
        quad_reg0 <= i_quad;
        cos_reg0 <= dds_cosine_data;
        sin_reg0 <= dds_sine_data;
    end

    // Stage 1
    inph_cos_reg1 <= $signed(inph_reg0) * $signed(cos_reg0);
    inph_sin_reg1 <= $signed(inph_reg0) * $signed(sin_reg0);
    quad_reg1 <= quad_reg0;
    cos_reg1 <= cos_reg0;
    sin_reg1 <= sin_reg0;

    // Stage 2
    inph_cos_reg2 <= inph_cos_reg1;
    inph_sin_reg2 <= inph_sin_reg1;
    quad_cos_reg2 <= $signed(quad_reg1) * $signed(cos_reg1);
    quad_sin_reg2 <= $signed(quad_reg1) * $signed(sin_reg1);

    // Stage 3
    inph_reg3 <= inph_cos_reg2 + quad_sin_reg2;
    quad_reg3 <= quad_cos_reg2 - inph_sin_reg2;

    // Stage 4 (Output)
    o_inph <= (inph_reg3[WIDTH+18-1:17-1] + 1'b1) >> 1;
    o_quad <= (quad_reg3[WIDTH+18-1:17-1] + 1'b1) >> 1;
    o_inph_oflow <= (inph_reg3[WIDTH+18] ^ inph_reg3[WIDTH+18-1]) | (inph_reg3[WIDTH+18] ^ inph_reg3[WIDTH+18-2]);
    o_quad_oflow <= (quad_reg3[WIDTH+18] ^ quad_reg3[WIDTH+18-1]) | (quad_reg3[WIDTH+18] ^ quad_reg3[WIDTH+18-2]);

end

endmodule: rx_channel_modulator

`default_nettype wire
