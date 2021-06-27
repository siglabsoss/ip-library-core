/*
 * Module: tb_graviton_ti_cfg
 * 
 */
 
`timescale 1s/1ns

module tb_graviton_ti_cfg;

    logic i_sysclk = 0;
    logic i_srst = 0;
    logic i_cfg_start = 0;
    logic o_cfg_done;
    logic o_sif_reset_n;
    logic o_sif_sclk;
    logic o_sif_sel_n;
    logic o_sif_sdout;
    
    localparam SYS_CLK_T_SECS = 100e-9;
    
    intf_cmd cmd();
    
    `define ADC /* change this to change which TI part configuration is simulated */
    
    `ifdef ADC 
         localparam SIF_ADDR_BITS       = 7;
         localparam SIF_DATA_BITS       = 8;
         localparam CFG_ROM_WORDS       = 3;
         localparam CFG_ROM_FILE        = "../cfg_rom_files/adc_cfg_rom.hex";
         localparam [6:0] CMD_SIF_ADDR  = 7'h7f;
         localparam [7:0] CMD_SIF_WDATA = 8'h12;
    `elsif DAC 
         localparam SIF_ADDR_BITS       = 7;
         localparam SIF_DATA_BITS       = 16;
         localparam CFG_ROM_WORDS       = 8;
         localparam CFG_ROM_FILE        = "../cfg_rom_files/dac_cfg_rom.hex";
         localparam [6:0] CMD_SIF_ADDR  = 7'h7f;
         localparam [7:0] CMD_SIF_WDATA = 16'h1234;
    `elsif LMK04826
         localparam SIF_ADDR_BITS       = 15;
         localparam SIF_DATA_BITS       = 8;
         localparam CFG_ROM_WORDS       = 37;
         localparam CFG_ROM_FILE        = "../cfg_rom_files/lmk04826_cfg_rom.hex";
         localparam [14:0] CMD_SIF_ADDR = 14'h3fff;
         localparam [7:0] CMD_SIF_WDATA = 16'h1234;
    `else
         localparam SIF_ADDR_BITS = 0;
         localparam SIF_DATA_BITS = 0;
         localparam CFG_ROM_WORDS = 0;
         localparam CFG_ROM_FILE  = "fail.hex";
    `endif
    
    localparam SIF_SHIFT_REG_BITS = SIF_ADDR_BITS + SIF_DATA_BITS;


    initial begin
        forever #(SYS_CLK_T_SECS/2) i_sysclk = ~i_sysclk;
    end
    
    initial begin
        i_srst <= 1;
        #(10*SYS_CLK_T_SECS);
        @(posedge i_sysclk);
        i_srst <= 0;
    end
    
    initial begin
        @(negedge i_srst);
        #(10*SYS_CLK_T_SECS);
        @(posedge i_sysclk);
        i_cfg_start <= 1;
        @(posedge i_sysclk);
        i_cfg_start <= 0;
        #(20000*SYS_CLK_T_SECS);
        $finish();
    end
    
    initial begin
        int i;
        logic [SIF_SHIFT_REG_BITS-1:0] sif_reg;
        forever begin
            @(negedge o_sif_sel_n);
            for (i=SIF_SHIFT_REG_BITS; i >= 0; i--) begin
                @(posedge o_sif_sclk);
                if (i == SIF_SHIFT_REG_BITS) begin // first bit is the rd/wr bit which we're not interested in storing for decoding the sif command later
                    if (o_sif_sdout) begin
                        $display("SIF READ DETECTED!");
                        $stop;
                        break;
                    end
                end else begin
                    sif_reg[i] = o_sif_sdout;
                end
            end
            $display("SIF WRITE: ADDR = 0x%h, DATA = 0x%h", sif_reg[SIF_SHIFT_REG_BITS-1:SIF_SHIFT_REG_BITS-SIF_ADDR_BITS], sif_reg[SIF_DATA_BITS-1:0]);
        end
    end
    
    // tests sif writes via the command interface
    
    initial begin
        DUT.cmd.sel <= 0;
        @(posedge o_cfg_done); 
        @(posedge i_sysclk);
        @(posedge i_sysclk);
        @(posedge i_sysclk);
        @(posedge i_sysclk);
        DUT.cmd.sel       <= 1;
        DUT.cmd.rd_wr_n   <= 0;
        DUT.cmd.byte_addr <= CMD_SIF_ADDR;
        DUT.cmd.wdata     <= CMD_SIF_WDATA;
        @(posedge i_sysclk);
        DUT.cmd.sel       <= 0;
    end
        
        
    graviton_ti_cfg #(
        .P_SYSCLK_DIV    ($ceil(100e-9/SYS_CLK_T_SECS)),
        .P_SIF_ADDR_BITS (SIF_ADDR_BITS),
        .P_SIF_DATA_BITS (SIF_DATA_BITS),
        .P_CFG_ROM_WORDS (CFG_ROM_WORDS),
        .P_CFG_ROM_FILE  (CFG_ROM_FILE)
        ) DUT (
    .i_sysclk          (i_sysclk         ), 
    .i_srst            (i_srst           ), 
    .cmd               (cmd              ), 
    .i_cfg_start       (i_cfg_start      ), 
    .o_cfg_done        (o_cfg_done       ), 
    .o_sif_reset_n     (o_sif_reset_n    ), 
    .o_sif_sclk        (o_sif_sclk       ), 
    .o_sif_sel_n       (o_sif_sel_n      ), 
    .o_sif_sdout       (o_sif_sdout      ));
endmodule


