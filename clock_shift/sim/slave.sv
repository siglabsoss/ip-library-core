
/*
 * Module: dac_top
 * 
 * TODO: Add module documentation
 */
module slave (

		/* NAMES CHOSEN TO CLOSELY MATCH GRAVITON SCHEMATIC, BUT THERE MIGHT BE DIFFERENCES WHERE I THOUGHT SCHEMATIC NAMES WERE UNCLEAR */
        
		input         FPGA0_CLK,
		output reg       LED_D6 = 0,
		output wire o_clk_25,
		output wire o_clk_125,
		input MIB,
		input [12:0] i_mib_ad,
		output o_MIB
		);
    
wire [1:0] PHASESEL;
assign PHASESEL = 0;
wire PHASEDIR;
wire PHASESTEP;
wire sys_pll_lock;
wire done;
assign o_MIB = MIB;
localparam delay = 10; //in ms
localparam FREQUENCY = 10; //MHz
localparam TRAINING_COUNTER_LIMIT = 1000 * FREQUENCY * delay;

logic reset_p = 1;
logic start;

clock_shift #(.TRAINING_COUNTER_LIMIT (10))
		clock_shift (
			.i_training_bit		(MIB),
			.i_traininig_clk	(o_clk_25),
			.o_pll_PHASEDIR		(PHASEDIR), 
			.o_pll_PHASESTEP	(PHASESTEP), 	
			.i_pll_lock	 		(sys_pll_lock),
			.i_start			(start),
			.i_reset_p			(reset_p),
			.o_done 			(done)
		);	
	
	sys_pll __ (
			.CLKI			(FPGA0_CLK), 
			.PHASESEL		(PHASESEL	), 
			.PHASEDIR		(PHASEDIR	), 
			.PHASESTEP		(PHASESTEP	), 
			.CLKOP			(o_clk_125), 
			.CLKOS			(o_clk_25), 
			.LOCK			(sys_pll_lock));	
	
	localparam pattern_1 = 13'h0AAA;
	localparam pattern_2 = 13'h0555;
	localparam pattern_3 = 13'h0f0f;
	localparam pattern_4 = 13'h10f0;
	localparam pattern_5 = 13'h0000;
	localparam pattern_6 = 13'h1fff;
	localparam pattern_7 = 13'h00f5;
	
	logic [7:0] rst_cntr = 8'hff;
	
	always_ff @(posedge o_clk_25) begin
		if (rst_cntr != 8'hff) begin
			reset_p <= 1;
			rst_cntr++;
			start <= 0;
		end else begin
			reset_p <= 0;
			start <= 1;
		end
	end
	
	
	enum {
		START	 ,
	    PATTERN_1, 
	    PATTERN_2, 
	    PATTERN_3, 
	    PATTERN_4, 
	    PATTERN_5, 
	    PATTERN_6, 
	    PATTERN_7, 
	    ERROR 	 
	} STATE;
	logic [4:0] counter_logic = 0;
	always @(posedge o_clk_25) begin
		if (done) begin
			STATE <= START;
			// counter_logic <= 0;
			$display("done");
			$monitor("i_mib_ad = %h", i_mib_ad);
		end
		
		case (STATE)
			
			START: begin
				if (i_mib_ad == pattern_1) begin
					STATE <= PATTERN_2;
				end
			end
			
			PATTERN_2: begin
				if (i_mib_ad == pattern_2) begin
					STATE <= PATTERN_3;
				end	else begin
					STATE <= ERROR;
				end
			end
			
			PATTERN_3: begin
				if (i_mib_ad == pattern_3) begin
					STATE <= PATTERN_4;
				end	else begin
					STATE <= ERROR;
				end
			end			
			
			PATTERN_4: begin
				if (i_mib_ad == pattern_4) begin
					STATE <= PATTERN_5;
				end	else begin
					STATE <= ERROR;
				end
			end		
			
			PATTERN_5: begin
				if (i_mib_ad == pattern_5) begin
					STATE <= PATTERN_6;
				end	else begin
					STATE <= ERROR;
				end
			end
			
			PATTERN_6: begin
				if (i_mib_ad == pattern_6) begin
					STATE <= PATTERN_7;
				end	else begin
					STATE <= ERROR;
				end
			end
			
			PATTERN_7: begin
				if (i_mib_ad == pattern_7) begin
					STATE <= PATTERN_1;
				end	else begin
					STATE <= ERROR;
				end
			end		
			
			PATTERN_1: begin
				if (i_mib_ad == pattern_1) begin
					STATE <= PATTERN_2;
					counter_logic <= counter_logic + 1;
					if (counter_logic == 15) begin
						$display("<<TB_SUCCESS>>");
						$finish;
					end
				end	else begin
					STATE <= ERROR;
				end
			end		
			
			ERROR: begin
				LED_D6 <= 1;
			end
			
			default: begin
				LED_D6 <= 0;
			end
			
		endcase
	end
endmodule


