
/*
 * Module: udp_rx_stream_buffer
 *
 * This module does the following:
 *
 * 1. Consumes UDP payload data from the udp_pkt_router port FIFO it's connected to.
 * 2. Verifies that the expected UDP sequence number was received if present and reports an error if it wasn't (i.e. a UDP packet got dropped so there was a jump of > 1 in received sequence number)
 * 3. Queues the UDP payload data (after removing the sequence number if present) in a first-word-fall-through FIFO.  The FIFO will also convert to a wider read width if specified.
 * 4. Presents the data to downstream logic along with a parity bit that makes for even parity.
 *
 * NOTES:
 *
 * * This module expects to consume data form the udp_pkt_router module which has a First-Word-Fall-Through FIFO at its output.
 * * This module is ONLY for UDP streaming Rx data (i.e. data that doesn't expect responses).
 * * This module expects that if present, the UDP sequence number is first four bytes of the UDP payload (MSB first).
 * * RD_WIDTH must a multiple of 8.
 * * RD_DEPTH specifies the number of RD_WIDTH values that the FIFO can store (e.g. RD_WIDTH = 32 and RD_DEPTH = 1024 means the FIFO depth is 4096 bytes ((32/8) * 1024))
 *
 * TODO: ADD PARAMETER THAT ALLOWS USER TO CHOOSE WHETHER OR NOT OVERFLOW IS ACCEPTABLE (NOTE: IT CAN NEVER BE ACCEPTABLE WHEN SEQ_NUM_PRSNT = 1)
 *
 */

`default_nettype none

module udp_rx_stream_buffer #(
        parameter int unsigned RD_WIDTH       = 32,      // incoming data width to buffer is always 8-bits so this must be an integer multiple of 8
        parameter int unsigned RD_DEPTH       = 1024,    // byte depth of the buffer will be (RD_WIDTH/8) * RD_DEPTH
        parameter              FAMILY         = "ECP5U",
        parameter              IMPLEMENTATION = "EBR",   // "LUT" or "EBR"
        parameter              RESET_MODE     = "sync",  // "async" or "sync"
        parameter bit          BIG_ENDIAN_FMT = 1,       // set to 1 if incoming Ethernet data is in big endian format.  set to 0 for little endian format. 
        parameter bit          SEQ_NUM_PRSNT  = 1,       // Set to 1 if the UDP Rx stream has a sequence number as its first four bytes.  This enables successive sequence number checking and removal of the sequence num from the ouput data stream.
        parameter bit          SIM_MODE       = 0        // Needed because of issue with Lattice pmi_fifo_dc macro not correctly supporting "sync" resetmode in simulation

)(

        /* LATTICE GBIT MAC RX CLOCK DOMAIN SIGNALS */
        input                 i_rxmac_clk,
        input                 i_rxmac_srst, // synchronous to i_rxmac_clk
        output reg            o_udp_port_fifo_rd,
        input                 i_udp_port_fifo_byte_vld,
        input                 i_udp_port_fifo_last_byte,
        input  [7:0]          i_udp_port_fifo_byte,
        output                o_buffer_afull,
        output reg            o_buffer_overflow, // pulsed for one clock

        /* SYSTEM CLOCK DOMAIN SIGNALS */
        input                 i_sys_clk,
        input                 i_sys_srst,
        input                 i_buffer_rd,
        output                o_buffer_data_vld,
        output                o_buffer_data_parity,
        output [RD_WIDTH-1:0] o_buffer_data,
        output reg            o_buffer_underflow, // pulsed for one clock
        output reg            o_udp_seq_num_error // pulsed for one clock

);

    initial begin
        assert ((RD_WIDTH >= 8) && (RD_WIDTH % 8 == 0)) else $fatal(0, "RD_WIDTH must be >= 8 and an integer multiple of 8!");
    end

    localparam int unsigned BUF_WR_DEPTH = (RD_WIDTH/8)*RD_DEPTH;

    enum {
        WAIT_FOR_NEW_UDP_PAYLOAD,
        STORE_SEQ_NUM_0,
        STORE_SEQ_NUM_1,
        STORE_SEQ_NUM_2,
        STORE_SEQ_NUM_3,
        STORE_PAYLOAD
    } buf_wr_fsm_state;

    logic                buf_fifo_wren;
    logic [7:0]          buf_fifo_wdata;
    logic                buf_fifo_full;
    logic                buf_fifo_rden;
    logic                buf_fifo_rdata_vld;
    logic [RD_WIDTH-1:0] buf_fifo_rdata;
    logic [RD_WIDTH-1:0] buf_data_pipe_0;
    logic [RD_WIDTH-1:0] buf_data_pipe_1;
    logic [RD_WIDTH-1:0] buf_data_pipe_2;
    logic                buf_data_vld_pipe_0;
    logic                buf_data_vld_pipe_1;
    logic                buf_data_vld_pipe_2;
    logic                buf_data_parity_pipe_0_high; // pipe 0 is split across two registers to alleviate timing constraint problems encountered when xor'ing wide buses
    logic                buf_data_parity_pipe_0_low;  // pipe 0 is split across two registers to alleviate timing constraint problems encountered when xor'ing wide buses
    logic                buf_data_parity_pipe_1;
    logic                buf_data_parity_pipe_2;
    logic                udp_seq_num_check_flag;
    logic [31:0]         udp_seq_num_received; // remember, if present the sequence number is assumed to be the first four bytes of the udp payload
    logic [31:0]         udp_seq_num_expected; // remember, if present the sequence number is assumed to be the first four bytes of the udp payload


    always_ff @(posedge i_rxmac_clk) begin

        if (i_rxmac_srst) begin
            buf_wr_fsm_state       <= WAIT_FOR_NEW_UDP_PAYLOAD;
            o_udp_port_fifo_rd     <= 0;
            buf_fifo_wren          <= 0;
            udp_seq_num_expected   <= '0;
            udp_seq_num_check_flag <= 0;
            o_udp_seq_num_error    <= 0;
        end else begin

            /* defaults */
            o_udp_port_fifo_rd  <= 0;
            buf_fifo_wren       <= 0;
            o_udp_seq_num_error <= 0;

            case (buf_wr_fsm_state)

                WAIT_FOR_NEW_UDP_PAYLOAD: begin
                    udp_seq_num_check_flag <= 0;
                    if (i_udp_port_fifo_byte_vld) begin
                        o_udp_port_fifo_rd <= 1;
                        if (SEQ_NUM_PRSNT) begin
                            buf_wr_fsm_state <= STORE_SEQ_NUM_0;
                        end else begin
                            buf_wr_fsm_state <= STORE_PAYLOAD;
                        end
                    end
                end

                STORE_SEQ_NUM_0: begin
                    o_udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        if (BIG_ENDIAN_FMT) begin
                            udp_seq_num_received[31:24] <= i_udp_port_fifo_byte;
                        end else begin
                            udp_seq_num_received[7:0] <= i_udp_port_fifo_byte;
                        end
                        buf_wr_fsm_state <= STORE_SEQ_NUM_1;
                    end
                end

                STORE_SEQ_NUM_1: begin
                    o_udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        if (BIG_ENDIAN_FMT) begin
                            udp_seq_num_received[23:16] <= i_udp_port_fifo_byte;
                        end else begin
                            udp_seq_num_received[15:8] <= i_udp_port_fifo_byte;
                        end
                        buf_wr_fsm_state <= STORE_SEQ_NUM_2;
                    end
                end

                STORE_SEQ_NUM_2: begin
                    o_udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        if (BIG_ENDIAN_FMT) begin
                            udp_seq_num_received[15:8] <= i_udp_port_fifo_byte;
                        end else begin
                            udp_seq_num_received[23:16] <= i_udp_port_fifo_byte;
                        end
                        buf_wr_fsm_state <= STORE_SEQ_NUM_3;
                    end
                end

                STORE_SEQ_NUM_3: begin
                    o_udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        if (BIG_ENDIAN_FMT) begin
                            udp_seq_num_received[7:0] <= i_udp_port_fifo_byte;
                        end else begin
                            udp_seq_num_received[31:24] <= i_udp_port_fifo_byte;
                        end
                        buf_wr_fsm_state <= STORE_PAYLOAD;
                    end
                end

                STORE_PAYLOAD: begin

                    o_udp_port_fifo_rd <= 1;

                    if (o_udp_port_fifo_rd & i_udp_port_fifo_byte_vld) begin
                        buf_fifo_wren  <= 1;
                        buf_fifo_wdata <= i_udp_port_fifo_byte;

                        if (i_udp_port_fifo_last_byte) begin
                            o_udp_port_fifo_rd <= 0;
                            buf_wr_fsm_state <= WAIT_FOR_NEW_UDP_PAYLOAD;
                        end
                    end

                    if (~udp_seq_num_check_flag & SEQ_NUM_PRSNT) begin
                        udp_seq_num_check_flag <= 1;
                        if (udp_seq_num_received != udp_seq_num_expected) begin
                            o_udp_seq_num_error <= 1;
                        end
                        udp_seq_num_expected <= udp_seq_num_received + 1;
                    end

                end
            endcase
        end
    end

`ifndef VERILATE_DEF

    pmi_fifo_dc_fwft_v1_0 #(
            .WR_DEPTH       (BUF_WR_DEPTH),
            .WR_DEPTH_AFULL (BUF_WR_DEPTH/2),
            .WR_WIDTH       (8),
            .RD_WIDTH       (RD_WIDTH),
            .FAMILY         (FAMILY),
            .IMPLEMENTATION (IMPLEMENTATION),
            .RESET_MODE     (RESET_MODE),
            .WORD_SWAP      (BIG_ENDIAN_FMT),
            .SIM_MODE       (SIM_MODE)
        ) buffer_fifo (
            .wrclk        (i_rxmac_clk),
            .wrclk_rst    (i_rxmac_srst),
            .rdclk        (i_sys_clk),
            .rdclk_rst    (i_sys_srst),
            .wren         (buf_fifo_wren),
            .wdata        (buf_fifo_wdata),
            .full         (buf_fifo_full),
            .afull        (o_buffer_afull),
            .rden         (buf_fifo_rden),
            .rdata        (buf_fifo_rdata),
            .rdata_vld    (buf_fifo_rdata_vld));

`else

    logic [31:0] buffer_fifo_fill;
    logic fifo_dc_rb_ready;
    width_8_32 #(
            .CAPACITY    (BUF_WR_DEPTH)
            ) fifo_dc_rb (
                .clk         (i_sys_clk),
                .reset       (i_sys_srst),

                .t0_data     (buf_fifo_wdata),
                .t0_valid    (buf_fifo_wren),
                .t0_ready    (fifo_dc_rb_ready),

                .i0_data     (buf_fifo_rdata),
                .i0_valid    (buf_fifo_rdata_vld),
                .i0_ready    (buf_fifo_rden),

                .fillcount   (buffer_fifo_fill)
            );
    assign o_buffer_afull = buffer_fifo_fill > ((BUF_WR_DEPTH/2)-1);

    assign buf_fifo_full = !fifo_dc_rb_ready;

`endif

    // monitor for fifo overflow
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_buffer_overflow <= 0;
        end else begin
            o_buffer_overflow <= 0;
            if (buf_fifo_wren & buf_fifo_full) begin
                o_buffer_overflow <= 1;
            end
        end
    end


    // monitor for buffer_fifo underflow (indicated user asserting i_buffer_rd when buf_data_vld_pipe_2 == 0)
    always_ff @(posedge i_sys_clk) begin
        if (i_sys_srst) begin
            o_buffer_underflow <= 0;
        end else begin
            o_buffer_underflow <= 0;
            if (i_buffer_rd & ~buf_data_vld_pipe_2) begin
                o_buffer_underflow <= 1;
            end
        end
    end


    /* pulls samples from the buffer_fifo , computes their parity, and presents them to the downstream logic */

    // NOTE: THE PIPELINE IS ONLY NECESSARY BECAUSE THE PARITY CALCULATION MIGHT NOT BE ABLE TO BE DONE IN ONE CLOCK

    assign buf_fifo_rden = i_buffer_rd | ~buf_data_vld_pipe_2 | ~buf_data_vld_pipe_1 | ~buf_data_vld_pipe_0;

    always_ff @(posedge i_sys_clk) begin
        if (i_sys_srst) begin
            buf_data_vld_pipe_0         <= 0;
            buf_data_vld_pipe_1         <= 0;
            buf_data_vld_pipe_2         <= 0;
            buf_data_parity_pipe_0_high <= 0;
            buf_data_parity_pipe_0_low  <= 0;
            buf_data_parity_pipe_1      <= 0;
            buf_data_parity_pipe_2      <= 0;
        end else begin

            if (buf_fifo_rden) begin
                // always take output of dac fifo upon read and store it in pipe stage 0
                buf_data_vld_pipe_0         <= buf_fifo_rdata_vld;
                buf_data_pipe_0             <= buf_fifo_rdata;
                buf_data_parity_pipe_0_high <= ^(buf_fifo_rdata[RD_WIDTH-1:(RD_WIDTH/2)]);
                buf_data_parity_pipe_0_low  <= ^(buf_fifo_rdata[(RD_WIDTH/2)-1:0]);

                if (i_buffer_rd) begin // upstream user requested a read so everything in the pipe must move
                    buf_data_vld_pipe_1    <= buf_data_vld_pipe_0;
                    buf_data_pipe_1        <= buf_data_pipe_0;
                    buf_data_vld_pipe_2    <= buf_data_vld_pipe_1;
                    buf_data_pipe_2        <= buf_data_pipe_1;
                    buf_data_parity_pipe_1 <= buf_data_parity_pipe_0_high ^ buf_data_parity_pipe_0_low;
                    buf_data_parity_pipe_2 <= buf_data_parity_pipe_1;
                end else begin // some stage in the pipe wasn't valid so we're trying to fill the gap, hence we only advance the pipe if that achieves our goal

                    if (~buf_data_vld_pipe_2) begin // last stage not valid so move everyone forward
                        buf_data_vld_pipe_1    <= buf_data_vld_pipe_0;
                        buf_data_pipe_1        <= buf_data_pipe_0;
                        buf_data_parity_pipe_1 <= buf_data_parity_pipe_0_high ^ buf_data_parity_pipe_0_low;
                        buf_data_vld_pipe_2    <= buf_data_vld_pipe_1;
                        buf_data_pipe_2        <= buf_data_pipe_1;
                        buf_data_parity_pipe_2 <= buf_data_parity_pipe_1;
                    end

                    if (~buf_data_vld_pipe_1) begin  // second to last stage not valid so move first stage forward
                        buf_data_vld_pipe_1    <= buf_data_vld_pipe_0;
                        buf_data_pipe_1        <= buf_data_pipe_0;
                        buf_data_parity_pipe_1 <= buf_data_parity_pipe_0_high ^ buf_data_parity_pipe_0_low;
                    end

                end
            end

        end
    end

    assign o_buffer_data_vld    = buf_data_vld_pipe_2;
    assign o_buffer_data        = buf_data_pipe_2;
    assign o_buffer_data_parity = buf_data_parity_pipe_2;


endmodule

`default_nettype wire