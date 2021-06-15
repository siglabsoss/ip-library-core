/*
 * Module: tb_pmi_fifo_dc_fwft_v1_0
 * 
 */
 
`default_nettype none
 
module tb_pmi_fifo_dc_fwft_v1_0;
    
    localparam TB_WR_DEPTH       = 1024;
    localparam TB_WR_DEPTH_AFULL = 1023;
    localparam TB_WR_WIDTH       = 8;
    localparam TB_RD_WIDTH       = 32;
    localparam TB_WORD_SWAP      = 1;
    localparam TB_FAMILY         = "ecp5u";
    localparam TB_IMPLEMENTATION = "EBR";
    
    logic                   wrclk = 0;
    logic                   wrclk_rst = 0;
    logic                   rdclk = 0;
    logic                   rdclk_rst = 0;
    logic                   wren = 0;
    logic                   rden = 0;
    logic                   full;
    logic                   afull;
    logic [TB_WR_WIDTH-1:0] wdata;
    logic [TB_RD_WIDTH-1:0] rdata;
    logic                   rdata_vld;

        

    
    /*
     * 
     * CLOCK & RESET GENERATION
     * 
     */
    
    initial begin
        forever #5ns wrclk <= ~wrclk;
    end
    
    initial begin
        forever #5ns rdclk <= ~rdclk;
    end
    
    initial begin
        @(posedge wrclk);
        wrclk_rst <= 1;
        repeat (10) @(posedge wrclk);
        wrclk_rst <= 0;
    end
    
    initial begin
        @(posedge rdclk);
        rdclk_rst <= 1;
        repeat (10) @(posedge rdclk);
        rdclk_rst <= 0;
    end
    
    
    /*
     * 
     * STIMULUS
     * 
     */
    
    initial begin
        
        bit [TB_WR_WIDTH-1:0] tb_wrdata = '0;
        
        @(negedge wrclk_rst);
        repeat (10) @(posedge wrclk);
        
        repeat (TB_WR_DEPTH) begin
            @(posedge wrclk);
            wren      <= 1;
            wdata     <= tb_wrdata;
            tb_wrdata <= tb_wrdata + 1;
        end
        
        @(posedge wrclk);
        wren <= 0;
            
        repeat (1000) @(posedge wrclk);
        
        $display("<<<TB_SUCCESS>>>");
        $finish();
    end
    
    initial begin
        @(negedge rdclk_rst);
        
        forever begin
            @(posedge rdclk);
            rden <= rdata_vld;
        end
    end
    
    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH        (TB_WR_DEPTH       ), 
        .WR_DEPTH_AFULL  (TB_WR_DEPTH_AFULL ), 
        .WR_WIDTH        (TB_WR_WIDTH       ), 
        .RD_WIDTH        (TB_RD_WIDTH       ), 
        .FAMILY          (TB_FAMILY         ), 
        .IMPLEMENTATION  (TB_IMPLEMENTATION ), 
        .WORD_SWAP       (TB_WORD_SWAP      ),
        .SIM_MODE        (1'b1              )
        ) pmi_fifo_dc_fwft_v1_0 (
        .wrclk           (wrclk          ), 
        .wrclk_rst       (wrclk_rst      ), 
        .rdclk           (rdclk          ), 
        .rdclk_rst       (rdclk_rst      ), 
        .wren            (wren           ), 
        .wdata           (wdata          ), 
        .full            (full           ), 
        .afull           (afull          ),
        .rden            (rden           ), 
        .rdata           (rdata          ), 
        .rdata_vld       (rdata_vld      ));

endmodule


`default_nettype wire