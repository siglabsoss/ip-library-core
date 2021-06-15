//
// Template Test Bench Module
//

`timescale 10ps / 10ps

`default_nettype none

module tb_nco;

localparam integer PWIDTH = 23;
localparam integer SWIDTH = 36;

logic signed [PWIDTH-1:0] i_phase;
logic                     i_valid;
logic signed [SWIDTH-1:0] o_cosine;
logic signed [SWIDTH-1:0] o_sine;
logic                     o_valid;
logic                     i_clock;
logic                     i_enable;
logic                     i_reset;

nco #(.PWIDTH(PWIDTH), .SWIDTH(SWIDTH)) uut (.*);

always begin: clock_gen
    #5 i_clock = 1'b1;
    #5 i_clock = 1'b0;
end

// debug variable declarations
logic [31:0] loop_index = 0;
logic [31:0] glbl_err_count = 0;
logic [31:0] local_err_count = 0;
logic [31:0] increment_value = 1;
logic [31:0] run_count = 0;

task reset_all;
    i_reset = 1'b1;
    i_phase = '0;
    i_valid = 1'b0;
    #1000;
    @(negedge i_clock) i_reset = 1'b0;
endtask: reset_all

initial begin: stimulus
    i_reset = 1'b1;
    i_enable = 1'b1;
    #1000;
    reset_all();

    // Test 1: No data in = no data out.
    $display("Test 1 Started!");
    increment_value = 1;
    reset_all();
    #1000;
    if (run_count > 0) begin
        $display("Error: Test 1 failed! No data input, but data output received.");
        glbl_err_count++;
    end
    #100;
    $display("Test 1 Done!");

    // Test 2: Basic LUT values out...
    $display("Test 2 Started!");
    increment_value = 1 << 18;
    reset_all();
    for (int i = 0; i < 1000; i++) begin
        i_phase = i_phase + increment_value;
        i_valid = 1'b1;
        #10;
    end
    i_phase = 0;
    i_valid = 1'b0;
    #10000;
    if (run_count != 1000) begin
        $display("Error: Test 2 failed! Expected 1000 outputs, but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 2 Done!");

    // Test 3: Basic Interpolation values out...
    $display("Test 3 Started!");
    increment_value = (1 << 10);
    reset_all();
    for (int i = 0; i < 10000; i++) begin
        i_phase = i_phase + increment_value;
        i_valid = 1'b1;
        #10;
    end
    i_phase = 0;
    i_valid = 1'b0;
    #10000;
    if (run_count != 10000) begin
        $display("Error: Test 3 failed! Expected 10000 outputs, but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 3 Done!");

    // Test 4: All phase values...
    $display("Test 4 Started!");
    increment_value = 1;
    reset_all();
    for (int i = 0; i < 1000000; i++) begin
        i_phase = i_phase + increment_value;
        i_valid = 1'b1;
        #10;
    end
    i_phase = 0;
    i_valid = 1'b0;
    #10000;
    if (run_count != 1000000) begin
        $display("Error: Test 4 failed! Expected 100000 outputs, but received %d.", run_count);
        glbl_err_count++;
    end
    #100;
    $display("Test 4 Done!");

    // Finished
    #10000;
    glbl_err_count = glbl_err_count + local_err_count;
    $display("Simulation done!");
    if (glbl_err_count > 0) begin
        $display("Detected %d errors...", glbl_err_count);
    end else begin
        $display("<<TB_SUCCESS>>");
    end
    $finish();

end

// Tests the output sequence to make sure it matches the input
logic [31:0] stored_value = 0;
logic        increment_i_in_data = 1'b0;

always @(posedge i_clock) begin
    if (i_reset == 1'b1) begin
        run_count <= '0;
    end else begin
        if (o_valid == 1'b1) begin
            run_count <= run_count + 1;
        end
    end
end

endmodule: tb_nco

`default_nettype wire
