`timescale 10ps / 10ps

`default_nettype none

module cic_decim_integrator #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_quad_data,
    input  wire logic             i_valid,
    output      logic [WIDTH-1:0] o_inph_data,
    output      logic [WIDTH-1:0] o_quad_data,
    output      logic             o_valid,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

logic [WIDTH-1:0] inph_accum;
logic [WIDTH-1:0] quad_accum;

always @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        inph_accum <= '0;
        quad_accum <= '0;
    end else if (i_valid == 1'b1) begin
        inph_accum <= inph_accum + i_inph_data;
        quad_accum <= quad_accum + i_quad_data;
    end
    o_valid <= i_valid;
end

assign o_inph_data = inph_accum;
assign o_quad_data = quad_accum;

endmodule: cic_decim_integrator

`default_nettype wire
