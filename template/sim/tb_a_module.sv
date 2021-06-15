//
// Template Test Bench Module
//

`timescale 10ps / 10ps

`default_nettype none

module tb_a_module;

localparam integer WIDTH = 16;

// Upstream signaling
logic [WIDTH-1:0]    i_in_data;
logic                i_in_valid;
logic                o_in_ready;
// Downstream signaling
logic [WIDTH-1:0]    o_out_data;
logic                o_out_valid;
logic                i_out_ready;
// Control signaling
logic                i_clock;
logic                i_enable;
logic                i_reset;

a_module #(.WIDTH(WIDTH)) uut (.*);

always begin: clock_gen
    #5 i_clock = 1'b1;
    #5 i_clock = 1'b0;
end

// debug variable declarations
logic [31:0] loop_index = 0;
logic [31:0] glbl_err_count = 0;
logic [31:0] increment_value = 1;
logic [31:0] run_count = 0;

task reset_all;
    i_reset = 1'b1;
    i_in_valid = 1'b0;
    i_out_ready = 1'b0;
    #1000;
    @(negedge i_clock) i_reset = 1'b0;
endtask: reset_all

initial begin: stimulus
    i_reset = 1'b1;
    #1000;
    reset_all();

    // Test 1: No data in = no data out.
    $display("Test 1 Started!");
    increment_value = 1;
    reset_all();
    #1000;
    if (run_count > 0) begin
        $display("Error: est 1 failed! No data input, but data output received.");
        glbl_err_count++;
    end
    #100;
    $display("Test 1 Done!");

    // Stimulus goes here...

    // Finished
    #10000;
    $display("Simulation done!");
    $finish();

end

// Tests the output sequence to make sure it matches the input
logic [31:0] local_err_count = 0;
logic [31:0] stored_value = 0;
logic        increment_i_in_data = 1'b0;
always @(posedge i_clock) begin: seq_check
    if (i_reset == 1'b1) begin
        stored_value <= 0;
        run_count <= 0;
        increment_i_in_data <= 1'b0;
    end else begin
        // Flag input counter to be incremented
        increment_i_in_data <= i_in_valid & o_in_ready;

        // Validate incrementing output sequence
        if ((o_out_valid & i_out_ready) == 1'b1) begin
            if (o_out_data != stored_value) begin
                $display("Error: Output of %d expected, but received %d.", stored_value, o_out_data);
                local_err_count++;
            end
            //$display("    %d", uut.out_data_reg);

            // Increment value for next time
            run_count <= run_count + 1;
            stored_value <= stored_value + increment_value;
        end
    end
end

// Increment input counter
always @(negedge i_clock) begin: incrementer
    if (i_reset == 1'b1) begin
        i_in_data <= 0;
    end else if (increment_i_in_data == 1'b1) begin
        i_in_data <= i_in_data + increment_value;
    end
end

// Do this in your test bench
initial begin
    $dumpfile("skid.vcd");
    $dumpvars;
end

endmodule: tb_a_module

`default_nettype wire
