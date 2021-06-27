`timescale 10ps / 10ps

`default_nettype none

module upconverter #(
    parameter integer WIDTH       = 16,
    parameter bit     INTERP_ONLY = 1'b0 // set to 1 to bypass the DDS and just perform interpolation
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_quad_data,
    output wire logic             o_ready,
    output wire logic [WIDTH-1:0] o_inph_data,
    output wire logic [WIDTH-1:0] o_quad_data,
    input  wire logic             i_ready,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

logic signed [WIDTH-1:0] cascade_inph_reg_n1;
logic signed [WIDTH-1:0] cascade_quad_reg_n1;

duc_hb_cascade #(
    .WIDTH(WIDTH))
duc_hb_cascade_inst (
    .i_inph_data(i_inph_data        ),
    .i_quad_data(i_quad_data        ),
    .o_ready    (o_ready            ),
    .o_inph_data(cascade_inph_reg_n1),
    .o_quad_data(cascade_quad_reg_n1),
    .i_ready    (i_ready            ),
    .i_clock    (i_clock            ),
    .i_reset    (i_reset            ));

// duc_hb_interp_fir_h0 #(.WIDTH(WIDTH))
// duc_hb_interp_fir_h0_inst (
//     .i_inph_data      (i_inph_data        ),
//     .i_quad_data      (i_quad_data        ),
//     .o_ready          (o_ready            ),
//     .o_inph_data      (cascade_inph_reg_n1),
//     .o_quad_data      (cascade_quad_reg_n1),
//     .i_ready          (i_ready            ),
//     .i_clock          (i_clock            ),
//     .i_reset          (i_reset            ));

generate

    if (INTERP_ONLY == 1'b0) begin

        // Pipeline Stage 0
        logic signed [36-1:0] cosine_reg_n1;
        logic signed [36-1:0] sine_reg_n1;

        duc_fixed_dds duc_fixed_dds_inst (
            .o_cosine_data(cosine_reg_n1),
            .o_sine_data  (sine_reg_n1  ),
            .i_ready      (i_ready      ),
            .i_clock      (i_clock      ),
            .i_reset      (i_reset      ));

        // Pipeline Stage 0
        logic signed [WIDTH-1:0] inph_data_reg0;
        logic signed [WIDTH-1:0] quad_data_reg0;
        logic signed [36-1:0] cosine_reg0;
        logic signed [36-1:0] sine_reg0;
        always_ff @(posedge i_clock) begin
            if (i_ready == 1'b1) begin
                inph_data_reg0 <= cascade_inph_reg_n1;
                quad_data_reg0 <= cascade_quad_reg_n1;
                cosine_reg0 <= cosine_reg_n1;
                sine_reg0 <= sine_reg_n1;
                // cosine_reg0 <= {1'b0, {35{1'b1}}};
                // sine_reg0 <= '0;
            end
        end

        // Pipeline Stages 1, 2, and 3
        logic signed [36+WIDTH-1:0] inph_inph_data_reg1;
        logic signed [36+WIDTH-1:0] inph_quad_data_reg1;
        logic signed [36+WIDTH-1:0] quad_inph_data_reg1;
        logic signed [36+WIDTH-1:0] quad_quad_data_reg1;

        logic signed [36+WIDTH:0] inph_data_reg2;
        logic signed [36+WIDTH:0] quad_data_reg2;

        logic signed [WIDTH:0] inph_data_reg3;
        logic signed [WIDTH:0] quad_data_reg3;

        logic signed [WIDTH-1:0] inph_data_reg4;
        logic signed [WIDTH-1:0] quad_data_reg4;

        always_ff @(posedge i_clock) begin
            if (i_ready == 1'b1) begin
                // Pipeline Stage 1
                inph_inph_data_reg1 <= $signed(inph_data_reg0) * $signed(cosine_reg0);
                inph_quad_data_reg1 <= $signed(inph_data_reg0) * $signed(sine_reg0);
                quad_inph_data_reg1 <= $signed(quad_data_reg0) * $signed(cosine_reg0);
                quad_quad_data_reg1 <= $signed(quad_data_reg0) * $signed(sine_reg0);

                // Pipeline Stage 2
                inph_data_reg2 <= { inph_inph_data_reg1[36+WIDTH-1], inph_inph_data_reg1 }
                    + { quad_quad_data_reg1[36+WIDTH-1], quad_quad_data_reg1 };
                quad_data_reg2 <= { quad_inph_data_reg1[36+WIDTH-1], quad_inph_data_reg1 }
                    - { inph_quad_data_reg1[36+WIDTH-1], inph_quad_data_reg1 };

                // Pipeline Stage 2 - Intentional gain of 2 added here to account for single-ended transmit
                inph_data_reg3 <= (inph_data_reg2[36+WIDTH:34] + 1'b1) <<< 2;
                quad_data_reg3 <= (quad_data_reg2[36+WIDTH:34] + 1'b1) <<< 2;

                // Pipeline Stage 3
                if (inph_data_reg3[WIDTH] != inph_data_reg3[WIDTH-1]) begin
                    if (inph_data_reg3[WIDTH] == 1'b1) begin
                        inph_data_reg4 <= { 1'b1, { (WIDTH-1){1'b0} } };
                    end else begin
                        inph_data_reg4 <= { 1'b0, { (WIDTH-1){1'b1} } };
                    end
                end else begin
                    inph_data_reg4 <= inph_data_reg3;
                end
                if (quad_data_reg3[WIDTH] != quad_data_reg3[WIDTH-1]) begin
                    if (quad_data_reg3[WIDTH] == 1'b1) begin
                        quad_data_reg4 <= { 1'b0, { (WIDTH-1){1'b1} } };
                    end else begin
                        quad_data_reg4 <= { 1'b1, { (WIDTH-1){1'b0} } };
                    end
                end else begin
                    quad_data_reg4 <= quad_data_reg3;
                end
            end
        end

        assign o_inph_data = inph_data_reg4;
        assign o_quad_data = quad_data_reg4;

    end else begin

        assign o_inph_data = cascade_inph_reg_n1;
        assign o_quad_data = cascade_quad_reg_n1;

    end
endgenerate

endmodule: upconverter

`default_nettype wire
