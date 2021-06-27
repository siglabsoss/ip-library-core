`timescale 10ps / 10ps

`default_nettype none

module ddc_hb_cascade #(
    parameter integer WIDTH = 16
) (
    input  wire logic [WIDTH-1:0] i_inph_data,
    input  wire logic [WIDTH-1:0] i_quad_data,
    input  wire logic [WIDTH-1:0] i_inph_delay_data,
    input  wire logic [WIDTH-1:0] i_quad_delay_data,
    input  wire logic             i_valid,
    output      logic [WIDTH-1:0] o_inph_data,
    output      logic [WIDTH-1:0] o_quad_data,
    output      logic             o_valid,
    input  wire logic             i_clock,
    input  wire logic             i_reset
);

logic [WIDTH-1:0] h0_inph_data;
logic [WIDTH-1:0] h0_quad_data;
logic             h0_valid;

ddc_hb_decim_firx2_h0 #(.WIDTH(WIDTH))
hb_decim_firx2_h0_inst (
    .i_inph_data      (i_inph_data      ),
    .i_quad_data      (i_quad_data      ),
    .i_inph_delay_data(i_inph_delay_data),
    .i_quad_delay_data(i_quad_delay_data),
    .i_valid          (i_valid          ),
    .o_inph_data      (h0_inph_data     ),
    .o_quad_data      (h0_quad_data     ),
    .o_valid          (h0_valid         ),
    .i_clock          (i_clock          ),
    .i_reset          (i_reset          ));

integer f0;
initial begin
        
    
        
    f0 = $fopen("h0_data.csv","w");
    
        
end
    
always_ff @(posedge i_clock) begin
        
    if (h0_valid) begin
        $fwrite(f0,"%d, %d\n",$signed(h0_quad_data), $signed(h0_inph_data));
    end
    
end
logic [WIDTH-1:0] h1_inph_data;
logic [WIDTH-1:0] h1_quad_data;
logic             h1_valid;

ddc_hb_decim_fir_h1 #(.WIDTH(WIDTH))
hb_decim_fir_h1_inst (
    .i_inph_data      (h0_inph_data     ),
    .i_quad_data      (h0_quad_data     ),
    .i_valid          (h0_valid         ),
    .o_inph_data      (h1_inph_data     ),
    .o_quad_data      (h1_quad_data     ),
    .o_valid          (h1_valid         ),
    .i_clock          (i_clock          ),
    .i_reset          (i_reset          ));

ddc_hb_decim_fir_h2 #(.WIDTH(WIDTH))
hb_decim_fir_h2_inst (
    .i_inph_data      (h1_inph_data     ),
    .i_quad_data      (h1_quad_data     ),
    .i_valid          (h1_valid         ),
    .o_inph_data      (o_inph_data      ),
    .o_quad_data      (o_quad_data      ),
    .o_valid          (o_valid          ),
    .i_clock          (i_clock          ),
    .i_reset          (i_reset          ));

endmodule: ddc_hb_cascade

`default_nettype wire
