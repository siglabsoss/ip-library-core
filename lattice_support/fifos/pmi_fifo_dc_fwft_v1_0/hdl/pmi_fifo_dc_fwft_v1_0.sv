
/*
 * Module: pmi_fifo_dc_fwft_v1_0
 * 
 * Wraps the Lattice pmi_fifo_dc macro and adds logic for it to operate as a first-word-fall-through FIFO
 * 
 */
 
`default_nettype none

module pmi_fifo_dc_fwft_v1_0 #(
    parameter int unsigned WR_DEPTH       = 1024,     // should be a power of 2
    parameter int unsigned WR_DEPTH_AFULL = 1023,
    parameter int unsigned WR_WIDTH       = 8,
    parameter int unsigned RD_WIDTH       = 32,       // should be an integer ratio of WR_WIDTH
    parameter              FAMILY         = "ECP5U", 
    parameter              IMPLEMENTATION = "EBR",    // "LUT" or "EBR"
    parameter              RESET_MODE     = "sync",   // "async" or "sync"

    // 0 = no swap, 1 = swap larger of write width or read width on a boundary that is the smaller of the two.  
    // For example if WR_WIDTH = 8, RD_WIDTH = 32, and WORD_SWAP = 0 then the first byte written into this FIFO will appear as the LSB of the first word read from it.
    // Setting this parameter to 1 makes it so that this first byte written appears as the MSB of the first word read.
    parameter bit          WORD_SWAP      = 1,        
    parameter bit          SIM_MODE       = 0,         // set to one if simulating since Lattice's pmi_fifo_dc behavioral model incorrectly errors out complaining that "sync" resetmode isn't supported for ECP5
    parameter bit          VERILATE       = 0,
    parameter bit          DELAYED_BACK_PRESSURE = 0
)(
    input      wire                wrclk,
    input      wire                wrclk_rst,
    input      wire                rdclk,
    input      wire                rdclk_rst,
    input      wire                wren,
    input      wire [WR_WIDTH-1:0] wdata,
    output     wire               full,
    output     wire               afull,
    input      wire               rden,
    output     wire[RD_WIDTH-1:0] rdata,
    output reg                rdata_vld
);

`ifndef SMODE
  parameter MODE=0;
`else
  parameter MODE=1;
`endif
    
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
            
    generate
        
        if (MODE|SIM_MODE) begin

            pmi_fifo_dc #(
                .pmi_data_width_w      (WR_WIDTH),
                .pmi_data_width_r      (RD_WIDTH),
                .pmi_data_depth_w      (WR_DEPTH),
                .pmi_data_depth_r      (RD_DEPTH),
                .pmi_full_flag         (WR_DEPTH),
                .pmi_empty_flag        (0),
                .pmi_almost_full_flag  (WR_DEPTH_AFULL), 
                .pmi_almost_empty_flag (1),
                .pmi_regmode           ("noreg"), // this must be "noreg" for fwft logic below to work
                .pmi_resetmode         ("async"), // must be "async" for simulation or sim will fail with an error because Lattice has a bug in their pmi_fifo_dc sim model
                .pmi_family            (FAMILY),
                .module_type           ("pmi_fifo_dc"),
                .pmi_implementation    (IMPLEMENTATION)
            ) le_fifo_dc (
                .Data        (wdata_int),
                .WrClock     (wrclk),
                .RdClock     (rdclk),
                .Reset       (wrclk_rst),
                .RPReset     (rdclk_rst),
                .WrEn        (wren),
                .Full        (full),
                .RdEn        (fifo_rden),
                .Q           (fifo_rdata),
                .Empty       (fifo_empty),
                .AlmostEmpty (),
                .AlmostFull  (afull)); 
            
        end else begin

        if(!VERILATE) begin

            pmi_fifo_dc #(
                .pmi_data_width_w      (WR_WIDTH),
                .pmi_data_width_r      (RD_WIDTH),
                .pmi_data_depth_w      (WR_DEPTH),
                .pmi_data_depth_r      (RD_DEPTH),
                .pmi_full_flag         (WR_DEPTH),
                .pmi_empty_flag        (0),
                .pmi_almost_full_flag  (WR_DEPTH_AFULL), 
                .pmi_almost_empty_flag (1),
                .pmi_regmode           ("noreg"),     // this must be noreg for fwft logic below to work
                .pmi_resetmode         (RESET_MODE), // "sync" seems to work ok for synthesis though
                .pmi_family            (FAMILY),
                .module_type           ("pmi_fifo_dc"),
                .pmi_implementation    (IMPLEMENTATION)
            ) le_fifo_dc (
                .Data        (wdata_int),
                .WrClock     (wrclk),
                .RdClock     (rdclk),
                .Reset       (wrclk_rst),
                .RPReset     (rdclk_rst),
                .WrEn        (wren),
                .Full        (full),
                .RdEn        (fifo_rden),
                .Q           (fifo_rdata),
                .Empty       (fifo_empty),
                .AlmostEmpty (),
                .AlmostFull  (afull)); 

        end else begin
            if (WR_WIDTH != RD_WIDTH ) begin
                // WR_WIDTH must be the same as RD_WIDTH in pmi_fifo_dc_fwft_v1_0 under verilator
                static_assert_pmi_fifo_dc static_assert_pmi_fifo_dc();
            end


            generic_fifo_sc_a #(
               .dw      (WR_WIDTH),
               .aw      ($clog2(WR_WIDTH)),
               .ALMOST_FULL (WR_DEPTH_AFULL)
               ) le_fifo_sc (
                .din         (wdata_int),
                .clk         (wrclk),
                .rst         (!wrclk_rst), // I think this is rst_n
                .we          (wren),
                .clr         (1'b0),
                .full        (full),
                .afull       (afull),
                .afull_n     (),
                .o_afull_n_d (),
                .re          (fifo_rden),
                .dout        (fifo_rdata),
                .empty       (fifo_empty),
                .fillcount   ());



        end


        end

    endgenerate
    
    /* first-word-fall-through logic */

    generate

    if(!DELAYED_BACK_PRESSURE) begin
        assign fifo_rden = ~fifo_empty & (rden | ~rdata_vld | (~fifo_rdata_vld_buf & ~fifo_rdata_vld));
    end else begin
        assign fifo_rden = ~fifo_empty & rden;
    end
    
    always_ff @(posedge rdclk) begin
        if (rdclk_rst) begin
            fifo_rdata_vld <= 0;
        end else begin
            fifo_rdata_vld <= fifo_rden;
        end
    end

    logic [7:0]debug;
    
    always_ff @(posedge rdclk) begin
        if (rdclk_rst) begin
            rdata_vld          <= 0;
            fifo_rdata_vld_buf <= 0;
            debug <= 8'h52;
        end else begin
            if (rden) begin // user asserted read

                if (fifo_rdata_vld_buf) begin                  // valid data in holding buffer, so advance it
                    rdata_int          <= fifo_rdata_buf;
                    rdata_vld          <= 1;
                    debug <= 8'h41; // "A"
                    if (fifo_rdata_vld) begin                  // valid data is also coming out of the fifo so store it
                        fifo_rdata_buf     <= fifo_rdata;
                        fifo_rdata_vld_buf <= 1;
                        debug <= 8'h42; // "B"
                    end else begin                             // no new data from the fifo, 
                        fifo_rdata_vld_buf <= 0;               // so invalidate the holding buffer 
                        debug <= 8'h43; // "C"
                    end
                end else if (fifo_rdata_vld) begin             // no data in holding buffer and new data from
                    rdata_int          <= fifo_rdata;          // the fifo is available so jump over the 
                    rdata_vld          <= 1;                   // holding buffer and advance it
                    fifo_rdata_vld_buf <= 0;
                    debug <= 8'h44; // "D"
                end else begin                                 // no data in holding buffer or from the fifo
                    rdata_vld          <= 0;
                    fifo_rdata_vld_buf <= 0;
                    debug <= 8'h45; // "E"
                end

            end else if (fifo_rdata_vld) begin                 // new data is being read out of the fifo, decide where it should go
                if(DELAYED_BACK_PRESSURE) begin
                    rdata_vld <= fifo_rden;
                end
                if (~rdata_vld) begin                          // we're currently not presenting valid data at the module's output 
                    if (fifo_rdata_vld_buf) begin              // there's valid data in the holding buffer, advance it to the output and replace it with this new data
                        rdata_int          <= fifo_rdata_buf;
                        rdata_vld          <= 1;
                        fifo_rdata_buf     <= fifo_rdata;
                        fifo_rdata_vld_buf <= 1;
                        debug <= 8'h46; // "F"
                    end else begin                             // there's nothing in the holding buffer so skip over it and go straight to output
                        rdata_int          <= fifo_rdata;
                        rdata_vld          <= 1;
                        fifo_rdata_vld_buf <= 0;
                        debug <= 8'h47; // "G"
                    end
                end else begin                                 // we're presenting valid data at the output so put this new data in the holding buffer
                    fifo_rdata_buf     <= fifo_rdata;
                    fifo_rdata_vld_buf <= 1;
                    debug <= 8'h48; // "H"
                end
            end else begin
                if(DELAYED_BACK_PRESSURE) begin
                    rdata_vld <= 0; // or 0
                end
                debug <= 8'h49; // "I"
            end

        end
    end

    endgenerate

    
endmodule

`default_nettype wire
