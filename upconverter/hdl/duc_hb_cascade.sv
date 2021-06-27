`timescale 10ps / 10ps

`default_nettype none

module duc_hb_cascade #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_quad_data,
    output wire logic             o_ready,
    output wire logic [WIDTH-1:0] o_inph_data,
    output wire logic [WIDTH-1:0] o_quad_data,
    input  wire logic             i_ready,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

logic [WIDTH-1:0] h1_inph_data;
logic [WIDTH-1:0] h1_quad_data;
logic             h1_ready;

duc_hb_interp_fir_h0 #(.WIDTH(WIDTH))
duc_hb_interp_fir_h0_inst (
    .i_inph_data      (i_inph_data      ),
    .i_quad_data      (i_quad_data      ),
    .o_ready          (o_ready          ),
    .o_inph_data      (h1_inph_data     ),
    .o_quad_data      (h1_quad_data     ),
    .i_ready          (h1_ready         ),
    .i_clock          (i_clock          ),
    .i_reset          (i_reset          ));

// Concatenated data
logic [2*WIDTH-1:0] h1_iq_data;
assign h1_iq_data = {
    h1_quad_data,
    h1_inph_data
};

// Skidded outputs
logic [2*WIDTH-1:0] h1_skid_iq_data;
logic               h1_skid_iq_ready;

duc_skid #(
    .WIDTH(2*WIDTH))
duc_skid_inph_inst (
    .i_clock    (i_clock         ),
    .i_reset    (i_reset         ),
    .i_in_data  (h1_iq_data      ),
    .o_in_ready (h1_ready        ),
    .o_out_data (h1_skid_iq_data ),
    .i_out_ready(h1_skid_iq_ready));

duc_hb_interp_fir_h0 #(.WIDTH(WIDTH))
duc_hb_interp_fir_h1_inst (
    .i_inph_data      (h1_skid_iq_data[WIDTH-1:0]      ),
    .i_quad_data      (h1_skid_iq_data[2*WIDTH-1:WIDTH]),
    .o_ready          (h1_skid_iq_ready                ),
    .o_inph_data      (o_inph_data                     ),
    .o_quad_data      (o_quad_data                     ),
    .i_ready          (i_ready                         ),
    .i_clock          (i_clock                         ),
    .i_reset          (i_reset                         ));

endmodule: duc_hb_cascade

`default_nettype wire
