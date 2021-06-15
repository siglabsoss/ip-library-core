// tb_cic_decim.sv
//

`timescale 10ps / 10ps

`default_nettype none

module tb_cic_decimator;

localparam integer WIDTH = 16;
localparam real PI_VALUE = 4 * $atan(1.0);

logic [WIDTH-1:0] i_inph;
logic [WIDTH-1:0] i_quad;
logic             i_valid;
logic             o_ready;
logic [WIDTH-1:0] o_inph;
logic [WIDTH-1:0] o_quad;
logic             o_valid;
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

cic_decimator #(.WIDTH(WIDTH)) uut (.*);

always begin: clock_gen
    #5 i_clock = 1'b1;
    #5 i_clock = 1'b0;
end

// debug variable declarations
logic [31:0] glbl_err_count = 0;
logic [31:0] test_number = 1;
logic [31:0] run_count = 0;
integer stim_fid;

// Temp value holders
logic [31:0] iq_data;
real frequencies [0:4999] = '{ 5000{ 0.0 } };
real passband_mean;
integer freq_count;
integer samp_num;
real fc;

// Test frequencies
localparam real f1 = 0.01 / 313.0;
localparam real f2 = 0.9 / 313.0;

// Used by check process, declared here so it
// can be included in the final total for the
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
    samp_num = 0;
    #1000;
    reset_all();

    // Test 1: No data in = no data out.
    $display("Test 1 Started!");
    test_number = 1;
    reset_all();
    #1000;
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

    // Test 2: Simple Sine In, Simple Sine Out
    $display("Test 2 Started!");
    test_number = 2;
    reset_all();
    #1000;
    samp_num = 0;
    for(integer lcount = 0; lcount < 1079539; lcount++) begin
        @(negedge i_clock) begin
            i_inph = $rtoi($floor(0.5 + $itor((1 << WIDTH-1) - 1) * $cos(2.0*PI_VALUE*f1*samp_num)));
            i_quad = $rtoi($floor(0.5 + $itor((1 << WIDTH-1) - 1) * $sin(2.0*PI_VALUE*f1*samp_num)));
            i_valid = 1'b1;
            samp_num = samp_num + 1;
            #10;
        end
    end
    i_valid = 1'b0;
    #2000;
    if (run_count != 3449) begin // Note: 1079539 / 313 = 3449 rem 2
        $display("Error: Test 2 failed! Expected 3449 samples at output but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 2 Done!");

    // Test 3: Simple Sine In, Vastly attenuated sine out
    $display("Test 3 Started!");
    test_number = 3;
    reset_all();
    #1000;
    samp_num = 0;
    for(integer lcount = 0; lcount < 4000*313; lcount++) begin
        @(negedge i_clock) begin
            i_inph = $rtoi($itor((1 << WIDTH-1) - 1) * $cos(2.0*PI_VALUE*f2*samp_num));
            i_quad = $rtoi($itor((1 << WIDTH-1) - 1) * $sin(2.0*PI_VALUE*f2*samp_num));
            i_valid = 1'b1;
            samp_num = samp_num + 1;
            #10;
        end
    end
    i_valid = 1'b0;
    #2000;
    if (run_count != 4000) begin
        $display("Error: Test 3 failed! Expected 4000 samples at output but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 3 Done!");

    // Test 4: Simple Sines In, Simple Sines Out (One rejected)
    $display("Test 4 Started!");
    test_number = 4;
    reset_all();
    #1000;
    samp_num = 0;
    for(integer lcount = 0; lcount < 4000*313; lcount++) begin
        @(negedge i_clock) begin
            i_inph = $rtoi($itor((1 << WIDTH-1) - 1) * $cos(2.0*PI_VALUE*0.00001*samp_num))
                + $rtoi($itor((1 << WIDTH-2) - 1) * $cos(2.0*PI_VALUE*0.00002*samp_num))
                + $rtoi($itor((1 << WIDTH-3) - 1) * $cos(2.0*PI_VALUE*0.00003*samp_num))
                + $rtoi($itor((1 << WIDTH-4) - 1) * $cos(2.0*PI_VALUE*0.00004*samp_num))
                + $rtoi($itor((1 << WIDTH-5) - 1) * $cos(2.0*PI_VALUE*0.00005*samp_num))
                + $rtoi($itor((1 << WIDTH-1) - 1) * $cos(2.0*PI_VALUE*0.01*samp_num));
            i_quad = $rtoi($itor((1 << WIDTH-1) - 1) * $sin(2.0*PI_VALUE*0.00001*samp_num))
                + $rtoi($itor((1 << WIDTH-2) - 1) * $sin(2.0*PI_VALUE*0.00002*samp_num))
                + $rtoi($itor((1 << WIDTH-3) - 1) * $sin(2.0*PI_VALUE*0.00003*samp_num))
                + $rtoi($itor((1 << WIDTH-4) - 1) * $sin(2.0*PI_VALUE*0.00004*samp_num))
                + $rtoi($itor((1 << WIDTH-5) - 1) * $sin(2.0*PI_VALUE*0.00005*samp_num))
                + $rtoi($itor((1 << WIDTH-1) - 1) * $sin(2.0*PI_VALUE*0.01*samp_num));
            i_valid = 1'b1;
            samp_num = samp_num + 1;
            #10;
        end
    end
    i_valid = 1'b0;
    #2000;
    if (run_count != 4000) begin
        $display("Error: Test 4 failed! Expected 4000 samples at output but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 4 Done!");

    // Test 5: Sine sweep to file
    $display("Test 5 Started!");
    test_number = 5;
    for(fc = -0.5/313; fc < 0.5/313; fc = fc + 0.01/313) begin
        $display("    Setting sinusoidal frequency to %f", fc);
        reset_all();
        #1000;
        samp_num = 0;
        for(integer lcount = 0; lcount < 4000*313; lcount++) begin
            @(negedge i_clock) begin
                i_inph = $rtoi($itor((1 << WIDTH-1) - 1) * $cos(2.0*PI_VALUE*fc*samp_num));
                i_quad = $rtoi($itor((1 << WIDTH-1) - 1) * $sin(2.0*PI_VALUE*fc*samp_num));
                i_valid = 1'b1;
                samp_num = samp_num + 1;
                #10;
            end
        end
        i_valid = 1'b0;
        #2000;
    end
    if (run_count != 4000) begin
        $display("Error: Test 5 failed! Expected 4000 samples at output but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    // Test the passband ripple is less than 0.5 dB
    passband_mean = 0.0;
    for (integer fcount = 0; fcount < freq_count; fcount++) begin
        passband_mean = passband_mean + frequencies[fcount];
    end
    passband_mean = passband_mean / $itor(freq_count);
    for (integer fcount = 0; fcount < freq_count; fcount++) begin
        if (frequencies[fcount] > passband_mean) begin
            if (20*$log10((frequencies[fcount] - passband_mean)) > 0.5) begin
                $display("Error, ripple in passband exceeds 0.5 dB!");
                glbl_err_count++;
            end
        end else if (frequencies[fcount] < passband_mean) begin
            if (20*$log10((passband_mean - frequencies[fcount])) > 0.5) begin
                $display("Error, ripple in passband exceeds 0.5 dB!");
                glbl_err_count++;
            end
        end
    end
    $display("Test 5 Done!");

    // Test 6:
    $display("Test 6 Started!");
    test_number = 6;
    reset_all();
    #1000;
    samp_num = 0;
    stim_fid = $fopen("stimulus.mif","r");
    if ($feof(stim_fid) || (!stim_fid)) begin
        $display("Failed to open stimulus file.");
        glbl_err_count++;
    end else for(integer lcount = 0; lcount < 1079539; lcount++) begin
        @(negedge i_clock) begin
            if($fscanf(stim_fid, "%b", iq_data) != 1) begin
                $display("Failed to read line in stimulus file.");
                glbl_err_count++;
            end
            i_inph = iq_data[15:0];
            i_quad = iq_data[31:16];
            i_valid = 1'b1;
            #10;
        end
    end
    if (stim_fid) begin
        $fclose(stim_fid);
    end
    stim_fid = 0;
    i_valid = 1'b0;
    #2000;
    if (run_count != 3449) begin // Note: 1079539/313 = 3449 + 2/313
        $display("Error: Test 6 failed! Expected 4000 samples at output but received %d.", run_count);
        glbl_err_count++;
    end
    // Test the passband ripple is less than 0.5 dB
    passband_mean = 0.0;
    for (integer fcount = 0; fcount < freq_count; fcount++) begin
        passband_mean = passband_mean + frequencies[fcount];
    end
    passband_mean = passband_mean / $itor(freq_count);
    for (integer fcount = 0; fcount < freq_count; fcount++) begin
        if (frequencies[fcount] > passband_mean) begin
            if (20*$log10((frequencies[fcount] - passband_mean)) > 0.5) begin
                $display("Error, ripple in passband exceeds 0.5 dB!");
                glbl_err_count++;
            end
        end else if (frequencies[fcount] < passband_mean) begin
            if (20*$log10((passband_mean - frequencies[fcount])) > 0.5) begin
                $display("Error, ripple in passband exceeds 0.5 dB!");
                glbl_err_count++;
            end
        end
    end
    #100;
    $display("Test 6 Done!");

    // Finished
    #10000;
    glbl_err_count = glbl_err_count + local_err_count;
    #100;
    if (glbl_err_count == 0) begin
        $display("<<TB_SUCCESS>>");
    end else begin
        $display("Error count = %d", glbl_err_count);
    end
    $display("Simulation done!");
    $finish();

end

// integer fid3;
// integer fid4;
// integer fid5;

// initial begin
//     fid3 = $fopen("test3.txt", "w+");
//     fid4 = $fopen("test4.txt", "w+");
//     fid5 = $fopen("test5.txt", "w+");
// end

// final begin
//     $fclose(fid3);
//     $fclose(fid4);
//     $fclose(fid5);
// end

// Tests the output sequence to make sure it matches the input
real last_frequency;
real magnitude;
real phase;
real inph;
real quad;
real last_inph;
real last_quad;
always @(posedge i_clock) begin: seq_check
    if (i_reset == 1'b1) begin
        last_frequency <= -100.0;
        run_count <= 0;
        freq_count <= 0;
    end else begin
        // Track number of outputs received
        if (o_valid == 1'b1) begin
            run_count <= run_count + 1;
            if (test_number == 2) begin
                last_inph = inph;
                last_quad = quad;
                inph = $signed(o_inph);
                quad = $signed(o_quad);
                magnitude = $sqrt(inph * inph + quad * quad);
                if ((run_count >= 313*1000) && (run_count < 313*3000)) begin
                    // Make sure that something is output (magnitude test)
                    if (magnitude < (1 << 12)) begin
                        $display("Error: Output amplitude is low compared to input.");
                        local_err_count <= local_err_count + 1;
                    end
                    // Verify that the operating frequency is correct
                    phase = $atan2(
                        inph * last_inph + quad * last_quad,
                        quad * last_inph - inph * last_quad);
                    if ((phase - 2 * PI_VALUE * f1 > 0.00001) || (phase - 2 * PI_VALUE * f1 < -0.00001)) begin
                        $display("Error: The output frequency is %f while the input is %f (units of normalized Hz).", phase / (2.0 * PI_VALUE), f1);
                        local_err_count <= local_err_count + 1;
                    end
                end
            end
            if (test_number == 3) begin
                //$fwrite(fid3,"%d, %d\n", $signed(o_inph), $signed(o_quad));
                last_inph = inph;
                last_quad = quad;
                inph = $signed(o_inph);
                quad = $signed(o_quad);
                magnitude = $sqrt(inph * inph + quad * quad);
                if ((run_count >= 313*1000) && (run_count < 313*3000)) begin
                    // Make sure that the signal is attenuated (magnitude test)
                    if (magnitude > (1 << 4)) begin
                        $display("Error: Output amplitude is high compared to input.");
                        local_err_count <= local_err_count + 1;
                    end
                end
            end
            if (test_number == 4) begin
                //$fwrite(fid4,"%d, %d\n", $signed(o_inph), $signed(o_quad));
                inph = $signed(o_inph);
                quad = $signed(o_quad);
                if ((run_count >= 313*1000) && (run_count < 313*3000)) begin
                    magnitude = magnitude + $sqrt(inph * inph + quad * quad);
                end else if (run_count == 313*3000) begin
                    // Make sure that the signal is attenuated (magnitude test)
                    if (magnitude < 100) begin
                        $display("Error: Output amplitude is low compared to input.");
                        local_err_count <= local_err_count + 1;
                    end
                end
            end
            if (test_number == 5) begin
                if ((samp_num > 3000*313) && (last_frequency != fc)) begin
                    inph = $signed(o_inph);
                    quad = $signed(o_quad);
                    magnitude = $sqrt(inph * inph + quad * quad);
                    phase = $atan2(quad, inph);
                    //$fwrite(fid5,"%f, %f, %f\n", fc, magnitude, phase);
                    // Store samples for testing at the end of this phase
                    if ((fc > -0.25/313.0) && (fc < 0.25/313.0)) begin
                        frequencies[freq_count] <= magnitude;
                        freq_count <= freq_count + 1;
                    end

                    last_frequency <= fc;
                end
            end
        end
    end
end

endmodule: tb_cic_decimator

`default_nettype wire
