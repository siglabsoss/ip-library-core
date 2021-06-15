// cic_decimator.sv
//
// Top level for the CIC decimation filtering block.
//

`timescale 10ps / 10ps

`default_nettype none

module cic_decimator #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph,
    input  wire logic [WIDTH-1:0] i_quad,
    input  wire logic             i_valid,
    output      logic             o_ready,
    output      logic [WIDTH-1:0] o_inph,
    output      logic [WIDTH-1:0] o_quad,
    output      logic             o_valid,
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

logic [50+WIDTH-1:0] cic_inph;
logic [50+WIDTH-1:0] cic_quad;
logic [50+WIDTH-1:0] comp_inph;
logic [50+WIDTH-1:0] comp_quad;
logic                comp_valid;

assign cic_inph = { { 50{ i_inph[WIDTH-1] } }, i_inph };
assign cic_quad = { { 50{ i_quad[WIDTH-1] } }, i_quad };

cic_decim_stages #(
    .FACTOR(       313),
    .DELAY (         2),
    .STAGES(         5),
    .WIDTH (WIDTH + 50))
cic_decim_stages_inst (
    .i_inph_data(cic_inph  ),
    .i_quad_data(cic_quad  ),
    .i_valid    (i_valid   ),
    .o_inph_data(comp_inph ),
    .o_quad_data(comp_quad ),
    .o_valid    (comp_valid),
    .i_clock    (i_clock   ),
    .i_reset    (i_reset   ));


// Perform Rounding
logic [4+WIDTH-1:0] comp_rounded_inph;
logic [4+WIDTH-1:0] comp_rounded_quad;
logic               comp_rounded_valid;

always_ff @(posedge i_clock) begin
    // Valid Pipeline
    if (i_reset == 1'b1) begin
        comp_rounded_valid <= 1'b0;
    end else begin
        comp_rounded_valid <= comp_valid;
    end
    // Round half-up algorithm
    comp_rounded_inph <= (comp_inph[WIDTH+50-1-:WIDTH+4+1] + 1'b1) >>> 1;
    comp_rounded_quad <= (comp_quad[WIDTH+50-1-:WIDTH+4+1] + 1'b1) >>> 1;
end

// Perform Saturation
logic [WIDTH-1:0] comp_saturated_inph;
logic [WIDTH-1:0] comp_saturated_quad;
logic             comp_saturated_valid;
logic             comp_saturated_ready;

always_ff @(posedge i_clock) begin
    // Valid pipeline
    if (i_reset == 1'b1) begin
        comp_saturated_valid <= 1'b0;
    end else begin
        comp_saturated_valid <= comp_valid;
    end
    // In-Phase Saturation Detection
    if (((&comp_rounded_inph[4+WIDTH-1:WIDTH-1]) != 1'b1)
            && ((|comp_rounded_inph[4+WIDTH-1:WIDTH-1]) != 1'b0)) begin
        // Saturation event
        if (comp_rounded_inph[4+WIDTH-1] == 1'b0) begin
            o_cic_inph_pos_oflow <= 1'b1;
            o_cic_inph_neg_oflow <= 1'b0;
            comp_saturated_inph <= { 1'b0, { (WIDTH-1){ 1'b1 } } };
        end else begin
            o_cic_inph_pos_oflow <= 1'b0;
            o_cic_inph_neg_oflow <= 1'b1;
            comp_saturated_inph <= { 1'b1, { (WIDTH-1){ 1'b0 } } };
        end
    end else begin
        // No saturation event
        o_cic_inph_pos_oflow <= 1'b0;
        o_cic_inph_neg_oflow <= 1'b0;
        comp_saturated_inph <= comp_rounded_inph[WIDTH-1:0];
    end
    // Quadrature Saturation Detection
    if (((&comp_rounded_quad[4+WIDTH-1:WIDTH-1]) != 1'b1)
            && ((|comp_rounded_quad[4+WIDTH-1:WIDTH-1]) != 1'b0)) begin
        // Saturation event
        if (comp_rounded_quad[4+WIDTH-1] == 1'b0) begin
            o_cic_quad_pos_oflow <= 1'b1;
            o_cic_quad_neg_oflow <= 1'b0;
            comp_saturated_quad <= { 1'b0, { (WIDTH-1){ 1'b1 } } };
        end else begin
            o_cic_quad_pos_oflow <= 1'b0;
            o_cic_quad_neg_oflow <= 1'b1;
            comp_saturated_quad <= { 1'b1, { (WIDTH-1){ 1'b0 } } };
        end
    end else begin
        // No saturation event
        o_cic_quad_pos_oflow <= 1'b0;
        o_cic_quad_neg_oflow <= 1'b0;
        comp_saturated_quad <= comp_rounded_quad[WIDTH-1:0];
    end
end

cic_decim_compfir #(
    .WIDTH(WIDTH))
cic_decim_compfir_inst (
    .i_inph          (comp_saturated_inph ),
    .i_quad          (comp_saturated_quad ),
    .i_valid         (comp_saturated_valid),
    .o_ready         (comp_saturated_ready),
    .o_inph          (o_inph              ),
    .o_quad          (o_quad              ),
    .o_inph_pos_oflow(o_inph_pos_oflow    ),
    .o_inph_neg_oflow(o_inph_neg_oflow    ),
    .o_quad_pos_oflow(o_quad_pos_oflow    ),
    .o_quad_neg_oflow(o_quad_neg_oflow    ),
    .o_valid         (o_valid             ),
    .i_clock         (i_clock             ),
    .i_reset         (i_reset             ));

`ifdef SIMULATION
always @(posedge i_clock) begin
    if ((comp_rounded_valid == 1'b1) && (comp_rounded_ready == 1'b0)) begin
        // Should never occur if the decimation factor is > the impulse response of the
        // compensation filter (in this case 33).
        $display("Error in cic_decimator: Compensator not ready when CIC output valid.");
    end
end
`endif

endmodule: cic_decimator

`default_nettype wire
