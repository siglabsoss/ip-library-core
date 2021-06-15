/*
 * Module: mac_tx_arbiter
 * 
 * This module arbitrates access to the Lattice Semiconductor Gbit Ethernet MAC Tx interface.
 * 
 * It scans all input sources in a round-robin manner looking for a source presenting valid data.  It then consumes the full Ethernet II Frame from that source adding it to
 * it's output queue FIFO.  The output queue FIFO is what feeds the Lattice Gbit Ethernet MAC Tx interface. 
 * 
 * Module Requirements/Assumptions:
 * 
 *     * All input sources provide COMPLETE Ethernet II Frames that are limited to ETH_FRAME_MAX_BYTES as defined in ethernet_support_pkg.sv (see the packages directory of this module's parent folder)      
 *     * All input sources provide one byte of their current Ethernet II Frame at a time from a First-Word-Fall-Through FIFO or equivalent interface
 *       (i.e. the source asserts Valid when it has data to present and the simultaneous assertion of Valid from the source and Read from this module signifies the current source
 *        byte has been read)
 *     * All input sources provide a last byte flag along with the Ethernet II Frame byte that signifies whether or not the current byte is the last byte of the Ethernet II Frame. 
 *     
 *     
 * Warnings:
 * 
 *     * While not required it is recommended that an input source be able to provide the bytes of its current Ethernet II Frame on successive clock cycles (i.e. without gaps) after
 *       asserting its Valid signal for the first byte.  Once an input source is granted access no other input source can be serviced until the complete Ethernet II Frame is consumed
 *       from that source, which means that a single slow source can cause buffer overflows in other sources.
 *     
 * 
 */
  
`include "ethernet_support_pkg.sv"

`default_nettype none

/* verilator lint_off LITENDIAN */
 
module mac_tx_arbiter #(
        
    parameter int unsigned NUM_INPUTS            = 2,
    parameter int unsigned MAX_ETH_FRAME_BUFFERS = 5,       // number of Max Size Ethernet II Frames that can be simultaneously buffered
    parameter              FAMILY                = "ECP5U", 
    parameter              IMPLEMENTATION        = "EBR",   // "LUT" or "EBR"
    parameter              RESET_MODE            = "sync",  // "async" or "sync"
    parameter bit          SIM_MODE              = 0        // set to one if simulating 
        
)(
    input                             i_txmac_clk,
    input                             i_txmac_srst, // synchronous to i_txmac_clk

    /* INPUT SOURCES */
    input      [0:NUM_INPUTS-1] [7:0] i_src_byte,
    input      [0:NUM_INPUTS-1]       i_src_byte_vld,  // think of this as the source request line to the round-robin arbiter
    input      [0:NUM_INPUTS-1]       i_src_last_byte,
    output reg [0:NUM_INPUTS-1]       o_src_byte_rd,   // think of this as the round-robin arbiter grant line to the source

    /* LATTICE Gbit ETH MAC TX INTERFACE */
    input                             i_tx_macread,
    output                            o_tx_fifoavail,
    output                            o_tx_fifoeof,
    output                            o_tx_fifoempty,
    output                      [7:0] o_tx_fifodata,
    
    /* ERROR REPORTING */

    // THESE ERROR STATUS SIGNALS GET ASSERTED FOR ONE CLOCK IF THEIR RESPECTIVE ERROR OCCURS.  YOU NEED EXTERNAL LOGIC TO KEEP TRACK OF THESE ERRORS IF DESIRED.
    output reg                        o_eth_frame_fifo_overflow
//    output reg       [NUM_INPUTS-1:0] o_src_eth_frame_too_long_err 
);
    
    localparam int unsigned ETH_FRAME_BYTES_TO_BUFFER = MAX_ETH_FRAME_BUFFERS * ETH_FRAME_MAX_BYTES;
    localparam int unsigned ETH_FRAME_FIFO_DEPTH      = 2**($clog2(ETH_FRAME_BYTES_TO_BUFFER)); // next power of 2
    localparam int unsigned ETH_FRAME_CNTR_BITS       = $clog2(ETH_FRAME_FIFO_DEPTH); // a few more bits than we actually need since the minimum ethernet frame byte size is actually 60 bytes since we let the Lattice Gbit MAC handle the Frame Checksum insertion 
//    localparam int unsigned ETH_FRAME_BYTE_CNTR_BITS  = $clog2(ETH_FRAME_MAX_BYTES);
    localparam int unsigned RR_ARB_SRC_INDEX_BITS     = $clog2(NUM_INPUTS);
    
    
    logic [0:NUM_INPUTS-1] rr_arb_grant_mask;
    logic [0:NUM_INPUTS-1] rr_arb_grant;
    logic [0:NUM_INPUTS-1] rr_arb_req_raw;
    logic [0:NUM_INPUTS-1] rr_arb_req_masked;
    
    logic [RR_ARB_SRC_INDEX_BITS-1:0] rr_arb_src_index;
    
    logic                           eth_frame_fifo_wren;
    logic                           eth_frame_fifo_full;
    logic                     [8:0] eth_frame_fifo_din; 
    logic                     [8:0] eth_frame_fifo_dout;
    logic                           eth_frame_fifo_dout_vld;
    logic [ETH_FRAME_CNTR_BITS-1:0] eth_frame_fifo_frame_cntr;

    logic                           tx_fifoeof_reg; 
    
/* verilator lint_on LITENDIAN */

//    logic [ETH_FRAME_BYTE_CNTR_BITS-1:0] eth_frame_byte_cntr;
    
    
    /*
     * ROUND-ROBIN ARBITER LOGIC
     */
    
    assign rr_arb_req_raw    = i_src_byte_vld;
    assign rr_arb_req_masked = i_src_byte_vld & ~rr_arb_grant_mask;
    assign o_src_byte_rd     = rr_arb_grant & ~{NUM_INPUTS{eth_frame_fifo_full}};

    /* convert one-hot grant to binary index value */
    always_comb begin
        for (int unsigned i=0; i<NUM_INPUTS; i++) begin
            if (rr_arb_grant[i]) begin
`ifndef VERILATE_DEF
                rr_arb_src_index <= RR_ARB_SRC_INDEX_BITS'(i);
`else
                rr_arb_src_index = RR_ARB_SRC_INDEX_BITS'(i);
`endif
            end
        end
    end


    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            rr_arb_grant_mask <= '0;
            rr_arb_grant      <= '0;
        end else begin
            
            if ( rr_arb_grant == {NUM_INPUTS{1'b0}} ) begin // currently not granting the bus to anyone
                
                // determine the lowest numbered request signal that is asserted and grant it access
                rr_arb_grant      <= rr_arb_req_raw & (~rr_arb_req_raw + 1'b1);
                rr_arb_grant_mask <= rr_arb_req_raw & (~rr_arb_req_raw + 1'b1);

            end else if ( ( o_src_byte_rd[rr_arb_src_index]  & i_src_last_byte[rr_arb_src_index] & i_src_byte_vld[rr_arb_src_index] ) == 1 ) begin // we were granting the bus to someone and they just completed their last byte
                    
 // TODO: THERE'S A ONE CLOCK DE-ASSERTION OF THE GRANT SIGNAL WHEN EITHER THE ROUND-ROBIN ARBITER GOES FULL CIRCLE OR WHEN THE CURRENT REQUESTING SOURCE IS ALSO THE NEXT SOURCE TO RECEIVE THE GRANT.  THIS SHOULD BE ELIMINATED TO IMPROVE ARBITER EFFICIENCY.

//                if ( (rr_arb_req_raw & ~rr_arb_grant_mask) == {NUM_INPUTS{1'b0}} ) begin // no one is making a request or we've masked out all requests so use the raw requests
//                if ( ( rr_arb_req_raw == {NUM_INPUTS{1'b0}} ) || ( rr_arb_req_masked == {NUM_INPUTS{1'b0}} ) ) begin // no one is making a request or we've masked out all requests so use the raw requests
//                if ( ( rr_arb_req_raw == {NUM_INPUTS{1'b0}} ) || ( rr_arb_grant_mask == {NUM_INPUTS{1'b1}} ) ) begin // no one is making a request or we've masked out all requests so use the raw requests
//                    rr_arb_grant      <= rr_arb_req_raw & (~rr_arb_req_raw + 1'b1);
//                    rr_arb_grant_mask <= rr_arb_req_raw & (~rr_arb_req_raw + 1'b1);
//                end else begin
                    rr_arb_grant      <= rr_arb_req_masked & (~rr_arb_req_masked + 1'b1);
                    rr_arb_grant_mask <= rr_arb_grant_mask | (rr_arb_req_masked & (~rr_arb_req_masked + 1'b1)); // mask out the person we just gave the grant to
//                end
            end
        end
    end
    
    assign eth_frame_fifo_wren = ( ~eth_frame_fifo_full & o_src_byte_rd[rr_arb_src_index] & i_src_byte_vld[rr_arb_src_index] ) ? 1 : 0; // only write when the fifo isn't full, there's valid data, and we're reading it.
    assign eth_frame_fifo_din  = {i_src_last_byte[rr_arb_src_index], i_src_byte[rr_arb_src_index]};

`ifndef VERILATE_DEF
    generate
        
        if (SIM_MODE) begin

            // using pmi_fifo_dc because pmi_fifo won't let me specify the reset as synchronous and this can result in hold timing violations in Diamond, whereas you don't get those violations with pmi_fifo_dc
            pmi_fifo_dc #(
                .pmi_data_width_w      (9),
                .pmi_data_width_r      (9),
                .pmi_data_depth_w      (ETH_FRAME_FIFO_DEPTH),
                .pmi_data_depth_r      (ETH_FRAME_FIFO_DEPTH),
                .pmi_full_flag         (ETH_FRAME_FIFO_DEPTH),
                .pmi_empty_flag        (0),
                .pmi_almost_full_flag  (ETH_FRAME_FIFO_DEPTH-ETH_FRAME_MAX_BYTES), 
                .pmi_almost_empty_flag (1),
                .pmi_regmode           ("noreg"),     // this must be noreg for fwft logic below to work
                .pmi_resetmode         ("async"),     // must be "async" for simulation or sim will fail with an error because Lattice has a bug in their pmi_fifo_dc sim model
                .pmi_family            (FAMILY),
                .module_type           ("pmi_fifo_dc"),
                .pmi_implementation    (IMPLEMENTATION)
            ) ETH_FRAME_FIFO (
                .WrClock     (i_txmac_clk),
                .RdClock     (i_txmac_clk),
                .Reset       (i_txmac_srst),
                .RPReset     (i_txmac_srst),
                .WrEn        (eth_frame_fifo_wren),
                .Data        (eth_frame_fifo_din),
                .Full        (eth_frame_fifo_full),
                .RdEn        (i_tx_macread),
                .Q           (eth_frame_fifo_dout),
                .Empty       (o_tx_fifoempty),
                .AlmostEmpty (),
                .AlmostFull  ()); 
            
        end else begin

            // using pmi_fifo_dc because pmi_fifo won't let me specify the reset as synchronous and this can result in hold timing violations in Diamond, whereas you don't get those violations with pmi_fifo_dc
            pmi_fifo_dc #(
                .pmi_data_width_w      (9),
                .pmi_data_width_r      (9),
                .pmi_data_depth_w      (ETH_FRAME_FIFO_DEPTH),
                .pmi_data_depth_r      (ETH_FRAME_FIFO_DEPTH),
                .pmi_full_flag         (ETH_FRAME_FIFO_DEPTH),
                .pmi_empty_flag        (0),
                .pmi_almost_full_flag  (ETH_FRAME_FIFO_DEPTH-ETH_FRAME_MAX_BYTES), 
                .pmi_almost_empty_flag (1),
                .pmi_regmode           ("noreg"),     // this must be noreg for fwft logic below to work
                .pmi_resetmode         (RESET_MODE), // "sync" seems to work ok for synthesis though
                .pmi_family            (FAMILY),
                .module_type           ("pmi_fifo_dc"),
                .pmi_implementation    (IMPLEMENTATION)
            ) ETH_FRAME_FIFO (
                .WrClock     (i_txmac_clk),
                .RdClock     (i_txmac_clk),
                .Reset       (i_txmac_srst),
                .RPReset     (i_txmac_srst),
                .WrEn        (eth_frame_fifo_wren),
                .Data        (eth_frame_fifo_din),
                .Full        (eth_frame_fifo_full),
                .RdEn        (i_tx_macread),
                .Q           (eth_frame_fifo_dout),
                .Empty       (o_tx_fifoempty),
                .AlmostEmpty (),
                .AlmostFull  ());
            
        end
    endgenerate
`else


    generic_fifo_sc_a #(
       .dw      (9),
       .aw      ($clog2(ETH_FRAME_FIFO_DEPTH)),
       .ALMOST_FULL (ETH_FRAME_FIFO_DEPTH-ETH_FRAME_MAX_BYTES)
       ) ETH_FRAME_FIFO  (
        .din          (eth_frame_fifo_din),
        .clk          (i_txmac_clk),
        .rst          (!i_txmac_srst),
        .we           (eth_frame_fifo_wren),
        .clr          (1'b0),
        .full         (eth_frame_fifo_full),
        .afull        (),
        .afull_n      (),
        .o_afull_n_d  (),
        .re           (i_tx_macread),
        .dout         (eth_frame_fifo_dout),
        .empty        (o_tx_fifoempty),
        .fillcount    ()
    );

`endif
    
    /*
     * USED TO CREATE ONE CLOCK WIDE PULSE ON o_tx_fifoeof
     */
    
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            tx_fifoeof_reg <= 0;
        end else begin
            tx_fifoeof_reg <= eth_frame_fifo_dout[8];
        end
    end

//    assign o_tx_fifoavail      = (eth_frame_fifo_frame_cntr == {ETH_FRAME_CNTR_BITS{1'b0}}) ? 0 : 1;
    assign o_tx_fifoavail      = |eth_frame_fifo_frame_cntr & ~o_tx_fifoempty;
    assign o_tx_fifodata       = eth_frame_fifo_dout[7:0];
    assign o_tx_fifoeof        = eth_frame_fifo_dout[8] & ~tx_fifoeof_reg; // creates one clock wide pulse on o_tx_fifoeof


    /* 
     * ETH FRAME FIFO DOUT VALID GENERATION (ONLY USED INTERNALLY)
     */
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            eth_frame_fifo_dout_vld <= 0;
        end else begin
            eth_frame_fifo_dout_vld <= (i_tx_macread & ~o_tx_fifoempty) ? 1 : 0;
        end
    end


    /* 
     * KEEP TRACK OF HOW MANY COMPLETE ETHERNET FRAMES ARE IN THE FIFO
     */
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            eth_frame_fifo_frame_cntr <= '0;
        end else begin
            
            // NOTE: THE ORDER OF THESE IF STATEMENTS IS CRITICAL

            if (eth_frame_fifo_wren & eth_frame_fifo_din[8]) begin // end of ethernet frame marker written into output fifo so there's now another full ethernet frame ready to be consumed
                eth_frame_fifo_frame_cntr <= eth_frame_fifo_frame_cntr + 1;
            end
            
            if (o_tx_fifoeof & eth_frame_fifo_dout_vld) begin // end of frame mark read out of output fifo so there's now one fewer ethernet frames ready to be consumed
                eth_frame_fifo_frame_cntr <= eth_frame_fifo_frame_cntr - 1;
            end
            
            if (eth_frame_fifo_wren & eth_frame_fifo_din[8] & o_tx_fifoempty & eth_frame_fifo_dout_vld) begin // simultaneous packet read out of fifo and new one written into fifo
                eth_frame_fifo_frame_cntr <= eth_frame_fifo_frame_cntr;
            end

        end
    end
    
    
    /* 
     * monitor for ETH_FRAME_FIFO overflow and pulse the error flag if it happens
     */
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            o_eth_frame_fifo_overflow <= 0;
        end else begin
            o_eth_frame_fifo_overflow <= 0;
            if (eth_frame_fifo_full & eth_frame_fifo_wren) begin
                o_eth_frame_fifo_overflow <= 1;
            end
        end
    end
    

    /*
     * monitor for Ethernet II frames that exceed ETH_FRAME_MAX_BYTES and pulse the error flag if it happens
     */
    
//    always_ff @(posedge i_txmac_clk) begin
//        if (i_txmac_srst) begin
//            eth_frame_byte_cntr          <= '0;
//            o_src_eth_frame_too_long_err <= '0;
//        end else begin
//
//            /* default */
//            o_src_eth_frame_too_long_err <= '0;
//            
//            if (i_src_byte_vld[rr_arb_src_index] & o_src_byte_rd[rr_arb_src_index]) begin
//                
//                /* default */
//                eth_frame_byte_cntr <= eth_frame_byte_cntr + 1;
//                
//                if ( (eth_frame_byte_cntr == ETH_FRAME_BYTE_CNTR_BITS'(ETH_FRAME_MAX_BYTES-1)) && (i_src_last_byte[rr_arb_src_index] == 0) ) begin // source didn't indicate this is the last byte when it should've
//                    o_src_eth_frame_too_long_err[rr_arb_src_index] <= 1;
//                end
//                
//                if (i_src_last_byte[rr_arb_src_index]) begin
//                    eth_frame_byte_cntr <= '0;
//                end
//
//            end
//        end
//    end
    
endmodule

`default_nettype wire