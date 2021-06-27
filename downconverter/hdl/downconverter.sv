`timescale 10ps / 10ps

`default_nettype none

module downconverter #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_inph_delay_data,
    input  wire logic             i_valid,
    output      logic [WIDTH-1:0] o_inph_data,
    output      logic [WIDTH-1:0] o_quad_data,
    output      logic             o_valid,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);




// Pipeline Stage 0
logic signed [36-1:0] cosine_reg_n1;
logic signed [36-1:0] sine_reg_n1;
logic signed [36-1:0] cosine_delay_reg_n1;
logic signed [36-1:0] sine_delay_reg_n1;

fixed_ddsx2 ddc_ddsx2_inst (
    .o_cosine_data      (cosine_reg_n1      ),
    .o_sine_data        (sine_reg_n1        ),
    .o_cosine_delay_data(cosine_delay_reg_n1),
    .o_sine_delay_data  (sine_delay_reg_n1  ),
    .i_ready            (i_valid            ),
    .i_clock            (i_clock            ),
    .i_reset            (i_reset            ));

// Pipeline Stage 0
logic signed [WIDTH-1:0] inph_data_reg0;
logic signed [WIDTH-1:0] inph_data_delay_reg0;
logic signed [36-1:0] cosine_reg0;
logic signed [36-1:0] sine_reg0;
logic signed [36-1:0] cosine_delay_reg0;
logic signed [36-1:0] sine_delay_reg0;
logic                 valid_reg0;
always_ff @(posedge i_clock) begin
    inph_data_reg0 <= i_inph_data;
    inph_data_delay_reg0 <= i_inph_delay_data;
    cosine_reg0 <= cosine_reg_n1;
    sine_reg0 <= sine_reg_n1;
    cosine_delay_reg0 <= cosine_delay_reg_n1;
    sine_delay_reg0 <= sine_delay_reg_n1;
    valid_reg0 <= i_valid;
end

// Pipeline Stages 1, 2, and 3
logic signed [36+WIDTH-1:0] inph_data_reg1;
logic signed [36+WIDTH-1:0] quad_data_reg1;
logic signed [36+WIDTH-1:0] inph_data_delay_reg1;
logic signed [36+WIDTH-1:0] quad_data_delay_reg1;
logic                       valid_reg1;

logic signed [WIDTH:0] inph_data_reg2;
logic signed [WIDTH:0] quad_data_reg2;
logic signed [WIDTH:0] inph_data_delay_reg2;
logic signed [WIDTH:0] quad_data_delay_reg2;
logic                  valid_reg2;

logic signed [WIDTH-1:0] inph_data_reg3;
logic signed [WIDTH-1:0] quad_data_reg3;
logic signed [WIDTH-1:0] inph_data_delay_reg3;
logic signed [WIDTH-1:0] quad_data_delay_reg3;
logic                    valid_reg3;

integer f0;
integer f2;
integer f1;
integer f3;
integer f4;
initial begin



    f0 = $fopen("o_inph_data.csv","w");
    f2 = $fopen("o_inph_data_delay.csv","w");

    f1 = $fopen("cos_sin.csv","w");

    f3 = $fopen("cos_sin_delay.csv","w");
    f4 = $fopen("output.csv","w");



end

always_ff @(posedge i_clock) begin

    if (i_valid) begin
        $fwrite(f0,"%d, %d\n",$signed(quad_data_reg1), $signed(inph_data_reg1));
        $fwrite(f2,"%d, %d\n",$signed(quad_data_delay_reg1), $signed(inph_data_delay_reg1));
    end

    if (i_valid) begin
        $fwrite(f1,"%d, %d\n",$signed(cosine_reg0), $signed(sine_reg0));
        $fwrite(f3,"%d, %d\n",$signed(cosine_delay_reg0), $signed(sine_delay_reg0));
    end

    if (o_valid) begin
        $fwrite (f4, "%d, %d\n", $signed (o_quad_data), $signed (o_inph_data));
    end

end


always_ff @(posedge i_clock) begin
    // Pipeline Stage 1
    inph_data_reg1 <= $signed(inph_data_reg0) * $signed(cosine_reg0);
    quad_data_reg1 <= $signed(inph_data_reg0) * $signed(sine_reg0);
    inph_data_delay_reg1 <= $signed(inph_data_delay_reg0) * $signed(cosine_delay_reg0);
    quad_data_delay_reg1 <= $signed(inph_data_delay_reg0) * $signed(sine_delay_reg0);
    valid_reg1 <= valid_reg0;

    // Pipeline Stage 2 - Intentional gain of 2 added here to account for single-ended receive
    inph_data_reg2 <= ({ inph_data_reg1[36+WIDTH-1], inph_data_reg1[36+WIDTH-1:34] } + 1'b1) >> 1;
    quad_data_reg2 <= ({ quad_data_reg1[36+WIDTH-1], quad_data_reg1[36+WIDTH-1:34] } + 1'b1) >> 1;
    inph_data_delay_reg2 <= ({ inph_data_delay_reg1[36+WIDTH-1], inph_data_delay_reg1[36+WIDTH-1:34] } + 1'b1) >> 1;
    quad_data_delay_reg2 <= ({ quad_data_delay_reg1[36+WIDTH-1], quad_data_delay_reg1[36+WIDTH-1:34] } + 1'b1) >> 1;
    valid_reg2 <= valid_reg1;

    // Pipeline Stage 3
    if (inph_data_reg2[WIDTH] != inph_data_reg2[WIDTH-1]) begin // saturating
        if (inph_data_reg2[WIDTH] == 1'b1) begin
            inph_data_reg3 <= { 1'b1, { (WIDTH-1){1'b0} } };
        end else begin
            inph_data_reg3 <= { 1'b0, { (WIDTH-1){1'b1} } };
        end
    end else begin
        inph_data_reg3 <= inph_data_reg2;
    end
    if (quad_data_reg2[WIDTH] != quad_data_reg2[WIDTH-1]) begin
        if (quad_data_reg2[WIDTH] == 1'b1) begin
            quad_data_reg3 <= { 1'b0, { (WIDTH-1){1'b1} } };
        end else begin
            quad_data_reg3 <= { 1'b1, { (WIDTH-1){1'b0} } };
        end
    end else begin
        quad_data_reg3 <= -quad_data_reg2;
    end
    if (inph_data_delay_reg2[WIDTH] != inph_data_delay_reg2[WIDTH-1]) begin
        if (inph_data_delay_reg2[WIDTH] == 1'b1) begin
            inph_data_delay_reg3 <= { 1'b1, { (WIDTH-1){1'b0} } };
        end else begin
            inph_data_delay_reg3 <= { 1'b0, { (WIDTH-1){1'b1} } };
        end
    end else begin
        inph_data_delay_reg3 <= inph_data_delay_reg2;
    end
    if (quad_data_delay_reg2[WIDTH] != quad_data_delay_reg2[WIDTH-1]) begin
        if (quad_data_delay_reg2[WIDTH] == 1'b1) begin
            quad_data_delay_reg3 <= { 1'b0, { (WIDTH-1){1'b1} } };
        end else begin
            quad_data_delay_reg3 <= { 1'b1, { (WIDTH-1){1'b0} } };
        end
    end else begin
        quad_data_delay_reg3 <= -quad_data_delay_reg2;
    end
    valid_reg3 <= valid_reg2;
end

ddc_hb_cascade #(
    .WIDTH(WIDTH))
ddc_hb_cascade_inst (
    .i_inph_data      (inph_data_reg3      ),
    .i_quad_data      (quad_data_reg3      ),
    .i_inph_delay_data(inph_data_delay_reg3),
    .i_quad_delay_data(quad_data_delay_reg3),
    .i_valid          (valid_reg3          ),
    .o_inph_data      (o_inph_data         ),
    .o_quad_data      (o_quad_data         ),
    .o_valid          (o_valid             ),
    .i_clock          (i_clock             ),
    .i_reset          (i_reset             ));

endmodule: downconverter

`default_nettype wire
