// tb_cic_interpolator.sv
//

`timescale 10ps / 10ps

`default_nettype none

module tb_cic_interpolator;

localparam integer WIDTH = 16;
localparam real PI_VALUE = 4 * $atan(1.0);

logic [WIDTH-1:0] i_inph;
logic [WIDTH-1:0] i_quad;
logic             o_ready;
logic [WIDTH-1:0] o_inph;
logic [WIDTH-1:0] o_quad;
logic             i_ready;
logic             o_inph_pos_oflow;
logic             o_inph_neg_oflow;
logic             o_quad_pos_oflow;
logic             o_quad_neg_oflow;
logic             o_cic_inph_pos_oflow;
logic             o_cic_inph_neg_oflow;
logic             o_cic_quad_pos_oflow;
logic             o_cic_quad_neg_oflow;
logic             i_clock;
logic             i_reset;

cic_interpolator #(.WIDTH(WIDTH)) uut (.*);

always begin: clock_gen
    #5 i_clock = 1'b1;
    #5 i_clock = 1'b0;
end

// debug variable declarations
logic [31:0] test_number = 1;
logic [31:0] run_count = 0;
integer      inph;
integer      quad;
real         magnitude;
real         phase;
integer      fid;
real         fc;

real         max_passband = -(1 << 30);
real         min_passband = (1 << 30);

task reset_all;
    i_reset = 1'b1;
    i_ready = 1'b0;
    #1000;
    @(negedge i_clock) i_reset = 1'b0;
endtask: reset_all

initial begin: stimulus
    err::reset();
    fc = 0.01;
    i_reset = 1'b1;
    #1000;
    reset_all();
    test_number = 1;

    // Test 1 - Uninterrupted pulling on output pulls on input at correct rate
    $display("Test %d started...", test_number);
    reset_all();
    i_ready = 1'b1;
    #1252000; // 400 * 313 * 10;
    i_ready = 1'b0;
    #10000;
    if (run_count != 400) begin
        $display("    Error: Consumed %d inputs, but expected 400.", run_count);
        err::increment();
    end
    $display("Test %d complete!", test_number);
    test_number++;

    // Test 2 - Pulling every 4th cycle on output pulls on input at correct rate
    $display("Test %d started...", test_number);
    reset_all();
    for (integer iteration_number = 0; iteration_number < 400*313; iteration_number++) begin
        i_ready = 1'b1;
        #10;
        i_ready = 1'b0;
        #30;
    end
    i_ready = 1'b0;
    #10000;
    if (run_count != 400) begin
        $display("    Error: Consumed %d inputs, but expected 400.", run_count);
        err::increment();
    end
    $display("Test %d complete!", test_number);
    test_number++;

    // Test 3 - Sine sweep
    $display("Test %d started...", test_number);
    $display("    Opening 'test1.txt' for writing...");
    fid = $fopen("test1.txt", "w");
    for (real frequency = -0.35; frequency < 0.35; frequency = frequency + 0.01) begin
        fc = frequency;
        reset_all();
        for (integer iteration_number = 0; iteration_number < 150*313; iteration_number++) begin
            i_ready = 1'b1;
            if (iteration_number == 150*313-1) begin
                inph = $signed(o_inph);
                quad = $signed(o_quad);
                magnitude = $sqrt($pow($itor(inph), 2.0) + $pow($itor(quad), 2.0));
                phase = 180 * $atan2($itor(quad), $itor(inph)) / PI_VALUE;
                if ((fc > -0.225) && (fc < 0.225)) begin
                    if (magnitude > max_passband) begin
                        max_passband = magnitude;
                    end
                    if (magnitude < min_passband) begin
                        min_passband = magnitude;
                    end
                end
                $display("        f = %f; I/Q = %d, %d; M/P = %f, %f", fc, inph, quad, magnitude, phase);
                $fwrite(fid, "%f, %f, %f\n", fc, magnitude, phase);
            end
            #10;
            i_ready = 1'b0;
            #30;
        end
    end
    i_ready = 1'b0;
    #10000;
    $fclose(fid);
    if (20*$log10(max_passband / min_passband) > 1.0) begin
        $display("    Error: Passband ripple is out of spec: %f dB.", 20*$log10(max_passband / min_passband));
        err::increment();
    end
    if (run_count != 150) begin
        $display("    Error: Consumed %d inputs, but expected 150.", run_count);
        err::increment();
    end
    $display("Test %d complete!", test_number);
    test_number++;

    // Finished
    #10000;
    err::report_success_or_failure();
    $display("Simulation done!");
    $finish();
end

always @(posedge i_clock) begin: stim_for_interp
    if (i_reset == 1'b1) begin
        i_inph <= 0;
        i_quad <= 0;
        run_count <= 0;
    end else if (o_ready == 1'b1) begin
        i_inph <= ((1 << (WIDTH-2))-1) * $cos(2.0*PI_VALUE*fc*run_count);
        i_quad <= ((1 << (WIDTH-2))-1) * $sin(2.0*PI_VALUE*fc*run_count);
        run_count <= run_count + 1;
    end
end

endmodule: tb_cic_interpolator

`default_nettype wire
