// tb_downconverter.sv
//

`timescale 10ps / 10ps

`default_nettype none

module tb_downconverter;

localparam integer WIDTH = 16;

logic [WIDTH-1:0] i_inph_data;
logic [WIDTH-1:0] i_inph_delay_data;
logic             i_valid;
logic [32-1:0]    i_phase_inc;
logic             i_phase_inc_valid;
logic [WIDTH-1:0] o_inph_data;
logic [WIDTH-1:0] o_quad_data;
logic             o_valid;
logic             i_clock;
logic             i_reset;

downconverter #(.WIDTH(WIDTH)) uut (.*);

always begin: clock_gen
    #5 i_clock = 1'b1;
    #5 i_clock = 1'b0;
end

// debug variable declarations
logic [31:0] glbl_err_count = 0;
logic [31:0] test_number = 1;
logic [31:0] run_count = 0;

// Used by check process, declared here so it
// can be included in the final tall for the
// global error count.
logic [31:0] local_err_count = 0;

task reset_all;
    i_reset = 1'b1;
    i_inph_data = 0;
    i_inph_delay_data = 0;
    i_valid = 1'b0;
    i_phase_inc <= '0;
    i_phase_inc_valid <= 1'b0;
    #1000;
    @(negedge i_clock) i_reset = 1'b0;
endtask: reset_all

initial begin: stimulus
    i_reset = 1'b1;
    #1000;
    reset_all();

    // Test 1: No data in = no data out.
    $display("Test 1 Started!");
    test_number = 1;
    reset_all();
    #1000;
    i_phase_inc <= $rtoi((31.5 / 250.0) * $pow(2.0, 32.0));
    i_phase_inc_valid <= 1'b1;
    #10;
    i_phase_inc <= '0;
    i_phase_inc_valid <= 1'b0;
    #10;
    @(negedge i_clock) begin
        i_valid = 1'b0;
        #10;
    end
    i_valid = 1'b0;
    #1000;
    if (run_count > 0) begin
        $display("Error: Test 1 failed! No data input, but data output received.");
        glbl_err_count++;
    end
    #100;
    $display("Test 1 Done!");

    // Test 2: No data in = no data out.
    $display("Test 2 Started!");
    test_number = 2;
    reset_all();
    #1000;
    for (integer in_idx = 0; in_idx < 10000; in_idx++) begin
        @(negedge i_clock) begin
            i_inph_data = ((1 << 15)-1) * $cos(2*(4*$atan(1.0))*((31.5 / 250.0) + 0.01)*2*in_idx);
            i_inph_delay_data = ((1 << 15)-1) * $cos(2*(4*$atan(1.0))*((31.5 / 250.0) + 0.01)*2*(in_idx+1));
            //$display("i: %d", $signed(i_inph_data));
            i_valid = 1'b1;
            #10;
        end
    end
    i_valid = 1'b0;
    #1000;
    if (run_count != 10000/2/2) begin
        $display("Error: Test 2 failed! 10000 samples of input, but %d samples of output.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 2 Done!");

    // Finished
    #10000;
    glbl_err_count = glbl_err_count + local_err_count;
    $display("Simulation done!");
    $finish();

end

// Tests the output sequence to make sure it matches the input
always @(posedge i_clock) begin: seq_check
    if (i_reset == 1'b1) begin
        run_count <= 0;
    end else begin
        // Track number of outputs received
        if (o_valid == 1'b1) begin
            run_count <= run_count + 1;

            if (test_number == 2) begin
                // $display("o: (%d, %d); arctan(y/x) = %f",
                //     $signed(o_inph_data), $signed(o_quad_data),
                //     360.0/(4.0*$atan(1.0))*$atan2(o_quad_data, o_inph_data));
            end
        end
    end
end

endmodule: tb_downconverter

`default_nettype wire
