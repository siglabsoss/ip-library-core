// tb_channel_modulator.sv
//

`timescale 10ps / 10ps

`default_nettype none

module tb_rx_channel_modulator;

localparam integer WIDTH = 16;
localparam integer NUM_CHANNELS = 4096;

// Input Sample Interface
logic [WIDTH-1:0] i_inph;
logic [WIDTH-1:0] i_quad;
logic             i_valid;
// Phase Accumulator Increment
logic [12-1:0]    i_phase_inc;
logic             i_phase_inc_valid;
// Output Sample Interface
logic [WIDTH-1:0] o_inph;
logic [WIDTH-1:0] o_quad;
logic             o_inph_oflow;
logic             o_quad_oflow;
logic             o_valid;
// Clock and Reset
logic             i_clock;
logic             i_reset;

rx_channel_modulator #(
    .WIDTH(WIDTH),
    .NUM_CHANNELS(NUM_CHANNELS))
uut (.*);

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
    i_inph = 0;
    i_quad = 0;
    i_valid = 1'b0;
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
    i_valid = 1'b0;
    @(negedge i_clock) begin
        #10;
    end
    #1000;
    if (run_count > 0) begin
        $display("Error: Test 1 failed! No data input, but data output received.");
        glbl_err_count++;
    end
    #100;
    $display("Test 1 Done!");

    // Test 2: Same amount of data in to out...
    $display("Test 2 Started!");
    test_number = 2;
    i_phase_inc = 1;
    i_phase_inc_valid = 1'b1;
    reset_all();
    #1000;
    i_valid = 1'b1;
    for (integer pidx = 0; pidx < 100000; pidx++) begin
        @(negedge i_clock) begin
            i_inph <= 1 << (WIDTH-2);
            i_quad <= 0;
            i_valid = 1'b1;
            #10;
            // if (pidx % 5 > 0) begin
            //     i_valid = 1'b0;
            //     #10;
            // end
            i_valid = 1'b0;
            #30;
        end
    end
    i_valid = 1'b0;
    #1000;
    if (run_count != 100000) begin
        $display("Error: Input 100000 samples, received %d samples.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 2 Done!");

    // Finished
    #10000;
    glbl_err_count = glbl_err_count + local_err_count;
    $display("Simulation done!");
    if (glbl_err_count == 0) begin
        $display("<<TB_SUCCESS>>");
    end
    $finish();

end

// Tests the output sequence to make sure it matches the input

real prev_sine, sine;
real prev_cosine, cosine;
real rot_sine, rot_cosine;
real rot_angle;

always @(posedge i_clock) begin: seq_check
    if (i_reset == 1'b1) begin
        run_count <= 0;

        rot_angle = 0;
        prev_sine = 0;
        prev_cosine = 0;
        sine = 0;
        cosine = 0;
        rot_cosine = 0;
        rot_sine = 0;
    end else begin
        // Track number of outputs received
        if (o_valid == 1'b1) begin
            run_count <= run_count + 1;

            prev_sine = sine;
            prev_cosine = cosine;
            sine = $signed(o_quad) / $itor(1 << WIDTH-2);
            cosine = $signed(o_inph) / $itor(1 << WIDTH-2);
            if (test_number == 2) begin
                if (run_count > 10000) begin
                    rot_cosine = cosine * prev_cosine + sine * prev_sine;
                    rot_sine = sine * prev_cosine - cosine * prev_sine;
                    rot_angle = 0.9995 * rot_angle + 0.0005 * (180 * $atan2(rot_sine, rot_cosine) / (2 * $atan2(1.0, 0.0)));
                    //$display("angle = %f", rot_angle);
                end
                if (run_count == 100000-1) begin
                    if (((1 + NUM_CHANNELS * rot_angle / 360.0) > 0.0001)
                            || ((1 + NUM_CHANNELS * rot_angle / 360.0) < -0.0001)) begin
                        $display("Error detected in angle! %f != %f", rot_angle, 360.0 / $itor(NUM_CHANNELS));
                        $display("Ratio = %f", rot_angle / (360.0 / $itor(NUM_CHANNELS)));
                        local_err_count <= local_err_count + 1;
                    end
                    //$display("%f, %f", rot_angle, 360.0 / $itor(NUM_CHANNELS));
                end
            end
        end
    end
end

endmodule: tb_rx_channel_modulator

`default_nettype wire
