`timescale 10ps / 10ps

`default_nettype none

module cic_decim_comb #(
    parameter integer WIDTH = 16,
    parameter integer DELAY = 2
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

logic [DELAY*WIDTH-1:0] inph_delays;
logic [DELAY*WIDTH-1:0] quad_delays;

generate

if (DELAY == 1) begin
    always @(posedge i_clock) begin
        if (i_reset == 1'b1) begin
            inph_delays <= { (DELAY*WIDTH){1'b0} };
            quad_delays <= { (DELAY*WIDTH){1'b0} };
            o_inph_data <= { (WIDTH){1'b0} };
            o_quad_data <= { (WIDTH){1'b0} };
        end else if (i_valid == 1'b1) begin
            inph_delays <= i_inph_data;
            quad_delays <= i_quad_data;
            o_inph_data <= i_inph_data - inph_delays;
            o_quad_data <= i_quad_data - quad_delays;
        end
        o_valid <= i_valid;
    end
end

if (DELAY > 1) begin
    always @(posedge i_clock) begin
        if (i_reset == 1'b1) begin
            inph_delays <= { (DELAY*WIDTH){1'b0} };
            quad_delays <= { (DELAY*WIDTH){1'b0} };
            o_inph_data <= { (WIDTH){1'b0} };
            o_quad_data <= { (WIDTH){1'b0} };
        end else if (i_valid == 1'b1) begin
            inph_delays[WIDTH-1:0] <= i_inph_data;
            quad_delays[WIDTH-1:0] <= i_quad_data;
            for (integer d = 1; d < DELAY; d++) begin
                inph_delays[(d+1)*WIDTH-1-:WIDTH] <= inph_delays[d*WIDTH-1-:WIDTH];
                quad_delays[(d+1)*WIDTH-1-:WIDTH] <= quad_delays[d*WIDTH-1-:WIDTH];
            end
            o_inph_data <= i_inph_data - inph_delays[DELAY*WIDTH-1-:WIDTH];
            o_quad_data <= i_quad_data - quad_delays[DELAY*WIDTH-1-:WIDTH];
        end
        o_valid <= i_valid;
    end
end
endgenerate

endmodule: cic_decim_comb

`default_nettype wire
