// tb_upconverter.sv
//

`timescale 10ps / 10ps

`default_nettype none

module tb_upconverter;

localparam integer WIDTH = 16;

logic [WIDTH-1:0] i_inph_data;
logic [WIDTH-1:0] i_quad_data;
logic             o_ready;
// logic [32-1:0]    i_phase_inc;
// logic             i_phase_inc_valid;
logic [WIDTH-1:0] o_inph_data;
logic [WIDTH-1:0] o_quad_data;
logic             i_ready;
logic             i_clock;
logic             i_reset;

upconverter #(.WIDTH(WIDTH)) uut (.*);

always begin: clock_gen
    #5 i_clock = 1'b1;
    #5 i_clock = 1'b0;
end

// debug variable declarations
logic [31:0] glbl_err_count = 0;
logic [31:0] test_number = 1;
logic [31:0] run_count = 0;

// Used by check process, declared here so it
// can be included in the final total for the
// global error count.
logic [31:0] local_err_count = 0;

task reset_all;
    i_reset = 1'b1;
    i_ready = 1'b0;
    #1000;
    @(negedge i_clock) i_reset = 1'b0;
endtask: reset_all

integer fid;

initial begin: stimulus
    i_reset = 1'b1;
    #1000;
    reset_all();

    // // Test 1: No data in = no data out.
    // $display("Test 1 Started!");
    // test_number = 1;
    // reset_all();
    // #1000;

    // @(negedge i_clock) begin
    //     i_ready = 1'b0;
    //     #10;
    // end
    // i_ready = 1'b0;
    // #1000;
    // if (run_count > 0) begin
    //     $display("Error: Test 1 failed! No data input, but data output received.");
    //     glbl_err_count++;
    // end
    // #100;
    // $display("Test 1 Done!");

    // Test 2: No data in = no data out.
    $display("Test 2 Started!");
    test_number = 2;
    reset_all();
    #1000;
    for (integer in_idx = 0; in_idx < 10000; in_idx++) begin
        @(negedge i_clock) begin
            i_ready = 1'b1;
            #10;
        end
    end
    i_ready = 1'b0;
    #1000;
    if ((run_count != 10000/2/2) && (run_count != 10000/2/2 + 1)) begin
        $display("Error: Test 2 failed! 10000 samples read from output, but %d samples of input read.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 2 Done!");

    // Test 3: Various sinusoidal signals.
    $display("Test 3 Started!");
    test_number = 3;
    reset_all();
    #1000;
    fid = $fopen("test_output.txt", "w");
    for (integer in_idx = 0; in_idx < (1<<19); in_idx++) begin
        @(negedge i_clock) begin
            if (in_idx > 200) begin
                $fwrite(fid, "%d, %d\n", $signed(o_inph_data), $signed(o_quad_data));
            end
            i_ready = 1'b1;
            #10;
        end
    end
    $fclose(fid);
    i_ready = 1'b0;
    #1000;
    if ((run_count != (1<<19)/2/2) && (run_count != (1<<19)/2/2 + 1)) begin
        $display("Error: Test 3 failed! 10000 samples read from output, but %d samples of input read.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 3 Done!");

    // Finished
    #10000;
    glbl_err_count = glbl_err_count + local_err_count;
    if (glbl_err_count != 0) begin
        $display("Failed with %d errors", glbl_err_count);
    end else begin
        $display("<<TB_SUCCESS>>");
    end
    $display("Simulation done!");
    $finish();

end

// Tests the output sequence to make sure it matches the input
always @(posedge i_clock) begin: seq_check
    if (i_reset == 1'b1) begin
        run_count <= 0;
    end else begin
        // Track number of outputs received
        if (o_ready == 1'b1) begin
            run_count <= run_count + 1;

            if (test_number == 2) begin
                // $display("o: (%d, %d); arctan(y/x) = %f",
                //     $signed(o_inph_data), $signed(o_quad_data),
                //     360.0/(4.0*$atan(1.0))*$atan2(o_quad_data, o_inph_data));
            end
        end
    end
end

// Provides stimulus for input
integer sample_cnt;
always @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        sample_cnt <= 0;
    end else if (o_ready == 1'b1) begin
        sample_cnt <= sample_cnt + 1;
    end

    if (o_ready == 1'b1) begin
        if (test_number == 2) begin
            i_inph_data <= (1 << (WIDTH-1)) - 1;
            i_quad_data <= 0;
        end else if (test_number == 3) begin
            i_inph_data <= $rtoi($pow(2.0, 14.0) * $cos(2.0*3.14159*8.0/32.25*$itor(sample_cnt)));
            i_quad_data <= $rtoi($pow(2.0, 14.0) * $sin(2.0*3.14159*8.0/32.25*$itor(sample_cnt)));
        end
    end
end

endmodule: tb_upconverter

`default_nettype wire
