
`timescale 1ns/1ns

module tb_intf_cmd;
    
    logic tb_cmd_clk = 0;
    logic tb_cmd_srst;
    
    logic          tb_host_sel = 0;
    logic          tb_host_rd_wr_n;
    logic [31:0]   tb_host_byte_addr;
    logic [31:0]   tb_host_wdata;
    logic          tb_host_ack;
    logic [31:0]   tb_host_rdata;
    
    initial begin
        forever #5 tb_cmd_clk = ~tb_cmd_clk;
    end
    
    initial begin
        tb_cmd_srst = 1;
        #1000;
        @(posedge tb_cmd_clk);
        tb_cmd_srst = 0;
    end
    
    initial begin
        @(negedge tb_cmd_srst);
        @(posedge tb_cmd_clk);
        @(posedge tb_cmd_clk);
        @(posedge tb_cmd_clk);
        
        tb_host_sel       <= 1; 
        tb_host_rd_wr_n   <= 0;
        tb_host_byte_addr <= 32'h00000000;
        tb_host_wdata     <= 32'h12345678;
        @(posedge tb_cmd_clk);
        tb_host_sel <= 0;
        @(negedge tb_host_ack);
        @(posedge tb_cmd_clk);
        tb_host_sel       <= 1; 
        tb_host_rd_wr_n   <= 0;
        tb_host_byte_addr <= 32'h80000000;
        tb_host_wdata     <= 32'habcdabcd;
        @(posedge tb_cmd_clk);
        tb_host_sel <= 0;
        @(negedge tb_host_ack);
        @(posedge tb_cmd_clk);
        tb_host_sel       <= 1; 
        tb_host_rd_wr_n   <= 1;
        tb_host_byte_addr <= 32'h00000000;
        @(posedge tb_cmd_clk);
        tb_host_sel       <= 0;
        @(negedge tb_host_ack);
        @(posedge tb_cmd_clk);
        tb_host_sel       <= 1; 
        tb_host_rd_wr_n   <= 1;
        tb_host_byte_addr <= 32'h80000000;
        @(posedge tb_cmd_clk);
        tb_host_sel       <= 0; 
        @(negedge tb_host_ack);
        
        #10000;
        $finish();
        tb_host_sel <= 0;
        
    end

    intf_cmd #(31, 32) tb_cmd_bus[2**1-1:0]();
    
    cmd_slave cmd_slave_0 (.i_sysclk(tb_cmd_clk), .i_srst(tb_cmd_srst), .cmd(tb_cmd_bus[0]));
    cmd_slave cmd_slave_1 (.i_sysclk(tb_cmd_clk), .i_srst(tb_cmd_srst), .cmd(tb_cmd_bus[1]));
    
    cmd_master #(
        .HOST_ADDR_BITS          (32), 
        .HOST_ADDR_BITS_FOR_SEL  (1), 
        .HOST_DATA_BITS          (32)
        ) cmd_master_inst (
        .i_sysclk                (tb_cmd_clk              ),
        .i_srst                  (tb_cmd_srst             ),
        .i_host_sel              (tb_host_sel             ), 
        .i_host_rd_wr_n          (tb_host_rd_wr_n         ), 
        .i_host_byte_addr        (tb_host_byte_addr       ), 
        .i_host_wdata            (tb_host_wdata           ), 
        .o_host_ack              (tb_host_ack             ), 
        .o_host_rdata            (tb_host_rdata           ), 
        .cmd                     (tb_cmd_bus              ));

endmodule


