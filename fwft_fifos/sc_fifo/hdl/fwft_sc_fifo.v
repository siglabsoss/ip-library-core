
module fwft_sc_fifo 
  #(
    parameter DEPTH = 1024, // should be a power of 2
    parameter WIDTH = 8,
    parameter ALMOST_FULL = 10

    )
   (
    input wire             clk,
    input wire             rst,
    input wire             wren,
    input wire [WIDTH-1:0] wdata,
    output wire            full,
    output wire            o_afull,
    input wire             rden,
    output reg [WIDTH-1:0] rdata,
    output reg             rdata_vld,
    output wire            o_afull_n,
    output wire            o_afull_n_d,
    output wire [31:0]     fillcount

    );
   /* parameter range checks */

   wire                    fifo_rden;
   wire                    fifo_empty;
   wire [WIDTH-1:0]        fifo_rdata;
   reg                     fifo_rdata_vld;
   reg [WIDTH-1:0]         fifo_rdata_buf;
   reg                     fifo_rdata_vld_buf;
   /* verilator lint_off PINMISSING */

   generic_fifo_sc_a 
     #(
       .dw      (WIDTH),
       .aw      ($clog2(DEPTH)),
       .ALMOST_FULL (ALMOST_FULL)
       ) le_fifo_sc 
       (
        .din        (wdata),
        .clk      (clk),
        .rst         (!rst),
        .we          (wren),
        .clr         (1'b0),
        .full       (full),
        .afull    (o_afull),
        .afull_n   (o_afull_n),
        .o_afull_n_d (o_afull_n_d),
        .re          (fifo_rden),
        .dout       (fifo_rdata),
        .empty      (fifo_empty),
        .fillcount(fillcount));

   /* verilator lint_on PINMISSING */


   assign fifo_rden = ~fifo_empty & (rden | ~rdata_vld | (~fifo_rdata_vld_buf & ~fifo_rdata_vld));

   always @(posedge clk) begin
      if (rst) begin
         fifo_rdata_vld <= 0;
      end else begin
         fifo_rdata_vld <= fifo_rden;
      end
   end

   /* first-word-fall-through logic */

   always @(posedge clk) begin
      if (rst) begin
         rdata_vld          <= 0;
         fifo_rdata_vld_buf <= 0;
      end else begin

         if (rden) begin // user asserted read

            if (fifo_rdata_vld_buf) begin                  // valid data in holding buffer, so advance it
               rdata              <= fifo_rdata_buf;
               rdata_vld          <= 1;
               if (fifo_rdata_vld) begin                  // valid data is also coming out of the fifo so store it
                  fifo_rdata_buf     <= fifo_rdata;
                  fifo_rdata_vld_buf <= 1;
               end else begin                             // no new data from the fifo, so invalidate the holding buffer
                  fifo_rdata_vld_buf <= 0;
               end
            end else if (fifo_rdata_vld) begin             // no data in holding buffer and new data from the fifo is available so jump over the holding buffer and advance it
               rdata              <= fifo_rdata;
               rdata_vld          <= 1;
               fifo_rdata_vld_buf <= 0;
            end else begin                                 // no data in holding buffer or from the fifo
               rdata_vld          <= 0;
               fifo_rdata_vld_buf <= 0;
            end

         end else if (fifo_rdata_vld) begin                 // new data is being read out of the fifo, decide where it should go

            if (~rdata_vld) begin                          // we're currently not presenting valid data at the module's output
               if (fifo_rdata_vld_buf) begin              // there's valid data in the holding buffer, advance it to the output and replace it with this new data
                  rdata              <= fifo_rdata_buf;
                  rdata_vld          <= 1;
                  fifo_rdata_buf     <= fifo_rdata;
                  fifo_rdata_vld_buf <= 1;
               end else begin                             // there's nothing in the holding buffer so skip over it and go straight to output
                  rdata              <= fifo_rdata;
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
