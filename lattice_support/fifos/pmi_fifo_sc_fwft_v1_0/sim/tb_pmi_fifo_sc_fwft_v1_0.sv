/*
 * Module: tb_pmi_fifo_sc_fwft_v1_0
 * 
 */
 
module tb_pmi_fifo_sc_fwft_v1_0;
    
    /* TEST BENCH SIGNALS */    

    localparam TB_DEPTH          = 1024;
    localparam TB_DEPTH_AFULL    = 1023;
    localparam TB_WIDTH          = 8;
    localparam TB_FAMILY         = "ecp5u";
    localparam TB_IMPLEMENTATION = "EBR";
    
    logic                clk = 0;
    logic                rst = 0;
    logic                wren = 0;
    logic                rden = 0;
    logic                full;
    logic                afull;
    logic [TB_WIDTH-1:0] wdata;
    logic [TB_WIDTH-1:0] rdata;
    logic                rdata_vld;

        
    /*
     * 
     * CLOCK & RESET GENERATION
     * 
     */
    
    initial begin
        forever #5ns clk <= ~clk;
    end
    
    initial begin
        @(posedge clk);
        rst <= 1;
        repeat (10) @(posedge clk);
        rst <= 0;
    end
    
    
    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        
        bit [TB_WIDTH-1:0] tb_wrdata = '0;
        
        @(negedge rst);
        repeat (10) @(posedge clk);
        
        repeat (TB_DEPTH) begin
            @(posedge clk);
            wren      <= 1;
            wdata     <= tb_wrdata;
            tb_wrdata <= tb_wrdata + 1;
        end
        
        @(posedge clk);
        wren <= 0;
            
        repeat (1000) @(posedge clk);
        
        $display("<<<TB_SUCCESS>>>");
        $finish();
    end
    
    initial begin
        @(negedge rst);
        
        forever begin
            @(posedge clk);
            rden <= rdata_vld;
        end
    end
    
    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH          (TB_DEPTH          ), 
        .DEPTH_AFULL    (TB_DEPTH_AFULL    ), 
        .WIDTH          (TB_WIDTH          ), 
        .FAMILY         (TB_FAMILY         ), 
        .IMPLEMENTATION (TB_IMPLEMENTATION ),
        .SIM_MODE       (1)
        ) pmi_fifo_sc_fwft_v1_0 (
        .clk            (clk          ), 
        .rst            (rst      ), 
        .wren           (wren           ), 
        .wdata          (wdata          ), 
        .full           (full           ), 
        .afull          (afull          ),
        .rden           (rden           ), 
        .rdata          (rdata          ), 
        .rdata_vld      (rdata_vld      ));

endmodule


`default_nettype wire
