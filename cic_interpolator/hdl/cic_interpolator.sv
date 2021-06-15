// cic_interpolator.sv
//
// Top level for the CIC interpolation filtering block.
//

`timescale 10ps / 10ps

`default_nettype none

module cic_interpolator #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph,
    input  wire logic [WIDTH-1:0] i_quad,
    output      logic             o_ready,
    output      logic [WIDTH-1:0] o_inph,
    output      logic [WIDTH-1:0] o_quad,
    input  wire logic             i_ready,
    output      logic             o_inph_pos_oflow,
    output      logic             o_inph_neg_oflow,
    output      logic             o_quad_pos_oflow,
    output      logic             o_quad_neg_oflow,
    output      logic             o_cic_inph_pos_oflow,
    output      logic             o_cic_inph_neg_oflow,
    output      logic             o_cic_quad_pos_oflow,
    output      logic             o_cic_quad_neg_oflow,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

// Compensator Signals
logic [WIDTH+1:0] shadow_inph;
logic [WIDTH+1:0] shadow_quad;
logic [WIDTH+1:0] comp_inph;
logic [WIDTH+1:0] comp_quad;
logic             comp_ready;

assign shadow_inph = {
    i_inph[WIDTH-1],
    i_inph[WIDTH-1],
    i_inph
};

assign shadow_quad = {
    i_quad[WIDTH-1],
    i_quad[WIDTH-1],
    i_quad
};

// always_ff @ (posedge i_clock) begin
//     if (i_reset == 1'b1) begin
//         shadow_inph <= 1 << 14;
//         shadow_quad <= 0;
//     end else if (comp_ready == 1'b1) begin
//         shadow_inph <= 0;
//         shadow_quad <= 0;
//     end
// end

// Compensator
cic_interp_compfir #(
    .WIDTH(WIDTH+2))
cic_interp_compfir_inst (
    .i_inph          (shadow_inph     ),
    .i_quad          (shadow_quad     ),
    .o_ready         (o_ready         ),
    .o_inph          (comp_inph       ),
    .o_quad          (comp_quad       ),
    .o_inph_pos_oflow(o_inph_pos_oflow),
    .o_inph_neg_oflow(o_inph_neg_oflow),
    .o_quad_pos_oflow(o_quad_pos_oflow),
    .o_quad_neg_oflow(o_quad_neg_oflow),
    .i_ready         (comp_ready      ),
    .i_clock         (i_clock         ),
    .i_reset         (i_reset         ));

// CIC stages
localparam MAXY = 50;
logic [MAXY+WIDTH+2-1:0] cic_inph;
logic [MAXY+WIDTH+2-1:0] cic_quad;
cic_interp_stages #(
    .WIDTH (MAXY+WIDTH+2),
    .FACTOR(         313),
    .DELAY (           2),
    .STAGES(           5))
cic_interp_stages_inst (
    .i_inph_data({ { MAXY{ comp_inph[WIDTH+1] } }, comp_inph }),
    .i_quad_data({ { MAXY{ comp_quad[WIDTH+1] } }, comp_quad }),
    .o_ready    (comp_ready                                   ),
    .o_inph_data(cic_inph                                     ),
    .o_quad_data(cic_quad                                     ),
    .i_ready    (i_ready                                      ),
    .i_clock    (i_clock                                      ),
    .i_reset    (i_reset                                      ));

// Saturation/rounding of CIC output
logic [WIDTH+3-1:0] cic_inph_rounded;
logic [WIDTH+3-1:0] cic_quad_rounded;
logic [WIDTH-1:0]   cic_inph_saturated;
logic [WIDTH-1:0]   cic_quad_saturated;
always_ff @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        cic_inph_rounded <= { (WIDTH+3){ 1'b0 } };
        cic_quad_rounded <= { (WIDTH+3){ 1'b0 } };
        cic_inph_saturated <= { WIDTH{ 1'b0 } };
        cic_quad_saturated <= { WIDTH{ 1'b0 } };
        o_cic_inph_pos_oflow <= 1'b0;
        o_cic_inph_neg_oflow <= 1'b0;
        o_cic_quad_pos_oflow <= 1'b0;
        o_cic_quad_neg_oflow <= 1'b0;
    end else if (i_ready == 1'b1) begin
        // Round Half Up
        //cic_inph_rounded <= ({ cic_inph[MAXY-4+WIDTH+2-1], cic_inph[MAXY+WIDTH+2-1:MAXY-5] } + 1'b1) >> 1;
        cic_inph_rounded <= ({ cic_inph[MAXY+WIDTH+2-1], cic_inph[MAXY+WIDTH+2-1:MAXY-5] } + 1'b1) >> 1;
        //cic_quad_rounded <= ({ cic_quad[MAXY-4+WIDTH+2-1], cic_quad[MAXY+WIDTH+2-1:MAXY-5] } + 1'b1) >> 1;
        cic_quad_rounded <= ({ cic_quad[MAXY+WIDTH+2-1], cic_quad[MAXY+WIDTH+2-1:MAXY-5] } + 1'b1) >> 1;
        // In-Phase Saturation Detection
        if (((&cic_inph_rounded[WIDTH+3-1:WIDTH-1]) != 1'b1)
                && ((|cic_inph_rounded[WIDTH+3-1:WIDTH-1]) != 1'b0)) begin
            // Saturation Event
            if (cic_inph_rounded[WIDTH+3-1] == 1'b0) begin
                o_cic_inph_pos_oflow <= 1'b1;
                o_cic_inph_neg_oflow <= 1'b0;
                cic_inph_saturated <= { 1'b0, { (WIDTH-1){ 1'b1 } } };
            end else begin
                o_cic_inph_pos_oflow <= 1'b0;
                o_cic_inph_neg_oflow <= 1'b1;
                cic_inph_saturated <= { 1'b1, { (WIDTH-1){ 1'b0 } } };
            end
        end else begin
            o_cic_inph_pos_oflow <= 1'b0;
            o_cic_inph_neg_oflow <= 1'b0;
            cic_inph_saturated <= cic_inph_rounded[WIDTH-1:0];
        end
        // Quadrature Saturation Detection
        if (((&cic_quad_rounded[WIDTH+3-1:WIDTH-1]) != 1'b1)
                && ((|cic_quad_rounded[WIDTH+3-1:WIDTH-1]) != 1'b0)) begin
            // Saturation Event
            if (cic_quad_rounded[WIDTH+3-1] == 1'b0) begin
                o_cic_quad_pos_oflow <= 1'b1;
                o_cic_quad_neg_oflow <= 1'b0;
                cic_quad_saturated <= { 1'b0, { (WIDTH-1){ 1'b1 } } };
            end else begin
                o_cic_quad_pos_oflow <= 1'b0;
                o_cic_quad_neg_oflow <= 1'b1;
                cic_quad_saturated <= { 1'b1, { (WIDTH-1){ 1'b0 } } };
            end
        end else begin
            o_cic_quad_pos_oflow <= 1'b0;
            o_cic_quad_neg_oflow <= 1'b0;
            cic_quad_saturated <= cic_quad_rounded[WIDTH-1:0];
        end
    end
end

assign o_inph = cic_inph_saturated;
assign o_quad = cic_quad_saturated;

endmodule: cic_interpolator

`default_nettype wire
