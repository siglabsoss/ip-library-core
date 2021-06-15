/*
 * Brief: This module emits multiple select lines based on the configurable 
 *        NumOutputSelects and NumBoardCmdIntfs
 */

module intf_demux #(
    parameter NUM_BOARD_CMD_INTFS   =  4, // This is the cmd_intfs coming out of fmc_bridge
    parameter NUM_OUTPUT_SELECTS    =  8,
    parameter HOST_ADDRESS_BITS     = 25,
    parameter TARGETS_ADRESS_BITS   = 16, // TODO(tbags): consider design issues
    parameter HOST_DATA_BITS        = 32
    )
(
    // system inputs
    input i_sys_clk,    // Clock
    input i_sys_rst,    // System reset.

    // TODO(shashank): Try to make this cooler :P
    output [NUM_OUTPUT_SELECTS-1:0] o_select_lines,
    intf_cmd.slave                  i_cmd_master,
    // We don't o_sel here we 
    intf_cmd.master                 o_cmd_memory

);

localparam DEMUX_SEL_START = HOST_ADDRESS_BITS - $clog2(NUM_BOARD_CMD_INTFS);
localparam DEMUX_SEL_END = HOST_ADDRESS_BITS - $clog2(NUM_BOARD_CMD_INTFS) - $clog2(NUM_OUTPUT_SELECTS);

reg [NUM_OUTPUT_SELECTS-1:0] select_reg;


reg                            cmd_sel_reg;
reg                            cmd_ack_reg;
reg                            cmd_rd_wr_n_reg;
reg [TARGETS_ADRESS_BITS-1:0]  cmd_byte_addr_reg;
reg [HOST_DATA_BITS-1:0]       cmd_wdata_reg;
reg [HOST_DATA_BITS-1:0]       cmd_rdata_reg;

reg [$clog2(NUM_OUTPUT_SELECTS)-1:0] demux_selector;

enum {
    IDLE,
    DEMUX
} demux_fsm;

integer iter;

always_ff @(posedge i_sys_clk) begin 
    if(i_sys_rst) begin
        demux_fsm <= IDLE;
    end else begin
        cmd_sel_reg <= i_cmd_master.sel;
        cmd_rd_wr_n_reg <= i_cmd_master.rd_wr_n;
        cmd_byte_addr_reg <= i_cmd_master.byte_addr;
        cmd_wdata_reg <= i_cmd_master.wdata;

        cmd_ack_reg <= o_cmd_memory.ack;
        cmd_rdata_reg <= o_cmd_memory.rdata;

        case(demux_fsm)
            IDLE: begin
                if(i_cmd_master.sel) begin
                    demux_selector <= i_cmd_master.byte_addr[DEMUX_SEL_START -1 : DEMUX_SEL_END -1];
                    demux_fsm <= DEMUX;
                end
            end
            DEMUX: begin
                for(iter = 0; iter < NUM_OUTPUT_SELECTS; iter++) begin
                    if(iter == demux_selector) begin
                        select_reg[iter] = cmd_sel_reg;
                    end
                end
                if (o_cmd_memory.ack) begin
                    demux_fsm <= IDLE;
                end
            end
            default: begin
                demux_fsm <= DEMUX;
            end
        endcase // demux_fsm

    end

end

assign o_select_lines = select_reg;

assign i_cmd_master.ack = cmd_ack_reg;
assign i_cmd_master.rdata = cmd_rdata_reg;

assign o_cmd_memory.wdata = cmd_wdata_reg;
assign o_cmd_memory.rd_wr_n = cmd_rd_wr_n_reg;

endmodule // intf_demux
