//
// Template SystemVerilog Module
//

`timescale 10ps / 10ps

`default_nettype none

module a_module #(
    parameter integer WIDTH = 16
) (
    // Upstream signaling
    input wire logic [WIDTH-1:0]    i_in_data,
    input wire logic                i_in_valid,
    output     logic                o_in_ready,
    // Downstream signaling
    output     logic [WIDTH-1:0]    o_out_data,
    output     logic                o_out_valid,
    input wire logic                i_out_ready,
    // Control signaling
    input wire logic                i_clock,
    input wire logic                i_enable,
    input wire logic                i_reset
);

// RTL goes here...

endmodule: a_module

`default_nettype wire