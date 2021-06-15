/*
 * Module: eth_dac_data_rx
 * 
 * This module does the following:
 * 
 * 1. Consumes UDP payloads from the udp_pkt_router port FIFO corresponding to the port designated for DAC UDP data.
 * 2. Verifies that the expected UDP sequence number was received and reports an error if it wasn't (i.e. a UDP packet got dropped so there was a jump of > 1 in received sequence number)
 * 3. Queues the DAC data from the UDP payload (after removing the sequence number) in a first-word-fall-through FIFO.
 * 4. Presents the DAC with each 32-bit sample as well as its parity.
 * 
 */
 
`default_nettype none

module eth_dac_data_rx #(
    parameter int unsigned DAC_FIFO_WR_DEPTH_BYTES = 8192
)(

    /* LATTICE GBIT MAC RX CLOCK DOMAIN SIGNALS */
    input        i_rxmac_clk, 
    input        i_rxmac_srst, // synchronous to i_rxmac_clk
    output       o_udp_port_fifo_rd,
    input        i_udp_port_fifo_byte_vld,
    input        i_udp_port_fifo_last_byte,
    input  [7:0] i_udp_port_fifo_byte,
    output reg   o_dac_fifo_overflow, // pulsed for one clock
    
    /* ETH TO DAC FPGA CLOCK DOMAIN SIGNALS */
    input         i_sys_clk,
    input         i_sys_srst,
    input         i_dac_data_rd,
    output        o_dac_data_parity,
    output [31:0] o_dac_data,
    output reg    o_dac_fifo_underflow,
    output reg    o_udp_seq_num_error

);

    enum {
        WAIT_FOR_NEW_DAC_DATA,
        STORE_SEQ_NUM_0,
        STORE_SEQ_NUM_1,
        STORE_SEQ_NUM_2,
        STORE_SEQ_NUM_3,
        STORE_DAC_SAMPLES
    } dac_data_fsm_state;
    
    logic        dac_fifo_wren;
    logic [7:0]  dac_fifo_wdata;
    logic        dac_fifo_full;
    logic        dac_fifo_rden;
    logic        dac_fifo_rdata_vld;
    logic [31:0] dac_fifo_rdata;
    logic [31:0] dac_data_pipe_0;
    logic [31:0] dac_data_pipe_1;
    logic [31:0] dac_data_pipe_2;
    logic        dac_data_vld_pipe_0;
    logic        dac_data_vld_pipe_1;
    logic        dac_data_vld_pipe_2;
    logic        udp_port_fifo_rd;
    logic        udp_seq_num_check_flag;
    logic [31:0] udp_seq_num_received;
    logic [31:0] udp_seq_num_expected;
    
//    assign o_udp_port_fifo_rd = udp_port_fifo_rd & ~(i_udp_port_fifo_last_byte & i_udp_port_fifo_byte_vld);  // avoid reading of next byte accidentally
    assign o_udp_port_fifo_rd = udp_port_fifo_rd;
    
    always_ff @(posedge i_rxmac_clk) begin
        
        if (i_rxmac_srst) begin
            dac_data_fsm_state     <= WAIT_FOR_NEW_DAC_DATA;
            udp_port_fifo_rd       <= 0;
            dac_fifo_wren          <= 0;
            udp_seq_num_expected   <= '0;
            udp_seq_num_check_flag <= 0;
            o_udp_seq_num_error    <= 0;
        end else begin
            
            /* defaults */
            udp_port_fifo_rd    <= 0;
            dac_fifo_wren       <= 0;
            o_udp_seq_num_error <= 0;
        
            case (dac_data_fsm_state)
                WAIT_FOR_NEW_DAC_DATA: begin
                    udp_seq_num_check_flag <= 0;
                    if (i_udp_port_fifo_byte_vld) begin
                        udp_port_fifo_rd   <= 1;
                        dac_data_fsm_state <= STORE_SEQ_NUM_0;
                    end
                end
                STORE_SEQ_NUM_0: begin
                    udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        udp_seq_num_received[31:24] <= i_udp_port_fifo_byte;
                        dac_data_fsm_state          <= STORE_SEQ_NUM_1;
                    end
                end
                STORE_SEQ_NUM_1: begin
                    udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        udp_seq_num_received[23:16] <= i_udp_port_fifo_byte;
                        dac_data_fsm_state          <= STORE_SEQ_NUM_2;
                    end
                end
                STORE_SEQ_NUM_2: begin
                    udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        udp_seq_num_received[15:8] <= i_udp_port_fifo_byte;
                        dac_data_fsm_state         <= STORE_SEQ_NUM_3;
                    end
                end
                STORE_SEQ_NUM_3: begin
                    udp_port_fifo_rd <= 1;
                    if (i_udp_port_fifo_byte_vld) begin
                        udp_seq_num_received[7:0] <= i_udp_port_fifo_byte;
                        dac_data_fsm_state        <= STORE_DAC_SAMPLES;
                    end
                end
                STORE_DAC_SAMPLES: begin
                    
                    if (~udp_seq_num_check_flag) begin
                        udp_seq_num_check_flag <= 1;
                        if (udp_seq_num_received != udp_seq_num_expected) begin
                            o_udp_seq_num_error <= 1;
                        end
                        udp_seq_num_expected <= udp_seq_num_received + 1; 
                    end
                    
                    udp_port_fifo_rd <= 1;
                    
                    if (udp_port_fifo_rd & i_udp_port_fifo_byte_vld) begin
                        dac_fifo_wren  <= 1;
                        dac_fifo_wdata <= i_udp_port_fifo_byte;
                        
                        if (i_udp_port_fifo_last_byte) begin
                            udp_port_fifo_rd   <= 0;
                            dac_data_fsm_state <= WAIT_FOR_NEW_DAC_DATA;
                        end
                    end
                end
            endcase
        end
    end
    
    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH       (DAC_FIFO_WR_DEPTH_BYTES),
        .WR_DEPTH_AFULL (DAC_FIFO_WR_DEPTH_BYTES-1),
        .WR_WIDTH       (8),
        .RD_WIDTH       (32),
        .FAMILY         ("ECP5U"),
        .IMPLEMENTATION ("EBR"),
        .RESET_MODE     ("sync"),
        .WORD_SWAP      (1), // fix byte swapping that happens when going from 8-bits to 32-bits in the dac_fifo
        .SIM_MODE       (1)
        ) dac_fifo (
        .wrclk        (i_rxmac_clk),
        .wrclk_rst    (i_rxmac_srst),
        .rdclk        (i_sys_clk),
        .rdclk_rst    (i_sys_srst),
        .wren         (dac_fifo_wren),
        .wdata        (dac_fifo_wdata),
        .full         (dac_fifo_full),
        .afull        (),
        .rden         (dac_fifo_rden),
        .rdata        (dac_fifo_rdata),
        .rdata_vld    (dac_fifo_rdata_vld));
    
    // monitor for fifo overflow
    always_ff @(posedge i_rxmac_clk) begin
        if (i_rxmac_srst) begin
            o_dac_fifo_overflow <= 0;
        end else begin
            o_dac_fifo_overflow <= 0;
            if (dac_fifo_wren & dac_fifo_full) begin
                o_dac_fifo_overflow <= 1;
            end
        end
    end
    

    // monitor for fifo underflow (indicated user asserting i_dac_data_rd when dac_data_vld_pipe_2 == 0)
    always_ff @(posedge i_sys_clk) begin
        if (i_sys_srst) begin
            o_dac_fifo_underflow    <= 0;
        end else begin
            o_dac_fifo_underflow   <= 0;
            
            if (i_dac_data_rd & ~dac_data_vld_pipe_2) begin 
                o_dac_fifo_underflow <= 1;
            end
        end
    end
    

    /* pulls DAC samples from the dac_fifo, computes their parity, and presents them to the DAC FPGA */
    
    // NOTE: THE PIPELINE IS ONLY NECESSARY BECAUSE THE PARITY CALCULATION CAN'T BE DONE IN ONE CLOCK (AT LEAST THAT WAS THE CASE WITH PARITY CHECKING OF INCOMING ADC SAMPLES)

    // TODO: ADD PARITY PIPELINE AND CALC
     
    assign dac_fifo_rden = i_dac_data_rd | ~dac_data_vld_pipe_2 | ~dac_data_vld_pipe_1 | ~dac_data_vld_pipe_0;
    
    always_ff @(posedge i_sys_clk) begin
        if (i_sys_srst) begin
            dac_data_vld_pipe_0 <= 0;
            dac_data_vld_pipe_1 <= 0;
            dac_data_vld_pipe_2 <= 0;
        end else begin
            
            if (dac_fifo_rden) begin
                // always take output of dac fifo upon read and store it in pipe stage 0
                dac_data_vld_pipe_0 <= dac_fifo_rdata_vld;
                dac_data_pipe_0     <= dac_fifo_rdata;
                
                if (i_dac_data_rd) begin // upstream user requested a read so everything in the pipe must move
                    dac_data_vld_pipe_1 <= dac_data_vld_pipe_0;
                    dac_data_pipe_1     <= dac_data_pipe_0;
                    dac_data_vld_pipe_2 <= dac_data_vld_pipe_1;
                    dac_data_pipe_2     <= dac_data_pipe_1;
                end else begin // some stage in the pipe wasn't valid so we're trying to fill the gap, hence we only advance the pipe if that achieves our goal
                    if (~dac_data_vld_pipe_1 & dac_data_vld_pipe_0) begin
                        dac_data_vld_pipe_1 <= dac_data_vld_pipe_0;
                        dac_data_pipe_1     <= dac_data_pipe_0;
                    end
                    
                    if (~dac_data_vld_pipe_2 & dac_data_vld_pipe_1) begin
                        dac_data_vld_pipe_2 <= dac_data_vld_pipe_1;
                        dac_data_pipe_2     <= dac_data_pipe_1;
                    end
                end
            end

        end
    end
    
    assign o_dac_data        = (dac_data_vld_pipe_2) ? dac_data_pipe_2 : '0; // if we run out of data push zeros to the DAC
    assign o_dac_data_parity = 0; // TODO: ADD PARITY PIPELINE AND CALC
            

endmodule

`default_nettype wire