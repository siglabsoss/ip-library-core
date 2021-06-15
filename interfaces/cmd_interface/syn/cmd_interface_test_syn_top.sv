/****************************************************************************
 * cmd_interface_test_syn_top.sv
 ****************************************************************************/

/**
 * Module: cmd_interface_test_syn_top
 * 
 * TODO: Add module documentation
 */
module cmd_interface_test_syn_top (
    input clk,
    input srst,
    input sel,
    input rd_wr_n,
    input [31:0] byte_addr,
    input [31:0] wdata,
    output ack,
    output [31:0] rdata
);
    
    localparam ADDR_BITS         = 32;
    localparam ADDR_BITS_FOR_SEL = 2;
    localparam DATA_BITS         = 32;

    intf_cmd #(ADDR_BITS-ADDR_BITS_FOR_SEL, DATA_BITS) cmd_bus[2**ADDR_BITS_FOR_SEL-1:0]();
    
    cmd_slave cmd_slave_0 (.i_sysclk(clk), .i_srst(srst), .cmd(cmd_bus[0]));
    cmd_slave cmd_slave_1 (.i_sysclk(clk), .i_srst(srst), .cmd(cmd_bus[1]));
    
    cmd_master #(
        .HOST_ADDR_BITS          (ADDR_BITS), 
        .HOST_ADDR_BITS_FOR_SEL  (ADDR_BITS_FOR_SEL), 
        .HOST_DATA_BITS          (DATA_BITS)
        ) cmd_master_inst (
        .i_sysclk                (clk             ),
        .i_srst                  (srst            ),
        .i_host_sel              (sel             ), 
        .i_host_rd_wr_n          (rd_wr_n         ), 
        .i_host_byte_addr        (byte_addr       ), 
        .i_host_wdata            (wdata           ), 
        .o_host_ack              (ack             ), 
        .o_host_rdata            (rdata           ), 
        .cmd                     (cmd_bus         ));


endmodule


