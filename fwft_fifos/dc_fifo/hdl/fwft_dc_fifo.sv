
/*
 * Module: fwft_dc_fifo
 * 
 * Wraps the Lattice pmi_fifo_dc macro and adds logic for it to operate as a first-word-fall-through FIFO
 * 
 */
 
`default_nettype none

module fwft_dc_fifo #(
    parameter int unsigned WR_DEPTH       = 1024,     // should be a power of 2
    parameter int unsigned WR_WIDTH       = 8
    //parameter int unsigned RD_WIDTH       = 32,       // should be an integer ratio of WR_WIDTH

    // 0 = no swap, 1 = swap larger of write width or read width on a boundary that is the smaller of the two.  
    // For example if WR_WIDTH = 8, RD_WIDTH = 32, and WORD_SWAP = 0 then the first byte written into this FIFO will appear as the LSB of the first word read from it.
    // Setting this parameter to 1 makes it so that this first byte written appears as the MSB of the first word read.
   // parameter bit          WORD_SWAP      = 1,        
    
)(
    input      wire                wrclk,
    input      wire                wrclk_rst,
    input      wire                rdclk,
    input      wire                rdclk_rst,
    input      wire                wren,
    input      wire [WR_WIDTH-1:0] wdata,
    output     wire               full,
    input      wire               rden,
    output     wire[RD_WIDTH-1:0] rdata,
    output reg                rdata_vld
);
    localparam int unsigned RD_WIDTH       = WR_WIDTH;       // should be an integer ratio of WR_WIDTH
    localparam WORD_SWAP = 0;
    /* parameter range checks */
    initial begin
        assert ( (WR_WIDTH >= 1) && (WR_WIDTH <= 256) ) else $fatal(1, "Error!  Parameter WR_WIDTH must be in the range [1,256]");
        assert ( (RD_WIDTH >= 1) && (RD_WIDTH <= 256) ) else $fatal(1, "Error!  Parameter RD_WIDTH must be in the range [1,256]");
    end

    localparam RD_DEPTH   = (WR_WIDTH < RD_WIDTH) ? (WR_DEPTH / (RD_WIDTH/WR_WIDTH)) : (WR_DEPTH * (WR_WIDTH/RD_WIDTH));
    localparam PORT_RATIO = (WR_WIDTH < RD_WIDTH) ? (RD_WIDTH/WR_WIDTH) : (WR_WIDTH/RD_WIDTH);

    logic                fifo_rden;
    logic                fifo_empty;
    logic [RD_WIDTH-1:0] fifo_rdata;
    logic                fifo_rdata_vld;
    logic [RD_WIDTH-1:0] fifo_rdata_buf;
    logic                fifo_rdata_vld_buf;
    
    logic [WR_WIDTH-1:0] wdata_int;
    logic [RD_WIDTH-1:0] rdata_int;
    
    // swapping of input or output data ports based on user preference and port width ratios
    generate
        genvar i;
        if (WORD_SWAP == 1) begin 
            if (WR_WIDTH < RD_WIDTH) begin
                assign wdata_int = wdata;
                for (i=0; i<PORT_RATIO; i++) begin
                    assign rdata[(RD_WIDTH-(i*WR_WIDTH)-1):(RD_WIDTH-(i*WR_WIDTH)-WR_WIDTH)] = rdata_int[((i*WR_WIDTH)+WR_WIDTH-1):(i*WR_WIDTH)];
                end
            end else if (WR_WIDTH > RD_WIDTH) begin
                assign rdata = rdata_int;
                for (i=0; i<PORT_RATIO; i++) begin
                    assign wdata_int[(WR_WIDTH-(i*RD_WIDTH)-1):(WR_WIDTH-(i*RD_WIDTH)-RD_WIDTH)] = wdata[((i*RD_WIDTH)+RD_WIDTH-1):(i*RD_WIDTH)];
                end
            end else begin // nothing to swap if same widths
                assign rdata     = rdata_int;
                assign wdata_int = wdata;
            end
        end else begin
            assign rdata     = rdata_int;
            assign wdata_int = wdata;
        end
    endgenerate
            
   
    generic_fifo_dc #(
    		.dw      (WR_WIDTH),
    		.aw      ($clog2(WR_DEPTH))
    	) le_fifo_dc (
    		.din        (wdata_int),
    		.wr_clk     (wrclk),
    		.rd_clk     (rdclk),
    		.wrst       (!wrclk_rst),
    		.rrst       (!rdclk_rst),
    		.we          (wren),
    		.full        (full),
    		.re          (fifo_rden),
    		.dout        (fifo_rdata),
    		.empty       (fifo_empty),
        .clr 		 (1'b0)); 
            
        
    

    assign fifo_rden = ~fifo_empty & (rden | ~rdata_vld | (~fifo_rdata_vld_buf & ~fifo_rdata_vld));
    
    always_ff @(posedge rdclk) begin
        if (rdclk_rst) begin
            fifo_rdata_vld <= 0;
        end else begin
            fifo_rdata_vld <= fifo_rden;
        end
    end

    /* first-word-fall-through logic */
    
    always_ff @(posedge rdclk) begin
        if (rdclk_rst) begin
            rdata_vld          <= 0;
            fifo_rdata_vld_buf <= 0;
        end else begin
            
            if (rden) begin // user asserted read

                if (fifo_rdata_vld_buf) begin                  // valid data in holding buffer, so advance it
                    rdata_int          <= fifo_rdata_buf;
                    rdata_vld          <= 1;
                    if (fifo_rdata_vld) begin                  // valid data is also coming out of the fifo so store it
                        fifo_rdata_buf     <= fifo_rdata;
                        fifo_rdata_vld_buf <= 1;
                    end else begin                             // no new data from the fifo, so invalidate the holding buffer 
                        fifo_rdata_vld_buf <= 0;
                    end
                end else if (fifo_rdata_vld) begin             // no data in holding buffer and new data from the fifo is available so jump over the holding buffer and advance it
                    rdata_int          <= fifo_rdata;
                    rdata_vld          <= 1;
                    fifo_rdata_vld_buf <= 0;
                end else begin                                 // no data in holding buffer or from the fifo
                    rdata_vld          <= 0;
                    fifo_rdata_vld_buf <= 0;
                end

            end else if (fifo_rdata_vld) begin                 // new data is being read out of the fifo, decide where it should go
                
                if (~rdata_vld) begin                          // we're currently not presenting valid data at the module's output 
                    if (fifo_rdata_vld_buf) begin              // there's valid data in the holding buffer, advance it to the output and replace it with this new data
                        rdata_int          <= fifo_rdata_buf;
                        rdata_vld          <= 1;
                        fifo_rdata_buf     <= fifo_rdata;
                        fifo_rdata_vld_buf <= 1;
                    end else begin                             // there's nothing in the holding buffer so skip over it and go straight to output
                        rdata_int          <= fifo_rdata;
                        rdata_vld          <= 1;
                        fifo_rdata_vld_buf <= 0;
                    end
                end else begin                                 // we're presenting valid data at the output so put this new data in the holding buffer
                    fifo_rdata_buf     <= fifo_rdata;
                    fifo_rdata_vld_buf <= 1;
                end

            end

        end
    end

    
endmodule

`default_nettype wire