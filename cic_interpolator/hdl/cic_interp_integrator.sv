`timescale 10ps / 10ps

`default_nettype none

module cic_interp_integrator #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_quad_data,
    output      logic [WIDTH-1:0] o_inph_data,
    output      logic [WIDTH-1:0] o_quad_data,
    input  wire logic             i_ready,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

logic [WIDTH-1:0] inph_accum;
logic [WIDTH-1:0] quad_accum;

always @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        inph_accum <= { WIDTH{ 1'b0 } };
        quad_accum <= { WIDTH{ 1'b0 } };
    end else if (i_ready == 1'b1) begin
        inph_accum <= inph_accum + i_inph_data;
        quad_accum <= quad_accum + i_quad_data;
    end
end

assign o_inph_data = inph_accum;
assign o_quad_data = quad_accum;

endmodule: cic_interp_integrator

`default_nettype wire
