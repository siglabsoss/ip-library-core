module master (

    /* NAMES CHOSEN TO CLOSELY MATCH GRAVITON SCHEMATIC, BUT THERE MIGHT BE DIFFERENCES WHERE I THOUGHT SCHEMATIC NAMES WERE UNCLEAR */

    input      CFG_CLK,

    output reg LED_D3,
	output reg [12:0] o_mib_ad,
	output wire MIB
);

   
    logic       clk25;
    logic       clk50;
    logic       sys_pll_locked;

	logic training = 0;
    assign MIB = training;
   

  
    

/********************************************************************************/


    assign LED_D3 = sys_pll_locked;



    /*
     *
     * PLL FOR ACTUAL SYSTEM CLOCK (ONLY VALID AFTER LMK04826 CLOCK CHIP IS CONFIGURED)
     *
     */

    sys_pll sys_pll (.CLKI(CFG_CLK), .CLKOP(sys_clk), .CLKOS(clk25), .LOCK(sys_pll_locked));


    
    localparam pattern_1 = 13'h0AAA;
    localparam pattern_2 = 13'h0555;
    localparam pattern_3 = 13'h0f0f;
    localparam pattern_4 = 13'h10f0;
    localparam pattern_5 = 13'h0000;
    localparam pattern_6 = 13'h1fff;
    localparam pattern_7 = 13'h00f5;
	reg [2:0] counter_25 = 0;
    always @(posedge clk25)
    begin
	
    	case(counter_25)
    		3'b000 :	begin
    			o_mib_ad  <= pattern_1; // Send the data packet-1	
    			counter_25 <= 3'b001;
    		end

    		3'b001 :	begin
    			o_mib_ad  <= pattern_2; // Send the data packet-2
    			counter_25 <= 3'b010;
    		end

    		3'b010 :	begin
    			o_mib_ad  <= pattern_3; // Send the data packet-3
    			counter_25 <= 3'b011;
    		end

    		3'b011 :	begin
    			o_mib_ad  <= pattern_4; // Send the data packet-4
    			counter_25 <= 3'b100; //
    		end
    		3'b100 :	begin
    			o_mib_ad  <= pattern_5; // Send the data packet-5
    			counter_25 <= 3'b101; //
    		end

    		3'b101 :	begin
    			o_mib_ad  <= pattern_6; // Send the data packet-6
    			counter_25 <= 3'b110; //
    		end

    		3'b110 :	begin
    			o_mib_ad  <= pattern_7; // Send the data packet-7
    			counter_25 <= 3'b000; //
    		end
    		default: begin
    			counter_25 <= 0;
    			o_mib_ad <= 0;
    		end
    	endcase
    end	
    
    
	always @(posedge clk25) begin
    	if (sys_pll_locked) begin
    		training <= !training;
    	end
    end

endmodule