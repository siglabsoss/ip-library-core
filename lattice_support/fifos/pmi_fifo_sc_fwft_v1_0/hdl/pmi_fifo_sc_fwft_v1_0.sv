
/*
 * Module: pmi_fifo_sc_fwft_v1_0
 * 
 * Wraps the Lattice pmi_fifo macro and adds logic for it to operate as a first-word-fall-through FIFO
 * 
 */
 
`default_nettype none
 
module pmi_fifo_sc_fwft_v1_0 #(
    parameter int unsigned DEPTH          = 1024,     // should be a power of 2
    parameter int unsigned DEPTH_AFULL    = 1023,
    parameter int unsigned WIDTH          = 8,
    parameter              FAMILY         = "ECP5U", 
    parameter              IMPLEMENTATION = "EBR",     // "LUT" or "EBR"
    parameter              RESET_MODE     = "sync",   // "async" or "sync"
    parameter bit          SIM_MODE       = 0         // set to one if simulating since Lattice's pmi_fifo_dc behavioral model incorrectly errors out complaining that "sync" resetmode isn't supported for ECP5

)(
    input    wire              clk,
    input    wire              rst,
    input    wire              wren,
    input    wire  [WIDTH-1:0] wdata,
    output   wire              full,
    output   wire              afull,
    input    wire              rden,
    output reg [WIDTH-1:0] rdata,
    output reg             rdata_vld
        
);
    /* parameter range checks */
    initial begin
        assert ( (WIDTH >= 1) && (WIDTH <= 256) ) else $fatal(1, "Error!  Parameter WIDTH must be in the range [1,256]");
    end

`ifndef VERILATE_DEF
    logic                  fifo_rden;
    logic                  fifo_empty;
    logic [WIDTH-1:0] fifo_rdata;
    logic                  fifo_rdata_vld;
    logic [WIDTH-1:0] fifo_rdata_buf;
    logic                  fifo_rdata_vld_buf;

`ifndef SMODE
  parameter MODE=0;
`else
  parameter MODE=1;
`endif
    
    generate
        
        if (MODE|SIM_MODE) begin
    
            // using pmi_fifo_dc because pmi_fifo won't let me specify the reset as synchronous and this can result in hold timing violations in Diamond, whereas you don't get those violations with pmi_fifo_dc
            pmi_fifo_dc #(
                .pmi_data_width_w      (WIDTH),
                .pmi_data_width_r      (WIDTH),
                .pmi_data_depth_w      (DEPTH),
                .pmi_data_depth_r      (DEPTH),
                .pmi_full_flag         (DEPTH),
                .pmi_empty_flag        (0),
                .pmi_almost_full_flag  (DEPTH_AFULL), 
                .pmi_almost_empty_flag (1),
                .pmi_regmode           ("noreg"),     // this must be noreg for fwft logic below to work
                .pmi_resetmode         ("async"),     // must be "async" for simulation or sim will fail with an error because Lattice has a bug in their pmi_fifo_dc sim model
                .pmi_family            (FAMILY),
                .module_type           ("pmi_fifo_dc"),
                .pmi_implementation    (IMPLEMENTATION)
            ) le_fifo_sc (
                .Data        (wdata),
                .WrClock     (clk),
                .RdClock     (clk),
                .Reset       (rst),
                .RPReset     (rst),
                .WrEn        (wren),
                .Full        (full),
                .RdEn        (fifo_rden),
                .Q           (fifo_rdata),
                .Empty       (fifo_empty),
                .AlmostEmpty (),
                .AlmostFull  (afull)); 
            
        end else begin

            // using pmi_fifo_dc because pmi_fifo won't let me specify the reset as synchronous and this can result in hold timing violations in Diamond, whereas you don't get those violations with pmi_fifo_dc
            pmi_fifo_dc #(
                .pmi_data_width_w      (WIDTH),
                .pmi_data_width_r      (WIDTH),
                .pmi_data_depth_w      (DEPTH),
                .pmi_data_depth_r      (DEPTH),
                .pmi_full_flag         (DEPTH),
                .pmi_empty_flag        (0),
                .pmi_almost_full_flag  (DEPTH_AFULL), 
                .pmi_almost_empty_flag (1),
                .pmi_regmode           ("noreg"),     // this must be noreg for fwft logic below to work
                .pmi_resetmode         (RESET_MODE),  // must be "async" for simulation or sim will fail with an error because Lattice has a bug in their pmi_fifo_dc sim model
                .pmi_family            (FAMILY),
                .module_type           ("pmi_fifo_dc"),
                .pmi_implementation    (IMPLEMENTATION)
            ) le_fifo_sc (
                .Data        (wdata),
                .WrClock     (clk),
                .RdClock     (clk),
                .Reset       (rst),
                .RPReset     (rst),
                .WrEn        (wren),
                .Full        (full),
                .RdEn        (fifo_rden),
                .Q           (fifo_rdata),
                .Empty       (fifo_empty),
                .AlmostEmpty (),
                .AlmostFull  (afull)); 
            
        end 
    endgenerate
    

    assign fifo_rden = ~fifo_empty & (rden | ~rdata_vld | (~fifo_rdata_vld_buf & ~fifo_rdata_vld));
    
    always_ff @(posedge clk) begin
        if (rst) begin
            fifo_rdata_vld <= 0;
        end else begin
            fifo_rdata_vld <= fifo_rden;
        end
    end

    /* first-word-fall-through logic */
    
    always_ff @(posedge clk) begin
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

`else

fwft_sc_fifo #(
       .DEPTH        (DEPTH),
       .WIDTH        (WIDTH),
       .ALMOST_FULL  (DEPTH_AFULL)
) wrap_buffer (
      .clk          (clk),
      .rst          (rst),
      .wren         (wren),
      .wdata        (wdata),
      .full         (full),
      .o_afull      (afull),
      .rden         (rden),
      .rdata        (rdata),
      .rdata_vld    (rdata_vld));

`endif

endmodule

`default_nettype wire
