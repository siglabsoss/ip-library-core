`timescale 10 ps / 10 ps

interface intf_cmd #(
    parameter ADDR_BITS = 26,
    parameter DATA_BITS = 32
) ();

    logic                 sel;
    logic                 ack;
    logic                 rd_wr_n;
    logic [ADDR_BITS-1:0] byte_addr;
    logic [DATA_BITS-1:0] wdata;
    logic [DATA_BITS-1:0] rdata;


    modport master (
        output sel,
        output rd_wr_n,
        output byte_addr,
        output wdata,
        input  ack,
        input  rdata
    );

    modport slave (
        input  sel,
        input  rd_wr_n,
        input  byte_addr,
        input  wdata,
        output ack,
        output rdata
    );

endinterface: intf_cmd
