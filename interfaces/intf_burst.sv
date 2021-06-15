`timescale 10 ps / 10 ps

`default_nettype none

interface intf_burst();

    parameter integer WIDTH = 16;

    logic [WIDTH-1:0]   bdata;
    logic               bvalid;
    logic               bready;

    modport upstream(
        output bvalid, bdata,
        input  bready
    );

    modport downstream(
        input  bvalid, bdata,
        output bready
    );

endinterface: intf_burst

`default_nettype wire