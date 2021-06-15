
/*
 * Module: pmi_fifo_dc_fwft
 * 
 * TODO: Make WR and RD widths customizable
 */

module pmi_fifo_dc_fwft #(
    parameter int unsigned WR_DEPTH_BYTES = 8192
)(
    input             wrclk,
    input             wrclk_srst,
    input             rdclk,
    input             rdclk_srst,
    input             wren,
    input  [ 7:0]     wdata,
    output            full,
    input             rden,
    output reg [31:0] rdata,
    output reg        rdata_vld
);


    logic        fifo_rden;
    logic        fifo_empty;
    logic [31:0] fifo_rdata;
    logic        fifo_rdata_vld;
    logic [31:0] fifo_rdata_buf;
    logic        fifo_rdata_vld_buf;

    pmi_fifo_dc #(
        .pmi_data_width_w      (8),
        .pmi_data_width_r      (32),
        .pmi_data_depth_w      (WR_DEPTH_BYTES),
        .pmi_data_depth_r      (WR_DEPTH_BYTES/4),
        .pmi_full_flag         (WR_DEPTH_BYTES),
        .pmi_empty_flag        (0),
        .pmi_almost_full_flag  (WR_DEPTH_BYTES-1), 
        .pmi_almost_empty_flag (1),
        .pmi_regmode           ("noreg"),
`ifndef SIM_MODE        
        .pmi_resetmode         ("sync"), 
`else
        .pmi_resetmode         ("async"),
`endif
        .pmi_family            ("ECP5U"),
        .module_type           ("pmi_fifo_dc"),
        .pmi_implementation    ("EBR")
    ) le_fifo (
        .Data        (wdata),
        .WrClock     (wrclk),
        .RdClock     (rdclk),
        .Reset       (wrclk_srst),
        .RPReset     (rdclk_srst),
        .WrEn        (wren),
        .Full        (full),
        .RdEn        (fifo_rden),
        .Q           (fifo_rdata),
        .Empty       (fifo_empty),
        .AlmostEmpty (),
        .AlmostFull  ()); 
    

    assign fifo_rden = ~fifo_empty & (rden | ~rdata_vld | (~fifo_rdata_vld_buf & ~fifo_rdata_vld));
    
    always_ff @(posedge rdclk) begin
        if (rdclk_srst) begin
            fifo_rdata_vld <= 0;
        end else begin
            fifo_rdata_vld <= fifo_rden;
        end
    end

    /* first-word-fall-through logic */
    
    always_ff @(posedge rdclk) begin
        if (rdclk_srst) begin
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


