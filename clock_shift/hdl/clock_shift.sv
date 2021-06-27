//-----------------------------------------------------
// Design Name : clock_shift
// File Name   : clock_shift.sv
// Authors	   : Anurag Goyal
// Function    : Top module for Clock Shift 
//-----------------------------------------------------
 
`default_nettype none
module clock_shift #(
		parameter TRAINING_COUNTER_LIMIT = 10
		)
		(
		input wire i_training_bit, // a continuous stream of 1010101010....
		input wire i_traininig_clk, // clock to be shifted
		output reg o_pll_PHASESTEP, // should be connected to 'PHASESTEP' on pll
		output wire o_pll_PHASEDIR, // should be connected to 'PHASEDIR' on pll
		output wire o_pll_PHASELOADREG, // should be connected to 'PHASELOADREG' on pll
		input wire i_pll_lock, // connect to 'LOCK' on pll
		input wire i_start, // goes high when 
		input wire i_reset_p,
		output reg o_done // it gets high when the process is complete
		);

	assign o_pll_PHASEDIR = 1'b0; // for selecting delayed (lagging) phase
	assign o_pll_PHASELOADREG = 1'b0; // to select PHASESEL method only.	
	enum {
		INITIAL_WAIT	   ,
		CHECK_RECEIVED_DATA, 	
		EXPECT_0 		   ,
		EXPECT_1 		   ,	
		ERROR_DETECT	   	
	} STATE;
	
	reg error_detect;
	reg [31:0] training_counter;
	reg check;
	reg move_given;
	reg i_training_sequence_r0;
	reg sys_pll_lock_r0;
	
	always @(posedge i_traininig_clk) begin
				
		if (i_reset_p) begin
			STATE 					<= INITIAL_WAIT;
			error_detect 			<= 0;
			training_counter 		<= 0;
			i_training_sequence_r0 	<= 0;
			sys_pll_lock_r0			<= 0;
		end else begin
			
			i_training_sequence_r0 <= i_training_bit;
			sys_pll_lock_r0 <= i_pll_lock;
			
			
			case (STATE)
				
				INITIAL_WAIT: begin
					if (sys_pll_lock_r0 && i_start) begin
						STATE <= CHECK_RECEIVED_DATA;
					end
				end
				
				CHECK_RECEIVED_DATA: begin
					if (i_training_sequence_r0) begin
						STATE <= EXPECT_0;
						training_counter <= training_counter + 1;
					end else begin
						STATE <= EXPECT_1;
						training_counter <= training_counter + 1;
					end
				end
				
				EXPECT_0: begin
					if (i_training_sequence_r0 == 0) begin
						STATE <= EXPECT_1;
						training_counter <= training_counter + 1;
						if (training_counter == TRAINING_COUNTER_LIMIT) begin
							training_counter <= training_counter;
						end
						if (training_counter == TRAINING_COUNTER_LIMIT) begin
							STATE <= ERROR_DETECT;
						end
					end else begin
						STATE <= ERROR_DETECT;
						error_detect <= 1;
					end
				end
				
				EXPECT_1: begin
					if (i_training_sequence_r0 == 1) begin
						STATE <= EXPECT_0;
						training_counter <= training_counter + 1;
						if (training_counter == TRAINING_COUNTER_LIMIT) begin
							training_counter <= training_counter;
						end
						if (training_counter == TRAINING_COUNTER_LIMIT) begin
							STATE <= ERROR_DETECT;
						end
					end else begin
						STATE <= ERROR_DETECT;
						error_detect <= 1;
					end
	 
				end
				
				ERROR_DETECT: begin
					if (check) begin
						error_detect <= 0;
						STATE <= CHECK_RECEIVED_DATA;
					end
					
					if (move_given) begin
						training_counter <= 0;
					end
				end
				
			endcase
		end
	end
	

	enum {
		INITIAL						,
		IDLE 						,
		INITIAL_CORRECT 			,	
		INITIAL_BAD 				,	
		MOVE_PULSE 					,
		MOVE_1 						,
		MOVE_0 						,
		LIMIT_REACHED 				,
		GIVE_MOVE_TILL_ERROR_COMES 	,
		PHASE_STEP_1 				,
		PHASE_STEP_0 				,
		WAIT 						
	} TRAINING_STATE;
	
	reg limit_reached;
	reg flag;
	reg [31:0] move_counter;
	reg [31:0] calibration_counter;
	
	reg one_time_error;
	reg [31:0] wait_counter;
	
	always @(posedge i_traininig_clk) begin
		if (i_reset_p) begin
			check 				<= 0;
			move_given 			<= 0;	
			TRAINING_STATE 		<= INITIAL;
			limit_reached 		<= 0;
			flag 				<= 1;
			move_counter 		<= 0;
			calibration_counter <= 0;
			one_time_error 		<= 1;
			wait_counter 		<= 0;
			o_pll_PHASESTEP 	<= 0;
			o_done 				<= 0;
		end else begin
			
			case (TRAINING_STATE)
				
				INITIAL: begin
					if (sys_pll_lock_r0 && i_start) begin
						TRAINING_STATE <= IDLE;
					end
				end
				
				IDLE: begin
					check <= 0;
					if ((training_counter == TRAINING_COUNTER_LIMIT) && flag && one_time_error) begin
						TRAINING_STATE <= GIVE_MOVE_TILL_ERROR_COMES;
					end else if (training_counter == TRAINING_COUNTER_LIMIT) begin
						TRAINING_STATE <= INITIAL_CORRECT;
					end else if (error_detect && flag) begin
						TRAINING_STATE <= INITIAL_BAD;
						one_time_error <= 0;
					end else if (error_detect) begin
						TRAINING_STATE <= LIMIT_REACHED;
						// LOADN <= 0; // reseting the delay 
					end
				end
				
				INITIAL_CORRECT: begin
					TRAINING_STATE <= MOVE_PULSE;
					flag <= 0;
				end
				
				INITIAL_BAD: begin
					move_counter <= 0;
					TRAINING_STATE <= MOVE_PULSE;
				end
				
				MOVE_PULSE: begin
					if (move_given) begin
						TRAINING_STATE <= IDLE;
						move_given <= 0;
					end else begin
						TRAINING_STATE <= MOVE_1;
					end
				end
				
				MOVE_1: begin
					o_pll_PHASESTEP <= 1;
					move_given <= 1;
					TRAINING_STATE <= MOVE_0;
					move_counter <= move_counter + 1;
				end
				
				MOVE_0: begin
					o_pll_PHASESTEP <= 0;
					TRAINING_STATE <= MOVE_PULSE;
					check <= move_given;
				end
				
				LIMIT_REACHED: begin
					limit_reached <= 1;
					if (calibration_counter != (move_counter>>1)) begin
						TRAINING_STATE <= PHASE_STEP_1;
						calibration_counter <= calibration_counter + 1;
					end else begin
						o_done <= 1;
					end
				end
				
				GIVE_MOVE_TILL_ERROR_COMES: begin
					one_time_error <= 1;
					if (move_given) begin
						TRAINING_STATE <= IDLE;
						move_given <= 0;
					end else begin	
						TRAINING_STATE <= PHASE_STEP_1;
					end
				end	
				
				PHASE_STEP_1: begin
					o_pll_PHASESTEP <= 1;
					if (limit_reached == 0) begin
						move_given <= 1;
					end
					TRAINING_STATE <= PHASE_STEP_0;				
				end
				
				PHASE_STEP_0: begin
					o_pll_PHASESTEP <= 0;
					if (limit_reached == 0) begin
						TRAINING_STATE <= GIVE_MOVE_TILL_ERROR_COMES;
						check <= move_given;	
					end else begin
						TRAINING_STATE <= WAIT;
						wait_counter <= 0;
					end
				end
				
				WAIT: begin
					wait_counter <= wait_counter + 1;
					if (wait_counter == TRAINING_COUNTER_LIMIT) begin
						TRAINING_STATE <= LIMIT_REACHED;
					end
					
					
				end
			endcase
			
		end
	end
endmodule
`default_nettype wire