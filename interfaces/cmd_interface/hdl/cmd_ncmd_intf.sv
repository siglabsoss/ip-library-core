/*
 * Brief: This module creates multiple cmd_intf outs based on parameters
 *        specified.
 * 
 */

module cmd_ncmd_intf #(
    parameter NUM_OUTPUT_SEL_BITS                =  4,
    parameter HOST_ADDRESS_BITS                  = 26,
    parameter TARGETS_ADRESS_BITS                = 16, // these modules are internal, by policy we will follow only 16 bits.
    parameter HOST_DATA_BITS                     = 32,
    // be sure to set to a value less than the ACK timeout clocks of the module driving i_cmd
    parameter int         P_CMD_ACK_TIMEOUT_CLKS = 16 
    )

(
    input               i_sys_clk,
    input               i_sys_rst,
    // incoming interface from fmc_slave
    intf_cmd.slave      i_cmd,
    // outgoing interfaces
    intf_cmd.master     o_cmd[(NUM_OUTPUT_SEL_BITS**2)-1:0]
     
);


localparam CMD_DATA_BITS = HOST_DATA_BITS;
localparam CMD_ADDR_BITS = HOST_ADDRESS_BITS - 2 ** (NUM_OUTPUT_SEL_BITS);
localparam NUM_OUTPUT_BRIDGES = 2 ** (NUM_OUTPUT_SEL_BITS);

logic [NUM_OUTPUT_SEL_BITS-1:0]  select_bridge;
logic [NUM_OUTPUT_SEL_BITS-1:0]  select_bridge_reg;
logic [NUM_OUTPUT_BRIDGES-1:0]          cmd_sel;

logic [31:0]                            cmd_rdata[CMD_DATA_BITS-1:0];
logic [NUM_OUTPUT_BRIDGES-1:0]          cmd_ack;
logic                                   cmd_rd_wr_n;
logic [CMD_ADDR_BITS-1:0]               cmd_byte_addr;
logic [CMD_DATA_BITS-1:0]               cmd_wdata;


logic [$clog2(P_CMD_ACK_TIMEOUT_CLKS)-1:0] cmd_ack_timeout_cntr;
logic                                      cmd_ack_timeout_cntr_en;

enum {
    IDLE,
    WAIT_FOR_ACK
} bridge_fsm;


genvar i;

generate 
  for (i = 0; i < NUM_OUTPUT_BRIDGES; i = i + 1)  begin : dm_out
            assign o_cmd[i].sel       = cmd_sel[i];
            assign o_cmd[i].rd_wr_n   = cmd_rd_wr_n;
            assign o_cmd[i].byte_addr = cmd_byte_addr;
            assign o_cmd[i].wdata     = cmd_wdata;
            assign cmd_rdata[i]       = o_cmd[i].rdata;
            assign cmd_ack[i]         = o_cmd[i].ack;
  end
endgenerate


always_comb begin
    select_bridge = i_cmd.byte_addr[HOST_ADDRESS_BITS-1:CMD_ADDR_BITS];
end

always_ff @ (posedge i_sys_clk) begin: CMD_ACK_TIMEOUT_CNTR

    if ((~cmd_ack_timeout_cntr_en) | i_sys_rst) begin
        cmd_ack_timeout_cntr <= {$bits(cmd_ack_timeout_cntr){1'b0}};
    end else begin
        cmd_ack_timeout_cntr <= cmd_ack_timeout_cntr + 1;
    end
end


always_ff @(posedge i_sys_clk) begin
    if(i_sys_rst) begin
         cmd_sel    <= {NUM_OUTPUT_BRIDGES{1'b0}};
         cmd_ack_timeout_cntr_en <= 0;
         bridge_fsm <= IDLE;
    end else begin
        cmd_sel    <= {NUM_OUTPUT_BRIDGES{1'b0}};
        cmd_ack_timeout_cntr_en <= 0;
          case (bridge_fsm)
            IDLE: begin
                if (i_cmd.sel) begin
                    cmd_sel[select_bridge] <= 1;
                    cmd_rd_wr_n            <= i_cmd.rd_wr_n;
                    cmd_byte_addr          <= i_cmd.byte_addr[CMD_ADDR_BITS-1:0] & ({(CMD_ADDR_BITS){1'b0}} | {TARGETS_ADRESS_BITS{1'b1}}) ;
                    cmd_wdata              <= i_cmd.wdata;
                    select_bridge_reg      <= select_bridge;
                    cmd_ack_timeout_cntr_en <= 1'b1;
                    bridge_fsm             <= WAIT_FOR_ACK;             
                end

            end

            WAIT_FOR_ACK: begin
                if(cmd_ack[select_bridge_reg]) begin
                    i_cmd.ack               <= 1;
                    i_cmd.rdata             <= cmd_rdata[select_bridge_reg];
                    bridge_fsm              <= IDLE;
                end else if ((cmd_ack_timeout_cntr == P_CMD_ACK_TIMEOUT_CLKS -1)) begin 
                    bridge_fsm <= IDLE;
                end

            end
            default: begin
                bridge_fsm <= IDLE;
            end
          endcase
    end
end

endmodule
