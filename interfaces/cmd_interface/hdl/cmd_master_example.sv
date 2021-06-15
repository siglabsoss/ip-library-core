module cmd_master #(
    parameter int unsigned HOST_ADDR_BITS         = 32,
    parameter int unsigned HOST_ADDR_BITS_FOR_SEL = 8,
    parameter int unsigned HOST_DATA_BITS         = 32,
    parameter int unsigned CMD_ACK_TIMEOUT_CLKS   = 32 
)(
    input                           i_sysclk,
    input                           i_srst,
    input                           i_host_sel,
    input                           i_host_rd_wr_n,
    input      [HOST_ADDR_BITS-1:0] i_host_byte_addr,
    input      [HOST_DATA_BITS-1:0] i_host_wdata,
    output reg                      o_host_ack,
    output reg [31:0]               o_host_rdata,
    intf_cmd.master                 cmd[2**HOST_ADDR_BITS_FOR_SEL]
);
    
    localparam CMD_SLAVES    = 2**HOST_ADDR_BITS_FOR_SEL;
    localparam CMD_ADDR_BITS = HOST_ADDR_BITS - HOST_ADDR_BITS_FOR_SEL;
    localparam CMD_DATA_BITS = HOST_DATA_BITS;
    
    
    logic [CMD_SLAVES-1:0]    cmd_ack;
    logic [CMD_SLAVES-1:0]    cmd_sel;
    logic [31:0]              cmd_rdata[CMD_SLAVES-1:0];
    logic                     cmd_rd_wr_n;
    logic [CMD_ADDR_BITS-1:0] cmd_byte_addr;
    logic [CMD_DATA_BITS-1:0] cmd_wdata;
    
    logic [HOST_ADDR_BITS_FOR_SEL-1:0] slave_index;
    logic [HOST_ADDR_BITS_FOR_SEL-1:0] slave_index_reg;
    
    enum {
        IDLE,
        WAIT_FOR_SLAVE_ACK
    } cmd_master_fsm_state;
    
    logic [$clog2(CMD_ACK_TIMEOUT_CLKS)-1:0] cmd_ack_timeout_cntr;
    
    
    /* tie all common slave signals together (and pray synthesis tools are smart enough to remove duplicate logic) */
    
    genvar i;
    generate
        for (i=0; i<CMD_SLAVES; i++) begin
            assign cmd[i].sel       = cmd_sel[i];
            assign cmd[i].rd_wr_n   = cmd_rd_wr_n;
            assign cmd[i].byte_addr = cmd_byte_addr;
            assign cmd[i].wdata     = cmd_wdata;
            assign cmd_rdata[i]     = cmd[i].rdata;
            assign cmd_ack[i]       = cmd[i].ack;
        end
    endgenerate
    

    always_comb begin
        slave_index = i_host_byte_addr[HOST_ADDR_BITS-1:CMD_ADDR_BITS];    
    end
    

    always_ff @(posedge i_sysclk) begin
        
        if (i_srst) begin

            cmd_sel              <= {CMD_SLAVES{1'b0}};
            o_host_ack           <= 0;
            cmd_master_fsm_state <= IDLE;

        end else begin
            
            /* defaults */
            cmd_sel    <= '0; 
            o_host_ack <= 0;
            
            case (cmd_master_fsm_state)
                
                IDLE: begin
                    
                    cmd_ack_timeout_cntr <= '0;
                    
                    if (i_host_sel) begin
                        cmd_sel[slave_index] <= 1;
                        cmd_rd_wr_n          <= i_host_rd_wr_n;
                        cmd_byte_addr        <= i_host_byte_addr[CMD_ADDR_BITS-1:0];
                        cmd_wdata            <= i_host_wdata;
                        slave_index_reg      <= slave_index;
                        cmd_master_fsm_state <= WAIT_FOR_SLAVE_ACK;
                    end
                    
                end
                
                WAIT_FOR_SLAVE_ACK: begin
                    
                    cmd_ack_timeout_cntr <= cmd_ack_timeout_cntr + 1;
                    
                    if (cmd_ack[slave_index_reg]) begin
                        o_host_ack           <= 1;
                        o_host_rdata         <= cmd_rdata[slave_index_reg];
                        cmd_master_fsm_state <= IDLE;
                    end else if (cmd_ack_timeout_cntr == (CMD_ACK_TIMEOUT_CLKS-1)) begin // don't ACK host, it should have its own timeout
                        cmd_master_fsm_state <= IDLE;
                    end
                end
                
            endcase
        end
    end
    
endmodule