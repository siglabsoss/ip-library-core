`timescale 10 ps / 10 ps

`default_nettype none

interface intf_vr();

    parameter integer WIDTH = 16;

    logic [WIDTH-1:0]   data;
    logic               valid;
    logic               ready;

    modport upstream(
        output valid, data,
        input  ready
    );

    modport downstream(
        input  valid, data,
        output ready
    );

endinterface: intf_vr

`default_nettype wire
