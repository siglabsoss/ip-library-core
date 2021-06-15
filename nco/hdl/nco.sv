`timescale 10 ps / 10 ps

`default_nettype none

module nco #(
    parameter integer PWIDTH = 23,
    parameter integer SWIDTH = 18
) (
    input  wire	logic signed [PWIDTH-1:0] i_phase,
    input  wire logic                     i_valid,
    output      logic signed [SWIDTH-1:0] o_cosine,
    output      logic signed [SWIDTH-1:0] o_sine,
    output      logic                     o_valid,
    input  wire logic                     i_clock,
    input  wire logic                     i_enable,
    input  wire logic                     i_reset
);

localparam integer LUT_LENGTH = 32;

// Eventually we could take advantage of the 4 clock cycles per sample
// to use a single memory for cosine and a single memory for sine, but
// for now we are optimizing for developer time not resource usage.
logic signed [SWIDTH-1:0] cos_mem0 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] sin_mem0 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] cos_mem1 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] sin_mem1 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] cos_mem2 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] sin_mem2 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] cos_mem3 [0:LUT_LENGTH-1];
logic signed [SWIDTH-1:0] sin_mem3 [0:LUT_LENGTH-1];

initial begin
    $readmemb("dds_cosines0.mif", cos_mem0);
    $readmemb("dds_sines0.mif", sin_mem0);
    $readmemb("dds_cosines1.mif", cos_mem1);
    $readmemb("dds_sines1.mif", sin_mem1);
    $readmemb("dds_cosines2.mif", cos_mem2);
    $readmemb("dds_sines2.mif", sin_mem2);
    $readmemb("dds_cosines3.mif", cos_mem3);
    $readmemb("dds_sines3.mif", sin_mem3);
end

logic signed [SWIDTH-1:0] cos_delay0;
logic signed [SWIDTH-1:0] sin_delay0;
logic signed [SWIDTH-1:0] cos_delay1;
logic signed [SWIDTH-1:0] sin_delay1;
logic signed [SWIDTH-1:0] cos_delay2;
logic signed [SWIDTH-1:0] sin_delay2;
logic signed [SWIDTH-1:0] cos_delay3;
logic signed [SWIDTH-1:0] sin_delay3;

always_comb begin
    cos_delay0 = cos_mem0[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    sin_delay0 = sin_mem0[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    cos_delay1 = cos_mem1[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    sin_delay1 = sin_mem1[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    cos_delay2 = cos_mem2[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    sin_delay2 = sin_mem2[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    cos_delay3 = cos_mem3[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
    sin_delay3 = sin_mem3[i_phase[PWIDTH-1:PWIDTH-$clog2(LUT_LENGTH)]];
end

localparam integer FWIDTH = PWIDTH - $clog2(LUT_LENGTH);

logic signed [FWIDTH-1:0] residual_reg0;
logic signed [SWIDTH-1:0] cos_delay0_reg0;
logic signed [SWIDTH-1:0] sin_delay0_reg0;
logic signed [SWIDTH-1:0] cos_delay1_reg0;
logic signed [SWIDTH-1:0] sin_delay1_reg0;
logic signed [SWIDTH-1:0] cos_delay2_reg0;
logic signed [SWIDTH-1:0] sin_delay2_reg0;
logic signed [SWIDTH-1:0] cos_delay3_reg0;
logic signed [SWIDTH-1:0] sin_delay3_reg0;
logic                     valid_reg0;

logic signed [FWIDTH-1:0] residual_reg1;
logic signed [SWIDTH-1:0] cos_delay0_reg1;
logic signed [SWIDTH-1:0] sin_delay0_reg1;
logic signed [SWIDTH-1:0] cos_delay1_reg1;
logic signed [SWIDTH-1:0] sin_delay1_reg1;
logic signed [SWIDTH-1:0] cos_delay2_reg1;
logic signed [SWIDTH-1:0] sin_delay2_reg1;
logic signed [SWIDTH-1:0] cos_delay3_reg1;
logic signed [SWIDTH-1:0] sin_delay3_reg1;
logic signed [SWIDTH-1:0] cos_a0_reg1;
logic signed [SWIDTH-1:0] sin_a0_reg1;
logic signed [SWIDTH-1:0] cos_a1a_reg1;
logic signed [SWIDTH-1:0] sin_a1a_reg1;
logic signed [SWIDTH-1:0] cos_b2a_reg1;
logic signed [SWIDTH-1:0] sin_b2a_reg1;
logic signed [SWIDTH-1:0] cos_b3a_reg1;
logic signed [SWIDTH-1:0] sin_b3a_reg1;
logic                     valid_reg1;

logic signed [FWIDTH-1:0] residual_reg2;
logic signed [SWIDTH-1:0] cos_b0_reg2;
logic signed [SWIDTH-1:0] sin_b0_reg2;
logic signed [SWIDTH-1:0] cos_a0_reg2;
logic signed [SWIDTH-1:0] sin_a0_reg2;
logic signed [SWIDTH-1:0] cos_a1_reg2;
logic signed [SWIDTH-1:0] sin_a1_reg2;
logic signed [SWIDTH-1:0] cos_b2_reg2;
logic signed [SWIDTH-1:0] sin_b2_reg2;
logic signed [SWIDTH-1:0] cos_b3_reg2;
logic signed [SWIDTH-1:0] sin_b3_reg2;
logic                     valid_reg2;

logic signed [FWIDTH-1:0] residual_reg3;
logic signed [SWIDTH-1:0] cos_b0_reg3;
logic signed [SWIDTH-1:0] sin_b0_reg3;
logic signed [SWIDTH-1:0] cos_b1_reg3;
logic signed [SWIDTH-1:0] sin_b1_reg3;
logic signed [SWIDTH-1:0] cos_b2_reg3;
logic signed [SWIDTH-1:0] sin_b2_reg3;
logic signed [SWIDTH-1:0] cos_b3_reg3;
logic signed [SWIDTH-1:0] sin_b3_reg3;
logic                     valid_reg3;

logic signed [FWIDTH-1:0] residual_reg4;
logic signed [SWIDTH-1:0] cos_b0_reg4;
logic signed [SWIDTH-1:0] sin_b0_reg4;
logic signed [SWIDTH-1:0] cos_b1_reg4;
logic signed [SWIDTH-1:0] sin_b1_reg4;
logic signed [SWIDTH-1:0] cos_b2_reg4;
logic signed [SWIDTH-1:0] sin_b2_reg4;
logic signed [SWIDTH-1:0] cos_b3_scaled_reg4;
logic signed [SWIDTH-1:0] sin_b3_scaled_reg4;
logic                     valid_reg4;

logic signed [FWIDTH-1:0] residual_reg5;
logic signed [SWIDTH-1:0] cos_b0_reg5;
logic signed [SWIDTH-1:0] sin_b0_reg5;
logic signed [SWIDTH-1:0] cos_b1_reg5;
logic signed [SWIDTH-1:0] sin_b1_reg5;
logic signed [SWIDTH-1:0] cos_b2_unscaled_reg5;
logic signed [SWIDTH-1:0] sin_b2_unscaled_reg5;
logic                     valid_reg5;

logic signed [FWIDTH-1:0] residual_reg6;
logic signed [SWIDTH-1:0] cos_b0_reg6;
logic signed [SWIDTH-1:0] sin_b0_reg6;
logic signed [SWIDTH-1:0] cos_b1_reg6;
logic signed [SWIDTH-1:0] sin_b1_reg6;
logic signed [SWIDTH-1:0] cos_b2_scaled_reg6;
logic signed [SWIDTH-1:0] sin_b2_scaled_reg6;
logic                     valid_reg6;

logic signed [FWIDTH-1:0] residual_reg7;
logic signed [SWIDTH-1:0] cos_b0_reg7;
logic signed [SWIDTH-1:0] sin_b0_reg7;
logic signed [SWIDTH-1:0] cos_b1_unscaled_reg7;
logic signed [SWIDTH-1:0] sin_b1_unscaled_reg7;
logic                     valid_reg7;

logic signed [SWIDTH-1:0] cos_b0_reg8;
logic signed [SWIDTH-1:0] sin_b0_reg8;
logic signed [SWIDTH-1:0] cos_b1_scaled_reg8;
logic signed [SWIDTH-1:0] sin_b1_scaled_reg8;
logic                     valid_reg8;

always_ff @(posedge i_clock) begin
    if (i_enable == 1'b1) begin
        // Pipeline Stage 0
        residual_reg0 <= i_phase[FWIDTH-1:0];
        cos_delay0_reg0 <= cos_delay0;
        sin_delay0_reg0 <= sin_delay0;
        cos_delay1_reg0 <= cos_delay1;
        sin_delay1_reg0 <= sin_delay1;
        cos_delay2_reg0 <= cos_delay2;
        sin_delay2_reg0 <= sin_delay2;
        cos_delay3_reg0 <= cos_delay3;
        sin_delay3_reg0 <= sin_delay3;

        // Pipeline Stage 1
        residual_reg1 <= residual_reg0;
        cos_delay0_reg1 <= cos_delay0_reg0;
        sin_delay0_reg1 <= sin_delay0_reg0;
        cos_delay1_reg1 <= cos_delay1_reg0;
        sin_delay1_reg1 <= sin_delay1_reg0;
        cos_delay2_reg1 <= cos_delay2_reg0;
        sin_delay2_reg1 <= sin_delay2_reg0;
        cos_delay3_reg1 <= cos_delay3_reg0;
        sin_delay3_reg1 <= sin_delay3_reg0;
        cos_a0_reg1 <= (cos_delay0_reg0 - cos_delay3_reg0) >>> 2;
        sin_a0_reg1 <= (sin_delay0_reg0 - sin_delay3_reg0) >>> 2;
        cos_a1a_reg1 <= (cos_delay0_reg0 + cos_delay2_reg0) >>> 1;
        sin_a1a_reg1 <= (sin_delay0_reg0 + sin_delay2_reg0) >>> 1;
        cos_b2a_reg1 <= (cos_delay1_reg0 + cos_delay3_reg0) >>> 1;
        sin_b2a_reg1 <= (sin_delay1_reg0 + sin_delay3_reg0) >>> 1;
        cos_b3a_reg1 <= cos_delay1_reg0 - cos_delay2_reg0;
        sin_b3a_reg1 <= sin_delay1_reg0 - sin_delay2_reg0;

        // Pipeline Stage 2
        residual_reg2 <= residual_reg1;
        cos_b0_reg2 <= cos_delay2_reg1;
        sin_b0_reg2 <= sin_delay2_reg1;
        cos_a0_reg2 <= cos_a0_reg1;
        sin_a0_reg2 <= sin_a0_reg1;
        cos_a1_reg2 <= cos_delay1_reg1 - cos_a1a_reg1;
        sin_a1_reg2 <= sin_delay1_reg1 - sin_a1a_reg1;
        cos_b2_reg2 <= (cos_b2a_reg1 - cos_delay2_reg1) >>> 1;
        sin_b2_reg2 <= (sin_b2a_reg1 - sin_delay2_reg1) >>> 1;
        cos_b3_reg2 <= (cos_a0_reg1 - cos_b3a_reg1) >>> 1;
        sin_b3_reg2 <= (sin_a0_reg1 - sin_b3a_reg1) >>> 1;

        // Pipeline Stage 3
        residual_reg3 <= residual_reg2;
        cos_b0_reg3 <= cos_b0_reg2;
        sin_b0_reg3 <= sin_b0_reg2;
        cos_b1_reg3 <= cos_a0_reg2 + cos_a1_reg2;
        sin_b1_reg3 <= sin_a0_reg2 + sin_a1_reg2;
        cos_b2_reg3 <= cos_b2_reg2;
        sin_b2_reg3 <= sin_b2_reg2;
        cos_b3_reg3 <= cos_b3_reg2;
        sin_b3_reg3 <= sin_b3_reg2;

        // Pipeline Stage 4
        residual_reg4 <= residual_reg3;
        cos_b0_reg4 <= cos_b0_reg3;
        sin_b0_reg4 <= sin_b0_reg3;
        cos_b1_reg4 <= cos_b1_reg3;
        sin_b1_reg4 <= sin_b1_reg3;
        cos_b2_reg4 <= cos_b2_reg3;
        sin_b2_reg4 <= sin_b2_reg3;
        cos_b3_scaled_reg4 <= (cos_b3_reg3 * residual_reg3) >>> (FWIDTH - 1);
        sin_b3_scaled_reg4 <= (sin_b3_reg3 * residual_reg3) >>> (FWIDTH - 1);

        // Pipeline Stage 5
        residual_reg5 <= residual_reg4;
        cos_b0_reg5 <= cos_b0_reg4;
        sin_b0_reg5 <= sin_b0_reg4;
        cos_b1_reg5 <= cos_b1_reg4;
        sin_b1_reg5 <= sin_b1_reg4;
        cos_b2_unscaled_reg5 <= cos_b2_reg4 - cos_b3_scaled_reg4;
        sin_b2_unscaled_reg5 <= sin_b2_reg4 - sin_b3_scaled_reg4;

        // Pipeline Stage 6
        residual_reg6 <= residual_reg5;
        cos_b0_reg6 <= cos_b0_reg5;
        sin_b0_reg6 <= sin_b0_reg5;
        cos_b1_reg6 <= cos_b1_reg5;
        sin_b1_reg6 <= sin_b1_reg5;
        cos_b2_scaled_reg6 <= (cos_b2_unscaled_reg5 * residual_reg5) >>> (FWIDTH - 1);
        sin_b2_scaled_reg6 <= (sin_b2_unscaled_reg5 * residual_reg5) >>> (FWIDTH - 1);

        // Pipeline Stage 7
        residual_reg7 <= residual_reg6;
        cos_b0_reg7 <= cos_b0_reg6;
        sin_b0_reg7 <= sin_b0_reg6;
        cos_b1_unscaled_reg7 <= cos_b1_reg6 - cos_b2_scaled_reg6;
        sin_b1_unscaled_reg7 <= sin_b1_reg6 - sin_b2_scaled_reg6;

        // Pipeline Stage 8
        cos_b0_reg8 <= cos_b0_reg7;
        sin_b0_reg8 <= sin_b0_reg7;
        cos_b1_scaled_reg8 <= (cos_b1_unscaled_reg7 * residual_reg7) >>> (FWIDTH - 1);
        sin_b1_scaled_reg8 <= (sin_b1_unscaled_reg7 * residual_reg7) >>> (FWIDTH - 1);

        // Pipeline Stage 9
        o_cosine <= cos_b0_reg8 - cos_b1_scaled_reg8;
        o_sine <= sin_b0_reg8 - sin_b1_scaled_reg8;
    end
end

always_ff @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        valid_reg0 <= 1'b0;
        valid_reg0 <= 1'b0;
        valid_reg1 <= 1'b0;
        valid_reg2 <= 1'b0;
        valid_reg3 <= 1'b0;
        valid_reg4 <= 1'b0;
        valid_reg5 <= 1'b0;
        valid_reg6 <= 1'b0;
        valid_reg7 <= 1'b0;
        valid_reg8 <= 1'b0;
        o_valid <= 1'b0;
    end else if (i_enable == 1'b1) begin
        valid_reg0 <= i_valid;
        valid_reg1 <= valid_reg0;
        valid_reg2 <= valid_reg1;
        valid_reg3 <= valid_reg2;
        valid_reg4 <= valid_reg3;
        valid_reg5 <= valid_reg4;
        valid_reg6 <= valid_reg5;
        valid_reg7 <= valid_reg6;
        valid_reg8 <= valid_reg7;
        o_valid <= valid_reg8;
    end
end

endmodule: nco

`default_nettype wire