module generic_dpram #(
    parameter aw = 5,
    parameter dw = 16
) (
    input  logic          rclk,
    input  logic          rce,
    input  logic [aw-1:0] raddr,
    output logic [dw-1:0] dout,

    input  logic          wclk,
    input  logic          wce,
    input  logic          we,
    input  logic [aw-1:0] waddr,
    input  logic [dw-1:0] di
);

    logic [dw-1:0] mem [0:(1 << aw)-1];
    logic [aw-1:0] read_addr;

    always_ff @(posedge rclk) begin
        if (rce) begin
            read_addr <= raddr;
        end
    end

    always_ff @(posedge wclk) begin
        if (wce && we) begin
            mem[waddr] <= di;
        end
    end

    assign dout = mem[read_addr];

endmodule
