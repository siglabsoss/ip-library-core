`timescale 10ps / 10ps

`default_nettype none

module fixed_ddsx2 (
    output      logic [36-1:0] o_cosine_data,
    output      logic [36-1:0] o_sine_data,
    output      logic [36-1:0] o_cosine_delay_data,
    output      logic [36-1:0] o_sine_delay_data,
    input  wire logic          i_ready,
    input  wire logic          i_clock,
    input  wire logic          i_reset
);

// Phase increment
localparam integer LUT_PERIOD = 100;
localparam integer PHASE_BITS = 7;
logic [PHASE_BITS-1:0] phase_accum = { PHASE_BITS{1'b0} };
logic [PHASE_BITS-1:0] phase_accum_delay = { { (PHASE_BITS-1){1'b0} }, 1'b1 };

always_ff @ (posedge i_clock) begin
    // Increment phase whenever an output is requested
    if (i_reset == 1'b1) begin
        phase_accum <= { PHASE_BITS{1'b0} };
        phase_accum_delay <= { { (PHASE_BITS-1){1'b0} }, 1'b1 };
    end else if (i_ready == 1'b1) begin
        if (phase_accum == LUT_PERIOD-2) begin
            phase_accum <= { PHASE_BITS{1'b0} };
        end else begin
            phase_accum <= phase_accum + 2;
        end
        if (phase_accum_delay == LUT_PERIOD-1) begin
            phase_accum_delay <= { { (PHASE_BITS-1){1'b0} }, 1'b1 };
        end else begin
            phase_accum_delay <= phase_accum_delay + 2;
        end
    end
end

// Sine/Cosine Look Up Table
localparam integer WIDTH = 36;

logic        [2*WIDTH-1:0]    sincos_reg0;
logic        [2*WIDTH-1:0]    sincos_delay_reg0;
logic signed [WIDTH-1:0]      cosine_reg0;
logic signed [WIDTH-1:0]      sine_reg0;
logic signed [WIDTH-1:0]      cosine_delay_reg0;
logic signed [WIDTH-1:0]      sine_delay_reg0;

// Pipeline Stage 0
// logic [2*WIDTH-1:0] sincos_lut_ram [0:(1 << $clog2(PHASE_BITS))-1];
logic [2*WIDTH-1:0] sincos_lut_ram [0:100-1];
initial begin
`ifdef DDC_SINCOS_PATH
    $readmemb(`DDC_SINCOS_PATH, sincos_lut_ram);
`else
    $readmemb("ddc_sincos.mif", sincos_lut_ram);
`endif
end
always_ff @ (posedge i_clock) begin
    if (i_ready == 1'b1) begin
        sincos_reg0 <= sincos_lut_ram[phase_accum];
        sincos_delay_reg0 <= sincos_lut_ram[phase_accum_delay];
    end
end

assign sine_reg0 = sincos_reg0[2*WIDTH-1:WIDTH];
assign cosine_reg0 = sincos_reg0[WIDTH-1:0];
assign sine_delay_reg0 = sincos_delay_reg0[2*WIDTH-1:WIDTH];
assign cosine_delay_reg0 = sincos_delay_reg0[WIDTH-1:0];

// Perform Correction
logic signed [WIDTH-1:0] cosine_reg1;
logic signed [WIDTH-1:0] sine_reg1;
logic signed [WIDTH-1:0] cosine_delay_reg1;
logic signed [WIDTH-1:0] sine_delay_reg1;

logic signed [WIDTH-1:0] cosine_reg2;
logic signed [WIDTH-1:0] sine_reg2;
logic signed [WIDTH-1:0] cosine_delay_reg2;
logic signed [WIDTH-1:0] sine_delay_reg2;

always_ff @ (posedge i_clock) begin
    if (i_ready == 1'b1) begin
        // Pipeline Stage 1
        cosine_reg1 <= cosine_reg0;
        sine_reg1 <= sine_reg0;

        cosine_delay_reg1 <= cosine_delay_reg0;
        sine_delay_reg1 <= sine_delay_reg0;

        // Pipeline Stage 2 - negate if needed
        cosine_reg2 <= cosine_reg1;
        sine_reg2 <= sine_reg1;
        cosine_delay_reg2 <= cosine_delay_reg1;
        sine_delay_reg2 <= sine_delay_reg1;

        // Pipeline Stage 3
        o_cosine_data <= cosine_reg2;
        o_sine_data <= sine_reg2;
        o_cosine_delay_data <= cosine_delay_reg2;
        o_sine_delay_data <= sine_delay_reg2;
    end
end

endmodule: fixed_ddsx2

`default_nettype wire
