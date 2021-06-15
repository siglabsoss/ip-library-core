/*
 * Module: tb_udp_rx_stream_buffer
 * 
 * TODO: Add module documentation
 */
 
`include "ethernet_support_pkg.sv"

`default_nettype none
 
module tb_mac_tx_arbiter;
    
    localparam TB_NUM_INPUTS = 3;
    localparam TB_MAX_ETH_FRAME_BUFFERS = 5;
    localparam TB_DUT_OUT_FIFO_DEPTH = 2**$clog2(TB_MAX_ETH_FRAME_BUFFERS * ETH_FRAME_MAX_BYTES);
     
    initial begin
        $display("TB_DUT_OUT_FIFO_DEPTH = %d", TB_DUT_OUT_FIFO_DEPTH);
    end
    
    /* DUT SIGNALS */

    logic                           i_txmac_clk;
    logic                           i_txmac_srst;
    logic [0:TB_NUM_INPUTS-1] [7:0] i_src_byte;
    logic [0:TB_NUM_INPUTS-1]       i_src_byte_vld;
    logic [0:TB_NUM_INPUTS-1]       i_src_last_byte;
    logic [0:TB_NUM_INPUTS-1]       o_src_byte_rd;
    logic                           i_tx_macread;
    logic                           o_tx_fifoavail;
    logic                           o_tx_fifoeof;
    logic                           o_tx_fifoempty;
    logic                     [7:0] o_tx_fifodata;
    logic                           o_eth_frame_fifo_overflow;
//    logic [0:TB_NUM_INPUTS-1]       o_src_eth_frame_too_long_err;

    /* TEST BENCH SIGNALS */
    
    byte tb_eth_frame_max [ETH_FRAME_MAX_BYTES]; // max size ethernet frame
    byte tb_eth_frame_min [ETH_FRAME_MIN_BYTES]; // min size ethernet frame
    
    logic       tb_frame_fifo_0_wren = 0;
    logic [8:0] tb_frame_fifo_0_wdata;
    logic       tb_frame_fifo_0_full;
    logic       tb_frame_fifo_0_afull;

    logic       tb_frame_fifo_1_wren = 0;
    logic [8:0] tb_frame_fifo_1_wdata;
    logic       tb_frame_fifo_1_full;
    logic       tb_frame_fifo_1_afull;

    logic       tb_frame_fifo_2_wren = 0;
    logic [8:0] tb_frame_fifo_2_wdata;
    logic       tb_frame_fifo_2_full;
    logic       tb_frame_fifo_2_afull;
    
    logic       tb_gate_macread = 0;
    logic       tb_tx_macread = 0;
    logic       tb_macread_vld = 0;
    logic [7:0] tb_expected_byte = 0;
    
    string      tb_test_str = "";
    int unsigned tb_err_cnt = 0;

    /* CLOCK AND RESET GENERATION */
    
    initial begin
        i_txmac_clk = 0;
        forever #4ns i_txmac_clk = ~i_txmac_clk;
    end
    
    initial begin
        i_txmac_srst = 0;
        @(posedge i_txmac_clk);
        i_txmac_srst <= 1;
        repeat (10) @(posedge i_txmac_clk);
        i_txmac_srst <= 0;
    end
    
    /* DATA GENERATION */
    
    initial begin
        for (int i=0; i<ETH_FRAME_MAX_BYTES; i++) begin tb_eth_frame_max[i] = byte'(i); end
        for (int i=0; i<ETH_FRAME_MIN_BYTES; i++) begin tb_eth_frame_min[i] = byte'(i); end
    end
        
            
    
    /* STIMULUS */
    
    initial begin
        
        @(negedge i_txmac_srst);
        
        repeat (10) @(posedge i_txmac_clk);
        
        tb_gate_macread <= 0; 
        
        /* TEST - BACK-TO-BACK REQUESTS FROM A SINGLE SOURCE */
        
        tb_test_str = "BACK2BACK SINGLE SOURCE";
        
        repeat (2) begin
            for (int i=0; i<ETH_FRAME_MAX_BYTES; i++) begin
                @(posedge i_txmac_clk);
                tb_frame_fifo_1_wren  <= 1;
                tb_frame_fifo_1_wdata <= {1'b0, tb_eth_frame_max[i]};
                if (i == ETH_FRAME_MAX_BYTES-1) begin
                    tb_frame_fifo_1_wdata <= {1'b1, tb_eth_frame_max[i]};
                end
            end
            @(posedge i_txmac_clk);
            tb_frame_fifo_1_wren <= 0;
        end

        while (i_src_byte_vld[1]) begin
            @(posedge i_txmac_clk);
        end
        
        /* TEST - BACK-TO-BACK REQUESTS FROM MULTIPLE SOURCES */
        
        while (~o_tx_fifoempty) begin
            @(posedge i_txmac_clk);
        end
        
        repeat (100) @(posedge i_txmac_clk);

        tb_test_str = "BACK2BACK MULTIPLE SOURCES";

        repeat (2) begin
            for (int i=0; i<ETH_FRAME_MAX_BYTES; i++) begin
                @(posedge i_txmac_clk);
                tb_frame_fifo_0_wren  <= 1;
                tb_frame_fifo_0_wdata <= {1'b0, tb_eth_frame_max[i]};
                tb_frame_fifo_2_wren  <= 1;
                tb_frame_fifo_2_wdata <= {1'b0, tb_eth_frame_max[i]};
                if (i == ETH_FRAME_MAX_BYTES-1) begin
                    tb_frame_fifo_0_wdata <= {1'b1, tb_eth_frame_max[i]};
                    tb_frame_fifo_2_wdata <= {1'b1, tb_eth_frame_max[i]};
                end
            end
            @(posedge i_txmac_clk);
            tb_frame_fifo_0_wren <= 0;
            tb_frame_fifo_2_wren <= 0;
        end

        while (i_src_byte_vld[0] | i_src_byte_vld[2]) begin
            @(posedge i_txmac_clk);
        end
        
        /* TEST - BACK-TO-BACK REQUESTS FROM ALL SOURCES */

        while (~o_tx_fifoempty) begin
            @(posedge i_txmac_clk);
        end
        
        repeat (100) @(posedge i_txmac_clk);

        tb_test_str = "BACK2BACK ALL SOURCES";

        repeat (2) begin
            for (int i=0; i<ETH_FRAME_MAX_BYTES; i++) begin
                @(posedge i_txmac_clk);
                tb_frame_fifo_0_wren  <= 1;
                tb_frame_fifo_0_wdata <= {1'b0, tb_eth_frame_max[i]};
                tb_frame_fifo_1_wren  <= 1;
                tb_frame_fifo_1_wdata <= {1'b0, tb_eth_frame_max[i]};
                tb_frame_fifo_2_wren  <= 1;
                tb_frame_fifo_2_wdata <= {1'b0, tb_eth_frame_max[i]};
                if (i == ETH_FRAME_MAX_BYTES-1) begin
                    tb_frame_fifo_0_wdata <= {1'b1, tb_eth_frame_max[i]};
                    tb_frame_fifo_1_wdata <= {1'b1, tb_eth_frame_max[i]};
                    tb_frame_fifo_2_wdata <= {1'b1, tb_eth_frame_max[i]};
                end
            end
            @(posedge i_txmac_clk);
            tb_frame_fifo_0_wren <= 0;
            tb_frame_fifo_1_wren <= 0;
            tb_frame_fifo_2_wren <= 0;
        end

        while (i_src_byte_vld[0] | i_src_byte_vld[1] | i_src_byte_vld[2]) begin
            @(posedge i_txmac_clk);
        end
        
        /* TEST - BACK-TO-BACK REQUESTS FROM NON FIRST SOURCE (I.E. NOT SOURCE 0) FOLLOWED BY REQUEST FROM FIRST SOURCE (I.E. SOURCE 0) */

        while (~o_tx_fifoempty) begin
            @(posedge i_txmac_clk);
        end
        
        repeat (100) @(posedge i_txmac_clk);

        tb_test_str = "BACK2BACK NON FIRST SOURCE THEN FIRST SOURCE";

        repeat (2) begin
            for (int i=0; i<ETH_FRAME_MAX_BYTES+1; i++) begin
                @(posedge i_txmac_clk);
                
                if (i < ETH_FRAME_MAX_BYTES) begin
                    tb_frame_fifo_2_wren  <= 1;
                    tb_frame_fifo_2_wdata <= {1'b0, tb_eth_frame_max[i]};
                    if (i == ETH_FRAME_MAX_BYTES-1) begin
                        tb_frame_fifo_2_wdata <= {1'b1, tb_eth_frame_max[i]};
                    end
                end else begin
                    tb_frame_fifo_2_wren <= 0;
                end

                if (i > 0) begin
                    tb_frame_fifo_0_wren  <= 1;
                    tb_frame_fifo_0_wdata <= {1'b0, tb_eth_frame_max[i-1]};
                    if (i == ETH_FRAME_MAX_BYTES) begin
                        tb_frame_fifo_0_wdata <= {1'b1, tb_eth_frame_max[i-1]};
                    end
                end else begin
                    tb_frame_fifo_0_wren <= 0;
                end
                
            end
            @(posedge i_txmac_clk);
            tb_frame_fifo_0_wren <= 0;
            tb_frame_fifo_2_wren <= 0;
        end
        
        while (i_src_byte_vld[0] | i_src_byte_vld[2]) begin
            @(posedge i_txmac_clk);
        end
        
        /* TEST - FILL DUT OUTPUT FIFO TO MAKE SURE IT DOESN'T OVERFLOW */
        
        while (~o_tx_fifoempty) begin
            @(posedge i_txmac_clk);
        end
        
        @(posedge i_txmac_clk);
        tb_gate_macread <= 1;

        repeat (100) @(posedge i_txmac_clk);

        tb_test_str = "DUT OUT FIFO OVERFLOW";
        
        repeat ( (TB_DUT_OUT_FIFO_DEPTH / ETH_FRAME_MAX_BYTES) + 1 ) begin // repeat enough full size ethernet frames to completely fill the DUT's output fifo
            for (int i=0; i<ETH_FRAME_MAX_BYTES; i++) begin
                @(posedge i_txmac_clk);
                tb_frame_fifo_0_wren  <= 1;
                tb_frame_fifo_0_wdata <= {1'b0, tb_eth_frame_max[i]};
                if (i == ETH_FRAME_MAX_BYTES-1) begin
                    tb_frame_fifo_0_wdata <= {1'b1, tb_eth_frame_max[i]};
                end
            end
            @(posedge i_txmac_clk);
            tb_frame_fifo_0_wren <= 0;
        end

        @(posedge i_txmac_clk);
        tb_gate_macread <= 0;

        while (i_src_byte_vld[0]) begin
            @(posedge i_txmac_clk);
        end

        while (~o_tx_fifoempty) begin
            @(posedge i_txmac_clk);
        end
        
        repeat (100) @(posedge i_txmac_clk);
        
        if (tb_err_cnt) begin
            $display("<<<TB_FAILURE>>>");
        end else begin
            $display("<<<TB_SUCCESS>>>");
        end
        
        $finish();
    end
    
    
    /*
     *  MIMIC CONSUMPTION OF ETHERNET FRAMES BY LATTICE GBIT MAC TX INTERFACE
     */
    
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            tb_tx_macread <= 0;
        end else begin
            // order of these two if statements matters
            if (o_tx_fifoavail) begin
                tb_tx_macread <= 1'b1 & ~tb_gate_macread;
            end
            if (o_tx_fifoeof) begin
                tb_tx_macread <= 0;
            end
        end
    end
    
    assign i_tx_macread = tb_tx_macread & ~o_tx_fifoeof;

    
    /*
     * GENERATE A VALID SIGNAL FOR BYTES COMING OUT OF THE DUT (USED FOR VALIDATING THE BYTES READ FROM THE DUT)
     */
    
    always_ff @(posedge i_txmac_clk) begin
        if (i_txmac_srst) begin
            tb_macread_vld <= 0;
        end else begin
            tb_macread_vld <= i_tx_macread;
        end
    end
    
    
    /*
     * These FIFOs feed the source inputs of the DUTs with Ethernet frames.
     * The first two feed Max Size Ethernet Frames while the third feeds Min Size Ethernet Frames.
     */

    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (2**$clog2(2*ETH_FRAME_MAX_BYTES)),  // each one can hold 2 full ethernet frames at least
        .DEPTH_AFULL     (2**$clog2(2*ETH_FRAME_MAX_BYTES)), 
        .WIDTH           (9),
        .SIM_MODE        (1)
        ) tb_frame_fifo_0 (
        .clk             (i_txmac_clk), 
        .rst             (i_txmac_srst), 
        .wren            (tb_frame_fifo_0_wren), 
        .wdata           (tb_frame_fifo_0_wdata), 
        .full            (tb_frame_fifo_0_full), 
        .afull           (tb_frame_fifo_0_afull), 
        .rden            (o_src_byte_rd[0]), 
        .rdata           ({i_src_last_byte[0], i_src_byte[0]}), 
        .rdata_vld       (i_src_byte_vld[0]));

    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (2**$clog2(2*ETH_FRAME_MAX_BYTES)),  // each one can hold 2 full ethernet frames at least
        .DEPTH_AFULL     (2**$clog2(2*ETH_FRAME_MAX_BYTES)), 
        .WIDTH           (9),
        .SIM_MODE        (1)
        ) tb_frame_fifo_1 (
        .clk             (i_txmac_clk), 
        .rst             (i_txmac_srst), 
        .wren            (tb_frame_fifo_1_wren), 
        .wdata           (tb_frame_fifo_1_wdata), 
        .full            (tb_frame_fifo_1_full), 
        .afull           (tb_frame_fifo_1_afull), 
        .rden            (o_src_byte_rd[1]), 
        .rdata           ({i_src_last_byte[1], i_src_byte[1]}), 
        .rdata_vld       (i_src_byte_vld[1]));

    pmi_fifo_sc_fwft_v1_0 #(
        .DEPTH           (2**$clog2(2*ETH_FRAME_MAX_BYTES)),  // each one can hold 2 full ethernet frames at least
        .DEPTH_AFULL     (2**$clog2(2*ETH_FRAME_MAX_BYTES)), 
        .WIDTH           (9),
        .SIM_MODE        (1)
        ) tb_frame_fifo_2 (
        .clk             (i_txmac_clk), 
        .rst             (i_txmac_srst), 
        .wren            (tb_frame_fifo_2_wren), 
        .wdata           (tb_frame_fifo_2_wdata), 
        .full            (tb_frame_fifo_2_full), 
        .afull           (tb_frame_fifo_2_afull), 
        .rden            (o_src_byte_rd[2]), 
        .rdata           ({i_src_last_byte[2], i_src_byte[2]}), 
        .rdata_vld       (i_src_byte_vld[2]));
    
    
    mac_tx_arbiter #(
        .NUM_INPUTS            (TB_NUM_INPUTS),
        .MAX_ETH_FRAME_BUFFERS (TB_MAX_ETH_FRAME_BUFFERS),
        .SIM_MODE              (1)
        ) DUT (.*);
    
    
    /*
     * MONITOR FOR FIFO OVERFLOWS (BOTH IN DUT OUTPUT FIFO AND TEST BENCH SOURCE FIFOS)
     */
    
    always_ff @(posedge i_txmac_clk) begin
        if (o_eth_frame_fifo_overflow) begin
            $fatal(0, "ERROR!  OUTPUT FIFO OVERFLOW REPORTED BY DUT");
        end
        if (tb_frame_fifo_2_full & tb_frame_fifo_2_wren) begin
            $fatal(0, "ERROR! SOURCE FIFO 2 OVEFLOW");
        end
        if (tb_frame_fifo_1_full & tb_frame_fifo_1_wren) begin
            $fatal(0, "ERROR! SOURCE FIFO 1 OVEFLOW");
        end
        if (tb_frame_fifo_0_full & tb_frame_fifo_0_wren) begin
            $fatal(0, "ERROR! SOURCE FIFO 0 OVEFLOW");
        end
    end

    
    /*
     * MONITOR FOR OUT OF SEQUENCE BYTES FROM THE DUT OUTPUT FIFO
     */
    
    always_ff @(posedge i_txmac_clk) begin
        if (tb_macread_vld) begin
            if (o_tx_fifodata != tb_expected_byte) begin 
                $error("ERROR!  DUT PROVIDED INCORRECT OUTPUT BYTE 0x%H, EXPECTED 0x%H", o_tx_fifodata, tb_expected_byte);
                tb_err_cnt++;
            end
            if (o_tx_fifoeof) begin
                tb_expected_byte <= '0;
            end else begin
                tb_expected_byte <= o_tx_fifodata + 1;
            end
        end
    end

endmodule

`default_nettype wire


