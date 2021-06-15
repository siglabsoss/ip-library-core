/*
 * Module: tb_udp_rx_stream_buffer
 *
 * TODO: Add module documentation
 */

`include "ethernet_support_pkg.sv"

`default_nettype none

module tb_udp_rx_stream_buffer;

    localparam TB_RD_WIDTH       = 32;
    localparam TB_RD_DEPTH       = 1024;
    localparam TB_BIG_ENDIAN_FMT = 1;

    /* DUT SIGNALS */

    logic                   i_rxmac_clk = 0;
    logic                   i_rxmac_srst = 0;
    logic                   o_udp_port_fifo_rd;
    logic                   i_udp_port_fifo_byte_vld = 0;
    logic                   i_udp_port_fifo_last_byte = 0;
    logic [7:0]             i_udp_port_fifo_byte;
    logic                   o_buffer_overflow;
    logic                   i_sys_clk = 0;
    logic                   i_sys_srst = 0;
    logic                   i_buffer_rd;
    logic                   o_buffer_data_vld;
    logic                   o_buffer_data_parity;
    logic [TB_RD_WIDTH-1:0] o_buffer_data;
    logic                   o_buffer_afull;
    logic                   o_buffer_underflow;
    logic                   o_udp_seq_num_error;

    /* TEST BENCH SIGNALS */

    bit [0:UDP_PAYLOAD_MAX_BYTES-1] [7:0] tb_udp_data;
    bit [31:0] tb_udp_seq_num = '0;
    bit        tb_buffer_rd   = 0;

    /* CLOCK AND RESET GENERATION */

    initial begin
        forever #4ns i_rxmac_clk = ~i_rxmac_clk;
    end

    initial begin
        @(posedge i_rxmac_clk);
        i_rxmac_srst <= 1;
        repeat (10) @(posedge i_rxmac_clk);
        i_rxmac_srst <= 0;
    end

    initial begin
        forever #4ns i_sys_clk = ~i_sys_clk;
    end

    initial begin
        @(posedge i_sys_clk);
        i_sys_srst <= 1;
        repeat (10) @(posedge i_sys_clk);
        i_sys_srst <= 0;
    end



    /* STIMULUS */

    initial begin


        // fill in data (skipping over the sequence number)

        for (int i=0; i<UDP_PAYLOAD_MAX_BYTES-4; i++) begin
            tb_udp_data[i+4] = 8'(i);
        end

        @(negedge i_rxmac_srst);

        repeat (10) @(posedge i_rxmac_clk);

        for(int i=0; i<10; i++) begin
            // update the sequence number and preset the payload to the DUT
            tb_udp_data[0:3] = tb_udp_seq_num;
            tb_udp_seq_num++;

            repeat (10) @(posedge i_rxmac_clk);

            for(int j=0; j<UDP_PAYLOAD_MAX_BYTES; j++) begin
                i_udp_port_fifo_byte_vld  <= 1;
                i_udp_port_fifo_byte      <= tb_udp_data[j];
                i_udp_port_fifo_last_byte <= (j==UDP_PAYLOAD_MAX_BYTES-1) ? 1 : 0;

                if (~(i_udp_port_fifo_byte_vld & o_udp_port_fifo_rd)) begin
                    while (~(i_udp_port_fifo_byte_vld & o_udp_port_fifo_rd)) begin
                        @(posedge i_rxmac_clk);
                    end
                end else begin
                    @(posedge i_rxmac_clk);
                end
            end

            i_udp_port_fifo_byte_vld  <= 0;
            i_udp_port_fifo_last_byte <= 0;
        end

        repeat (1000) @(posedge i_rxmac_clk);
        $display("<<<TB_SUCCESS>>>");
        $finish();

    end


    // consume udp rx stream data from the buffer

    assign i_buffer_rd = o_buffer_data_vld & tb_buffer_rd;

    initial begin

        int k=4; // skip over sequence number which should get removed from the udp payload by the DUT

        @(negedge i_sys_srst);
        @(posedge i_sys_clk);

        // hold off on reading the buffer until at least a couple of complete read words have been queued to we can see how the output pipe of the buffer fills`
        while (~o_buffer_data_vld) begin
            @(posedge i_sys_clk);
        end

        repeat (16) @(posedge i_sys_clk);

        tb_buffer_rd <= 1;

        forever begin

            @(posedge i_sys_clk);

            if (i_buffer_rd & o_buffer_data_vld) begin
                if (o_buffer_data != {tb_udp_data[k], tb_udp_data[k+1], tb_udp_data[k+2], tb_udp_data[k+3]}) begin
                    $fatal(0, "Error!  DUT emitted 0x%H, expected 0x%H", o_buffer_data, {tb_udp_data[k], tb_udp_data[k+1], tb_udp_data[k+2], tb_udp_data[k+3]} );
                end

                if (^({o_buffer_data, o_buffer_data_parity})) begin // should be zero if parity bit correct (even parity)
                    $fatal(0, "Error!  DUT provided incorrect parity bit for current data word 0x%H", o_buffer_data);
                end
                if (k == UDP_PAYLOAD_MAX_BYTES-4) begin
                    k=4;
                end else begin
                    k+=4;
                end
            end
        end
    end

    initial begin
        forever begin
            @(posedge i_rxmac_clk);
            if (o_buffer_overflow) begin
                $fatal(0, "Error!  DUT reported a buffer overflow.");
            end
        end
    end

    initial begin
        forever begin
            @(posedge i_sys_clk);
            if (o_buffer_underflow) begin
                $fatal(0, "Error!  DUT reported a buffer underflow.");
            end
        end
    end


    udp_rx_stream_buffer #(
        .RD_WIDTH       (TB_RD_WIDTH),
        .RD_DEPTH       (TB_RD_DEPTH),
        .FAMILY         ("ECP5U"),
        .IMPLEMENTATION ("EBR"),
        .RESET_MODE     ("sync"),
        .BIG_ENDIAN_FMT (TB_BIG_ENDIAN_FMT),
        .SEQ_NUM_PRSNT  (1),
        .SIM_MODE       (1)
        ) DUT (.*);

endmodule

`default_nettype wire


