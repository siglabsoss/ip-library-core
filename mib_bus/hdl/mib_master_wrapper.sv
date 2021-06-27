
`default_nettype none

module mib_master_wrapper
#( 
    parameter int       P_MIB_ACK_TIMEOUT_CLKS = 32    // This is how many clocks to wait for a CMD ACK before concluding that no ACK will ever come (SHOULD MAKE SMALLER THAN MIB BUS ACK TIMEOUT!)
)
(
    input  wire             i_sysclk, 
    input  wire             i_srst,
    output reg              o_mib_start,            // from master, starts a mib transaction
    output reg              o_mib_rd_wr_n,          // 1 = read, 0 = write
    output reg              o_cmd_mib_timeout,      //
    input  wire             i_mib_slave_ack,        // slave drives this during read data phases (if it's the target) (MAKE SURE THIS IS PULLED LOW AT MASTER)
    inout  wire             [15:0] mib_dabus,       // driven by slave during read data phases (if needed)
    intf_cmd.slave          cmd_slave
);

logic [15:0]                 mib_ad_int;
logic                        mib_ack_int_reg;
logic [15:0]                 mib_ad_int_reg        /* synthesis syn_noprune=1 */;
logic                        mib_ad_int_high_z_reg /* synthesis syn_noprune=1 */;                            
logic                        mib_ad_high_z_int;                            
logic [15:0]                 mib_ad_in_reg;
logic                        mib_start_int;
logic                        cmd_mib_timeout_int;
logic                        mib_rd_wr_n_int;

always_ff @(posedge i_sysclk) begin
    mib_ad_in_reg      <= mib_dabus;        
    mib_ack_int_reg    <= i_mib_slave_ack; 
    o_mib_start        <= mib_start_int;   
    o_mib_rd_wr_n      <= mib_rd_wr_n_int; 
    o_cmd_mib_timeout  <= cmd_mib_timeout_int;
end 

 
mib_master #(
    .P_MIB_ACK_TIMEOUT_CLKS(P_MIB_ACK_TIMEOUT_CLKS)  // This is how many clocks to wait for a slave ACK before concluding that no ACK will ever come :(
)
_mib_master
(
    .i_sysclk             (i_sysclk            ),      // currently cmd and mib interface are synchronous to this clock
    .i_srst               (i_srst              ), 
	.cmd_slave            (cmd_slave           ), 
    .i_mib_ad             (mib_ad_in_reg       ),      // driven by slave during read data phases (if needed)    
    .i_mib_slave_ack      (mib_ack_int_reg     ),      // slave drives this during write phase to ack write data or during read data phase to signal valid read data 
    .o_cmd_mib_timeout    (cmd_mib_timeout_int ), 
    .o_mib_start          (mib_start_int       ),      // master drives this for one clock during address phase 1 
    .o_mib_rd_wr_n        (mib_rd_wr_n_int     ),      // 1 = read  0 = write
    .o_mib_ad_high_z      (mib_ad_high_z_int   ),      // 1 = tri-state b_mib_ad at top level  0 = drive it
    .o_mib_ad             (mib_ad_int          )       // driven by master during address phases and write data phases (if needed)
);

always_ff @(posedge i_sysclk) begin
    mib_ad_int_reg         <= mib_ad_int;
    mib_ad_int_high_z_reg  <= mib_ad_high_z_int;
end

assign mib_dabus   = (mib_ad_int_high_z_reg)  ? 'bz : mib_ad_int_reg;

endmodule

`default_nettype wire