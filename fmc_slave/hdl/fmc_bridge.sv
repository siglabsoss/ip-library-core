/*
 * Brief: bridge outs of cmd_intf selected based on the NumOutputBridge and
 *        HostTargetAddress.
 * 
 */

module fmc_bridge #(
    parameter NUM_OUTPUT_BRIDGES    =  4,
    parameter HOST_ADDRESS_BITS     = 26,
    parameter TARGETS_ADRESS_BITS   = 21,
    parameter HOST_DATA_BITS        = 32
    )

(
    input               i_sys_clk,
    input               i_sys_rst,
    // incoming interface from fmc_slave
    intf_cmd.slave      i_fmc,
    // outgoing interfaces
    intf_cmd.master     o_ext[(NUM_OUTPUT_BRIDGES)-1:0]
     
);


localparam CMD_DATA_BITS = HOST_DATA_BITS;
localparam CMD_ADDR_BITS = HOST_ADDRESS_BITS - $clog2(NUM_OUTPUT_BRIDGES);

logic [$clog2(NUM_OUTPUT_BRIDGES)-1:0]  select_bridge;
logic [$clog2(NUM_OUTPUT_BRIDGES)-1:0]  select_bridge_reg;
logic [NUM_OUTPUT_BRIDGES-1:0]          cmd_sel;

logic [31:0]                            cmd_rdata[CMD_DATA_BITS-1:0] /* synthesis syn_keep = 1 */;
logic [NUM_OUTPUT_BRIDGES-1:0]          cmd_ack;
logic                                   cmd_rd_wr_n;
logic [CMD_ADDR_BITS-1:0]               cmd_byte_addr;
logic [CMD_DATA_BITS-1:0]               cmd_wdata;

enum {
    IDLE,
    WAIT_FOR_ACK
} bridge_fsm;


genvar i;

generate 
  for (i = 0; i < NUM_OUTPUT_BRIDGES; i = i + 1)  begin : dm_out
            assign o_ext[i].sel       = cmd_sel[i];
            assign o_ext[i].rd_wr_n   = cmd_rd_wr_n;
            assign o_ext[i].byte_addr = cmd_byte_addr;
            assign o_ext[i].wdata     = cmd_wdata;
            assign cmd_rdata[i]       = o_ext[i].rdata;
            assign cmd_ack[i]         = o_ext[i].ack;
  end
endgenerate


always_comb begin
    select_bridge = i_fmc.byte_addr[HOST_ADDRESS_BITS-1:CMD_ADDR_BITS];
end


always_ff @(posedge i_sys_clk) begin
    if(i_sys_rst) begin
         cmd_sel    <= {NUM_OUTPUT_BRIDGES{1'b0}};
         bridge_fsm <= IDLE;
    end else begin
        cmd_sel    <= {NUM_OUTPUT_BRIDGES{1'b0}};
          case (bridge_fsm)
            IDLE: begin
                if (i_fmc.sel) begin
                    cmd_sel[select_bridge] <= 1;
                    cmd_rd_wr_n            <= i_fmc.rd_wr_n;
                    cmd_byte_addr          <= i_fmc.byte_addr[CMD_ADDR_BITS-1:0];
                    cmd_wdata              <= i_fmc.wdata;
                    select_bridge_reg      <= select_bridge;
                    bridge_fsm             <= WAIT_FOR_ACK;             
                end

            end

            WAIT_FOR_ACK: begin
                if(cmd_ack[select_bridge_reg]) begin
                    i_fmc.ack               <= 1;
                    i_fmc.rdata             <= cmd_rdata[select_bridge_reg];
                    bridge_fsm              <= IDLE;
                end

            end
            default: begin
                bridge_fsm <= IDLE;
                    end
          endcase
    end
end

endmodule
