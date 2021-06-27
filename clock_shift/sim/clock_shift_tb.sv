// synopsys translate_off	
`default_nettype none
`timescale 1ns/100ps

module clock_shift_tb;
	reg i_clk;
	wire dummy_clk;
	wire training_sequence;
	wire [12:0] pattern;
	wire master_pll_lock;
	wire slave_pll_lock;
	wire o_clk_25;
	wire o_clk_125;
	initial 
	begin
		i_clk = 0;
	end
	
	always #4 i_clk = !i_clk;
	assign #2 dummy_clk = i_clk;
	
	master master (
		.CFG_CLK    (i_clk        ), 
		.LED_D3     (master_pll_lock       ), 
		.o_mib_ad  	(pattern ),
		.MIB		(training_sequence));
	
	slave slave (
		.FPGA0_CLK  (dummy_clk ), 
		.LED_D6     (slave_pll_lock    ), 
		.o_clk_25   (o_clk_25  ), 
		.o_clk_125  (o_clk_125 ), 
		.MIB        (training_sequence       ), 
		.i_mib_ad   (pattern  ));
	
endmodule

// synopsys translate_on
`default_nettype wire