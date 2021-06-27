`timescale 10ps / 10ps

`default_nettype none

module rx_chmod_dds (
    input  wire logic [12-1:0] i_phase_inc,
    input  wire logic          i_phase_inc_valid,
    output      logic [18-1:0] o_cosine_data,
    output      logic [18-1:0] o_sine_data,
    input       logic          i_ready,
    input  wire logic          i_clock,
    input  wire logic          i_reset
);

// Phase increment
logic [12-1:0] phase_inc_reg;
logic [12-1:0] phase_accum;

always_ff @ (posedge i_clock) begin
    // Read input phase increment
    if (i_phase_inc_valid == 1'b1) begin
        phase_inc_reg <= i_phase_inc;
    end
    // Increment phase whenever an output is requested
    if (i_reset == 1'b1) begin
        phase_accum <= '0;
    end else if (i_ready == 1'b1) begin
        phase_accum <= phase_accum + phase_inc_reg;
    end
end

// Sine/Cosine Look Up Table
localparam integer WIDTH = 18;

logic signed [WIDTH-1:0] cosine_reg0 /* synthesis syn_ramstyle="block_ram" */;
logic signed [WIDTH-1:0] sine_reg0 /* synthesis syn_ramstyle="block_ram" */;

// Pipeline Stage 0
always_ff @ (posedge i_clock) begin
    if (i_ready == 1'b1) begin
        // Perform table look up
        case (phase_accum)
        0: begin
            cosine_reg0 <= 18'sb011111111111111111;
            sine_reg0   <= 18'sb000000000000000000;
        end
        1: begin
            cosine_reg0 <= 18'sb011111111111111111;
            sine_reg0   <= 18'sb000000000011001001;
        end
        2: begin
            cosine_reg0 <= 18'sb011111111111111110;
            sine_reg0   <= 18'sb000000000110010010;
        end
        3: begin
            cosine_reg0 <= 18'sb011111111111111110;
            sine_reg0   <= 18'sb000000001001011011;
        end
        4: begin
            cosine_reg0 <= 18'sb011111111111111101;
            sine_reg0   <= 18'sb000000001100100100;
        end
        5: begin
            cosine_reg0 <= 18'sb011111111111111011;
            sine_reg0   <= 18'sb000000001111101101;
        end
        6: begin
            cosine_reg0 <= 18'sb011111111111111001;
            sine_reg0   <= 18'sb000000010010110110;
        end
        7: begin
            cosine_reg0 <= 18'sb011111111111110111;
            sine_reg0   <= 18'sb000000010101111111;
        end
        8: begin
            cosine_reg0 <= 18'sb011111111111110101;
            sine_reg0   <= 18'sb000000011001001000;
        end
        9: begin
            cosine_reg0 <= 18'sb011111111111110011;
            sine_reg0   <= 18'sb000000011100010001;
        end
        10: begin
            cosine_reg0 <= 18'sb011111111111110000;
            sine_reg0   <= 18'sb000000011111011011;
        end
        11: begin
            cosine_reg0 <= 18'sb011111111111101100;
            sine_reg0   <= 18'sb000000100010100100;
        end
        12: begin
            cosine_reg0 <= 18'sb011111111111101001;
            sine_reg0   <= 18'sb000000100101101101;
        end
        13: begin
            cosine_reg0 <= 18'sb011111111111100101;
            sine_reg0   <= 18'sb000000101000110110;
        end
        14: begin
            cosine_reg0 <= 18'sb011111111111100001;
            sine_reg0   <= 18'sb000000101011111111;
        end
        15: begin
            cosine_reg0 <= 18'sb011111111111011100;
            sine_reg0   <= 18'sb000000101111001000;
        end
        16: begin
            cosine_reg0 <= 18'sb011111111111011000;
            sine_reg0   <= 18'sb000000110010010001;
        end
        17: begin
            cosine_reg0 <= 18'sb011111111111010010;
            sine_reg0   <= 18'sb000000110101011010;
        end
        18: begin
            cosine_reg0 <= 18'sb011111111111001101;
            sine_reg0   <= 18'sb000000111000100011;
        end
        19: begin
            cosine_reg0 <= 18'sb011111111111000111;
            sine_reg0   <= 18'sb000000111011101100;
        end
        20: begin
            cosine_reg0 <= 18'sb011111111111000001;
            sine_reg0   <= 18'sb000000111110110101;
        end
        21: begin
            cosine_reg0 <= 18'sb011111111110111011;
            sine_reg0   <= 18'sb000001000001111110;
        end
        22: begin
            cosine_reg0 <= 18'sb011111111110110100;
            sine_reg0   <= 18'sb000001000101000110;
        end
        23: begin
            cosine_reg0 <= 18'sb011111111110101101;
            sine_reg0   <= 18'sb000001001000001111;
        end
        24: begin
            cosine_reg0 <= 18'sb011111111110100110;
            sine_reg0   <= 18'sb000001001011011000;
        end
        25: begin
            cosine_reg0 <= 18'sb011111111110011111;
            sine_reg0   <= 18'sb000001001110100001;
        end
        26: begin
            cosine_reg0 <= 18'sb011111111110010111;
            sine_reg0   <= 18'sb000001010001101010;
        end
        27: begin
            cosine_reg0 <= 18'sb011111111110001111;
            sine_reg0   <= 18'sb000001010100110011;
        end
        28: begin
            cosine_reg0 <= 18'sb011111111110000110;
            sine_reg0   <= 18'sb000001010111111100;
        end
        29: begin
            cosine_reg0 <= 18'sb011111111101111101;
            sine_reg0   <= 18'sb000001011011000101;
        end
        30: begin
            cosine_reg0 <= 18'sb011111111101110100;
            sine_reg0   <= 18'sb000001011110001110;
        end
        31: begin
            cosine_reg0 <= 18'sb011111111101101011;
            sine_reg0   <= 18'sb000001100001010111;
        end
        32: begin
            cosine_reg0 <= 18'sb011111111101100001;
            sine_reg0   <= 18'sb000001100100011111;
        end
        33: begin
            cosine_reg0 <= 18'sb011111111101010111;
            sine_reg0   <= 18'sb000001100111101000;
        end
        34: begin
            cosine_reg0 <= 18'sb011111111101001101;
            sine_reg0   <= 18'sb000001101010110001;
        end
        35: begin
            cosine_reg0 <= 18'sb011111111101000010;
            sine_reg0   <= 18'sb000001101101111010;
        end
        36: begin
            cosine_reg0 <= 18'sb011111111100110111;
            sine_reg0   <= 18'sb000001110001000010;
        end
        37: begin
            cosine_reg0 <= 18'sb011111111100101100;
            sine_reg0   <= 18'sb000001110100001011;
        end
        38: begin
            cosine_reg0 <= 18'sb011111111100100000;
            sine_reg0   <= 18'sb000001110111010100;
        end
        39: begin
            cosine_reg0 <= 18'sb011111111100010101;
            sine_reg0   <= 18'sb000001111010011101;
        end
        40: begin
            cosine_reg0 <= 18'sb011111111100001000;
            sine_reg0   <= 18'sb000001111101100101;
        end
        41: begin
            cosine_reg0 <= 18'sb011111111011111100;
            sine_reg0   <= 18'sb000010000000101110;
        end
        42: begin
            cosine_reg0 <= 18'sb011111111011101111;
            sine_reg0   <= 18'sb000010000011110111;
        end
        43: begin
            cosine_reg0 <= 18'sb011111111011100010;
            sine_reg0   <= 18'sb000010000110111111;
        end
        44: begin
            cosine_reg0 <= 18'sb011111111011010101;
            sine_reg0   <= 18'sb000010001010001000;
        end
        45: begin
            cosine_reg0 <= 18'sb011111111011000111;
            sine_reg0   <= 18'sb000010001101010001;
        end
        46: begin
            cosine_reg0 <= 18'sb011111111010111001;
            sine_reg0   <= 18'sb000010010000011001;
        end
        47: begin
            cosine_reg0 <= 18'sb011111111010101010;
            sine_reg0   <= 18'sb000010010011100010;
        end
        48: begin
            cosine_reg0 <= 18'sb011111111010011100;
            sine_reg0   <= 18'sb000010010110101010;
        end
        49: begin
            cosine_reg0 <= 18'sb011111111010001101;
            sine_reg0   <= 18'sb000010011001110011;
        end
        50: begin
            cosine_reg0 <= 18'sb011111111001111110;
            sine_reg0   <= 18'sb000010011100111011;
        end
        51: begin
            cosine_reg0 <= 18'sb011111111001101110;
            sine_reg0   <= 18'sb000010100000000100;
        end
        52: begin
            cosine_reg0 <= 18'sb011111111001011110;
            sine_reg0   <= 18'sb000010100011001100;
        end
        53: begin
            cosine_reg0 <= 18'sb011111111001001110;
            sine_reg0   <= 18'sb000010100110010100;
        end
        54: begin
            cosine_reg0 <= 18'sb011111111000111110;
            sine_reg0   <= 18'sb000010101001011101;
        end
        55: begin
            cosine_reg0 <= 18'sb011111111000101101;
            sine_reg0   <= 18'sb000010101100100101;
        end
        56: begin
            cosine_reg0 <= 18'sb011111111000011100;
            sine_reg0   <= 18'sb000010101111101110;
        end
        57: begin
            cosine_reg0 <= 18'sb011111111000001010;
            sine_reg0   <= 18'sb000010110010110110;
        end
        58: begin
            cosine_reg0 <= 18'sb011111110111111001;
            sine_reg0   <= 18'sb000010110101111110;
        end
        59: begin
            cosine_reg0 <= 18'sb011111110111100111;
            sine_reg0   <= 18'sb000010111001000110;
        end
        60: begin
            cosine_reg0 <= 18'sb011111110111010100;
            sine_reg0   <= 18'sb000010111100001111;
        end
        61: begin
            cosine_reg0 <= 18'sb011111110111000010;
            sine_reg0   <= 18'sb000010111111010111;
        end
        62: begin
            cosine_reg0 <= 18'sb011111110110101111;
            sine_reg0   <= 18'sb000011000010011111;
        end
        63: begin
            cosine_reg0 <= 18'sb011111110110011011;
            sine_reg0   <= 18'sb000011000101100111;
        end
        64: begin
            cosine_reg0 <= 18'sb011111110110001000;
            sine_reg0   <= 18'sb000011001000101111;
        end
        65: begin
            cosine_reg0 <= 18'sb011111110101110100;
            sine_reg0   <= 18'sb000011001011110111;
        end
        66: begin
            cosine_reg0 <= 18'sb011111110101100000;
            sine_reg0   <= 18'sb000011001110111111;
        end
        67: begin
            cosine_reg0 <= 18'sb011111110101001011;
            sine_reg0   <= 18'sb000011010010000111;
        end
        68: begin
            cosine_reg0 <= 18'sb011111110100110111;
            sine_reg0   <= 18'sb000011010101001111;
        end
        69: begin
            cosine_reg0 <= 18'sb011111110100100001;
            sine_reg0   <= 18'sb000011011000010111;
        end
        70: begin
            cosine_reg0 <= 18'sb011111110100001100;
            sine_reg0   <= 18'sb000011011011011111;
        end
        71: begin
            cosine_reg0 <= 18'sb011111110011110110;
            sine_reg0   <= 18'sb000011011110100111;
        end
        72: begin
            cosine_reg0 <= 18'sb011111110011100000;
            sine_reg0   <= 18'sb000011100001101111;
        end
        73: begin
            cosine_reg0 <= 18'sb011111110011001010;
            sine_reg0   <= 18'sb000011100100110111;
        end
        74: begin
            cosine_reg0 <= 18'sb011111110010110011;
            sine_reg0   <= 18'sb000011100111111111;
        end
        75: begin
            cosine_reg0 <= 18'sb011111110010011101;
            sine_reg0   <= 18'sb000011101011000110;
        end
        76: begin
            cosine_reg0 <= 18'sb011111110010000101;
            sine_reg0   <= 18'sb000011101110001110;
        end
        77: begin
            cosine_reg0 <= 18'sb011111110001101110;
            sine_reg0   <= 18'sb000011110001010110;
        end
        78: begin
            cosine_reg0 <= 18'sb011111110001010110;
            sine_reg0   <= 18'sb000011110100011101;
        end
        79: begin
            cosine_reg0 <= 18'sb011111110000111110;
            sine_reg0   <= 18'sb000011110111100101;
        end
        80: begin
            cosine_reg0 <= 18'sb011111110000100101;
            sine_reg0   <= 18'sb000011111010101100;
        end
        81: begin
            cosine_reg0 <= 18'sb011111110000001101;
            sine_reg0   <= 18'sb000011111101110100;
        end
        82: begin
            cosine_reg0 <= 18'sb011111101111110011;
            sine_reg0   <= 18'sb000100000000111100;
        end
        83: begin
            cosine_reg0 <= 18'sb011111101111011010;
            sine_reg0   <= 18'sb000100000100000011;
        end
        84: begin
            cosine_reg0 <= 18'sb011111101111000000;
            sine_reg0   <= 18'sb000100000111001010;
        end
        85: begin
            cosine_reg0 <= 18'sb011111101110100110;
            sine_reg0   <= 18'sb000100001010010010;
        end
        86: begin
            cosine_reg0 <= 18'sb011111101110001100;
            sine_reg0   <= 18'sb000100001101011001;
        end
        87: begin
            cosine_reg0 <= 18'sb011111101101110010;
            sine_reg0   <= 18'sb000100010000100000;
        end
        88: begin
            cosine_reg0 <= 18'sb011111101101010111;
            sine_reg0   <= 18'sb000100010011101000;
        end
        89: begin
            cosine_reg0 <= 18'sb011111101100111011;
            sine_reg0   <= 18'sb000100010110101111;
        end
        90: begin
            cosine_reg0 <= 18'sb011111101100100000;
            sine_reg0   <= 18'sb000100011001110110;
        end
        91: begin
            cosine_reg0 <= 18'sb011111101100000100;
            sine_reg0   <= 18'sb000100011100111101;
        end
        92: begin
            cosine_reg0 <= 18'sb011111101011101000;
            sine_reg0   <= 18'sb000100100000000100;
        end
        93: begin
            cosine_reg0 <= 18'sb011111101011001011;
            sine_reg0   <= 18'sb000100100011001011;
        end
        94: begin
            cosine_reg0 <= 18'sb011111101010101111;
            sine_reg0   <= 18'sb000100100110010010;
        end
        95: begin
            cosine_reg0 <= 18'sb011111101010010010;
            sine_reg0   <= 18'sb000100101001011001;
        end
        96: begin
            cosine_reg0 <= 18'sb011111101001110100;
            sine_reg0   <= 18'sb000100101100100000;
        end
        97: begin
            cosine_reg0 <= 18'sb011111101001010111;
            sine_reg0   <= 18'sb000100101111100111;
        end
        98: begin
            cosine_reg0 <= 18'sb011111101000111001;
            sine_reg0   <= 18'sb000100110010101110;
        end
        99: begin
            cosine_reg0 <= 18'sb011111101000011010;
            sine_reg0   <= 18'sb000100110101110101;
        end
        100: begin
            cosine_reg0 <= 18'sb011111100111111100;
            sine_reg0   <= 18'sb000100111000111011;
        end
        101: begin
            cosine_reg0 <= 18'sb011111100111011101;
            sine_reg0   <= 18'sb000100111100000010;
        end
        102: begin
            cosine_reg0 <= 18'sb011111100110111110;
            sine_reg0   <= 18'sb000100111111001001;
        end
        103: begin
            cosine_reg0 <= 18'sb011111100110011110;
            sine_reg0   <= 18'sb000101000010001111;
        end
        104: begin
            cosine_reg0 <= 18'sb011111100101111111;
            sine_reg0   <= 18'sb000101000101010110;
        end
        105: begin
            cosine_reg0 <= 18'sb011111100101011110;
            sine_reg0   <= 18'sb000101001000011100;
        end
        106: begin
            cosine_reg0 <= 18'sb011111100100111110;
            sine_reg0   <= 18'sb000101001011100011;
        end
        107: begin
            cosine_reg0 <= 18'sb011111100100011101;
            sine_reg0   <= 18'sb000101001110101001;
        end
        108: begin
            cosine_reg0 <= 18'sb011111100011111100;
            sine_reg0   <= 18'sb000101010001101111;
        end
        109: begin
            cosine_reg0 <= 18'sb011111100011011011;
            sine_reg0   <= 18'sb000101010100110110;
        end
        110: begin
            cosine_reg0 <= 18'sb011111100010111001;
            sine_reg0   <= 18'sb000101010111111100;
        end
        111: begin
            cosine_reg0 <= 18'sb011111100010011000;
            sine_reg0   <= 18'sb000101011011000010;
        end
        112: begin
            cosine_reg0 <= 18'sb011111100001110101;
            sine_reg0   <= 18'sb000101011110001000;
        end
        113: begin
            cosine_reg0 <= 18'sb011111100001010011;
            sine_reg0   <= 18'sb000101100001001110;
        end
        114: begin
            cosine_reg0 <= 18'sb011111100000110000;
            sine_reg0   <= 18'sb000101100100010100;
        end
        115: begin
            cosine_reg0 <= 18'sb011111100000001101;
            sine_reg0   <= 18'sb000101100111011010;
        end
        116: begin
            cosine_reg0 <= 18'sb011111011111101001;
            sine_reg0   <= 18'sb000101101010100000;
        end
        117: begin
            cosine_reg0 <= 18'sb011111011111000110;
            sine_reg0   <= 18'sb000101101101100110;
        end
        118: begin
            cosine_reg0 <= 18'sb011111011110100010;
            sine_reg0   <= 18'sb000101110000101100;
        end
        119: begin
            cosine_reg0 <= 18'sb011111011101111101;
            sine_reg0   <= 18'sb000101110011110010;
        end
        120: begin
            cosine_reg0 <= 18'sb011111011101011001;
            sine_reg0   <= 18'sb000101110110110111;
        end
        121: begin
            cosine_reg0 <= 18'sb011111011100110100;
            sine_reg0   <= 18'sb000101111001111101;
        end
        122: begin
            cosine_reg0 <= 18'sb011111011100001110;
            sine_reg0   <= 18'sb000101111101000010;
        end
        123: begin
            cosine_reg0 <= 18'sb011111011011101001;
            sine_reg0   <= 18'sb000110000000001000;
        end
        124: begin
            cosine_reg0 <= 18'sb011111011011000011;
            sine_reg0   <= 18'sb000110000011001101;
        end
        125: begin
            cosine_reg0 <= 18'sb011111011010011101;
            sine_reg0   <= 18'sb000110000110010011;
        end
        126: begin
            cosine_reg0 <= 18'sb011111011001110110;
            sine_reg0   <= 18'sb000110001001011000;
        end
        127: begin
            cosine_reg0 <= 18'sb011111011001010000;
            sine_reg0   <= 18'sb000110001100011101;
        end
        128: begin
            cosine_reg0 <= 18'sb011111011000101001;
            sine_reg0   <= 18'sb000110001111100011;
        end
        129: begin
            cosine_reg0 <= 18'sb011111011000000001;
            sine_reg0   <= 18'sb000110010010101000;
        end
        130: begin
            cosine_reg0 <= 18'sb011111010111011001;
            sine_reg0   <= 18'sb000110010101101101;
        end
        131: begin
            cosine_reg0 <= 18'sb011111010110110001;
            sine_reg0   <= 18'sb000110011000110010;
        end
        132: begin
            cosine_reg0 <= 18'sb011111010110001001;
            sine_reg0   <= 18'sb000110011011110111;
        end
        133: begin
            cosine_reg0 <= 18'sb011111010101100001;
            sine_reg0   <= 18'sb000110011110111100;
        end
        134: begin
            cosine_reg0 <= 18'sb011111010100111000;
            sine_reg0   <= 18'sb000110100010000001;
        end
        135: begin
            cosine_reg0 <= 18'sb011111010100001111;
            sine_reg0   <= 18'sb000110100101000110;
        end
        136: begin
            cosine_reg0 <= 18'sb011111010011100101;
            sine_reg0   <= 18'sb000110101000001010;
        end
        137: begin
            cosine_reg0 <= 18'sb011111010010111011;
            sine_reg0   <= 18'sb000110101011001111;
        end
        138: begin
            cosine_reg0 <= 18'sb011111010010010001;
            sine_reg0   <= 18'sb000110101110010100;
        end
        139: begin
            cosine_reg0 <= 18'sb011111010001100111;
            sine_reg0   <= 18'sb000110110001011000;
        end
        140: begin
            cosine_reg0 <= 18'sb011111010000111100;
            sine_reg0   <= 18'sb000110110100011101;
        end
        141: begin
            cosine_reg0 <= 18'sb011111010000010001;
            sine_reg0   <= 18'sb000110110111100001;
        end
        142: begin
            cosine_reg0 <= 18'sb011111001111100110;
            sine_reg0   <= 18'sb000110111010100101;
        end
        143: begin
            cosine_reg0 <= 18'sb011111001110111010;
            sine_reg0   <= 18'sb000110111101101010;
        end
        144: begin
            cosine_reg0 <= 18'sb011111001110001110;
            sine_reg0   <= 18'sb000111000000101110;
        end
        145: begin
            cosine_reg0 <= 18'sb011111001101100010;
            sine_reg0   <= 18'sb000111000011110010;
        end
        146: begin
            cosine_reg0 <= 18'sb011111001100110110;
            sine_reg0   <= 18'sb000111000110110110;
        end
        147: begin
            cosine_reg0 <= 18'sb011111001100001001;
            sine_reg0   <= 18'sb000111001001111010;
        end
        148: begin
            cosine_reg0 <= 18'sb011111001011011100;
            sine_reg0   <= 18'sb000111001100111110;
        end
        149: begin
            cosine_reg0 <= 18'sb011111001010101110;
            sine_reg0   <= 18'sb000111010000000010;
        end
        150: begin
            cosine_reg0 <= 18'sb011111001010000001;
            sine_reg0   <= 18'sb000111010011000110;
        end
        151: begin
            cosine_reg0 <= 18'sb011111001001010011;
            sine_reg0   <= 18'sb000111010110001001;
        end
        152: begin
            cosine_reg0 <= 18'sb011111001000100100;
            sine_reg0   <= 18'sb000111011001001101;
        end
        153: begin
            cosine_reg0 <= 18'sb011111000111110110;
            sine_reg0   <= 18'sb000111011100010001;
        end
        154: begin
            cosine_reg0 <= 18'sb011111000111000111;
            sine_reg0   <= 18'sb000111011111010100;
        end
        155: begin
            cosine_reg0 <= 18'sb011111000110010111;
            sine_reg0   <= 18'sb000111100010011000;
        end
        156: begin
            cosine_reg0 <= 18'sb011111000101101000;
            sine_reg0   <= 18'sb000111100101011011;
        end
        157: begin
            cosine_reg0 <= 18'sb011111000100111000;
            sine_reg0   <= 18'sb000111101000011110;
        end
        158: begin
            cosine_reg0 <= 18'sb011111000100001000;
            sine_reg0   <= 18'sb000111101011100001;
        end
        159: begin
            cosine_reg0 <= 18'sb011111000011011000;
            sine_reg0   <= 18'sb000111101110100101;
        end
        160: begin
            cosine_reg0 <= 18'sb011111000010100111;
            sine_reg0   <= 18'sb000111110001101000;
        end
        161: begin
            cosine_reg0 <= 18'sb011111000001110110;
            sine_reg0   <= 18'sb000111110100101011;
        end
        162: begin
            cosine_reg0 <= 18'sb011111000001000101;
            sine_reg0   <= 18'sb000111110111101110;
        end
        163: begin
            cosine_reg0 <= 18'sb011111000000010011;
            sine_reg0   <= 18'sb000111111010110000;
        end
        164: begin
            cosine_reg0 <= 18'sb011110111111100001;
            sine_reg0   <= 18'sb000111111101110011;
        end
        165: begin
            cosine_reg0 <= 18'sb011110111110101111;
            sine_reg0   <= 18'sb001000000000110110;
        end
        166: begin
            cosine_reg0 <= 18'sb011110111101111100;
            sine_reg0   <= 18'sb001000000011111000;
        end
        167: begin
            cosine_reg0 <= 18'sb011110111101001010;
            sine_reg0   <= 18'sb001000000110111011;
        end
        168: begin
            cosine_reg0 <= 18'sb011110111100010111;
            sine_reg0   <= 18'sb001000001001111101;
        end
        169: begin
            cosine_reg0 <= 18'sb011110111011100011;
            sine_reg0   <= 18'sb001000001101000000;
        end
        170: begin
            cosine_reg0 <= 18'sb011110111010101111;
            sine_reg0   <= 18'sb001000010000000010;
        end
        171: begin
            cosine_reg0 <= 18'sb011110111001111100;
            sine_reg0   <= 18'sb001000010011000100;
        end
        172: begin
            cosine_reg0 <= 18'sb011110111001000111;
            sine_reg0   <= 18'sb001000010110000111;
        end
        173: begin
            cosine_reg0 <= 18'sb011110111000010011;
            sine_reg0   <= 18'sb001000011001001001;
        end
        174: begin
            cosine_reg0 <= 18'sb011110110111011110;
            sine_reg0   <= 18'sb001000011100001011;
        end
        175: begin
            cosine_reg0 <= 18'sb011110110110101001;
            sine_reg0   <= 18'sb001000011111001100;
        end
        176: begin
            cosine_reg0 <= 18'sb011110110101110011;
            sine_reg0   <= 18'sb001000100010001110;
        end
        177: begin
            cosine_reg0 <= 18'sb011110110100111101;
            sine_reg0   <= 18'sb001000100101010000;
        end
        178: begin
            cosine_reg0 <= 18'sb011110110100000111;
            sine_reg0   <= 18'sb001000101000010010;
        end
        179: begin
            cosine_reg0 <= 18'sb011110110011010001;
            sine_reg0   <= 18'sb001000101011010011;
        end
        180: begin
            cosine_reg0 <= 18'sb011110110010011010;
            sine_reg0   <= 18'sb001000101110010101;
        end
        181: begin
            cosine_reg0 <= 18'sb011110110001100011;
            sine_reg0   <= 18'sb001000110001010110;
        end
        182: begin
            cosine_reg0 <= 18'sb011110110000101100;
            sine_reg0   <= 18'sb001000110100010111;
        end
        183: begin
            cosine_reg0 <= 18'sb011110101111110100;
            sine_reg0   <= 18'sb001000110111011001;
        end
        184: begin
            cosine_reg0 <= 18'sb011110101110111101;
            sine_reg0   <= 18'sb001000111010011010;
        end
        185: begin
            cosine_reg0 <= 18'sb011110101110000100;
            sine_reg0   <= 18'sb001000111101011011;
        end
        186: begin
            cosine_reg0 <= 18'sb011110101101001100;
            sine_reg0   <= 18'sb001001000000011100;
        end
        187: begin
            cosine_reg0 <= 18'sb011110101100010011;
            sine_reg0   <= 18'sb001001000011011101;
        end
        188: begin
            cosine_reg0 <= 18'sb011110101011011010;
            sine_reg0   <= 18'sb001001000110011110;
        end
        189: begin
            cosine_reg0 <= 18'sb011110101010100001;
            sine_reg0   <= 18'sb001001001001011110;
        end
        190: begin
            cosine_reg0 <= 18'sb011110101001100111;
            sine_reg0   <= 18'sb001001001100011111;
        end
        191: begin
            cosine_reg0 <= 18'sb011110101000101101;
            sine_reg0   <= 18'sb001001001111011111;
        end
        192: begin
            cosine_reg0 <= 18'sb011110100111110011;
            sine_reg0   <= 18'sb001001010010100000;
        end
        193: begin
            cosine_reg0 <= 18'sb011110100110111001;
            sine_reg0   <= 18'sb001001010101100000;
        end
        194: begin
            cosine_reg0 <= 18'sb011110100101111110;
            sine_reg0   <= 18'sb001001011000100001;
        end
        195: begin
            cosine_reg0 <= 18'sb011110100101000011;
            sine_reg0   <= 18'sb001001011011100001;
        end
        196: begin
            cosine_reg0 <= 18'sb011110100100000111;
            sine_reg0   <= 18'sb001001011110100001;
        end
        197: begin
            cosine_reg0 <= 18'sb011110100011001100;
            sine_reg0   <= 18'sb001001100001100001;
        end
        198: begin
            cosine_reg0 <= 18'sb011110100010010000;
            sine_reg0   <= 18'sb001001100100100001;
        end
        199: begin
            cosine_reg0 <= 18'sb011110100001010011;
            sine_reg0   <= 18'sb001001100111100001;
        end
        200: begin
            cosine_reg0 <= 18'sb011110100000010111;
            sine_reg0   <= 18'sb001001101010100000;
        end
        201: begin
            cosine_reg0 <= 18'sb011110011111011010;
            sine_reg0   <= 18'sb001001101101100000;
        end
        202: begin
            cosine_reg0 <= 18'sb011110011110011101;
            sine_reg0   <= 18'sb001001110000011111;
        end
        203: begin
            cosine_reg0 <= 18'sb011110011101011111;
            sine_reg0   <= 18'sb001001110011011111;
        end
        204: begin
            cosine_reg0 <= 18'sb011110011100100010;
            sine_reg0   <= 18'sb001001110110011110;
        end
        205: begin
            cosine_reg0 <= 18'sb011110011011100011;
            sine_reg0   <= 18'sb001001111001011101;
        end
        206: begin
            cosine_reg0 <= 18'sb011110011010100101;
            sine_reg0   <= 18'sb001001111100011101;
        end
        207: begin
            cosine_reg0 <= 18'sb011110011001100111;
            sine_reg0   <= 18'sb001001111111011100;
        end
        208: begin
            cosine_reg0 <= 18'sb011110011000101000;
            sine_reg0   <= 18'sb001010000010011011;
        end
        209: begin
            cosine_reg0 <= 18'sb011110010111101000;
            sine_reg0   <= 18'sb001010000101011001;
        end
        210: begin
            cosine_reg0 <= 18'sb011110010110101001;
            sine_reg0   <= 18'sb001010001000011000;
        end
        211: begin
            cosine_reg0 <= 18'sb011110010101101001;
            sine_reg0   <= 18'sb001010001011010111;
        end
        212: begin
            cosine_reg0 <= 18'sb011110010100101001;
            sine_reg0   <= 18'sb001010001110010101;
        end
        213: begin
            cosine_reg0 <= 18'sb011110010011101001;
            sine_reg0   <= 18'sb001010010001010100;
        end
        214: begin
            cosine_reg0 <= 18'sb011110010010101000;
            sine_reg0   <= 18'sb001010010100010010;
        end
        215: begin
            cosine_reg0 <= 18'sb011110010001100111;
            sine_reg0   <= 18'sb001010010111010001;
        end
        216: begin
            cosine_reg0 <= 18'sb011110010000100110;
            sine_reg0   <= 18'sb001010011010001111;
        end
        217: begin
            cosine_reg0 <= 18'sb011110001111100100;
            sine_reg0   <= 18'sb001010011101001101;
        end
        218: begin
            cosine_reg0 <= 18'sb011110001110100010;
            sine_reg0   <= 18'sb001010100000001011;
        end
        219: begin
            cosine_reg0 <= 18'sb011110001101100000;
            sine_reg0   <= 18'sb001010100011001001;
        end
        220: begin
            cosine_reg0 <= 18'sb011110001100011110;
            sine_reg0   <= 18'sb001010100110000110;
        end
        221: begin
            cosine_reg0 <= 18'sb011110001011011011;
            sine_reg0   <= 18'sb001010101001000100;
        end
        222: begin
            cosine_reg0 <= 18'sb011110001010011000;
            sine_reg0   <= 18'sb001010101100000010;
        end
        223: begin
            cosine_reg0 <= 18'sb011110001001010101;
            sine_reg0   <= 18'sb001010101110111111;
        end
        224: begin
            cosine_reg0 <= 18'sb011110001000010001;
            sine_reg0   <= 18'sb001010110001111100;
        end
        225: begin
            cosine_reg0 <= 18'sb011110000111001101;
            sine_reg0   <= 18'sb001010110100111010;
        end
        226: begin
            cosine_reg0 <= 18'sb011110000110001001;
            sine_reg0   <= 18'sb001010110111110111;
        end
        227: begin
            cosine_reg0 <= 18'sb011110000101000101;
            sine_reg0   <= 18'sb001010111010110100;
        end
        228: begin
            cosine_reg0 <= 18'sb011110000100000000;
            sine_reg0   <= 18'sb001010111101110001;
        end
        229: begin
            cosine_reg0 <= 18'sb011110000010111011;
            sine_reg0   <= 18'sb001011000000101110;
        end
        230: begin
            cosine_reg0 <= 18'sb011110000001110101;
            sine_reg0   <= 18'sb001011000011101010;
        end
        231: begin
            cosine_reg0 <= 18'sb011110000000110000;
            sine_reg0   <= 18'sb001011000110100111;
        end
        232: begin
            cosine_reg0 <= 18'sb011101111111101010;
            sine_reg0   <= 18'sb001011001001100100;
        end
        233: begin
            cosine_reg0 <= 18'sb011101111110100100;
            sine_reg0   <= 18'sb001011001100100000;
        end
        234: begin
            cosine_reg0 <= 18'sb011101111101011101;
            sine_reg0   <= 18'sb001011001111011100;
        end
        235: begin
            cosine_reg0 <= 18'sb011101111100010111;
            sine_reg0   <= 18'sb001011010010011000;
        end
        236: begin
            cosine_reg0 <= 18'sb011101111011001111;
            sine_reg0   <= 18'sb001011010101010101;
        end
        237: begin
            cosine_reg0 <= 18'sb011101111010001000;
            sine_reg0   <= 18'sb001011011000010001;
        end
        238: begin
            cosine_reg0 <= 18'sb011101111001000000;
            sine_reg0   <= 18'sb001011011011001100;
        end
        239: begin
            cosine_reg0 <= 18'sb011101110111111001;
            sine_reg0   <= 18'sb001011011110001000;
        end
        240: begin
            cosine_reg0 <= 18'sb011101110110110000;
            sine_reg0   <= 18'sb001011100001000100;
        end
        241: begin
            cosine_reg0 <= 18'sb011101110101101000;
            sine_reg0   <= 18'sb001011100011111111;
        end
        242: begin
            cosine_reg0 <= 18'sb011101110100011111;
            sine_reg0   <= 18'sb001011100110111011;
        end
        243: begin
            cosine_reg0 <= 18'sb011101110011010110;
            sine_reg0   <= 18'sb001011101001110110;
        end
        244: begin
            cosine_reg0 <= 18'sb011101110010001101;
            sine_reg0   <= 18'sb001011101100110001;
        end
        245: begin
            cosine_reg0 <= 18'sb011101110001000011;
            sine_reg0   <= 18'sb001011101111101100;
        end
        246: begin
            cosine_reg0 <= 18'sb011101101111111001;
            sine_reg0   <= 18'sb001011110010100111;
        end
        247: begin
            cosine_reg0 <= 18'sb011101101110101111;
            sine_reg0   <= 18'sb001011110101100010;
        end
        248: begin
            cosine_reg0 <= 18'sb011101101101100100;
            sine_reg0   <= 18'sb001011111000011101;
        end
        249: begin
            cosine_reg0 <= 18'sb011101101100011001;
            sine_reg0   <= 18'sb001011111011011000;
        end
        250: begin
            cosine_reg0 <= 18'sb011101101011001110;
            sine_reg0   <= 18'sb001011111110010010;
        end
        251: begin
            cosine_reg0 <= 18'sb011101101010000011;
            sine_reg0   <= 18'sb001100000001001100;
        end
        252: begin
            cosine_reg0 <= 18'sb011101101000110111;
            sine_reg0   <= 18'sb001100000100000111;
        end
        253: begin
            cosine_reg0 <= 18'sb011101100111101011;
            sine_reg0   <= 18'sb001100000111000001;
        end
        254: begin
            cosine_reg0 <= 18'sb011101100110011111;
            sine_reg0   <= 18'sb001100001001111011;
        end
        255: begin
            cosine_reg0 <= 18'sb011101100101010011;
            sine_reg0   <= 18'sb001100001100110101;
        end
        256: begin
            cosine_reg0 <= 18'sb011101100100000110;
            sine_reg0   <= 18'sb001100001111101111;
        end
        257: begin
            cosine_reg0 <= 18'sb011101100010111001;
            sine_reg0   <= 18'sb001100010010101000;
        end
        258: begin
            cosine_reg0 <= 18'sb011101100001101011;
            sine_reg0   <= 18'sb001100010101100010;
        end
        259: begin
            cosine_reg0 <= 18'sb011101100000011110;
            sine_reg0   <= 18'sb001100011000011011;
        end
        260: begin
            cosine_reg0 <= 18'sb011101011111010000;
            sine_reg0   <= 18'sb001100011011010101;
        end
        261: begin
            cosine_reg0 <= 18'sb011101011110000010;
            sine_reg0   <= 18'sb001100011110001110;
        end
        262: begin
            cosine_reg0 <= 18'sb011101011100110011;
            sine_reg0   <= 18'sb001100100001000111;
        end
        263: begin
            cosine_reg0 <= 18'sb011101011011100100;
            sine_reg0   <= 18'sb001100100100000000;
        end
        264: begin
            cosine_reg0 <= 18'sb011101011010010101;
            sine_reg0   <= 18'sb001100100110111001;
        end
        265: begin
            cosine_reg0 <= 18'sb011101011001000110;
            sine_reg0   <= 18'sb001100101001110010;
        end
        266: begin
            cosine_reg0 <= 18'sb011101010111110110;
            sine_reg0   <= 18'sb001100101100101010;
        end
        267: begin
            cosine_reg0 <= 18'sb011101010110100110;
            sine_reg0   <= 18'sb001100101111100011;
        end
        268: begin
            cosine_reg0 <= 18'sb011101010101010110;
            sine_reg0   <= 18'sb001100110010011011;
        end
        269: begin
            cosine_reg0 <= 18'sb011101010100000110;
            sine_reg0   <= 18'sb001100110101010011;
        end
        270: begin
            cosine_reg0 <= 18'sb011101010010110101;
            sine_reg0   <= 18'sb001100111000001100;
        end
        271: begin
            cosine_reg0 <= 18'sb011101010001100100;
            sine_reg0   <= 18'sb001100111011000100;
        end
        272: begin
            cosine_reg0 <= 18'sb011101010000010010;
            sine_reg0   <= 18'sb001100111101111011;
        end
        273: begin
            cosine_reg0 <= 18'sb011101001111000001;
            sine_reg0   <= 18'sb001101000000110011;
        end
        274: begin
            cosine_reg0 <= 18'sb011101001101101111;
            sine_reg0   <= 18'sb001101000011101011;
        end
        275: begin
            cosine_reg0 <= 18'sb011101001100011101;
            sine_reg0   <= 18'sb001101000110100010;
        end
        276: begin
            cosine_reg0 <= 18'sb011101001011001010;
            sine_reg0   <= 18'sb001101001001011010;
        end
        277: begin
            cosine_reg0 <= 18'sb011101001001110111;
            sine_reg0   <= 18'sb001101001100010001;
        end
        278: begin
            cosine_reg0 <= 18'sb011101001000100100;
            sine_reg0   <= 18'sb001101001111001000;
        end
        279: begin
            cosine_reg0 <= 18'sb011101000111010001;
            sine_reg0   <= 18'sb001101010001111111;
        end
        280: begin
            cosine_reg0 <= 18'sb011101000101111110;
            sine_reg0   <= 18'sb001101010100110110;
        end
        281: begin
            cosine_reg0 <= 18'sb011101000100101010;
            sine_reg0   <= 18'sb001101010111101101;
        end
        282: begin
            cosine_reg0 <= 18'sb011101000011010110;
            sine_reg0   <= 18'sb001101011010100011;
        end
        283: begin
            cosine_reg0 <= 18'sb011101000010000001;
            sine_reg0   <= 18'sb001101011101011010;
        end
        284: begin
            cosine_reg0 <= 18'sb011101000000101100;
            sine_reg0   <= 18'sb001101100000010000;
        end
        285: begin
            cosine_reg0 <= 18'sb011100111111010111;
            sine_reg0   <= 18'sb001101100011000110;
        end
        286: begin
            cosine_reg0 <= 18'sb011100111110000010;
            sine_reg0   <= 18'sb001101100101111100;
        end
        287: begin
            cosine_reg0 <= 18'sb011100111100101101;
            sine_reg0   <= 18'sb001101101000110010;
        end
        288: begin
            cosine_reg0 <= 18'sb011100111011010111;
            sine_reg0   <= 18'sb001101101011101000;
        end
        289: begin
            cosine_reg0 <= 18'sb011100111010000001;
            sine_reg0   <= 18'sb001101101110011110;
        end
        290: begin
            cosine_reg0 <= 18'sb011100111000101010;
            sine_reg0   <= 18'sb001101110001010011;
        end
        291: begin
            cosine_reg0 <= 18'sb011100110111010100;
            sine_reg0   <= 18'sb001101110100001001;
        end
        292: begin
            cosine_reg0 <= 18'sb011100110101111101;
            sine_reg0   <= 18'sb001101110110111110;
        end
        293: begin
            cosine_reg0 <= 18'sb011100110100100101;
            sine_reg0   <= 18'sb001101111001110011;
        end
        294: begin
            cosine_reg0 <= 18'sb011100110011001110;
            sine_reg0   <= 18'sb001101111100101000;
        end
        295: begin
            cosine_reg0 <= 18'sb011100110001110110;
            sine_reg0   <= 18'sb001101111111011101;
        end
        296: begin
            cosine_reg0 <= 18'sb011100110000011110;
            sine_reg0   <= 18'sb001110000010010010;
        end
        297: begin
            cosine_reg0 <= 18'sb011100101111000110;
            sine_reg0   <= 18'sb001110000101000110;
        end
        298: begin
            cosine_reg0 <= 18'sb011100101101101101;
            sine_reg0   <= 18'sb001110000111111011;
        end
        299: begin
            cosine_reg0 <= 18'sb011100101100010100;
            sine_reg0   <= 18'sb001110001010101111;
        end
        300: begin
            cosine_reg0 <= 18'sb011100101010111011;
            sine_reg0   <= 18'sb001110001101100100;
        end
        301: begin
            cosine_reg0 <= 18'sb011100101001100010;
            sine_reg0   <= 18'sb001110010000011000;
        end
        302: begin
            cosine_reg0 <= 18'sb011100101000001000;
            sine_reg0   <= 18'sb001110010011001100;
        end
        303: begin
            cosine_reg0 <= 18'sb011100100110101110;
            sine_reg0   <= 18'sb001110010101111111;
        end
        304: begin
            cosine_reg0 <= 18'sb011100100101010100;
            sine_reg0   <= 18'sb001110011000110011;
        end
        305: begin
            cosine_reg0 <= 18'sb011100100011111001;
            sine_reg0   <= 18'sb001110011011100111;
        end
        306: begin
            cosine_reg0 <= 18'sb011100100010011110;
            sine_reg0   <= 18'sb001110011110011010;
        end
        307: begin
            cosine_reg0 <= 18'sb011100100001000011;
            sine_reg0   <= 18'sb001110100001001101;
        end
        308: begin
            cosine_reg0 <= 18'sb011100011111101000;
            sine_reg0   <= 18'sb001110100100000000;
        end
        309: begin
            cosine_reg0 <= 18'sb011100011110001100;
            sine_reg0   <= 18'sb001110100110110011;
        end
        310: begin
            cosine_reg0 <= 18'sb011100011100110000;
            sine_reg0   <= 18'sb001110101001100110;
        end
        311: begin
            cosine_reg0 <= 18'sb011100011011010100;
            sine_reg0   <= 18'sb001110101100011001;
        end
        312: begin
            cosine_reg0 <= 18'sb011100011001111000;
            sine_reg0   <= 18'sb001110101111001011;
        end
        313: begin
            cosine_reg0 <= 18'sb011100011000011011;
            sine_reg0   <= 18'sb001110110001111110;
        end
        314: begin
            cosine_reg0 <= 18'sb011100010110111110;
            sine_reg0   <= 18'sb001110110100110000;
        end
        315: begin
            cosine_reg0 <= 18'sb011100010101100001;
            sine_reg0   <= 18'sb001110110111100010;
        end
        316: begin
            cosine_reg0 <= 18'sb011100010100000011;
            sine_reg0   <= 18'sb001110111010010100;
        end
        317: begin
            cosine_reg0 <= 18'sb011100010010100101;
            sine_reg0   <= 18'sb001110111101000110;
        end
        318: begin
            cosine_reg0 <= 18'sb011100010001000111;
            sine_reg0   <= 18'sb001110111111111000;
        end
        319: begin
            cosine_reg0 <= 18'sb011100001111101001;
            sine_reg0   <= 18'sb001111000010101001;
        end
        320: begin
            cosine_reg0 <= 18'sb011100001110001010;
            sine_reg0   <= 18'sb001111000101011010;
        end
        321: begin
            cosine_reg0 <= 18'sb011100001100101011;
            sine_reg0   <= 18'sb001111001000001100;
        end
        322: begin
            cosine_reg0 <= 18'sb011100001011001100;
            sine_reg0   <= 18'sb001111001010111101;
        end
        323: begin
            cosine_reg0 <= 18'sb011100001001101101;
            sine_reg0   <= 18'sb001111001101101110;
        end
        324: begin
            cosine_reg0 <= 18'sb011100001000001101;
            sine_reg0   <= 18'sb001111010000011111;
        end
        325: begin
            cosine_reg0 <= 18'sb011100000110101101;
            sine_reg0   <= 18'sb001111010011001111;
        end
        326: begin
            cosine_reg0 <= 18'sb011100000101001101;
            sine_reg0   <= 18'sb001111010110000000;
        end
        327: begin
            cosine_reg0 <= 18'sb011100000011101100;
            sine_reg0   <= 18'sb001111011000110000;
        end
        328: begin
            cosine_reg0 <= 18'sb011100000010001011;
            sine_reg0   <= 18'sb001111011011100000;
        end
        329: begin
            cosine_reg0 <= 18'sb011100000000101010;
            sine_reg0   <= 18'sb001111011110010000;
        end
        330: begin
            cosine_reg0 <= 18'sb011011111111001001;
            sine_reg0   <= 18'sb001111100001000000;
        end
        331: begin
            cosine_reg0 <= 18'sb011011111101100111;
            sine_reg0   <= 18'sb001111100011110000;
        end
        332: begin
            cosine_reg0 <= 18'sb011011111100000101;
            sine_reg0   <= 18'sb001111100110100000;
        end
        333: begin
            cosine_reg0 <= 18'sb011011111010100011;
            sine_reg0   <= 18'sb001111101001001111;
        end
        334: begin
            cosine_reg0 <= 18'sb011011111001000001;
            sine_reg0   <= 18'sb001111101011111110;
        end
        335: begin
            cosine_reg0 <= 18'sb011011110111011110;
            sine_reg0   <= 18'sb001111101110101110;
        end
        336: begin
            cosine_reg0 <= 18'sb011011110101111011;
            sine_reg0   <= 18'sb001111110001011101;
        end
        337: begin
            cosine_reg0 <= 18'sb011011110100011000;
            sine_reg0   <= 18'sb001111110100001100;
        end
        338: begin
            cosine_reg0 <= 18'sb011011110010110100;
            sine_reg0   <= 18'sb001111110110111010;
        end
        339: begin
            cosine_reg0 <= 18'sb011011110001010001;
            sine_reg0   <= 18'sb001111111001101001;
        end
        340: begin
            cosine_reg0 <= 18'sb011011101111101101;
            sine_reg0   <= 18'sb001111111100010111;
        end
        341: begin
            cosine_reg0 <= 18'sb011011101110001000;
            sine_reg0   <= 18'sb001111111111000101;
        end
        342: begin
            cosine_reg0 <= 18'sb011011101100100100;
            sine_reg0   <= 18'sb010000000001110100;
        end
        343: begin
            cosine_reg0 <= 18'sb011011101010111111;
            sine_reg0   <= 18'sb010000000100100001;
        end
        344: begin
            cosine_reg0 <= 18'sb011011101001011010;
            sine_reg0   <= 18'sb010000000111001111;
        end
        345: begin
            cosine_reg0 <= 18'sb011011100111110100;
            sine_reg0   <= 18'sb010000001001111101;
        end
        346: begin
            cosine_reg0 <= 18'sb011011100110001111;
            sine_reg0   <= 18'sb010000001100101010;
        end
        347: begin
            cosine_reg0 <= 18'sb011011100100101001;
            sine_reg0   <= 18'sb010000001111011000;
        end
        348: begin
            cosine_reg0 <= 18'sb011011100011000011;
            sine_reg0   <= 18'sb010000010010000101;
        end
        349: begin
            cosine_reg0 <= 18'sb011011100001011100;
            sine_reg0   <= 18'sb010000010100110010;
        end
        350: begin
            cosine_reg0 <= 18'sb011011011111110110;
            sine_reg0   <= 18'sb010000010111011111;
        end
        351: begin
            cosine_reg0 <= 18'sb011011011110001111;
            sine_reg0   <= 18'sb010000011010001011;
        end
        352: begin
            cosine_reg0 <= 18'sb011011011100100111;
            sine_reg0   <= 18'sb010000011100111000;
        end
        353: begin
            cosine_reg0 <= 18'sb011011011011000000;
            sine_reg0   <= 18'sb010000011111100100;
        end
        354: begin
            cosine_reg0 <= 18'sb011011011001011000;
            sine_reg0   <= 18'sb010000100010010001;
        end
        355: begin
            cosine_reg0 <= 18'sb011011010111110000;
            sine_reg0   <= 18'sb010000100100111101;
        end
        356: begin
            cosine_reg0 <= 18'sb011011010110001000;
            sine_reg0   <= 18'sb010000100111101001;
        end
        357: begin
            cosine_reg0 <= 18'sb011011010100011111;
            sine_reg0   <= 18'sb010000101010010100;
        end
        358: begin
            cosine_reg0 <= 18'sb011011010010110110;
            sine_reg0   <= 18'sb010000101101000000;
        end
        359: begin
            cosine_reg0 <= 18'sb011011010001001101;
            sine_reg0   <= 18'sb010000101111101011;
        end
        360: begin
            cosine_reg0 <= 18'sb011011001111100100;
            sine_reg0   <= 18'sb010000110010010110;
        end
        361: begin
            cosine_reg0 <= 18'sb011011001101111010;
            sine_reg0   <= 18'sb010000110101000010;
        end
        362: begin
            cosine_reg0 <= 18'sb011011001100010001;
            sine_reg0   <= 18'sb010000110111101101;
        end
        363: begin
            cosine_reg0 <= 18'sb011011001010100110;
            sine_reg0   <= 18'sb010000111010010111;
        end
        364: begin
            cosine_reg0 <= 18'sb011011001000111100;
            sine_reg0   <= 18'sb010000111101000010;
        end
        365: begin
            cosine_reg0 <= 18'sb011011000111010001;
            sine_reg0   <= 18'sb010000111111101100;
        end
        366: begin
            cosine_reg0 <= 18'sb011011000101100110;
            sine_reg0   <= 18'sb010001000010010111;
        end
        367: begin
            cosine_reg0 <= 18'sb011011000011111011;
            sine_reg0   <= 18'sb010001000101000001;
        end
        368: begin
            cosine_reg0 <= 18'sb011011000010010000;
            sine_reg0   <= 18'sb010001000111101011;
        end
        369: begin
            cosine_reg0 <= 18'sb011011000000100100;
            sine_reg0   <= 18'sb010001001010010100;
        end
        370: begin
            cosine_reg0 <= 18'sb011010111110111000;
            sine_reg0   <= 18'sb010001001100111110;
        end
        371: begin
            cosine_reg0 <= 18'sb011010111101001100;
            sine_reg0   <= 18'sb010001001111101000;
        end
        372: begin
            cosine_reg0 <= 18'sb011010111011011111;
            sine_reg0   <= 18'sb010001010010010001;
        end
        373: begin
            cosine_reg0 <= 18'sb011010111001110011;
            sine_reg0   <= 18'sb010001010100111010;
        end
        374: begin
            cosine_reg0 <= 18'sb011010111000000110;
            sine_reg0   <= 18'sb010001010111100011;
        end
        375: begin
            cosine_reg0 <= 18'sb011010110110011000;
            sine_reg0   <= 18'sb010001011010001100;
        end
        376: begin
            cosine_reg0 <= 18'sb011010110100101011;
            sine_reg0   <= 18'sb010001011100110100;
        end
        377: begin
            cosine_reg0 <= 18'sb011010110010111101;
            sine_reg0   <= 18'sb010001011111011101;
        end
        378: begin
            cosine_reg0 <= 18'sb011010110001001111;
            sine_reg0   <= 18'sb010001100010000101;
        end
        379: begin
            cosine_reg0 <= 18'sb011010101111100001;
            sine_reg0   <= 18'sb010001100100101101;
        end
        380: begin
            cosine_reg0 <= 18'sb011010101101110010;
            sine_reg0   <= 18'sb010001100111010101;
        end
        381: begin
            cosine_reg0 <= 18'sb011010101100000100;
            sine_reg0   <= 18'sb010001101001111101;
        end
        382: begin
            cosine_reg0 <= 18'sb011010101010010100;
            sine_reg0   <= 18'sb010001101100100100;
        end
        383: begin
            cosine_reg0 <= 18'sb011010101000100101;
            sine_reg0   <= 18'sb010001101111001100;
        end
        384: begin
            cosine_reg0 <= 18'sb011010100110110110;
            sine_reg0   <= 18'sb010001110001110011;
        end
        385: begin
            cosine_reg0 <= 18'sb011010100101000110;
            sine_reg0   <= 18'sb010001110100011010;
        end
        386: begin
            cosine_reg0 <= 18'sb011010100011010110;
            sine_reg0   <= 18'sb010001110111000001;
        end
        387: begin
            cosine_reg0 <= 18'sb011010100001100101;
            sine_reg0   <= 18'sb010001111001101000;
        end
        388: begin
            cosine_reg0 <= 18'sb011010011111110101;
            sine_reg0   <= 18'sb010001111100001110;
        end
        389: begin
            cosine_reg0 <= 18'sb011010011110000100;
            sine_reg0   <= 18'sb010001111110110101;
        end
        390: begin
            cosine_reg0 <= 18'sb011010011100010011;
            sine_reg0   <= 18'sb010010000001011011;
        end
        391: begin
            cosine_reg0 <= 18'sb011010011010100001;
            sine_reg0   <= 18'sb010010000100000001;
        end
        392: begin
            cosine_reg0 <= 18'sb011010011000110000;
            sine_reg0   <= 18'sb010010000110100111;
        end
        393: begin
            cosine_reg0 <= 18'sb011010010110111110;
            sine_reg0   <= 18'sb010010001001001101;
        end
        394: begin
            cosine_reg0 <= 18'sb011010010101001100;
            sine_reg0   <= 18'sb010010001011110010;
        end
        395: begin
            cosine_reg0 <= 18'sb011010010011011001;
            sine_reg0   <= 18'sb010010001110011000;
        end
        396: begin
            cosine_reg0 <= 18'sb011010010001100111;
            sine_reg0   <= 18'sb010010010000111101;
        end
        397: begin
            cosine_reg0 <= 18'sb011010001111110100;
            sine_reg0   <= 18'sb010010010011100010;
        end
        398: begin
            cosine_reg0 <= 18'sb011010001110000001;
            sine_reg0   <= 18'sb010010010110000111;
        end
        399: begin
            cosine_reg0 <= 18'sb011010001100001101;
            sine_reg0   <= 18'sb010010011000101011;
        end
        400: begin
            cosine_reg0 <= 18'sb011010001010011010;
            sine_reg0   <= 18'sb010010011011010000;
        end
        401: begin
            cosine_reg0 <= 18'sb011010001000100110;
            sine_reg0   <= 18'sb010010011101110100;
        end
        402: begin
            cosine_reg0 <= 18'sb011010000110110010;
            sine_reg0   <= 18'sb010010100000011000;
        end
        403: begin
            cosine_reg0 <= 18'sb011010000100111101;
            sine_reg0   <= 18'sb010010100010111100;
        end
        404: begin
            cosine_reg0 <= 18'sb011010000011001001;
            sine_reg0   <= 18'sb010010100101100000;
        end
        405: begin
            cosine_reg0 <= 18'sb011010000001010100;
            sine_reg0   <= 18'sb010010101000000011;
        end
        406: begin
            cosine_reg0 <= 18'sb011001111111011110;
            sine_reg0   <= 18'sb010010101010100111;
        end
        407: begin
            cosine_reg0 <= 18'sb011001111101101001;
            sine_reg0   <= 18'sb010010101101001010;
        end
        408: begin
            cosine_reg0 <= 18'sb011001111011110011;
            sine_reg0   <= 18'sb010010101111101101;
        end
        409: begin
            cosine_reg0 <= 18'sb011001111001111110;
            sine_reg0   <= 18'sb010010110010010000;
        end
        410: begin
            cosine_reg0 <= 18'sb011001111000000111;
            sine_reg0   <= 18'sb010010110100110011;
        end
        411: begin
            cosine_reg0 <= 18'sb011001110110010001;
            sine_reg0   <= 18'sb010010110111010101;
        end
        412: begin
            cosine_reg0 <= 18'sb011001110100011010;
            sine_reg0   <= 18'sb010010111001110111;
        end
        413: begin
            cosine_reg0 <= 18'sb011001110010100011;
            sine_reg0   <= 18'sb010010111100011010;
        end
        414: begin
            cosine_reg0 <= 18'sb011001110000101100;
            sine_reg0   <= 18'sb010010111110111100;
        end
        415: begin
            cosine_reg0 <= 18'sb011001101110110101;
            sine_reg0   <= 18'sb010011000001011101;
        end
        416: begin
            cosine_reg0 <= 18'sb011001101100111101;
            sine_reg0   <= 18'sb010011000011111111;
        end
        417: begin
            cosine_reg0 <= 18'sb011001101011000101;
            sine_reg0   <= 18'sb010011000110100000;
        end
        418: begin
            cosine_reg0 <= 18'sb011001101001001101;
            sine_reg0   <= 18'sb010011001001000010;
        end
        419: begin
            cosine_reg0 <= 18'sb011001100111010101;
            sine_reg0   <= 18'sb010011001011100011;
        end
        420: begin
            cosine_reg0 <= 18'sb011001100101011100;
            sine_reg0   <= 18'sb010011001110000011;
        end
        421: begin
            cosine_reg0 <= 18'sb011001100011100011;
            sine_reg0   <= 18'sb010011010000100100;
        end
        422: begin
            cosine_reg0 <= 18'sb011001100001101010;
            sine_reg0   <= 18'sb010011010011000101;
        end
        423: begin
            cosine_reg0 <= 18'sb011001011111110001;
            sine_reg0   <= 18'sb010011010101100101;
        end
        424: begin
            cosine_reg0 <= 18'sb011001011101110111;
            sine_reg0   <= 18'sb010011011000000101;
        end
        425: begin
            cosine_reg0 <= 18'sb011001011011111101;
            sine_reg0   <= 18'sb010011011010100101;
        end
        426: begin
            cosine_reg0 <= 18'sb011001011010000011;
            sine_reg0   <= 18'sb010011011101000101;
        end
        427: begin
            cosine_reg0 <= 18'sb011001011000001001;
            sine_reg0   <= 18'sb010011011111100100;
        end
        428: begin
            cosine_reg0 <= 18'sb011001010110001110;
            sine_reg0   <= 18'sb010011100010000011;
        end
        429: begin
            cosine_reg0 <= 18'sb011001010100010011;
            sine_reg0   <= 18'sb010011100100100011;
        end
        430: begin
            cosine_reg0 <= 18'sb011001010010011000;
            sine_reg0   <= 18'sb010011100111000010;
        end
        431: begin
            cosine_reg0 <= 18'sb011001010000011101;
            sine_reg0   <= 18'sb010011101001100000;
        end
        432: begin
            cosine_reg0 <= 18'sb011001001110100001;
            sine_reg0   <= 18'sb010011101011111111;
        end
        433: begin
            cosine_reg0 <= 18'sb011001001100100110;
            sine_reg0   <= 18'sb010011101110011101;
        end
        434: begin
            cosine_reg0 <= 18'sb011001001010101001;
            sine_reg0   <= 18'sb010011110000111100;
        end
        435: begin
            cosine_reg0 <= 18'sb011001001000101101;
            sine_reg0   <= 18'sb010011110011011010;
        end
        436: begin
            cosine_reg0 <= 18'sb011001000110110001;
            sine_reg0   <= 18'sb010011110101111000;
        end
        437: begin
            cosine_reg0 <= 18'sb011001000100110100;
            sine_reg0   <= 18'sb010011111000010101;
        end
        438: begin
            cosine_reg0 <= 18'sb011001000010110111;
            sine_reg0   <= 18'sb010011111010110011;
        end
        439: begin
            cosine_reg0 <= 18'sb011001000000111010;
            sine_reg0   <= 18'sb010011111101010000;
        end
        440: begin
            cosine_reg0 <= 18'sb011000111110111100;
            sine_reg0   <= 18'sb010011111111101101;
        end
        441: begin
            cosine_reg0 <= 18'sb011000111100111110;
            sine_reg0   <= 18'sb010100000010001010;
        end
        442: begin
            cosine_reg0 <= 18'sb011000111011000000;
            sine_reg0   <= 18'sb010100000100100111;
        end
        443: begin
            cosine_reg0 <= 18'sb011000111001000010;
            sine_reg0   <= 18'sb010100000111000011;
        end
        444: begin
            cosine_reg0 <= 18'sb011000110111000100;
            sine_reg0   <= 18'sb010100001001011111;
        end
        445: begin
            cosine_reg0 <= 18'sb011000110101000101;
            sine_reg0   <= 18'sb010100001011111011;
        end
        446: begin
            cosine_reg0 <= 18'sb011000110011000110;
            sine_reg0   <= 18'sb010100001110010111;
        end
        447: begin
            cosine_reg0 <= 18'sb011000110001000111;
            sine_reg0   <= 18'sb010100010000110011;
        end
        448: begin
            cosine_reg0 <= 18'sb011000101111000111;
            sine_reg0   <= 18'sb010100010011001111;
        end
        449: begin
            cosine_reg0 <= 18'sb011000101101001000;
            sine_reg0   <= 18'sb010100010101101010;
        end
        450: begin
            cosine_reg0 <= 18'sb011000101011001000;
            sine_reg0   <= 18'sb010100011000000101;
        end
        451: begin
            cosine_reg0 <= 18'sb011000101001001000;
            sine_reg0   <= 18'sb010100011010100000;
        end
        452: begin
            cosine_reg0 <= 18'sb011000100111000111;
            sine_reg0   <= 18'sb010100011100111011;
        end
        453: begin
            cosine_reg0 <= 18'sb011000100101000111;
            sine_reg0   <= 18'sb010100011111010101;
        end
        454: begin
            cosine_reg0 <= 18'sb011000100011000110;
            sine_reg0   <= 18'sb010100100001110000;
        end
        455: begin
            cosine_reg0 <= 18'sb011000100001000101;
            sine_reg0   <= 18'sb010100100100001010;
        end
        456: begin
            cosine_reg0 <= 18'sb011000011111000011;
            sine_reg0   <= 18'sb010100100110100100;
        end
        457: begin
            cosine_reg0 <= 18'sb011000011101000010;
            sine_reg0   <= 18'sb010100101000111101;
        end
        458: begin
            cosine_reg0 <= 18'sb011000011011000000;
            sine_reg0   <= 18'sb010100101011010111;
        end
        459: begin
            cosine_reg0 <= 18'sb011000011000111110;
            sine_reg0   <= 18'sb010100101101110000;
        end
        460: begin
            cosine_reg0 <= 18'sb011000010110111100;
            sine_reg0   <= 18'sb010100110000001001;
        end
        461: begin
            cosine_reg0 <= 18'sb011000010100111001;
            sine_reg0   <= 18'sb010100110010100010;
        end
        462: begin
            cosine_reg0 <= 18'sb011000010010110110;
            sine_reg0   <= 18'sb010100110100111011;
        end
        463: begin
            cosine_reg0 <= 18'sb011000010000110011;
            sine_reg0   <= 18'sb010100110111010100;
        end
        464: begin
            cosine_reg0 <= 18'sb011000001110110000;
            sine_reg0   <= 18'sb010100111001101100;
        end
        465: begin
            cosine_reg0 <= 18'sb011000001100101101;
            sine_reg0   <= 18'sb010100111100000100;
        end
        466: begin
            cosine_reg0 <= 18'sb011000001010101001;
            sine_reg0   <= 18'sb010100111110011100;
        end
        467: begin
            cosine_reg0 <= 18'sb011000001000100101;
            sine_reg0   <= 18'sb010101000000110100;
        end
        468: begin
            cosine_reg0 <= 18'sb011000000110100001;
            sine_reg0   <= 18'sb010101000011001011;
        end
        469: begin
            cosine_reg0 <= 18'sb011000000100011101;
            sine_reg0   <= 18'sb010101000101100011;
        end
        470: begin
            cosine_reg0 <= 18'sb011000000010011000;
            sine_reg0   <= 18'sb010101000111111010;
        end
        471: begin
            cosine_reg0 <= 18'sb011000000000010011;
            sine_reg0   <= 18'sb010101001010010001;
        end
        472: begin
            cosine_reg0 <= 18'sb010111111110001110;
            sine_reg0   <= 18'sb010101001100100111;
        end
        473: begin
            cosine_reg0 <= 18'sb010111111100001001;
            sine_reg0   <= 18'sb010101001110111110;
        end
        474: begin
            cosine_reg0 <= 18'sb010111111010000011;
            sine_reg0   <= 18'sb010101010001010100;
        end
        475: begin
            cosine_reg0 <= 18'sb010111110111111101;
            sine_reg0   <= 18'sb010101010011101010;
        end
        476: begin
            cosine_reg0 <= 18'sb010111110101110111;
            sine_reg0   <= 18'sb010101010110000000;
        end
        477: begin
            cosine_reg0 <= 18'sb010111110011110001;
            sine_reg0   <= 18'sb010101011000010110;
        end
        478: begin
            cosine_reg0 <= 18'sb010111110001101011;
            sine_reg0   <= 18'sb010101011010101100;
        end
        479: begin
            cosine_reg0 <= 18'sb010111101111100100;
            sine_reg0   <= 18'sb010101011101000001;
        end
        480: begin
            cosine_reg0 <= 18'sb010111101101011101;
            sine_reg0   <= 18'sb010101011111010110;
        end
        481: begin
            cosine_reg0 <= 18'sb010111101011010110;
            sine_reg0   <= 18'sb010101100001101011;
        end
        482: begin
            cosine_reg0 <= 18'sb010111101001001111;
            sine_reg0   <= 18'sb010101100011111111;
        end
        483: begin
            cosine_reg0 <= 18'sb010111100111000111;
            sine_reg0   <= 18'sb010101100110010100;
        end
        484: begin
            cosine_reg0 <= 18'sb010111100100111111;
            sine_reg0   <= 18'sb010101101000101000;
        end
        485: begin
            cosine_reg0 <= 18'sb010111100010110111;
            sine_reg0   <= 18'sb010101101010111100;
        end
        486: begin
            cosine_reg0 <= 18'sb010111100000101111;
            sine_reg0   <= 18'sb010101101101010000;
        end
        487: begin
            cosine_reg0 <= 18'sb010111011110100110;
            sine_reg0   <= 18'sb010101101111100100;
        end
        488: begin
            cosine_reg0 <= 18'sb010111011100011110;
            sine_reg0   <= 18'sb010101110001110111;
        end
        489: begin
            cosine_reg0 <= 18'sb010111011010010101;
            sine_reg0   <= 18'sb010101110100001010;
        end
        490: begin
            cosine_reg0 <= 18'sb010111011000001100;
            sine_reg0   <= 18'sb010101110110011101;
        end
        491: begin
            cosine_reg0 <= 18'sb010111010110000010;
            sine_reg0   <= 18'sb010101111000110000;
        end
        492: begin
            cosine_reg0 <= 18'sb010111010011111001;
            sine_reg0   <= 18'sb010101111011000011;
        end
        493: begin
            cosine_reg0 <= 18'sb010111010001101111;
            sine_reg0   <= 18'sb010101111101010101;
        end
        494: begin
            cosine_reg0 <= 18'sb010111001111100101;
            sine_reg0   <= 18'sb010101111111100111;
        end
        495: begin
            cosine_reg0 <= 18'sb010111001101011010;
            sine_reg0   <= 18'sb010110000001111001;
        end
        496: begin
            cosine_reg0 <= 18'sb010111001011010000;
            sine_reg0   <= 18'sb010110000100001011;
        end
        497: begin
            cosine_reg0 <= 18'sb010111001001000101;
            sine_reg0   <= 18'sb010110000110011100;
        end
        498: begin
            cosine_reg0 <= 18'sb010111000110111010;
            sine_reg0   <= 18'sb010110001000101110;
        end
        499: begin
            cosine_reg0 <= 18'sb010111000100101111;
            sine_reg0   <= 18'sb010110001010111111;
        end
        500: begin
            cosine_reg0 <= 18'sb010111000010100011;
            sine_reg0   <= 18'sb010110001101010000;
        end
        501: begin
            cosine_reg0 <= 18'sb010111000000011000;
            sine_reg0   <= 18'sb010110001111100000;
        end
        502: begin
            cosine_reg0 <= 18'sb010110111110001100;
            sine_reg0   <= 18'sb010110010001110001;
        end
        503: begin
            cosine_reg0 <= 18'sb010110111100000000;
            sine_reg0   <= 18'sb010110010100000001;
        end
        504: begin
            cosine_reg0 <= 18'sb010110111001110100;
            sine_reg0   <= 18'sb010110010110010001;
        end
        505: begin
            cosine_reg0 <= 18'sb010110110111100111;
            sine_reg0   <= 18'sb010110011000100001;
        end
        506: begin
            cosine_reg0 <= 18'sb010110110101011010;
            sine_reg0   <= 18'sb010110011010110000;
        end
        507: begin
            cosine_reg0 <= 18'sb010110110011001101;
            sine_reg0   <= 18'sb010110011101000000;
        end
        508: begin
            cosine_reg0 <= 18'sb010110110001000000;
            sine_reg0   <= 18'sb010110011111001111;
        end
        509: begin
            cosine_reg0 <= 18'sb010110101110110011;
            sine_reg0   <= 18'sb010110100001011110;
        end
        510: begin
            cosine_reg0 <= 18'sb010110101100100101;
            sine_reg0   <= 18'sb010110100011101100;
        end
        511: begin
            cosine_reg0 <= 18'sb010110101010010111;
            sine_reg0   <= 18'sb010110100101111011;
        end
        512: begin
            cosine_reg0 <= 18'sb010110101000001001;
            sine_reg0   <= 18'sb010110101000001001;
        end
        513: begin
            cosine_reg0 <= 18'sb010110100101111011;
            sine_reg0   <= 18'sb010110101010010111;
        end
        514: begin
            cosine_reg0 <= 18'sb010110100011101100;
            sine_reg0   <= 18'sb010110101100100101;
        end
        515: begin
            cosine_reg0 <= 18'sb010110100001011110;
            sine_reg0   <= 18'sb010110101110110011;
        end
        516: begin
            cosine_reg0 <= 18'sb010110011111001111;
            sine_reg0   <= 18'sb010110110001000000;
        end
        517: begin
            cosine_reg0 <= 18'sb010110011101000000;
            sine_reg0   <= 18'sb010110110011001101;
        end
        518: begin
            cosine_reg0 <= 18'sb010110011010110000;
            sine_reg0   <= 18'sb010110110101011010;
        end
        519: begin
            cosine_reg0 <= 18'sb010110011000100001;
            sine_reg0   <= 18'sb010110110111100111;
        end
        520: begin
            cosine_reg0 <= 18'sb010110010110010001;
            sine_reg0   <= 18'sb010110111001110100;
        end
        521: begin
            cosine_reg0 <= 18'sb010110010100000001;
            sine_reg0   <= 18'sb010110111100000000;
        end
        522: begin
            cosine_reg0 <= 18'sb010110010001110001;
            sine_reg0   <= 18'sb010110111110001100;
        end
        523: begin
            cosine_reg0 <= 18'sb010110001111100000;
            sine_reg0   <= 18'sb010111000000011000;
        end
        524: begin
            cosine_reg0 <= 18'sb010110001101010000;
            sine_reg0   <= 18'sb010111000010100011;
        end
        525: begin
            cosine_reg0 <= 18'sb010110001010111111;
            sine_reg0   <= 18'sb010111000100101111;
        end
        526: begin
            cosine_reg0 <= 18'sb010110001000101110;
            sine_reg0   <= 18'sb010111000110111010;
        end
        527: begin
            cosine_reg0 <= 18'sb010110000110011100;
            sine_reg0   <= 18'sb010111001001000101;
        end
        528: begin
            cosine_reg0 <= 18'sb010110000100001011;
            sine_reg0   <= 18'sb010111001011010000;
        end
        529: begin
            cosine_reg0 <= 18'sb010110000001111001;
            sine_reg0   <= 18'sb010111001101011010;
        end
        530: begin
            cosine_reg0 <= 18'sb010101111111100111;
            sine_reg0   <= 18'sb010111001111100101;
        end
        531: begin
            cosine_reg0 <= 18'sb010101111101010101;
            sine_reg0   <= 18'sb010111010001101111;
        end
        532: begin
            cosine_reg0 <= 18'sb010101111011000011;
            sine_reg0   <= 18'sb010111010011111001;
        end
        533: begin
            cosine_reg0 <= 18'sb010101111000110000;
            sine_reg0   <= 18'sb010111010110000010;
        end
        534: begin
            cosine_reg0 <= 18'sb010101110110011101;
            sine_reg0   <= 18'sb010111011000001100;
        end
        535: begin
            cosine_reg0 <= 18'sb010101110100001010;
            sine_reg0   <= 18'sb010111011010010101;
        end
        536: begin
            cosine_reg0 <= 18'sb010101110001110111;
            sine_reg0   <= 18'sb010111011100011110;
        end
        537: begin
            cosine_reg0 <= 18'sb010101101111100100;
            sine_reg0   <= 18'sb010111011110100110;
        end
        538: begin
            cosine_reg0 <= 18'sb010101101101010000;
            sine_reg0   <= 18'sb010111100000101111;
        end
        539: begin
            cosine_reg0 <= 18'sb010101101010111100;
            sine_reg0   <= 18'sb010111100010110111;
        end
        540: begin
            cosine_reg0 <= 18'sb010101101000101000;
            sine_reg0   <= 18'sb010111100100111111;
        end
        541: begin
            cosine_reg0 <= 18'sb010101100110010100;
            sine_reg0   <= 18'sb010111100111000111;
        end
        542: begin
            cosine_reg0 <= 18'sb010101100011111111;
            sine_reg0   <= 18'sb010111101001001111;
        end
        543: begin
            cosine_reg0 <= 18'sb010101100001101011;
            sine_reg0   <= 18'sb010111101011010110;
        end
        544: begin
            cosine_reg0 <= 18'sb010101011111010110;
            sine_reg0   <= 18'sb010111101101011101;
        end
        545: begin
            cosine_reg0 <= 18'sb010101011101000001;
            sine_reg0   <= 18'sb010111101111100100;
        end
        546: begin
            cosine_reg0 <= 18'sb010101011010101100;
            sine_reg0   <= 18'sb010111110001101011;
        end
        547: begin
            cosine_reg0 <= 18'sb010101011000010110;
            sine_reg0   <= 18'sb010111110011110001;
        end
        548: begin
            cosine_reg0 <= 18'sb010101010110000000;
            sine_reg0   <= 18'sb010111110101110111;
        end
        549: begin
            cosine_reg0 <= 18'sb010101010011101010;
            sine_reg0   <= 18'sb010111110111111101;
        end
        550: begin
            cosine_reg0 <= 18'sb010101010001010100;
            sine_reg0   <= 18'sb010111111010000011;
        end
        551: begin
            cosine_reg0 <= 18'sb010101001110111110;
            sine_reg0   <= 18'sb010111111100001001;
        end
        552: begin
            cosine_reg0 <= 18'sb010101001100100111;
            sine_reg0   <= 18'sb010111111110001110;
        end
        553: begin
            cosine_reg0 <= 18'sb010101001010010001;
            sine_reg0   <= 18'sb011000000000010011;
        end
        554: begin
            cosine_reg0 <= 18'sb010101000111111010;
            sine_reg0   <= 18'sb011000000010011000;
        end
        555: begin
            cosine_reg0 <= 18'sb010101000101100011;
            sine_reg0   <= 18'sb011000000100011101;
        end
        556: begin
            cosine_reg0 <= 18'sb010101000011001011;
            sine_reg0   <= 18'sb011000000110100001;
        end
        557: begin
            cosine_reg0 <= 18'sb010101000000110100;
            sine_reg0   <= 18'sb011000001000100101;
        end
        558: begin
            cosine_reg0 <= 18'sb010100111110011100;
            sine_reg0   <= 18'sb011000001010101001;
        end
        559: begin
            cosine_reg0 <= 18'sb010100111100000100;
            sine_reg0   <= 18'sb011000001100101101;
        end
        560: begin
            cosine_reg0 <= 18'sb010100111001101100;
            sine_reg0   <= 18'sb011000001110110000;
        end
        561: begin
            cosine_reg0 <= 18'sb010100110111010100;
            sine_reg0   <= 18'sb011000010000110011;
        end
        562: begin
            cosine_reg0 <= 18'sb010100110100111011;
            sine_reg0   <= 18'sb011000010010110110;
        end
        563: begin
            cosine_reg0 <= 18'sb010100110010100010;
            sine_reg0   <= 18'sb011000010100111001;
        end
        564: begin
            cosine_reg0 <= 18'sb010100110000001001;
            sine_reg0   <= 18'sb011000010110111100;
        end
        565: begin
            cosine_reg0 <= 18'sb010100101101110000;
            sine_reg0   <= 18'sb011000011000111110;
        end
        566: begin
            cosine_reg0 <= 18'sb010100101011010111;
            sine_reg0   <= 18'sb011000011011000000;
        end
        567: begin
            cosine_reg0 <= 18'sb010100101000111101;
            sine_reg0   <= 18'sb011000011101000010;
        end
        568: begin
            cosine_reg0 <= 18'sb010100100110100100;
            sine_reg0   <= 18'sb011000011111000011;
        end
        569: begin
            cosine_reg0 <= 18'sb010100100100001010;
            sine_reg0   <= 18'sb011000100001000101;
        end
        570: begin
            cosine_reg0 <= 18'sb010100100001110000;
            sine_reg0   <= 18'sb011000100011000110;
        end
        571: begin
            cosine_reg0 <= 18'sb010100011111010101;
            sine_reg0   <= 18'sb011000100101000111;
        end
        572: begin
            cosine_reg0 <= 18'sb010100011100111011;
            sine_reg0   <= 18'sb011000100111000111;
        end
        573: begin
            cosine_reg0 <= 18'sb010100011010100000;
            sine_reg0   <= 18'sb011000101001001000;
        end
        574: begin
            cosine_reg0 <= 18'sb010100011000000101;
            sine_reg0   <= 18'sb011000101011001000;
        end
        575: begin
            cosine_reg0 <= 18'sb010100010101101010;
            sine_reg0   <= 18'sb011000101101001000;
        end
        576: begin
            cosine_reg0 <= 18'sb010100010011001111;
            sine_reg0   <= 18'sb011000101111000111;
        end
        577: begin
            cosine_reg0 <= 18'sb010100010000110011;
            sine_reg0   <= 18'sb011000110001000111;
        end
        578: begin
            cosine_reg0 <= 18'sb010100001110010111;
            sine_reg0   <= 18'sb011000110011000110;
        end
        579: begin
            cosine_reg0 <= 18'sb010100001011111011;
            sine_reg0   <= 18'sb011000110101000101;
        end
        580: begin
            cosine_reg0 <= 18'sb010100001001011111;
            sine_reg0   <= 18'sb011000110111000100;
        end
        581: begin
            cosine_reg0 <= 18'sb010100000111000011;
            sine_reg0   <= 18'sb011000111001000010;
        end
        582: begin
            cosine_reg0 <= 18'sb010100000100100111;
            sine_reg0   <= 18'sb011000111011000000;
        end
        583: begin
            cosine_reg0 <= 18'sb010100000010001010;
            sine_reg0   <= 18'sb011000111100111110;
        end
        584: begin
            cosine_reg0 <= 18'sb010011111111101101;
            sine_reg0   <= 18'sb011000111110111100;
        end
        585: begin
            cosine_reg0 <= 18'sb010011111101010000;
            sine_reg0   <= 18'sb011001000000111010;
        end
        586: begin
            cosine_reg0 <= 18'sb010011111010110011;
            sine_reg0   <= 18'sb011001000010110111;
        end
        587: begin
            cosine_reg0 <= 18'sb010011111000010101;
            sine_reg0   <= 18'sb011001000100110100;
        end
        588: begin
            cosine_reg0 <= 18'sb010011110101111000;
            sine_reg0   <= 18'sb011001000110110001;
        end
        589: begin
            cosine_reg0 <= 18'sb010011110011011010;
            sine_reg0   <= 18'sb011001001000101101;
        end
        590: begin
            cosine_reg0 <= 18'sb010011110000111100;
            sine_reg0   <= 18'sb011001001010101001;
        end
        591: begin
            cosine_reg0 <= 18'sb010011101110011101;
            sine_reg0   <= 18'sb011001001100100110;
        end
        592: begin
            cosine_reg0 <= 18'sb010011101011111111;
            sine_reg0   <= 18'sb011001001110100001;
        end
        593: begin
            cosine_reg0 <= 18'sb010011101001100000;
            sine_reg0   <= 18'sb011001010000011101;
        end
        594: begin
            cosine_reg0 <= 18'sb010011100111000010;
            sine_reg0   <= 18'sb011001010010011000;
        end
        595: begin
            cosine_reg0 <= 18'sb010011100100100011;
            sine_reg0   <= 18'sb011001010100010011;
        end
        596: begin
            cosine_reg0 <= 18'sb010011100010000011;
            sine_reg0   <= 18'sb011001010110001110;
        end
        597: begin
            cosine_reg0 <= 18'sb010011011111100100;
            sine_reg0   <= 18'sb011001011000001001;
        end
        598: begin
            cosine_reg0 <= 18'sb010011011101000101;
            sine_reg0   <= 18'sb011001011010000011;
        end
        599: begin
            cosine_reg0 <= 18'sb010011011010100101;
            sine_reg0   <= 18'sb011001011011111101;
        end
        600: begin
            cosine_reg0 <= 18'sb010011011000000101;
            sine_reg0   <= 18'sb011001011101110111;
        end
        601: begin
            cosine_reg0 <= 18'sb010011010101100101;
            sine_reg0   <= 18'sb011001011111110001;
        end
        602: begin
            cosine_reg0 <= 18'sb010011010011000101;
            sine_reg0   <= 18'sb011001100001101010;
        end
        603: begin
            cosine_reg0 <= 18'sb010011010000100100;
            sine_reg0   <= 18'sb011001100011100011;
        end
        604: begin
            cosine_reg0 <= 18'sb010011001110000011;
            sine_reg0   <= 18'sb011001100101011100;
        end
        605: begin
            cosine_reg0 <= 18'sb010011001011100011;
            sine_reg0   <= 18'sb011001100111010101;
        end
        606: begin
            cosine_reg0 <= 18'sb010011001001000010;
            sine_reg0   <= 18'sb011001101001001101;
        end
        607: begin
            cosine_reg0 <= 18'sb010011000110100000;
            sine_reg0   <= 18'sb011001101011000101;
        end
        608: begin
            cosine_reg0 <= 18'sb010011000011111111;
            sine_reg0   <= 18'sb011001101100111101;
        end
        609: begin
            cosine_reg0 <= 18'sb010011000001011101;
            sine_reg0   <= 18'sb011001101110110101;
        end
        610: begin
            cosine_reg0 <= 18'sb010010111110111100;
            sine_reg0   <= 18'sb011001110000101100;
        end
        611: begin
            cosine_reg0 <= 18'sb010010111100011010;
            sine_reg0   <= 18'sb011001110010100011;
        end
        612: begin
            cosine_reg0 <= 18'sb010010111001110111;
            sine_reg0   <= 18'sb011001110100011010;
        end
        613: begin
            cosine_reg0 <= 18'sb010010110111010101;
            sine_reg0   <= 18'sb011001110110010001;
        end
        614: begin
            cosine_reg0 <= 18'sb010010110100110011;
            sine_reg0   <= 18'sb011001111000000111;
        end
        615: begin
            cosine_reg0 <= 18'sb010010110010010000;
            sine_reg0   <= 18'sb011001111001111110;
        end
        616: begin
            cosine_reg0 <= 18'sb010010101111101101;
            sine_reg0   <= 18'sb011001111011110011;
        end
        617: begin
            cosine_reg0 <= 18'sb010010101101001010;
            sine_reg0   <= 18'sb011001111101101001;
        end
        618: begin
            cosine_reg0 <= 18'sb010010101010100111;
            sine_reg0   <= 18'sb011001111111011110;
        end
        619: begin
            cosine_reg0 <= 18'sb010010101000000011;
            sine_reg0   <= 18'sb011010000001010100;
        end
        620: begin
            cosine_reg0 <= 18'sb010010100101100000;
            sine_reg0   <= 18'sb011010000011001001;
        end
        621: begin
            cosine_reg0 <= 18'sb010010100010111100;
            sine_reg0   <= 18'sb011010000100111101;
        end
        622: begin
            cosine_reg0 <= 18'sb010010100000011000;
            sine_reg0   <= 18'sb011010000110110010;
        end
        623: begin
            cosine_reg0 <= 18'sb010010011101110100;
            sine_reg0   <= 18'sb011010001000100110;
        end
        624: begin
            cosine_reg0 <= 18'sb010010011011010000;
            sine_reg0   <= 18'sb011010001010011010;
        end
        625: begin
            cosine_reg0 <= 18'sb010010011000101011;
            sine_reg0   <= 18'sb011010001100001101;
        end
        626: begin
            cosine_reg0 <= 18'sb010010010110000111;
            sine_reg0   <= 18'sb011010001110000001;
        end
        627: begin
            cosine_reg0 <= 18'sb010010010011100010;
            sine_reg0   <= 18'sb011010001111110100;
        end
        628: begin
            cosine_reg0 <= 18'sb010010010000111101;
            sine_reg0   <= 18'sb011010010001100111;
        end
        629: begin
            cosine_reg0 <= 18'sb010010001110011000;
            sine_reg0   <= 18'sb011010010011011001;
        end
        630: begin
            cosine_reg0 <= 18'sb010010001011110010;
            sine_reg0   <= 18'sb011010010101001100;
        end
        631: begin
            cosine_reg0 <= 18'sb010010001001001101;
            sine_reg0   <= 18'sb011010010110111110;
        end
        632: begin
            cosine_reg0 <= 18'sb010010000110100111;
            sine_reg0   <= 18'sb011010011000110000;
        end
        633: begin
            cosine_reg0 <= 18'sb010010000100000001;
            sine_reg0   <= 18'sb011010011010100001;
        end
        634: begin
            cosine_reg0 <= 18'sb010010000001011011;
            sine_reg0   <= 18'sb011010011100010011;
        end
        635: begin
            cosine_reg0 <= 18'sb010001111110110101;
            sine_reg0   <= 18'sb011010011110000100;
        end
        636: begin
            cosine_reg0 <= 18'sb010001111100001110;
            sine_reg0   <= 18'sb011010011111110101;
        end
        637: begin
            cosine_reg0 <= 18'sb010001111001101000;
            sine_reg0   <= 18'sb011010100001100101;
        end
        638: begin
            cosine_reg0 <= 18'sb010001110111000001;
            sine_reg0   <= 18'sb011010100011010110;
        end
        639: begin
            cosine_reg0 <= 18'sb010001110100011010;
            sine_reg0   <= 18'sb011010100101000110;
        end
        640: begin
            cosine_reg0 <= 18'sb010001110001110011;
            sine_reg0   <= 18'sb011010100110110110;
        end
        641: begin
            cosine_reg0 <= 18'sb010001101111001100;
            sine_reg0   <= 18'sb011010101000100101;
        end
        642: begin
            cosine_reg0 <= 18'sb010001101100100100;
            sine_reg0   <= 18'sb011010101010010100;
        end
        643: begin
            cosine_reg0 <= 18'sb010001101001111101;
            sine_reg0   <= 18'sb011010101100000100;
        end
        644: begin
            cosine_reg0 <= 18'sb010001100111010101;
            sine_reg0   <= 18'sb011010101101110010;
        end
        645: begin
            cosine_reg0 <= 18'sb010001100100101101;
            sine_reg0   <= 18'sb011010101111100001;
        end
        646: begin
            cosine_reg0 <= 18'sb010001100010000101;
            sine_reg0   <= 18'sb011010110001001111;
        end
        647: begin
            cosine_reg0 <= 18'sb010001011111011101;
            sine_reg0   <= 18'sb011010110010111101;
        end
        648: begin
            cosine_reg0 <= 18'sb010001011100110100;
            sine_reg0   <= 18'sb011010110100101011;
        end
        649: begin
            cosine_reg0 <= 18'sb010001011010001100;
            sine_reg0   <= 18'sb011010110110011000;
        end
        650: begin
            cosine_reg0 <= 18'sb010001010111100011;
            sine_reg0   <= 18'sb011010111000000110;
        end
        651: begin
            cosine_reg0 <= 18'sb010001010100111010;
            sine_reg0   <= 18'sb011010111001110011;
        end
        652: begin
            cosine_reg0 <= 18'sb010001010010010001;
            sine_reg0   <= 18'sb011010111011011111;
        end
        653: begin
            cosine_reg0 <= 18'sb010001001111101000;
            sine_reg0   <= 18'sb011010111101001100;
        end
        654: begin
            cosine_reg0 <= 18'sb010001001100111110;
            sine_reg0   <= 18'sb011010111110111000;
        end
        655: begin
            cosine_reg0 <= 18'sb010001001010010100;
            sine_reg0   <= 18'sb011011000000100100;
        end
        656: begin
            cosine_reg0 <= 18'sb010001000111101011;
            sine_reg0   <= 18'sb011011000010010000;
        end
        657: begin
            cosine_reg0 <= 18'sb010001000101000001;
            sine_reg0   <= 18'sb011011000011111011;
        end
        658: begin
            cosine_reg0 <= 18'sb010001000010010111;
            sine_reg0   <= 18'sb011011000101100110;
        end
        659: begin
            cosine_reg0 <= 18'sb010000111111101100;
            sine_reg0   <= 18'sb011011000111010001;
        end
        660: begin
            cosine_reg0 <= 18'sb010000111101000010;
            sine_reg0   <= 18'sb011011001000111100;
        end
        661: begin
            cosine_reg0 <= 18'sb010000111010010111;
            sine_reg0   <= 18'sb011011001010100110;
        end
        662: begin
            cosine_reg0 <= 18'sb010000110111101101;
            sine_reg0   <= 18'sb011011001100010001;
        end
        663: begin
            cosine_reg0 <= 18'sb010000110101000010;
            sine_reg0   <= 18'sb011011001101111010;
        end
        664: begin
            cosine_reg0 <= 18'sb010000110010010110;
            sine_reg0   <= 18'sb011011001111100100;
        end
        665: begin
            cosine_reg0 <= 18'sb010000101111101011;
            sine_reg0   <= 18'sb011011010001001101;
        end
        666: begin
            cosine_reg0 <= 18'sb010000101101000000;
            sine_reg0   <= 18'sb011011010010110110;
        end
        667: begin
            cosine_reg0 <= 18'sb010000101010010100;
            sine_reg0   <= 18'sb011011010100011111;
        end
        668: begin
            cosine_reg0 <= 18'sb010000100111101001;
            sine_reg0   <= 18'sb011011010110001000;
        end
        669: begin
            cosine_reg0 <= 18'sb010000100100111101;
            sine_reg0   <= 18'sb011011010111110000;
        end
        670: begin
            cosine_reg0 <= 18'sb010000100010010001;
            sine_reg0   <= 18'sb011011011001011000;
        end
        671: begin
            cosine_reg0 <= 18'sb010000011111100100;
            sine_reg0   <= 18'sb011011011011000000;
        end
        672: begin
            cosine_reg0 <= 18'sb010000011100111000;
            sine_reg0   <= 18'sb011011011100100111;
        end
        673: begin
            cosine_reg0 <= 18'sb010000011010001011;
            sine_reg0   <= 18'sb011011011110001111;
        end
        674: begin
            cosine_reg0 <= 18'sb010000010111011111;
            sine_reg0   <= 18'sb011011011111110110;
        end
        675: begin
            cosine_reg0 <= 18'sb010000010100110010;
            sine_reg0   <= 18'sb011011100001011100;
        end
        676: begin
            cosine_reg0 <= 18'sb010000010010000101;
            sine_reg0   <= 18'sb011011100011000011;
        end
        677: begin
            cosine_reg0 <= 18'sb010000001111011000;
            sine_reg0   <= 18'sb011011100100101001;
        end
        678: begin
            cosine_reg0 <= 18'sb010000001100101010;
            sine_reg0   <= 18'sb011011100110001111;
        end
        679: begin
            cosine_reg0 <= 18'sb010000001001111101;
            sine_reg0   <= 18'sb011011100111110100;
        end
        680: begin
            cosine_reg0 <= 18'sb010000000111001111;
            sine_reg0   <= 18'sb011011101001011010;
        end
        681: begin
            cosine_reg0 <= 18'sb010000000100100001;
            sine_reg0   <= 18'sb011011101010111111;
        end
        682: begin
            cosine_reg0 <= 18'sb010000000001110100;
            sine_reg0   <= 18'sb011011101100100100;
        end
        683: begin
            cosine_reg0 <= 18'sb001111111111000101;
            sine_reg0   <= 18'sb011011101110001000;
        end
        684: begin
            cosine_reg0 <= 18'sb001111111100010111;
            sine_reg0   <= 18'sb011011101111101101;
        end
        685: begin
            cosine_reg0 <= 18'sb001111111001101001;
            sine_reg0   <= 18'sb011011110001010001;
        end
        686: begin
            cosine_reg0 <= 18'sb001111110110111010;
            sine_reg0   <= 18'sb011011110010110100;
        end
        687: begin
            cosine_reg0 <= 18'sb001111110100001100;
            sine_reg0   <= 18'sb011011110100011000;
        end
        688: begin
            cosine_reg0 <= 18'sb001111110001011101;
            sine_reg0   <= 18'sb011011110101111011;
        end
        689: begin
            cosine_reg0 <= 18'sb001111101110101110;
            sine_reg0   <= 18'sb011011110111011110;
        end
        690: begin
            cosine_reg0 <= 18'sb001111101011111110;
            sine_reg0   <= 18'sb011011111001000001;
        end
        691: begin
            cosine_reg0 <= 18'sb001111101001001111;
            sine_reg0   <= 18'sb011011111010100011;
        end
        692: begin
            cosine_reg0 <= 18'sb001111100110100000;
            sine_reg0   <= 18'sb011011111100000101;
        end
        693: begin
            cosine_reg0 <= 18'sb001111100011110000;
            sine_reg0   <= 18'sb011011111101100111;
        end
        694: begin
            cosine_reg0 <= 18'sb001111100001000000;
            sine_reg0   <= 18'sb011011111111001001;
        end
        695: begin
            cosine_reg0 <= 18'sb001111011110010000;
            sine_reg0   <= 18'sb011100000000101010;
        end
        696: begin
            cosine_reg0 <= 18'sb001111011011100000;
            sine_reg0   <= 18'sb011100000010001011;
        end
        697: begin
            cosine_reg0 <= 18'sb001111011000110000;
            sine_reg0   <= 18'sb011100000011101100;
        end
        698: begin
            cosine_reg0 <= 18'sb001111010110000000;
            sine_reg0   <= 18'sb011100000101001101;
        end
        699: begin
            cosine_reg0 <= 18'sb001111010011001111;
            sine_reg0   <= 18'sb011100000110101101;
        end
        700: begin
            cosine_reg0 <= 18'sb001111010000011111;
            sine_reg0   <= 18'sb011100001000001101;
        end
        701: begin
            cosine_reg0 <= 18'sb001111001101101110;
            sine_reg0   <= 18'sb011100001001101101;
        end
        702: begin
            cosine_reg0 <= 18'sb001111001010111101;
            sine_reg0   <= 18'sb011100001011001100;
        end
        703: begin
            cosine_reg0 <= 18'sb001111001000001100;
            sine_reg0   <= 18'sb011100001100101011;
        end
        704: begin
            cosine_reg0 <= 18'sb001111000101011010;
            sine_reg0   <= 18'sb011100001110001010;
        end
        705: begin
            cosine_reg0 <= 18'sb001111000010101001;
            sine_reg0   <= 18'sb011100001111101001;
        end
        706: begin
            cosine_reg0 <= 18'sb001110111111111000;
            sine_reg0   <= 18'sb011100010001000111;
        end
        707: begin
            cosine_reg0 <= 18'sb001110111101000110;
            sine_reg0   <= 18'sb011100010010100101;
        end
        708: begin
            cosine_reg0 <= 18'sb001110111010010100;
            sine_reg0   <= 18'sb011100010100000011;
        end
        709: begin
            cosine_reg0 <= 18'sb001110110111100010;
            sine_reg0   <= 18'sb011100010101100001;
        end
        710: begin
            cosine_reg0 <= 18'sb001110110100110000;
            sine_reg0   <= 18'sb011100010110111110;
        end
        711: begin
            cosine_reg0 <= 18'sb001110110001111110;
            sine_reg0   <= 18'sb011100011000011011;
        end
        712: begin
            cosine_reg0 <= 18'sb001110101111001011;
            sine_reg0   <= 18'sb011100011001111000;
        end
        713: begin
            cosine_reg0 <= 18'sb001110101100011001;
            sine_reg0   <= 18'sb011100011011010100;
        end
        714: begin
            cosine_reg0 <= 18'sb001110101001100110;
            sine_reg0   <= 18'sb011100011100110000;
        end
        715: begin
            cosine_reg0 <= 18'sb001110100110110011;
            sine_reg0   <= 18'sb011100011110001100;
        end
        716: begin
            cosine_reg0 <= 18'sb001110100100000000;
            sine_reg0   <= 18'sb011100011111101000;
        end
        717: begin
            cosine_reg0 <= 18'sb001110100001001101;
            sine_reg0   <= 18'sb011100100001000011;
        end
        718: begin
            cosine_reg0 <= 18'sb001110011110011010;
            sine_reg0   <= 18'sb011100100010011110;
        end
        719: begin
            cosine_reg0 <= 18'sb001110011011100111;
            sine_reg0   <= 18'sb011100100011111001;
        end
        720: begin
            cosine_reg0 <= 18'sb001110011000110011;
            sine_reg0   <= 18'sb011100100101010100;
        end
        721: begin
            cosine_reg0 <= 18'sb001110010101111111;
            sine_reg0   <= 18'sb011100100110101110;
        end
        722: begin
            cosine_reg0 <= 18'sb001110010011001100;
            sine_reg0   <= 18'sb011100101000001000;
        end
        723: begin
            cosine_reg0 <= 18'sb001110010000011000;
            sine_reg0   <= 18'sb011100101001100010;
        end
        724: begin
            cosine_reg0 <= 18'sb001110001101100100;
            sine_reg0   <= 18'sb011100101010111011;
        end
        725: begin
            cosine_reg0 <= 18'sb001110001010101111;
            sine_reg0   <= 18'sb011100101100010100;
        end
        726: begin
            cosine_reg0 <= 18'sb001110000111111011;
            sine_reg0   <= 18'sb011100101101101101;
        end
        727: begin
            cosine_reg0 <= 18'sb001110000101000110;
            sine_reg0   <= 18'sb011100101111000110;
        end
        728: begin
            cosine_reg0 <= 18'sb001110000010010010;
            sine_reg0   <= 18'sb011100110000011110;
        end
        729: begin
            cosine_reg0 <= 18'sb001101111111011101;
            sine_reg0   <= 18'sb011100110001110110;
        end
        730: begin
            cosine_reg0 <= 18'sb001101111100101000;
            sine_reg0   <= 18'sb011100110011001110;
        end
        731: begin
            cosine_reg0 <= 18'sb001101111001110011;
            sine_reg0   <= 18'sb011100110100100101;
        end
        732: begin
            cosine_reg0 <= 18'sb001101110110111110;
            sine_reg0   <= 18'sb011100110101111101;
        end
        733: begin
            cosine_reg0 <= 18'sb001101110100001001;
            sine_reg0   <= 18'sb011100110111010100;
        end
        734: begin
            cosine_reg0 <= 18'sb001101110001010011;
            sine_reg0   <= 18'sb011100111000101010;
        end
        735: begin
            cosine_reg0 <= 18'sb001101101110011110;
            sine_reg0   <= 18'sb011100111010000001;
        end
        736: begin
            cosine_reg0 <= 18'sb001101101011101000;
            sine_reg0   <= 18'sb011100111011010111;
        end
        737: begin
            cosine_reg0 <= 18'sb001101101000110010;
            sine_reg0   <= 18'sb011100111100101101;
        end
        738: begin
            cosine_reg0 <= 18'sb001101100101111100;
            sine_reg0   <= 18'sb011100111110000010;
        end
        739: begin
            cosine_reg0 <= 18'sb001101100011000110;
            sine_reg0   <= 18'sb011100111111010111;
        end
        740: begin
            cosine_reg0 <= 18'sb001101100000010000;
            sine_reg0   <= 18'sb011101000000101100;
        end
        741: begin
            cosine_reg0 <= 18'sb001101011101011010;
            sine_reg0   <= 18'sb011101000010000001;
        end
        742: begin
            cosine_reg0 <= 18'sb001101011010100011;
            sine_reg0   <= 18'sb011101000011010110;
        end
        743: begin
            cosine_reg0 <= 18'sb001101010111101101;
            sine_reg0   <= 18'sb011101000100101010;
        end
        744: begin
            cosine_reg0 <= 18'sb001101010100110110;
            sine_reg0   <= 18'sb011101000101111110;
        end
        745: begin
            cosine_reg0 <= 18'sb001101010001111111;
            sine_reg0   <= 18'sb011101000111010001;
        end
        746: begin
            cosine_reg0 <= 18'sb001101001111001000;
            sine_reg0   <= 18'sb011101001000100100;
        end
        747: begin
            cosine_reg0 <= 18'sb001101001100010001;
            sine_reg0   <= 18'sb011101001001110111;
        end
        748: begin
            cosine_reg0 <= 18'sb001101001001011010;
            sine_reg0   <= 18'sb011101001011001010;
        end
        749: begin
            cosine_reg0 <= 18'sb001101000110100010;
            sine_reg0   <= 18'sb011101001100011101;
        end
        750: begin
            cosine_reg0 <= 18'sb001101000011101011;
            sine_reg0   <= 18'sb011101001101101111;
        end
        751: begin
            cosine_reg0 <= 18'sb001101000000110011;
            sine_reg0   <= 18'sb011101001111000001;
        end
        752: begin
            cosine_reg0 <= 18'sb001100111101111011;
            sine_reg0   <= 18'sb011101010000010010;
        end
        753: begin
            cosine_reg0 <= 18'sb001100111011000100;
            sine_reg0   <= 18'sb011101010001100100;
        end
        754: begin
            cosine_reg0 <= 18'sb001100111000001100;
            sine_reg0   <= 18'sb011101010010110101;
        end
        755: begin
            cosine_reg0 <= 18'sb001100110101010011;
            sine_reg0   <= 18'sb011101010100000110;
        end
        756: begin
            cosine_reg0 <= 18'sb001100110010011011;
            sine_reg0   <= 18'sb011101010101010110;
        end
        757: begin
            cosine_reg0 <= 18'sb001100101111100011;
            sine_reg0   <= 18'sb011101010110100110;
        end
        758: begin
            cosine_reg0 <= 18'sb001100101100101010;
            sine_reg0   <= 18'sb011101010111110110;
        end
        759: begin
            cosine_reg0 <= 18'sb001100101001110010;
            sine_reg0   <= 18'sb011101011001000110;
        end
        760: begin
            cosine_reg0 <= 18'sb001100100110111001;
            sine_reg0   <= 18'sb011101011010010101;
        end
        761: begin
            cosine_reg0 <= 18'sb001100100100000000;
            sine_reg0   <= 18'sb011101011011100100;
        end
        762: begin
            cosine_reg0 <= 18'sb001100100001000111;
            sine_reg0   <= 18'sb011101011100110011;
        end
        763: begin
            cosine_reg0 <= 18'sb001100011110001110;
            sine_reg0   <= 18'sb011101011110000010;
        end
        764: begin
            cosine_reg0 <= 18'sb001100011011010101;
            sine_reg0   <= 18'sb011101011111010000;
        end
        765: begin
            cosine_reg0 <= 18'sb001100011000011011;
            sine_reg0   <= 18'sb011101100000011110;
        end
        766: begin
            cosine_reg0 <= 18'sb001100010101100010;
            sine_reg0   <= 18'sb011101100001101011;
        end
        767: begin
            cosine_reg0 <= 18'sb001100010010101000;
            sine_reg0   <= 18'sb011101100010111001;
        end
        768: begin
            cosine_reg0 <= 18'sb001100001111101111;
            sine_reg0   <= 18'sb011101100100000110;
        end
        769: begin
            cosine_reg0 <= 18'sb001100001100110101;
            sine_reg0   <= 18'sb011101100101010011;
        end
        770: begin
            cosine_reg0 <= 18'sb001100001001111011;
            sine_reg0   <= 18'sb011101100110011111;
        end
        771: begin
            cosine_reg0 <= 18'sb001100000111000001;
            sine_reg0   <= 18'sb011101100111101011;
        end
        772: begin
            cosine_reg0 <= 18'sb001100000100000111;
            sine_reg0   <= 18'sb011101101000110111;
        end
        773: begin
            cosine_reg0 <= 18'sb001100000001001100;
            sine_reg0   <= 18'sb011101101010000011;
        end
        774: begin
            cosine_reg0 <= 18'sb001011111110010010;
            sine_reg0   <= 18'sb011101101011001110;
        end
        775: begin
            cosine_reg0 <= 18'sb001011111011011000;
            sine_reg0   <= 18'sb011101101100011001;
        end
        776: begin
            cosine_reg0 <= 18'sb001011111000011101;
            sine_reg0   <= 18'sb011101101101100100;
        end
        777: begin
            cosine_reg0 <= 18'sb001011110101100010;
            sine_reg0   <= 18'sb011101101110101111;
        end
        778: begin
            cosine_reg0 <= 18'sb001011110010100111;
            sine_reg0   <= 18'sb011101101111111001;
        end
        779: begin
            cosine_reg0 <= 18'sb001011101111101100;
            sine_reg0   <= 18'sb011101110001000011;
        end
        780: begin
            cosine_reg0 <= 18'sb001011101100110001;
            sine_reg0   <= 18'sb011101110010001101;
        end
        781: begin
            cosine_reg0 <= 18'sb001011101001110110;
            sine_reg0   <= 18'sb011101110011010110;
        end
        782: begin
            cosine_reg0 <= 18'sb001011100110111011;
            sine_reg0   <= 18'sb011101110100011111;
        end
        783: begin
            cosine_reg0 <= 18'sb001011100011111111;
            sine_reg0   <= 18'sb011101110101101000;
        end
        784: begin
            cosine_reg0 <= 18'sb001011100001000100;
            sine_reg0   <= 18'sb011101110110110000;
        end
        785: begin
            cosine_reg0 <= 18'sb001011011110001000;
            sine_reg0   <= 18'sb011101110111111001;
        end
        786: begin
            cosine_reg0 <= 18'sb001011011011001100;
            sine_reg0   <= 18'sb011101111001000000;
        end
        787: begin
            cosine_reg0 <= 18'sb001011011000010001;
            sine_reg0   <= 18'sb011101111010001000;
        end
        788: begin
            cosine_reg0 <= 18'sb001011010101010101;
            sine_reg0   <= 18'sb011101111011001111;
        end
        789: begin
            cosine_reg0 <= 18'sb001011010010011000;
            sine_reg0   <= 18'sb011101111100010111;
        end
        790: begin
            cosine_reg0 <= 18'sb001011001111011100;
            sine_reg0   <= 18'sb011101111101011101;
        end
        791: begin
            cosine_reg0 <= 18'sb001011001100100000;
            sine_reg0   <= 18'sb011101111110100100;
        end
        792: begin
            cosine_reg0 <= 18'sb001011001001100100;
            sine_reg0   <= 18'sb011101111111101010;
        end
        793: begin
            cosine_reg0 <= 18'sb001011000110100111;
            sine_reg0   <= 18'sb011110000000110000;
        end
        794: begin
            cosine_reg0 <= 18'sb001011000011101010;
            sine_reg0   <= 18'sb011110000001110101;
        end
        795: begin
            cosine_reg0 <= 18'sb001011000000101110;
            sine_reg0   <= 18'sb011110000010111011;
        end
        796: begin
            cosine_reg0 <= 18'sb001010111101110001;
            sine_reg0   <= 18'sb011110000100000000;
        end
        797: begin
            cosine_reg0 <= 18'sb001010111010110100;
            sine_reg0   <= 18'sb011110000101000101;
        end
        798: begin
            cosine_reg0 <= 18'sb001010110111110111;
            sine_reg0   <= 18'sb011110000110001001;
        end
        799: begin
            cosine_reg0 <= 18'sb001010110100111010;
            sine_reg0   <= 18'sb011110000111001101;
        end
        800: begin
            cosine_reg0 <= 18'sb001010110001111100;
            sine_reg0   <= 18'sb011110001000010001;
        end
        801: begin
            cosine_reg0 <= 18'sb001010101110111111;
            sine_reg0   <= 18'sb011110001001010101;
        end
        802: begin
            cosine_reg0 <= 18'sb001010101100000010;
            sine_reg0   <= 18'sb011110001010011000;
        end
        803: begin
            cosine_reg0 <= 18'sb001010101001000100;
            sine_reg0   <= 18'sb011110001011011011;
        end
        804: begin
            cosine_reg0 <= 18'sb001010100110000110;
            sine_reg0   <= 18'sb011110001100011110;
        end
        805: begin
            cosine_reg0 <= 18'sb001010100011001001;
            sine_reg0   <= 18'sb011110001101100000;
        end
        806: begin
            cosine_reg0 <= 18'sb001010100000001011;
            sine_reg0   <= 18'sb011110001110100010;
        end
        807: begin
            cosine_reg0 <= 18'sb001010011101001101;
            sine_reg0   <= 18'sb011110001111100100;
        end
        808: begin
            cosine_reg0 <= 18'sb001010011010001111;
            sine_reg0   <= 18'sb011110010000100110;
        end
        809: begin
            cosine_reg0 <= 18'sb001010010111010001;
            sine_reg0   <= 18'sb011110010001100111;
        end
        810: begin
            cosine_reg0 <= 18'sb001010010100010010;
            sine_reg0   <= 18'sb011110010010101000;
        end
        811: begin
            cosine_reg0 <= 18'sb001010010001010100;
            sine_reg0   <= 18'sb011110010011101001;
        end
        812: begin
            cosine_reg0 <= 18'sb001010001110010101;
            sine_reg0   <= 18'sb011110010100101001;
        end
        813: begin
            cosine_reg0 <= 18'sb001010001011010111;
            sine_reg0   <= 18'sb011110010101101001;
        end
        814: begin
            cosine_reg0 <= 18'sb001010001000011000;
            sine_reg0   <= 18'sb011110010110101001;
        end
        815: begin
            cosine_reg0 <= 18'sb001010000101011001;
            sine_reg0   <= 18'sb011110010111101000;
        end
        816: begin
            cosine_reg0 <= 18'sb001010000010011011;
            sine_reg0   <= 18'sb011110011000101000;
        end
        817: begin
            cosine_reg0 <= 18'sb001001111111011100;
            sine_reg0   <= 18'sb011110011001100111;
        end
        818: begin
            cosine_reg0 <= 18'sb001001111100011101;
            sine_reg0   <= 18'sb011110011010100101;
        end
        819: begin
            cosine_reg0 <= 18'sb001001111001011101;
            sine_reg0   <= 18'sb011110011011100011;
        end
        820: begin
            cosine_reg0 <= 18'sb001001110110011110;
            sine_reg0   <= 18'sb011110011100100010;
        end
        821: begin
            cosine_reg0 <= 18'sb001001110011011111;
            sine_reg0   <= 18'sb011110011101011111;
        end
        822: begin
            cosine_reg0 <= 18'sb001001110000011111;
            sine_reg0   <= 18'sb011110011110011101;
        end
        823: begin
            cosine_reg0 <= 18'sb001001101101100000;
            sine_reg0   <= 18'sb011110011111011010;
        end
        824: begin
            cosine_reg0 <= 18'sb001001101010100000;
            sine_reg0   <= 18'sb011110100000010111;
        end
        825: begin
            cosine_reg0 <= 18'sb001001100111100001;
            sine_reg0   <= 18'sb011110100001010011;
        end
        826: begin
            cosine_reg0 <= 18'sb001001100100100001;
            sine_reg0   <= 18'sb011110100010010000;
        end
        827: begin
            cosine_reg0 <= 18'sb001001100001100001;
            sine_reg0   <= 18'sb011110100011001100;
        end
        828: begin
            cosine_reg0 <= 18'sb001001011110100001;
            sine_reg0   <= 18'sb011110100100000111;
        end
        829: begin
            cosine_reg0 <= 18'sb001001011011100001;
            sine_reg0   <= 18'sb011110100101000011;
        end
        830: begin
            cosine_reg0 <= 18'sb001001011000100001;
            sine_reg0   <= 18'sb011110100101111110;
        end
        831: begin
            cosine_reg0 <= 18'sb001001010101100000;
            sine_reg0   <= 18'sb011110100110111001;
        end
        832: begin
            cosine_reg0 <= 18'sb001001010010100000;
            sine_reg0   <= 18'sb011110100111110011;
        end
        833: begin
            cosine_reg0 <= 18'sb001001001111011111;
            sine_reg0   <= 18'sb011110101000101101;
        end
        834: begin
            cosine_reg0 <= 18'sb001001001100011111;
            sine_reg0   <= 18'sb011110101001100111;
        end
        835: begin
            cosine_reg0 <= 18'sb001001001001011110;
            sine_reg0   <= 18'sb011110101010100001;
        end
        836: begin
            cosine_reg0 <= 18'sb001001000110011110;
            sine_reg0   <= 18'sb011110101011011010;
        end
        837: begin
            cosine_reg0 <= 18'sb001001000011011101;
            sine_reg0   <= 18'sb011110101100010011;
        end
        838: begin
            cosine_reg0 <= 18'sb001001000000011100;
            sine_reg0   <= 18'sb011110101101001100;
        end
        839: begin
            cosine_reg0 <= 18'sb001000111101011011;
            sine_reg0   <= 18'sb011110101110000100;
        end
        840: begin
            cosine_reg0 <= 18'sb001000111010011010;
            sine_reg0   <= 18'sb011110101110111101;
        end
        841: begin
            cosine_reg0 <= 18'sb001000110111011001;
            sine_reg0   <= 18'sb011110101111110100;
        end
        842: begin
            cosine_reg0 <= 18'sb001000110100010111;
            sine_reg0   <= 18'sb011110110000101100;
        end
        843: begin
            cosine_reg0 <= 18'sb001000110001010110;
            sine_reg0   <= 18'sb011110110001100011;
        end
        844: begin
            cosine_reg0 <= 18'sb001000101110010101;
            sine_reg0   <= 18'sb011110110010011010;
        end
        845: begin
            cosine_reg0 <= 18'sb001000101011010011;
            sine_reg0   <= 18'sb011110110011010001;
        end
        846: begin
            cosine_reg0 <= 18'sb001000101000010010;
            sine_reg0   <= 18'sb011110110100000111;
        end
        847: begin
            cosine_reg0 <= 18'sb001000100101010000;
            sine_reg0   <= 18'sb011110110100111101;
        end
        848: begin
            cosine_reg0 <= 18'sb001000100010001110;
            sine_reg0   <= 18'sb011110110101110011;
        end
        849: begin
            cosine_reg0 <= 18'sb001000011111001100;
            sine_reg0   <= 18'sb011110110110101001;
        end
        850: begin
            cosine_reg0 <= 18'sb001000011100001011;
            sine_reg0   <= 18'sb011110110111011110;
        end
        851: begin
            cosine_reg0 <= 18'sb001000011001001001;
            sine_reg0   <= 18'sb011110111000010011;
        end
        852: begin
            cosine_reg0 <= 18'sb001000010110000111;
            sine_reg0   <= 18'sb011110111001000111;
        end
        853: begin
            cosine_reg0 <= 18'sb001000010011000100;
            sine_reg0   <= 18'sb011110111001111100;
        end
        854: begin
            cosine_reg0 <= 18'sb001000010000000010;
            sine_reg0   <= 18'sb011110111010101111;
        end
        855: begin
            cosine_reg0 <= 18'sb001000001101000000;
            sine_reg0   <= 18'sb011110111011100011;
        end
        856: begin
            cosine_reg0 <= 18'sb001000001001111101;
            sine_reg0   <= 18'sb011110111100010111;
        end
        857: begin
            cosine_reg0 <= 18'sb001000000110111011;
            sine_reg0   <= 18'sb011110111101001010;
        end
        858: begin
            cosine_reg0 <= 18'sb001000000011111000;
            sine_reg0   <= 18'sb011110111101111100;
        end
        859: begin
            cosine_reg0 <= 18'sb001000000000110110;
            sine_reg0   <= 18'sb011110111110101111;
        end
        860: begin
            cosine_reg0 <= 18'sb000111111101110011;
            sine_reg0   <= 18'sb011110111111100001;
        end
        861: begin
            cosine_reg0 <= 18'sb000111111010110000;
            sine_reg0   <= 18'sb011111000000010011;
        end
        862: begin
            cosine_reg0 <= 18'sb000111110111101110;
            sine_reg0   <= 18'sb011111000001000101;
        end
        863: begin
            cosine_reg0 <= 18'sb000111110100101011;
            sine_reg0   <= 18'sb011111000001110110;
        end
        864: begin
            cosine_reg0 <= 18'sb000111110001101000;
            sine_reg0   <= 18'sb011111000010100111;
        end
        865: begin
            cosine_reg0 <= 18'sb000111101110100101;
            sine_reg0   <= 18'sb011111000011011000;
        end
        866: begin
            cosine_reg0 <= 18'sb000111101011100001;
            sine_reg0   <= 18'sb011111000100001000;
        end
        867: begin
            cosine_reg0 <= 18'sb000111101000011110;
            sine_reg0   <= 18'sb011111000100111000;
        end
        868: begin
            cosine_reg0 <= 18'sb000111100101011011;
            sine_reg0   <= 18'sb011111000101101000;
        end
        869: begin
            cosine_reg0 <= 18'sb000111100010011000;
            sine_reg0   <= 18'sb011111000110010111;
        end
        870: begin
            cosine_reg0 <= 18'sb000111011111010100;
            sine_reg0   <= 18'sb011111000111000111;
        end
        871: begin
            cosine_reg0 <= 18'sb000111011100010001;
            sine_reg0   <= 18'sb011111000111110110;
        end
        872: begin
            cosine_reg0 <= 18'sb000111011001001101;
            sine_reg0   <= 18'sb011111001000100100;
        end
        873: begin
            cosine_reg0 <= 18'sb000111010110001001;
            sine_reg0   <= 18'sb011111001001010011;
        end
        874: begin
            cosine_reg0 <= 18'sb000111010011000110;
            sine_reg0   <= 18'sb011111001010000001;
        end
        875: begin
            cosine_reg0 <= 18'sb000111010000000010;
            sine_reg0   <= 18'sb011111001010101110;
        end
        876: begin
            cosine_reg0 <= 18'sb000111001100111110;
            sine_reg0   <= 18'sb011111001011011100;
        end
        877: begin
            cosine_reg0 <= 18'sb000111001001111010;
            sine_reg0   <= 18'sb011111001100001001;
        end
        878: begin
            cosine_reg0 <= 18'sb000111000110110110;
            sine_reg0   <= 18'sb011111001100110110;
        end
        879: begin
            cosine_reg0 <= 18'sb000111000011110010;
            sine_reg0   <= 18'sb011111001101100010;
        end
        880: begin
            cosine_reg0 <= 18'sb000111000000101110;
            sine_reg0   <= 18'sb011111001110001110;
        end
        881: begin
            cosine_reg0 <= 18'sb000110111101101010;
            sine_reg0   <= 18'sb011111001110111010;
        end
        882: begin
            cosine_reg0 <= 18'sb000110111010100101;
            sine_reg0   <= 18'sb011111001111100110;
        end
        883: begin
            cosine_reg0 <= 18'sb000110110111100001;
            sine_reg0   <= 18'sb011111010000010001;
        end
        884: begin
            cosine_reg0 <= 18'sb000110110100011101;
            sine_reg0   <= 18'sb011111010000111100;
        end
        885: begin
            cosine_reg0 <= 18'sb000110110001011000;
            sine_reg0   <= 18'sb011111010001100111;
        end
        886: begin
            cosine_reg0 <= 18'sb000110101110010100;
            sine_reg0   <= 18'sb011111010010010001;
        end
        887: begin
            cosine_reg0 <= 18'sb000110101011001111;
            sine_reg0   <= 18'sb011111010010111011;
        end
        888: begin
            cosine_reg0 <= 18'sb000110101000001010;
            sine_reg0   <= 18'sb011111010011100101;
        end
        889: begin
            cosine_reg0 <= 18'sb000110100101000110;
            sine_reg0   <= 18'sb011111010100001111;
        end
        890: begin
            cosine_reg0 <= 18'sb000110100010000001;
            sine_reg0   <= 18'sb011111010100111000;
        end
        891: begin
            cosine_reg0 <= 18'sb000110011110111100;
            sine_reg0   <= 18'sb011111010101100001;
        end
        892: begin
            cosine_reg0 <= 18'sb000110011011110111;
            sine_reg0   <= 18'sb011111010110001001;
        end
        893: begin
            cosine_reg0 <= 18'sb000110011000110010;
            sine_reg0   <= 18'sb011111010110110001;
        end
        894: begin
            cosine_reg0 <= 18'sb000110010101101101;
            sine_reg0   <= 18'sb011111010111011001;
        end
        895: begin
            cosine_reg0 <= 18'sb000110010010101000;
            sine_reg0   <= 18'sb011111011000000001;
        end
        896: begin
            cosine_reg0 <= 18'sb000110001111100011;
            sine_reg0   <= 18'sb011111011000101001;
        end
        897: begin
            cosine_reg0 <= 18'sb000110001100011101;
            sine_reg0   <= 18'sb011111011001010000;
        end
        898: begin
            cosine_reg0 <= 18'sb000110001001011000;
            sine_reg0   <= 18'sb011111011001110110;
        end
        899: begin
            cosine_reg0 <= 18'sb000110000110010011;
            sine_reg0   <= 18'sb011111011010011101;
        end
        900: begin
            cosine_reg0 <= 18'sb000110000011001101;
            sine_reg0   <= 18'sb011111011011000011;
        end
        901: begin
            cosine_reg0 <= 18'sb000110000000001000;
            sine_reg0   <= 18'sb011111011011101001;
        end
        902: begin
            cosine_reg0 <= 18'sb000101111101000010;
            sine_reg0   <= 18'sb011111011100001110;
        end
        903: begin
            cosine_reg0 <= 18'sb000101111001111101;
            sine_reg0   <= 18'sb011111011100110100;
        end
        904: begin
            cosine_reg0 <= 18'sb000101110110110111;
            sine_reg0   <= 18'sb011111011101011001;
        end
        905: begin
            cosine_reg0 <= 18'sb000101110011110010;
            sine_reg0   <= 18'sb011111011101111101;
        end
        906: begin
            cosine_reg0 <= 18'sb000101110000101100;
            sine_reg0   <= 18'sb011111011110100010;
        end
        907: begin
            cosine_reg0 <= 18'sb000101101101100110;
            sine_reg0   <= 18'sb011111011111000110;
        end
        908: begin
            cosine_reg0 <= 18'sb000101101010100000;
            sine_reg0   <= 18'sb011111011111101001;
        end
        909: begin
            cosine_reg0 <= 18'sb000101100111011010;
            sine_reg0   <= 18'sb011111100000001101;
        end
        910: begin
            cosine_reg0 <= 18'sb000101100100010100;
            sine_reg0   <= 18'sb011111100000110000;
        end
        911: begin
            cosine_reg0 <= 18'sb000101100001001110;
            sine_reg0   <= 18'sb011111100001010011;
        end
        912: begin
            cosine_reg0 <= 18'sb000101011110001000;
            sine_reg0   <= 18'sb011111100001110101;
        end
        913: begin
            cosine_reg0 <= 18'sb000101011011000010;
            sine_reg0   <= 18'sb011111100010011000;
        end
        914: begin
            cosine_reg0 <= 18'sb000101010111111100;
            sine_reg0   <= 18'sb011111100010111001;
        end
        915: begin
            cosine_reg0 <= 18'sb000101010100110110;
            sine_reg0   <= 18'sb011111100011011011;
        end
        916: begin
            cosine_reg0 <= 18'sb000101010001101111;
            sine_reg0   <= 18'sb011111100011111100;
        end
        917: begin
            cosine_reg0 <= 18'sb000101001110101001;
            sine_reg0   <= 18'sb011111100100011101;
        end
        918: begin
            cosine_reg0 <= 18'sb000101001011100011;
            sine_reg0   <= 18'sb011111100100111110;
        end
        919: begin
            cosine_reg0 <= 18'sb000101001000011100;
            sine_reg0   <= 18'sb011111100101011110;
        end
        920: begin
            cosine_reg0 <= 18'sb000101000101010110;
            sine_reg0   <= 18'sb011111100101111111;
        end
        921: begin
            cosine_reg0 <= 18'sb000101000010001111;
            sine_reg0   <= 18'sb011111100110011110;
        end
        922: begin
            cosine_reg0 <= 18'sb000100111111001001;
            sine_reg0   <= 18'sb011111100110111110;
        end
        923: begin
            cosine_reg0 <= 18'sb000100111100000010;
            sine_reg0   <= 18'sb011111100111011101;
        end
        924: begin
            cosine_reg0 <= 18'sb000100111000111011;
            sine_reg0   <= 18'sb011111100111111100;
        end
        925: begin
            cosine_reg0 <= 18'sb000100110101110101;
            sine_reg0   <= 18'sb011111101000011010;
        end
        926: begin
            cosine_reg0 <= 18'sb000100110010101110;
            sine_reg0   <= 18'sb011111101000111001;
        end
        927: begin
            cosine_reg0 <= 18'sb000100101111100111;
            sine_reg0   <= 18'sb011111101001010111;
        end
        928: begin
            cosine_reg0 <= 18'sb000100101100100000;
            sine_reg0   <= 18'sb011111101001110100;
        end
        929: begin
            cosine_reg0 <= 18'sb000100101001011001;
            sine_reg0   <= 18'sb011111101010010010;
        end
        930: begin
            cosine_reg0 <= 18'sb000100100110010010;
            sine_reg0   <= 18'sb011111101010101111;
        end
        931: begin
            cosine_reg0 <= 18'sb000100100011001011;
            sine_reg0   <= 18'sb011111101011001011;
        end
        932: begin
            cosine_reg0 <= 18'sb000100100000000100;
            sine_reg0   <= 18'sb011111101011101000;
        end
        933: begin
            cosine_reg0 <= 18'sb000100011100111101;
            sine_reg0   <= 18'sb011111101100000100;
        end
        934: begin
            cosine_reg0 <= 18'sb000100011001110110;
            sine_reg0   <= 18'sb011111101100100000;
        end
        935: begin
            cosine_reg0 <= 18'sb000100010110101111;
            sine_reg0   <= 18'sb011111101100111011;
        end
        936: begin
            cosine_reg0 <= 18'sb000100010011101000;
            sine_reg0   <= 18'sb011111101101010111;
        end
        937: begin
            cosine_reg0 <= 18'sb000100010000100000;
            sine_reg0   <= 18'sb011111101101110010;
        end
        938: begin
            cosine_reg0 <= 18'sb000100001101011001;
            sine_reg0   <= 18'sb011111101110001100;
        end
        939: begin
            cosine_reg0 <= 18'sb000100001010010010;
            sine_reg0   <= 18'sb011111101110100110;
        end
        940: begin
            cosine_reg0 <= 18'sb000100000111001010;
            sine_reg0   <= 18'sb011111101111000000;
        end
        941: begin
            cosine_reg0 <= 18'sb000100000100000011;
            sine_reg0   <= 18'sb011111101111011010;
        end
        942: begin
            cosine_reg0 <= 18'sb000100000000111100;
            sine_reg0   <= 18'sb011111101111110011;
        end
        943: begin
            cosine_reg0 <= 18'sb000011111101110100;
            sine_reg0   <= 18'sb011111110000001101;
        end
        944: begin
            cosine_reg0 <= 18'sb000011111010101100;
            sine_reg0   <= 18'sb011111110000100101;
        end
        945: begin
            cosine_reg0 <= 18'sb000011110111100101;
            sine_reg0   <= 18'sb011111110000111110;
        end
        946: begin
            cosine_reg0 <= 18'sb000011110100011101;
            sine_reg0   <= 18'sb011111110001010110;
        end
        947: begin
            cosine_reg0 <= 18'sb000011110001010110;
            sine_reg0   <= 18'sb011111110001101110;
        end
        948: begin
            cosine_reg0 <= 18'sb000011101110001110;
            sine_reg0   <= 18'sb011111110010000101;
        end
        949: begin
            cosine_reg0 <= 18'sb000011101011000110;
            sine_reg0   <= 18'sb011111110010011101;
        end
        950: begin
            cosine_reg0 <= 18'sb000011100111111111;
            sine_reg0   <= 18'sb011111110010110011;
        end
        951: begin
            cosine_reg0 <= 18'sb000011100100110111;
            sine_reg0   <= 18'sb011111110011001010;
        end
        952: begin
            cosine_reg0 <= 18'sb000011100001101111;
            sine_reg0   <= 18'sb011111110011100000;
        end
        953: begin
            cosine_reg0 <= 18'sb000011011110100111;
            sine_reg0   <= 18'sb011111110011110110;
        end
        954: begin
            cosine_reg0 <= 18'sb000011011011011111;
            sine_reg0   <= 18'sb011111110100001100;
        end
        955: begin
            cosine_reg0 <= 18'sb000011011000010111;
            sine_reg0   <= 18'sb011111110100100001;
        end
        956: begin
            cosine_reg0 <= 18'sb000011010101001111;
            sine_reg0   <= 18'sb011111110100110111;
        end
        957: begin
            cosine_reg0 <= 18'sb000011010010000111;
            sine_reg0   <= 18'sb011111110101001011;
        end
        958: begin
            cosine_reg0 <= 18'sb000011001110111111;
            sine_reg0   <= 18'sb011111110101100000;
        end
        959: begin
            cosine_reg0 <= 18'sb000011001011110111;
            sine_reg0   <= 18'sb011111110101110100;
        end
        960: begin
            cosine_reg0 <= 18'sb000011001000101111;
            sine_reg0   <= 18'sb011111110110001000;
        end
        961: begin
            cosine_reg0 <= 18'sb000011000101100111;
            sine_reg0   <= 18'sb011111110110011011;
        end
        962: begin
            cosine_reg0 <= 18'sb000011000010011111;
            sine_reg0   <= 18'sb011111110110101111;
        end
        963: begin
            cosine_reg0 <= 18'sb000010111111010111;
            sine_reg0   <= 18'sb011111110111000010;
        end
        964: begin
            cosine_reg0 <= 18'sb000010111100001111;
            sine_reg0   <= 18'sb011111110111010100;
        end
        965: begin
            cosine_reg0 <= 18'sb000010111001000110;
            sine_reg0   <= 18'sb011111110111100111;
        end
        966: begin
            cosine_reg0 <= 18'sb000010110101111110;
            sine_reg0   <= 18'sb011111110111111001;
        end
        967: begin
            cosine_reg0 <= 18'sb000010110010110110;
            sine_reg0   <= 18'sb011111111000001010;
        end
        968: begin
            cosine_reg0 <= 18'sb000010101111101110;
            sine_reg0   <= 18'sb011111111000011100;
        end
        969: begin
            cosine_reg0 <= 18'sb000010101100100101;
            sine_reg0   <= 18'sb011111111000101101;
        end
        970: begin
            cosine_reg0 <= 18'sb000010101001011101;
            sine_reg0   <= 18'sb011111111000111110;
        end
        971: begin
            cosine_reg0 <= 18'sb000010100110010100;
            sine_reg0   <= 18'sb011111111001001110;
        end
        972: begin
            cosine_reg0 <= 18'sb000010100011001100;
            sine_reg0   <= 18'sb011111111001011110;
        end
        973: begin
            cosine_reg0 <= 18'sb000010100000000100;
            sine_reg0   <= 18'sb011111111001101110;
        end
        974: begin
            cosine_reg0 <= 18'sb000010011100111011;
            sine_reg0   <= 18'sb011111111001111110;
        end
        975: begin
            cosine_reg0 <= 18'sb000010011001110011;
            sine_reg0   <= 18'sb011111111010001101;
        end
        976: begin
            cosine_reg0 <= 18'sb000010010110101010;
            sine_reg0   <= 18'sb011111111010011100;
        end
        977: begin
            cosine_reg0 <= 18'sb000010010011100010;
            sine_reg0   <= 18'sb011111111010101010;
        end
        978: begin
            cosine_reg0 <= 18'sb000010010000011001;
            sine_reg0   <= 18'sb011111111010111001;
        end
        979: begin
            cosine_reg0 <= 18'sb000010001101010001;
            sine_reg0   <= 18'sb011111111011000111;
        end
        980: begin
            cosine_reg0 <= 18'sb000010001010001000;
            sine_reg0   <= 18'sb011111111011010101;
        end
        981: begin
            cosine_reg0 <= 18'sb000010000110111111;
            sine_reg0   <= 18'sb011111111011100010;
        end
        982: begin
            cosine_reg0 <= 18'sb000010000011110111;
            sine_reg0   <= 18'sb011111111011101111;
        end
        983: begin
            cosine_reg0 <= 18'sb000010000000101110;
            sine_reg0   <= 18'sb011111111011111100;
        end
        984: begin
            cosine_reg0 <= 18'sb000001111101100101;
            sine_reg0   <= 18'sb011111111100001000;
        end
        985: begin
            cosine_reg0 <= 18'sb000001111010011101;
            sine_reg0   <= 18'sb011111111100010101;
        end
        986: begin
            cosine_reg0 <= 18'sb000001110111010100;
            sine_reg0   <= 18'sb011111111100100000;
        end
        987: begin
            cosine_reg0 <= 18'sb000001110100001011;
            sine_reg0   <= 18'sb011111111100101100;
        end
        988: begin
            cosine_reg0 <= 18'sb000001110001000010;
            sine_reg0   <= 18'sb011111111100110111;
        end
        989: begin
            cosine_reg0 <= 18'sb000001101101111010;
            sine_reg0   <= 18'sb011111111101000010;
        end
        990: begin
            cosine_reg0 <= 18'sb000001101010110001;
            sine_reg0   <= 18'sb011111111101001101;
        end
        991: begin
            cosine_reg0 <= 18'sb000001100111101000;
            sine_reg0   <= 18'sb011111111101010111;
        end
        992: begin
            cosine_reg0 <= 18'sb000001100100011111;
            sine_reg0   <= 18'sb011111111101100001;
        end
        993: begin
            cosine_reg0 <= 18'sb000001100001010111;
            sine_reg0   <= 18'sb011111111101101011;
        end
        994: begin
            cosine_reg0 <= 18'sb000001011110001110;
            sine_reg0   <= 18'sb011111111101110100;
        end
        995: begin
            cosine_reg0 <= 18'sb000001011011000101;
            sine_reg0   <= 18'sb011111111101111101;
        end
        996: begin
            cosine_reg0 <= 18'sb000001010111111100;
            sine_reg0   <= 18'sb011111111110000110;
        end
        997: begin
            cosine_reg0 <= 18'sb000001010100110011;
            sine_reg0   <= 18'sb011111111110001111;
        end
        998: begin
            cosine_reg0 <= 18'sb000001010001101010;
            sine_reg0   <= 18'sb011111111110010111;
        end
        999: begin
            cosine_reg0 <= 18'sb000001001110100001;
            sine_reg0   <= 18'sb011111111110011111;
        end
        1000: begin
            cosine_reg0 <= 18'sb000001001011011000;
            sine_reg0   <= 18'sb011111111110100110;
        end
        1001: begin
            cosine_reg0 <= 18'sb000001001000001111;
            sine_reg0   <= 18'sb011111111110101101;
        end
        1002: begin
            cosine_reg0 <= 18'sb000001000101000110;
            sine_reg0   <= 18'sb011111111110110100;
        end
        1003: begin
            cosine_reg0 <= 18'sb000001000001111110;
            sine_reg0   <= 18'sb011111111110111011;
        end
        1004: begin
            cosine_reg0 <= 18'sb000000111110110101;
            sine_reg0   <= 18'sb011111111111000001;
        end
        1005: begin
            cosine_reg0 <= 18'sb000000111011101100;
            sine_reg0   <= 18'sb011111111111000111;
        end
        1006: begin
            cosine_reg0 <= 18'sb000000111000100011;
            sine_reg0   <= 18'sb011111111111001101;
        end
        1007: begin
            cosine_reg0 <= 18'sb000000110101011010;
            sine_reg0   <= 18'sb011111111111010010;
        end
        1008: begin
            cosine_reg0 <= 18'sb000000110010010001;
            sine_reg0   <= 18'sb011111111111011000;
        end
        1009: begin
            cosine_reg0 <= 18'sb000000101111001000;
            sine_reg0   <= 18'sb011111111111011100;
        end
        1010: begin
            cosine_reg0 <= 18'sb000000101011111111;
            sine_reg0   <= 18'sb011111111111100001;
        end
        1011: begin
            cosine_reg0 <= 18'sb000000101000110110;
            sine_reg0   <= 18'sb011111111111100101;
        end
        1012: begin
            cosine_reg0 <= 18'sb000000100101101101;
            sine_reg0   <= 18'sb011111111111101001;
        end
        1013: begin
            cosine_reg0 <= 18'sb000000100010100100;
            sine_reg0   <= 18'sb011111111111101100;
        end
        1014: begin
            cosine_reg0 <= 18'sb000000011111011011;
            sine_reg0   <= 18'sb011111111111110000;
        end
        1015: begin
            cosine_reg0 <= 18'sb000000011100010001;
            sine_reg0   <= 18'sb011111111111110011;
        end
        1016: begin
            cosine_reg0 <= 18'sb000000011001001000;
            sine_reg0   <= 18'sb011111111111110101;
        end
        1017: begin
            cosine_reg0 <= 18'sb000000010101111111;
            sine_reg0   <= 18'sb011111111111110111;
        end
        1018: begin
            cosine_reg0 <= 18'sb000000010010110110;
            sine_reg0   <= 18'sb011111111111111001;
        end
        1019: begin
            cosine_reg0 <= 18'sb000000001111101101;
            sine_reg0   <= 18'sb011111111111111011;
        end
        1020: begin
            cosine_reg0 <= 18'sb000000001100100100;
            sine_reg0   <= 18'sb011111111111111101;
        end
        1021: begin
            cosine_reg0 <= 18'sb000000001001011011;
            sine_reg0   <= 18'sb011111111111111110;
        end
        1022: begin
            cosine_reg0 <= 18'sb000000000110010010;
            sine_reg0   <= 18'sb011111111111111110;
        end
        1023: begin
            cosine_reg0 <= 18'sb000000000011001001;
            sine_reg0   <= 18'sb011111111111111111;
        end
        1024: begin
            cosine_reg0 <= 18'sb000000000000000000;
            sine_reg0   <= 18'sb011111111111111111;
        end
        1025: begin
            cosine_reg0 <= 18'sb111111111100110111;
            sine_reg0   <= 18'sb011111111111111111;
        end
        1026: begin
            cosine_reg0 <= 18'sb111111111001101110;
            sine_reg0   <= 18'sb011111111111111110;
        end
        1027: begin
            cosine_reg0 <= 18'sb111111110110100101;
            sine_reg0   <= 18'sb011111111111111110;
        end
        1028: begin
            cosine_reg0 <= 18'sb111111110011011100;
            sine_reg0   <= 18'sb011111111111111101;
        end
        1029: begin
            cosine_reg0 <= 18'sb111111110000010011;
            sine_reg0   <= 18'sb011111111111111011;
        end
        1030: begin
            cosine_reg0 <= 18'sb111111101101001010;
            sine_reg0   <= 18'sb011111111111111001;
        end
        1031: begin
            cosine_reg0 <= 18'sb111111101010000001;
            sine_reg0   <= 18'sb011111111111110111;
        end
        1032: begin
            cosine_reg0 <= 18'sb111111100110111000;
            sine_reg0   <= 18'sb011111111111110101;
        end
        1033: begin
            cosine_reg0 <= 18'sb111111100011101111;
            sine_reg0   <= 18'sb011111111111110011;
        end
        1034: begin
            cosine_reg0 <= 18'sb111111100000100101;
            sine_reg0   <= 18'sb011111111111110000;
        end
        1035: begin
            cosine_reg0 <= 18'sb111111011101011100;
            sine_reg0   <= 18'sb011111111111101100;
        end
        1036: begin
            cosine_reg0 <= 18'sb111111011010010011;
            sine_reg0   <= 18'sb011111111111101001;
        end
        1037: begin
            cosine_reg0 <= 18'sb111111010111001010;
            sine_reg0   <= 18'sb011111111111100101;
        end
        1038: begin
            cosine_reg0 <= 18'sb111111010100000001;
            sine_reg0   <= 18'sb011111111111100001;
        end
        1039: begin
            cosine_reg0 <= 18'sb111111010000111000;
            sine_reg0   <= 18'sb011111111111011100;
        end
        1040: begin
            cosine_reg0 <= 18'sb111111001101101111;
            sine_reg0   <= 18'sb011111111111011000;
        end
        1041: begin
            cosine_reg0 <= 18'sb111111001010100110;
            sine_reg0   <= 18'sb011111111111010010;
        end
        1042: begin
            cosine_reg0 <= 18'sb111111000111011101;
            sine_reg0   <= 18'sb011111111111001101;
        end
        1043: begin
            cosine_reg0 <= 18'sb111111000100010100;
            sine_reg0   <= 18'sb011111111111000111;
        end
        1044: begin
            cosine_reg0 <= 18'sb111111000001001011;
            sine_reg0   <= 18'sb011111111111000001;
        end
        1045: begin
            cosine_reg0 <= 18'sb111110111110000010;
            sine_reg0   <= 18'sb011111111110111011;
        end
        1046: begin
            cosine_reg0 <= 18'sb111110111010111010;
            sine_reg0   <= 18'sb011111111110110100;
        end
        1047: begin
            cosine_reg0 <= 18'sb111110110111110001;
            sine_reg0   <= 18'sb011111111110101101;
        end
        1048: begin
            cosine_reg0 <= 18'sb111110110100101000;
            sine_reg0   <= 18'sb011111111110100110;
        end
        1049: begin
            cosine_reg0 <= 18'sb111110110001011111;
            sine_reg0   <= 18'sb011111111110011111;
        end
        1050: begin
            cosine_reg0 <= 18'sb111110101110010110;
            sine_reg0   <= 18'sb011111111110010111;
        end
        1051: begin
            cosine_reg0 <= 18'sb111110101011001101;
            sine_reg0   <= 18'sb011111111110001111;
        end
        1052: begin
            cosine_reg0 <= 18'sb111110101000000100;
            sine_reg0   <= 18'sb011111111110000110;
        end
        1053: begin
            cosine_reg0 <= 18'sb111110100100111011;
            sine_reg0   <= 18'sb011111111101111101;
        end
        1054: begin
            cosine_reg0 <= 18'sb111110100001110010;
            sine_reg0   <= 18'sb011111111101110100;
        end
        1055: begin
            cosine_reg0 <= 18'sb111110011110101001;
            sine_reg0   <= 18'sb011111111101101011;
        end
        1056: begin
            cosine_reg0 <= 18'sb111110011011100001;
            sine_reg0   <= 18'sb011111111101100001;
        end
        1057: begin
            cosine_reg0 <= 18'sb111110011000011000;
            sine_reg0   <= 18'sb011111111101010111;
        end
        1058: begin
            cosine_reg0 <= 18'sb111110010101001111;
            sine_reg0   <= 18'sb011111111101001101;
        end
        1059: begin
            cosine_reg0 <= 18'sb111110010010000110;
            sine_reg0   <= 18'sb011111111101000010;
        end
        1060: begin
            cosine_reg0 <= 18'sb111110001110111110;
            sine_reg0   <= 18'sb011111111100110111;
        end
        1061: begin
            cosine_reg0 <= 18'sb111110001011110101;
            sine_reg0   <= 18'sb011111111100101100;
        end
        1062: begin
            cosine_reg0 <= 18'sb111110001000101100;
            sine_reg0   <= 18'sb011111111100100000;
        end
        1063: begin
            cosine_reg0 <= 18'sb111110000101100011;
            sine_reg0   <= 18'sb011111111100010101;
        end
        1064: begin
            cosine_reg0 <= 18'sb111110000010011011;
            sine_reg0   <= 18'sb011111111100001000;
        end
        1065: begin
            cosine_reg0 <= 18'sb111101111111010010;
            sine_reg0   <= 18'sb011111111011111100;
        end
        1066: begin
            cosine_reg0 <= 18'sb111101111100001001;
            sine_reg0   <= 18'sb011111111011101111;
        end
        1067: begin
            cosine_reg0 <= 18'sb111101111001000001;
            sine_reg0   <= 18'sb011111111011100010;
        end
        1068: begin
            cosine_reg0 <= 18'sb111101110101111000;
            sine_reg0   <= 18'sb011111111011010101;
        end
        1069: begin
            cosine_reg0 <= 18'sb111101110010101111;
            sine_reg0   <= 18'sb011111111011000111;
        end
        1070: begin
            cosine_reg0 <= 18'sb111101101111100111;
            sine_reg0   <= 18'sb011111111010111001;
        end
        1071: begin
            cosine_reg0 <= 18'sb111101101100011110;
            sine_reg0   <= 18'sb011111111010101010;
        end
        1072: begin
            cosine_reg0 <= 18'sb111101101001010110;
            sine_reg0   <= 18'sb011111111010011100;
        end
        1073: begin
            cosine_reg0 <= 18'sb111101100110001101;
            sine_reg0   <= 18'sb011111111010001101;
        end
        1074: begin
            cosine_reg0 <= 18'sb111101100011000101;
            sine_reg0   <= 18'sb011111111001111110;
        end
        1075: begin
            cosine_reg0 <= 18'sb111101011111111100;
            sine_reg0   <= 18'sb011111111001101110;
        end
        1076: begin
            cosine_reg0 <= 18'sb111101011100110100;
            sine_reg0   <= 18'sb011111111001011110;
        end
        1077: begin
            cosine_reg0 <= 18'sb111101011001101100;
            sine_reg0   <= 18'sb011111111001001110;
        end
        1078: begin
            cosine_reg0 <= 18'sb111101010110100011;
            sine_reg0   <= 18'sb011111111000111110;
        end
        1079: begin
            cosine_reg0 <= 18'sb111101010011011011;
            sine_reg0   <= 18'sb011111111000101101;
        end
        1080: begin
            cosine_reg0 <= 18'sb111101010000010010;
            sine_reg0   <= 18'sb011111111000011100;
        end
        1081: begin
            cosine_reg0 <= 18'sb111101001101001010;
            sine_reg0   <= 18'sb011111111000001010;
        end
        1082: begin
            cosine_reg0 <= 18'sb111101001010000010;
            sine_reg0   <= 18'sb011111110111111001;
        end
        1083: begin
            cosine_reg0 <= 18'sb111101000110111010;
            sine_reg0   <= 18'sb011111110111100111;
        end
        1084: begin
            cosine_reg0 <= 18'sb111101000011110001;
            sine_reg0   <= 18'sb011111110111010100;
        end
        1085: begin
            cosine_reg0 <= 18'sb111101000000101001;
            sine_reg0   <= 18'sb011111110111000010;
        end
        1086: begin
            cosine_reg0 <= 18'sb111100111101100001;
            sine_reg0   <= 18'sb011111110110101111;
        end
        1087: begin
            cosine_reg0 <= 18'sb111100111010011001;
            sine_reg0   <= 18'sb011111110110011011;
        end
        1088: begin
            cosine_reg0 <= 18'sb111100110111010001;
            sine_reg0   <= 18'sb011111110110001000;
        end
        1089: begin
            cosine_reg0 <= 18'sb111100110100001001;
            sine_reg0   <= 18'sb011111110101110100;
        end
        1090: begin
            cosine_reg0 <= 18'sb111100110001000001;
            sine_reg0   <= 18'sb011111110101100000;
        end
        1091: begin
            cosine_reg0 <= 18'sb111100101101111001;
            sine_reg0   <= 18'sb011111110101001011;
        end
        1092: begin
            cosine_reg0 <= 18'sb111100101010110001;
            sine_reg0   <= 18'sb011111110100110111;
        end
        1093: begin
            cosine_reg0 <= 18'sb111100100111101001;
            sine_reg0   <= 18'sb011111110100100001;
        end
        1094: begin
            cosine_reg0 <= 18'sb111100100100100001;
            sine_reg0   <= 18'sb011111110100001100;
        end
        1095: begin
            cosine_reg0 <= 18'sb111100100001011001;
            sine_reg0   <= 18'sb011111110011110110;
        end
        1096: begin
            cosine_reg0 <= 18'sb111100011110010001;
            sine_reg0   <= 18'sb011111110011100000;
        end
        1097: begin
            cosine_reg0 <= 18'sb111100011011001001;
            sine_reg0   <= 18'sb011111110011001010;
        end
        1098: begin
            cosine_reg0 <= 18'sb111100011000000001;
            sine_reg0   <= 18'sb011111110010110011;
        end
        1099: begin
            cosine_reg0 <= 18'sb111100010100111010;
            sine_reg0   <= 18'sb011111110010011101;
        end
        1100: begin
            cosine_reg0 <= 18'sb111100010001110010;
            sine_reg0   <= 18'sb011111110010000101;
        end
        1101: begin
            cosine_reg0 <= 18'sb111100001110101010;
            sine_reg0   <= 18'sb011111110001101110;
        end
        1102: begin
            cosine_reg0 <= 18'sb111100001011100011;
            sine_reg0   <= 18'sb011111110001010110;
        end
        1103: begin
            cosine_reg0 <= 18'sb111100001000011011;
            sine_reg0   <= 18'sb011111110000111110;
        end
        1104: begin
            cosine_reg0 <= 18'sb111100000101010100;
            sine_reg0   <= 18'sb011111110000100101;
        end
        1105: begin
            cosine_reg0 <= 18'sb111100000010001100;
            sine_reg0   <= 18'sb011111110000001101;
        end
        1106: begin
            cosine_reg0 <= 18'sb111011111111000100;
            sine_reg0   <= 18'sb011111101111110011;
        end
        1107: begin
            cosine_reg0 <= 18'sb111011111011111101;
            sine_reg0   <= 18'sb011111101111011010;
        end
        1108: begin
            cosine_reg0 <= 18'sb111011111000110110;
            sine_reg0   <= 18'sb011111101111000000;
        end
        1109: begin
            cosine_reg0 <= 18'sb111011110101101110;
            sine_reg0   <= 18'sb011111101110100110;
        end
        1110: begin
            cosine_reg0 <= 18'sb111011110010100111;
            sine_reg0   <= 18'sb011111101110001100;
        end
        1111: begin
            cosine_reg0 <= 18'sb111011101111100000;
            sine_reg0   <= 18'sb011111101101110010;
        end
        1112: begin
            cosine_reg0 <= 18'sb111011101100011000;
            sine_reg0   <= 18'sb011111101101010111;
        end
        1113: begin
            cosine_reg0 <= 18'sb111011101001010001;
            sine_reg0   <= 18'sb011111101100111011;
        end
        1114: begin
            cosine_reg0 <= 18'sb111011100110001010;
            sine_reg0   <= 18'sb011111101100100000;
        end
        1115: begin
            cosine_reg0 <= 18'sb111011100011000011;
            sine_reg0   <= 18'sb011111101100000100;
        end
        1116: begin
            cosine_reg0 <= 18'sb111011011111111100;
            sine_reg0   <= 18'sb011111101011101000;
        end
        1117: begin
            cosine_reg0 <= 18'sb111011011100110101;
            sine_reg0   <= 18'sb011111101011001011;
        end
        1118: begin
            cosine_reg0 <= 18'sb111011011001101110;
            sine_reg0   <= 18'sb011111101010101111;
        end
        1119: begin
            cosine_reg0 <= 18'sb111011010110100111;
            sine_reg0   <= 18'sb011111101010010010;
        end
        1120: begin
            cosine_reg0 <= 18'sb111011010011100000;
            sine_reg0   <= 18'sb011111101001110100;
        end
        1121: begin
            cosine_reg0 <= 18'sb111011010000011001;
            sine_reg0   <= 18'sb011111101001010111;
        end
        1122: begin
            cosine_reg0 <= 18'sb111011001101010010;
            sine_reg0   <= 18'sb011111101000111001;
        end
        1123: begin
            cosine_reg0 <= 18'sb111011001010001011;
            sine_reg0   <= 18'sb011111101000011010;
        end
        1124: begin
            cosine_reg0 <= 18'sb111011000111000101;
            sine_reg0   <= 18'sb011111100111111100;
        end
        1125: begin
            cosine_reg0 <= 18'sb111011000011111110;
            sine_reg0   <= 18'sb011111100111011101;
        end
        1126: begin
            cosine_reg0 <= 18'sb111011000000110111;
            sine_reg0   <= 18'sb011111100110111110;
        end
        1127: begin
            cosine_reg0 <= 18'sb111010111101110001;
            sine_reg0   <= 18'sb011111100110011110;
        end
        1128: begin
            cosine_reg0 <= 18'sb111010111010101010;
            sine_reg0   <= 18'sb011111100101111111;
        end
        1129: begin
            cosine_reg0 <= 18'sb111010110111100100;
            sine_reg0   <= 18'sb011111100101011110;
        end
        1130: begin
            cosine_reg0 <= 18'sb111010110100011101;
            sine_reg0   <= 18'sb011111100100111110;
        end
        1131: begin
            cosine_reg0 <= 18'sb111010110001010111;
            sine_reg0   <= 18'sb011111100100011101;
        end
        1132: begin
            cosine_reg0 <= 18'sb111010101110010001;
            sine_reg0   <= 18'sb011111100011111100;
        end
        1133: begin
            cosine_reg0 <= 18'sb111010101011001010;
            sine_reg0   <= 18'sb011111100011011011;
        end
        1134: begin
            cosine_reg0 <= 18'sb111010101000000100;
            sine_reg0   <= 18'sb011111100010111001;
        end
        1135: begin
            cosine_reg0 <= 18'sb111010100100111110;
            sine_reg0   <= 18'sb011111100010011000;
        end
        1136: begin
            cosine_reg0 <= 18'sb111010100001111000;
            sine_reg0   <= 18'sb011111100001110101;
        end
        1137: begin
            cosine_reg0 <= 18'sb111010011110110010;
            sine_reg0   <= 18'sb011111100001010011;
        end
        1138: begin
            cosine_reg0 <= 18'sb111010011011101100;
            sine_reg0   <= 18'sb011111100000110000;
        end
        1139: begin
            cosine_reg0 <= 18'sb111010011000100110;
            sine_reg0   <= 18'sb011111100000001101;
        end
        1140: begin
            cosine_reg0 <= 18'sb111010010101100000;
            sine_reg0   <= 18'sb011111011111101001;
        end
        1141: begin
            cosine_reg0 <= 18'sb111010010010011010;
            sine_reg0   <= 18'sb011111011111000110;
        end
        1142: begin
            cosine_reg0 <= 18'sb111010001111010100;
            sine_reg0   <= 18'sb011111011110100010;
        end
        1143: begin
            cosine_reg0 <= 18'sb111010001100001110;
            sine_reg0   <= 18'sb011111011101111101;
        end
        1144: begin
            cosine_reg0 <= 18'sb111010001001001001;
            sine_reg0   <= 18'sb011111011101011001;
        end
        1145: begin
            cosine_reg0 <= 18'sb111010000110000011;
            sine_reg0   <= 18'sb011111011100110100;
        end
        1146: begin
            cosine_reg0 <= 18'sb111010000010111110;
            sine_reg0   <= 18'sb011111011100001110;
        end
        1147: begin
            cosine_reg0 <= 18'sb111001111111111000;
            sine_reg0   <= 18'sb011111011011101001;
        end
        1148: begin
            cosine_reg0 <= 18'sb111001111100110011;
            sine_reg0   <= 18'sb011111011011000011;
        end
        1149: begin
            cosine_reg0 <= 18'sb111001111001101101;
            sine_reg0   <= 18'sb011111011010011101;
        end
        1150: begin
            cosine_reg0 <= 18'sb111001110110101000;
            sine_reg0   <= 18'sb011111011001110110;
        end
        1151: begin
            cosine_reg0 <= 18'sb111001110011100011;
            sine_reg0   <= 18'sb011111011001010000;
        end
        1152: begin
            cosine_reg0 <= 18'sb111001110000011101;
            sine_reg0   <= 18'sb011111011000101001;
        end
        1153: begin
            cosine_reg0 <= 18'sb111001101101011000;
            sine_reg0   <= 18'sb011111011000000001;
        end
        1154: begin
            cosine_reg0 <= 18'sb111001101010010011;
            sine_reg0   <= 18'sb011111010111011001;
        end
        1155: begin
            cosine_reg0 <= 18'sb111001100111001110;
            sine_reg0   <= 18'sb011111010110110001;
        end
        1156: begin
            cosine_reg0 <= 18'sb111001100100001001;
            sine_reg0   <= 18'sb011111010110001001;
        end
        1157: begin
            cosine_reg0 <= 18'sb111001100001000100;
            sine_reg0   <= 18'sb011111010101100001;
        end
        1158: begin
            cosine_reg0 <= 18'sb111001011101111111;
            sine_reg0   <= 18'sb011111010100111000;
        end
        1159: begin
            cosine_reg0 <= 18'sb111001011010111010;
            sine_reg0   <= 18'sb011111010100001111;
        end
        1160: begin
            cosine_reg0 <= 18'sb111001010111110110;
            sine_reg0   <= 18'sb011111010011100101;
        end
        1161: begin
            cosine_reg0 <= 18'sb111001010100110001;
            sine_reg0   <= 18'sb011111010010111011;
        end
        1162: begin
            cosine_reg0 <= 18'sb111001010001101100;
            sine_reg0   <= 18'sb011111010010010001;
        end
        1163: begin
            cosine_reg0 <= 18'sb111001001110101000;
            sine_reg0   <= 18'sb011111010001100111;
        end
        1164: begin
            cosine_reg0 <= 18'sb111001001011100011;
            sine_reg0   <= 18'sb011111010000111100;
        end
        1165: begin
            cosine_reg0 <= 18'sb111001001000011111;
            sine_reg0   <= 18'sb011111010000010001;
        end
        1166: begin
            cosine_reg0 <= 18'sb111001000101011011;
            sine_reg0   <= 18'sb011111001111100110;
        end
        1167: begin
            cosine_reg0 <= 18'sb111001000010010110;
            sine_reg0   <= 18'sb011111001110111010;
        end
        1168: begin
            cosine_reg0 <= 18'sb111000111111010010;
            sine_reg0   <= 18'sb011111001110001110;
        end
        1169: begin
            cosine_reg0 <= 18'sb111000111100001110;
            sine_reg0   <= 18'sb011111001101100010;
        end
        1170: begin
            cosine_reg0 <= 18'sb111000111001001010;
            sine_reg0   <= 18'sb011111001100110110;
        end
        1171: begin
            cosine_reg0 <= 18'sb111000110110000110;
            sine_reg0   <= 18'sb011111001100001001;
        end
        1172: begin
            cosine_reg0 <= 18'sb111000110011000010;
            sine_reg0   <= 18'sb011111001011011100;
        end
        1173: begin
            cosine_reg0 <= 18'sb111000101111111110;
            sine_reg0   <= 18'sb011111001010101110;
        end
        1174: begin
            cosine_reg0 <= 18'sb111000101100111010;
            sine_reg0   <= 18'sb011111001010000001;
        end
        1175: begin
            cosine_reg0 <= 18'sb111000101001110111;
            sine_reg0   <= 18'sb011111001001010011;
        end
        1176: begin
            cosine_reg0 <= 18'sb111000100110110011;
            sine_reg0   <= 18'sb011111001000100100;
        end
        1177: begin
            cosine_reg0 <= 18'sb111000100011101111;
            sine_reg0   <= 18'sb011111000111110110;
        end
        1178: begin
            cosine_reg0 <= 18'sb111000100000101100;
            sine_reg0   <= 18'sb011111000111000111;
        end
        1179: begin
            cosine_reg0 <= 18'sb111000011101101000;
            sine_reg0   <= 18'sb011111000110010111;
        end
        1180: begin
            cosine_reg0 <= 18'sb111000011010100101;
            sine_reg0   <= 18'sb011111000101101000;
        end
        1181: begin
            cosine_reg0 <= 18'sb111000010111100010;
            sine_reg0   <= 18'sb011111000100111000;
        end
        1182: begin
            cosine_reg0 <= 18'sb111000010100011111;
            sine_reg0   <= 18'sb011111000100001000;
        end
        1183: begin
            cosine_reg0 <= 18'sb111000010001011011;
            sine_reg0   <= 18'sb011111000011011000;
        end
        1184: begin
            cosine_reg0 <= 18'sb111000001110011000;
            sine_reg0   <= 18'sb011111000010100111;
        end
        1185: begin
            cosine_reg0 <= 18'sb111000001011010101;
            sine_reg0   <= 18'sb011111000001110110;
        end
        1186: begin
            cosine_reg0 <= 18'sb111000001000010010;
            sine_reg0   <= 18'sb011111000001000101;
        end
        1187: begin
            cosine_reg0 <= 18'sb111000000101010000;
            sine_reg0   <= 18'sb011111000000010011;
        end
        1188: begin
            cosine_reg0 <= 18'sb111000000010001101;
            sine_reg0   <= 18'sb011110111111100001;
        end
        1189: begin
            cosine_reg0 <= 18'sb110111111111001010;
            sine_reg0   <= 18'sb011110111110101111;
        end
        1190: begin
            cosine_reg0 <= 18'sb110111111100001000;
            sine_reg0   <= 18'sb011110111101111100;
        end
        1191: begin
            cosine_reg0 <= 18'sb110111111001000101;
            sine_reg0   <= 18'sb011110111101001010;
        end
        1192: begin
            cosine_reg0 <= 18'sb110111110110000011;
            sine_reg0   <= 18'sb011110111100010111;
        end
        1193: begin
            cosine_reg0 <= 18'sb110111110011000000;
            sine_reg0   <= 18'sb011110111011100011;
        end
        1194: begin
            cosine_reg0 <= 18'sb110111101111111110;
            sine_reg0   <= 18'sb011110111010101111;
        end
        1195: begin
            cosine_reg0 <= 18'sb110111101100111100;
            sine_reg0   <= 18'sb011110111001111100;
        end
        1196: begin
            cosine_reg0 <= 18'sb110111101001111001;
            sine_reg0   <= 18'sb011110111001000111;
        end
        1197: begin
            cosine_reg0 <= 18'sb110111100110110111;
            sine_reg0   <= 18'sb011110111000010011;
        end
        1198: begin
            cosine_reg0 <= 18'sb110111100011110101;
            sine_reg0   <= 18'sb011110110111011110;
        end
        1199: begin
            cosine_reg0 <= 18'sb110111100000110100;
            sine_reg0   <= 18'sb011110110110101001;
        end
        1200: begin
            cosine_reg0 <= 18'sb110111011101110010;
            sine_reg0   <= 18'sb011110110101110011;
        end
        1201: begin
            cosine_reg0 <= 18'sb110111011010110000;
            sine_reg0   <= 18'sb011110110100111101;
        end
        1202: begin
            cosine_reg0 <= 18'sb110111010111101110;
            sine_reg0   <= 18'sb011110110100000111;
        end
        1203: begin
            cosine_reg0 <= 18'sb110111010100101101;
            sine_reg0   <= 18'sb011110110011010001;
        end
        1204: begin
            cosine_reg0 <= 18'sb110111010001101011;
            sine_reg0   <= 18'sb011110110010011010;
        end
        1205: begin
            cosine_reg0 <= 18'sb110111001110101010;
            sine_reg0   <= 18'sb011110110001100011;
        end
        1206: begin
            cosine_reg0 <= 18'sb110111001011101001;
            sine_reg0   <= 18'sb011110110000101100;
        end
        1207: begin
            cosine_reg0 <= 18'sb110111001000100111;
            sine_reg0   <= 18'sb011110101111110100;
        end
        1208: begin
            cosine_reg0 <= 18'sb110111000101100110;
            sine_reg0   <= 18'sb011110101110111101;
        end
        1209: begin
            cosine_reg0 <= 18'sb110111000010100101;
            sine_reg0   <= 18'sb011110101110000100;
        end
        1210: begin
            cosine_reg0 <= 18'sb110110111111100100;
            sine_reg0   <= 18'sb011110101101001100;
        end
        1211: begin
            cosine_reg0 <= 18'sb110110111100100011;
            sine_reg0   <= 18'sb011110101100010011;
        end
        1212: begin
            cosine_reg0 <= 18'sb110110111001100010;
            sine_reg0   <= 18'sb011110101011011010;
        end
        1213: begin
            cosine_reg0 <= 18'sb110110110110100010;
            sine_reg0   <= 18'sb011110101010100001;
        end
        1214: begin
            cosine_reg0 <= 18'sb110110110011100001;
            sine_reg0   <= 18'sb011110101001100111;
        end
        1215: begin
            cosine_reg0 <= 18'sb110110110000100001;
            sine_reg0   <= 18'sb011110101000101101;
        end
        1216: begin
            cosine_reg0 <= 18'sb110110101101100000;
            sine_reg0   <= 18'sb011110100111110011;
        end
        1217: begin
            cosine_reg0 <= 18'sb110110101010100000;
            sine_reg0   <= 18'sb011110100110111001;
        end
        1218: begin
            cosine_reg0 <= 18'sb110110100111011111;
            sine_reg0   <= 18'sb011110100101111110;
        end
        1219: begin
            cosine_reg0 <= 18'sb110110100100011111;
            sine_reg0   <= 18'sb011110100101000011;
        end
        1220: begin
            cosine_reg0 <= 18'sb110110100001011111;
            sine_reg0   <= 18'sb011110100100000111;
        end
        1221: begin
            cosine_reg0 <= 18'sb110110011110011111;
            sine_reg0   <= 18'sb011110100011001100;
        end
        1222: begin
            cosine_reg0 <= 18'sb110110011011011111;
            sine_reg0   <= 18'sb011110100010010000;
        end
        1223: begin
            cosine_reg0 <= 18'sb110110011000011111;
            sine_reg0   <= 18'sb011110100001010011;
        end
        1224: begin
            cosine_reg0 <= 18'sb110110010101100000;
            sine_reg0   <= 18'sb011110100000010111;
        end
        1225: begin
            cosine_reg0 <= 18'sb110110010010100000;
            sine_reg0   <= 18'sb011110011111011010;
        end
        1226: begin
            cosine_reg0 <= 18'sb110110001111100001;
            sine_reg0   <= 18'sb011110011110011101;
        end
        1227: begin
            cosine_reg0 <= 18'sb110110001100100001;
            sine_reg0   <= 18'sb011110011101011111;
        end
        1228: begin
            cosine_reg0 <= 18'sb110110001001100010;
            sine_reg0   <= 18'sb011110011100100010;
        end
        1229: begin
            cosine_reg0 <= 18'sb110110000110100011;
            sine_reg0   <= 18'sb011110011011100011;
        end
        1230: begin
            cosine_reg0 <= 18'sb110110000011100011;
            sine_reg0   <= 18'sb011110011010100101;
        end
        1231: begin
            cosine_reg0 <= 18'sb110110000000100100;
            sine_reg0   <= 18'sb011110011001100111;
        end
        1232: begin
            cosine_reg0 <= 18'sb110101111101100101;
            sine_reg0   <= 18'sb011110011000101000;
        end
        1233: begin
            cosine_reg0 <= 18'sb110101111010100111;
            sine_reg0   <= 18'sb011110010111101000;
        end
        1234: begin
            cosine_reg0 <= 18'sb110101110111101000;
            sine_reg0   <= 18'sb011110010110101001;
        end
        1235: begin
            cosine_reg0 <= 18'sb110101110100101001;
            sine_reg0   <= 18'sb011110010101101001;
        end
        1236: begin
            cosine_reg0 <= 18'sb110101110001101011;
            sine_reg0   <= 18'sb011110010100101001;
        end
        1237: begin
            cosine_reg0 <= 18'sb110101101110101100;
            sine_reg0   <= 18'sb011110010011101001;
        end
        1238: begin
            cosine_reg0 <= 18'sb110101101011101110;
            sine_reg0   <= 18'sb011110010010101000;
        end
        1239: begin
            cosine_reg0 <= 18'sb110101101000101111;
            sine_reg0   <= 18'sb011110010001100111;
        end
        1240: begin
            cosine_reg0 <= 18'sb110101100101110001;
            sine_reg0   <= 18'sb011110010000100110;
        end
        1241: begin
            cosine_reg0 <= 18'sb110101100010110011;
            sine_reg0   <= 18'sb011110001111100100;
        end
        1242: begin
            cosine_reg0 <= 18'sb110101011111110101;
            sine_reg0   <= 18'sb011110001110100010;
        end
        1243: begin
            cosine_reg0 <= 18'sb110101011100110111;
            sine_reg0   <= 18'sb011110001101100000;
        end
        1244: begin
            cosine_reg0 <= 18'sb110101011001111010;
            sine_reg0   <= 18'sb011110001100011110;
        end
        1245: begin
            cosine_reg0 <= 18'sb110101010110111100;
            sine_reg0   <= 18'sb011110001011011011;
        end
        1246: begin
            cosine_reg0 <= 18'sb110101010011111110;
            sine_reg0   <= 18'sb011110001010011000;
        end
        1247: begin
            cosine_reg0 <= 18'sb110101010001000001;
            sine_reg0   <= 18'sb011110001001010101;
        end
        1248: begin
            cosine_reg0 <= 18'sb110101001110000100;
            sine_reg0   <= 18'sb011110001000010001;
        end
        1249: begin
            cosine_reg0 <= 18'sb110101001011000110;
            sine_reg0   <= 18'sb011110000111001101;
        end
        1250: begin
            cosine_reg0 <= 18'sb110101001000001001;
            sine_reg0   <= 18'sb011110000110001001;
        end
        1251: begin
            cosine_reg0 <= 18'sb110101000101001100;
            sine_reg0   <= 18'sb011110000101000101;
        end
        1252: begin
            cosine_reg0 <= 18'sb110101000010001111;
            sine_reg0   <= 18'sb011110000100000000;
        end
        1253: begin
            cosine_reg0 <= 18'sb110100111111010010;
            sine_reg0   <= 18'sb011110000010111011;
        end
        1254: begin
            cosine_reg0 <= 18'sb110100111100010110;
            sine_reg0   <= 18'sb011110000001110101;
        end
        1255: begin
            cosine_reg0 <= 18'sb110100111001011001;
            sine_reg0   <= 18'sb011110000000110000;
        end
        1256: begin
            cosine_reg0 <= 18'sb110100110110011100;
            sine_reg0   <= 18'sb011101111111101010;
        end
        1257: begin
            cosine_reg0 <= 18'sb110100110011100000;
            sine_reg0   <= 18'sb011101111110100100;
        end
        1258: begin
            cosine_reg0 <= 18'sb110100110000100100;
            sine_reg0   <= 18'sb011101111101011101;
        end
        1259: begin
            cosine_reg0 <= 18'sb110100101101101000;
            sine_reg0   <= 18'sb011101111100010111;
        end
        1260: begin
            cosine_reg0 <= 18'sb110100101010101011;
            sine_reg0   <= 18'sb011101111011001111;
        end
        1261: begin
            cosine_reg0 <= 18'sb110100100111101111;
            sine_reg0   <= 18'sb011101111010001000;
        end
        1262: begin
            cosine_reg0 <= 18'sb110100100100110100;
            sine_reg0   <= 18'sb011101111001000000;
        end
        1263: begin
            cosine_reg0 <= 18'sb110100100001111000;
            sine_reg0   <= 18'sb011101110111111001;
        end
        1264: begin
            cosine_reg0 <= 18'sb110100011110111100;
            sine_reg0   <= 18'sb011101110110110000;
        end
        1265: begin
            cosine_reg0 <= 18'sb110100011100000001;
            sine_reg0   <= 18'sb011101110101101000;
        end
        1266: begin
            cosine_reg0 <= 18'sb110100011001000101;
            sine_reg0   <= 18'sb011101110100011111;
        end
        1267: begin
            cosine_reg0 <= 18'sb110100010110001010;
            sine_reg0   <= 18'sb011101110011010110;
        end
        1268: begin
            cosine_reg0 <= 18'sb110100010011001111;
            sine_reg0   <= 18'sb011101110010001101;
        end
        1269: begin
            cosine_reg0 <= 18'sb110100010000010100;
            sine_reg0   <= 18'sb011101110001000011;
        end
        1270: begin
            cosine_reg0 <= 18'sb110100001101011001;
            sine_reg0   <= 18'sb011101101111111001;
        end
        1271: begin
            cosine_reg0 <= 18'sb110100001010011110;
            sine_reg0   <= 18'sb011101101110101111;
        end
        1272: begin
            cosine_reg0 <= 18'sb110100000111100011;
            sine_reg0   <= 18'sb011101101101100100;
        end
        1273: begin
            cosine_reg0 <= 18'sb110100000100101000;
            sine_reg0   <= 18'sb011101101100011001;
        end
        1274: begin
            cosine_reg0 <= 18'sb110100000001101110;
            sine_reg0   <= 18'sb011101101011001110;
        end
        1275: begin
            cosine_reg0 <= 18'sb110011111110110100;
            sine_reg0   <= 18'sb011101101010000011;
        end
        1276: begin
            cosine_reg0 <= 18'sb110011111011111001;
            sine_reg0   <= 18'sb011101101000110111;
        end
        1277: begin
            cosine_reg0 <= 18'sb110011111000111111;
            sine_reg0   <= 18'sb011101100111101011;
        end
        1278: begin
            cosine_reg0 <= 18'sb110011110110000101;
            sine_reg0   <= 18'sb011101100110011111;
        end
        1279: begin
            cosine_reg0 <= 18'sb110011110011001011;
            sine_reg0   <= 18'sb011101100101010011;
        end
        1280: begin
            cosine_reg0 <= 18'sb110011110000010001;
            sine_reg0   <= 18'sb011101100100000110;
        end
        1281: begin
            cosine_reg0 <= 18'sb110011101101011000;
            sine_reg0   <= 18'sb011101100010111001;
        end
        1282: begin
            cosine_reg0 <= 18'sb110011101010011110;
            sine_reg0   <= 18'sb011101100001101011;
        end
        1283: begin
            cosine_reg0 <= 18'sb110011100111100101;
            sine_reg0   <= 18'sb011101100000011110;
        end
        1284: begin
            cosine_reg0 <= 18'sb110011100100101011;
            sine_reg0   <= 18'sb011101011111010000;
        end
        1285: begin
            cosine_reg0 <= 18'sb110011100001110010;
            sine_reg0   <= 18'sb011101011110000010;
        end
        1286: begin
            cosine_reg0 <= 18'sb110011011110111001;
            sine_reg0   <= 18'sb011101011100110011;
        end
        1287: begin
            cosine_reg0 <= 18'sb110011011100000000;
            sine_reg0   <= 18'sb011101011011100100;
        end
        1288: begin
            cosine_reg0 <= 18'sb110011011001000111;
            sine_reg0   <= 18'sb011101011010010101;
        end
        1289: begin
            cosine_reg0 <= 18'sb110011010110001110;
            sine_reg0   <= 18'sb011101011001000110;
        end
        1290: begin
            cosine_reg0 <= 18'sb110011010011010110;
            sine_reg0   <= 18'sb011101010111110110;
        end
        1291: begin
            cosine_reg0 <= 18'sb110011010000011101;
            sine_reg0   <= 18'sb011101010110100110;
        end
        1292: begin
            cosine_reg0 <= 18'sb110011001101100101;
            sine_reg0   <= 18'sb011101010101010110;
        end
        1293: begin
            cosine_reg0 <= 18'sb110011001010101101;
            sine_reg0   <= 18'sb011101010100000110;
        end
        1294: begin
            cosine_reg0 <= 18'sb110011000111110100;
            sine_reg0   <= 18'sb011101010010110101;
        end
        1295: begin
            cosine_reg0 <= 18'sb110011000100111100;
            sine_reg0   <= 18'sb011101010001100100;
        end
        1296: begin
            cosine_reg0 <= 18'sb110011000010000101;
            sine_reg0   <= 18'sb011101010000010010;
        end
        1297: begin
            cosine_reg0 <= 18'sb110010111111001101;
            sine_reg0   <= 18'sb011101001111000001;
        end
        1298: begin
            cosine_reg0 <= 18'sb110010111100010101;
            sine_reg0   <= 18'sb011101001101101111;
        end
        1299: begin
            cosine_reg0 <= 18'sb110010111001011110;
            sine_reg0   <= 18'sb011101001100011101;
        end
        1300: begin
            cosine_reg0 <= 18'sb110010110110100110;
            sine_reg0   <= 18'sb011101001011001010;
        end
        1301: begin
            cosine_reg0 <= 18'sb110010110011101111;
            sine_reg0   <= 18'sb011101001001110111;
        end
        1302: begin
            cosine_reg0 <= 18'sb110010110000111000;
            sine_reg0   <= 18'sb011101001000100100;
        end
        1303: begin
            cosine_reg0 <= 18'sb110010101110000001;
            sine_reg0   <= 18'sb011101000111010001;
        end
        1304: begin
            cosine_reg0 <= 18'sb110010101011001010;
            sine_reg0   <= 18'sb011101000101111110;
        end
        1305: begin
            cosine_reg0 <= 18'sb110010101000010011;
            sine_reg0   <= 18'sb011101000100101010;
        end
        1306: begin
            cosine_reg0 <= 18'sb110010100101011101;
            sine_reg0   <= 18'sb011101000011010110;
        end
        1307: begin
            cosine_reg0 <= 18'sb110010100010100110;
            sine_reg0   <= 18'sb011101000010000001;
        end
        1308: begin
            cosine_reg0 <= 18'sb110010011111110000;
            sine_reg0   <= 18'sb011101000000101100;
        end
        1309: begin
            cosine_reg0 <= 18'sb110010011100111010;
            sine_reg0   <= 18'sb011100111111010111;
        end
        1310: begin
            cosine_reg0 <= 18'sb110010011010000100;
            sine_reg0   <= 18'sb011100111110000010;
        end
        1311: begin
            cosine_reg0 <= 18'sb110010010111001110;
            sine_reg0   <= 18'sb011100111100101101;
        end
        1312: begin
            cosine_reg0 <= 18'sb110010010100011000;
            sine_reg0   <= 18'sb011100111011010111;
        end
        1313: begin
            cosine_reg0 <= 18'sb110010010001100010;
            sine_reg0   <= 18'sb011100111010000001;
        end
        1314: begin
            cosine_reg0 <= 18'sb110010001110101101;
            sine_reg0   <= 18'sb011100111000101010;
        end
        1315: begin
            cosine_reg0 <= 18'sb110010001011110111;
            sine_reg0   <= 18'sb011100110111010100;
        end
        1316: begin
            cosine_reg0 <= 18'sb110010001001000010;
            sine_reg0   <= 18'sb011100110101111101;
        end
        1317: begin
            cosine_reg0 <= 18'sb110010000110001101;
            sine_reg0   <= 18'sb011100110100100101;
        end
        1318: begin
            cosine_reg0 <= 18'sb110010000011011000;
            sine_reg0   <= 18'sb011100110011001110;
        end
        1319: begin
            cosine_reg0 <= 18'sb110010000000100011;
            sine_reg0   <= 18'sb011100110001110110;
        end
        1320: begin
            cosine_reg0 <= 18'sb110001111101101110;
            sine_reg0   <= 18'sb011100110000011110;
        end
        1321: begin
            cosine_reg0 <= 18'sb110001111010111010;
            sine_reg0   <= 18'sb011100101111000110;
        end
        1322: begin
            cosine_reg0 <= 18'sb110001111000000101;
            sine_reg0   <= 18'sb011100101101101101;
        end
        1323: begin
            cosine_reg0 <= 18'sb110001110101010001;
            sine_reg0   <= 18'sb011100101100010100;
        end
        1324: begin
            cosine_reg0 <= 18'sb110001110010011100;
            sine_reg0   <= 18'sb011100101010111011;
        end
        1325: begin
            cosine_reg0 <= 18'sb110001101111101000;
            sine_reg0   <= 18'sb011100101001100010;
        end
        1326: begin
            cosine_reg0 <= 18'sb110001101100110100;
            sine_reg0   <= 18'sb011100101000001000;
        end
        1327: begin
            cosine_reg0 <= 18'sb110001101010000001;
            sine_reg0   <= 18'sb011100100110101110;
        end
        1328: begin
            cosine_reg0 <= 18'sb110001100111001101;
            sine_reg0   <= 18'sb011100100101010100;
        end
        1329: begin
            cosine_reg0 <= 18'sb110001100100011001;
            sine_reg0   <= 18'sb011100100011111001;
        end
        1330: begin
            cosine_reg0 <= 18'sb110001100001100110;
            sine_reg0   <= 18'sb011100100010011110;
        end
        1331: begin
            cosine_reg0 <= 18'sb110001011110110011;
            sine_reg0   <= 18'sb011100100001000011;
        end
        1332: begin
            cosine_reg0 <= 18'sb110001011100000000;
            sine_reg0   <= 18'sb011100011111101000;
        end
        1333: begin
            cosine_reg0 <= 18'sb110001011001001101;
            sine_reg0   <= 18'sb011100011110001100;
        end
        1334: begin
            cosine_reg0 <= 18'sb110001010110011010;
            sine_reg0   <= 18'sb011100011100110000;
        end
        1335: begin
            cosine_reg0 <= 18'sb110001010011100111;
            sine_reg0   <= 18'sb011100011011010100;
        end
        1336: begin
            cosine_reg0 <= 18'sb110001010000110101;
            sine_reg0   <= 18'sb011100011001111000;
        end
        1337: begin
            cosine_reg0 <= 18'sb110001001110000010;
            sine_reg0   <= 18'sb011100011000011011;
        end
        1338: begin
            cosine_reg0 <= 18'sb110001001011010000;
            sine_reg0   <= 18'sb011100010110111110;
        end
        1339: begin
            cosine_reg0 <= 18'sb110001001000011110;
            sine_reg0   <= 18'sb011100010101100001;
        end
        1340: begin
            cosine_reg0 <= 18'sb110001000101101100;
            sine_reg0   <= 18'sb011100010100000011;
        end
        1341: begin
            cosine_reg0 <= 18'sb110001000010111010;
            sine_reg0   <= 18'sb011100010010100101;
        end
        1342: begin
            cosine_reg0 <= 18'sb110001000000001000;
            sine_reg0   <= 18'sb011100010001000111;
        end
        1343: begin
            cosine_reg0 <= 18'sb110000111101010111;
            sine_reg0   <= 18'sb011100001111101001;
        end
        1344: begin
            cosine_reg0 <= 18'sb110000111010100110;
            sine_reg0   <= 18'sb011100001110001010;
        end
        1345: begin
            cosine_reg0 <= 18'sb110000110111110100;
            sine_reg0   <= 18'sb011100001100101011;
        end
        1346: begin
            cosine_reg0 <= 18'sb110000110101000011;
            sine_reg0   <= 18'sb011100001011001100;
        end
        1347: begin
            cosine_reg0 <= 18'sb110000110010010010;
            sine_reg0   <= 18'sb011100001001101101;
        end
        1348: begin
            cosine_reg0 <= 18'sb110000101111100001;
            sine_reg0   <= 18'sb011100001000001101;
        end
        1349: begin
            cosine_reg0 <= 18'sb110000101100110001;
            sine_reg0   <= 18'sb011100000110101101;
        end
        1350: begin
            cosine_reg0 <= 18'sb110000101010000000;
            sine_reg0   <= 18'sb011100000101001101;
        end
        1351: begin
            cosine_reg0 <= 18'sb110000100111010000;
            sine_reg0   <= 18'sb011100000011101100;
        end
        1352: begin
            cosine_reg0 <= 18'sb110000100100100000;
            sine_reg0   <= 18'sb011100000010001011;
        end
        1353: begin
            cosine_reg0 <= 18'sb110000100001110000;
            sine_reg0   <= 18'sb011100000000101010;
        end
        1354: begin
            cosine_reg0 <= 18'sb110000011111000000;
            sine_reg0   <= 18'sb011011111111001001;
        end
        1355: begin
            cosine_reg0 <= 18'sb110000011100010000;
            sine_reg0   <= 18'sb011011111101100111;
        end
        1356: begin
            cosine_reg0 <= 18'sb110000011001100000;
            sine_reg0   <= 18'sb011011111100000101;
        end
        1357: begin
            cosine_reg0 <= 18'sb110000010110110001;
            sine_reg0   <= 18'sb011011111010100011;
        end
        1358: begin
            cosine_reg0 <= 18'sb110000010100000010;
            sine_reg0   <= 18'sb011011111001000001;
        end
        1359: begin
            cosine_reg0 <= 18'sb110000010001010010;
            sine_reg0   <= 18'sb011011110111011110;
        end
        1360: begin
            cosine_reg0 <= 18'sb110000001110100011;
            sine_reg0   <= 18'sb011011110101111011;
        end
        1361: begin
            cosine_reg0 <= 18'sb110000001011110100;
            sine_reg0   <= 18'sb011011110100011000;
        end
        1362: begin
            cosine_reg0 <= 18'sb110000001001000110;
            sine_reg0   <= 18'sb011011110010110100;
        end
        1363: begin
            cosine_reg0 <= 18'sb110000000110010111;
            sine_reg0   <= 18'sb011011110001010001;
        end
        1364: begin
            cosine_reg0 <= 18'sb110000000011101001;
            sine_reg0   <= 18'sb011011101111101101;
        end
        1365: begin
            cosine_reg0 <= 18'sb110000000000111011;
            sine_reg0   <= 18'sb011011101110001000;
        end
        1366: begin
            cosine_reg0 <= 18'sb101111111110001100;
            sine_reg0   <= 18'sb011011101100100100;
        end
        1367: begin
            cosine_reg0 <= 18'sb101111111011011111;
            sine_reg0   <= 18'sb011011101010111111;
        end
        1368: begin
            cosine_reg0 <= 18'sb101111111000110001;
            sine_reg0   <= 18'sb011011101001011010;
        end
        1369: begin
            cosine_reg0 <= 18'sb101111110110000011;
            sine_reg0   <= 18'sb011011100111110100;
        end
        1370: begin
            cosine_reg0 <= 18'sb101111110011010110;
            sine_reg0   <= 18'sb011011100110001111;
        end
        1371: begin
            cosine_reg0 <= 18'sb101111110000101000;
            sine_reg0   <= 18'sb011011100100101001;
        end
        1372: begin
            cosine_reg0 <= 18'sb101111101101111011;
            sine_reg0   <= 18'sb011011100011000011;
        end
        1373: begin
            cosine_reg0 <= 18'sb101111101011001110;
            sine_reg0   <= 18'sb011011100001011100;
        end
        1374: begin
            cosine_reg0 <= 18'sb101111101000100001;
            sine_reg0   <= 18'sb011011011111110110;
        end
        1375: begin
            cosine_reg0 <= 18'sb101111100101110101;
            sine_reg0   <= 18'sb011011011110001111;
        end
        1376: begin
            cosine_reg0 <= 18'sb101111100011001000;
            sine_reg0   <= 18'sb011011011100100111;
        end
        1377: begin
            cosine_reg0 <= 18'sb101111100000011100;
            sine_reg0   <= 18'sb011011011011000000;
        end
        1378: begin
            cosine_reg0 <= 18'sb101111011101101111;
            sine_reg0   <= 18'sb011011011001011000;
        end
        1379: begin
            cosine_reg0 <= 18'sb101111011011000011;
            sine_reg0   <= 18'sb011011010111110000;
        end
        1380: begin
            cosine_reg0 <= 18'sb101111011000010111;
            sine_reg0   <= 18'sb011011010110001000;
        end
        1381: begin
            cosine_reg0 <= 18'sb101111010101101100;
            sine_reg0   <= 18'sb011011010100011111;
        end
        1382: begin
            cosine_reg0 <= 18'sb101111010011000000;
            sine_reg0   <= 18'sb011011010010110110;
        end
        1383: begin
            cosine_reg0 <= 18'sb101111010000010101;
            sine_reg0   <= 18'sb011011010001001101;
        end
        1384: begin
            cosine_reg0 <= 18'sb101111001101101010;
            sine_reg0   <= 18'sb011011001111100100;
        end
        1385: begin
            cosine_reg0 <= 18'sb101111001010111110;
            sine_reg0   <= 18'sb011011001101111010;
        end
        1386: begin
            cosine_reg0 <= 18'sb101111001000010011;
            sine_reg0   <= 18'sb011011001100010001;
        end
        1387: begin
            cosine_reg0 <= 18'sb101111000101101001;
            sine_reg0   <= 18'sb011011001010100110;
        end
        1388: begin
            cosine_reg0 <= 18'sb101111000010111110;
            sine_reg0   <= 18'sb011011001000111100;
        end
        1389: begin
            cosine_reg0 <= 18'sb101111000000010100;
            sine_reg0   <= 18'sb011011000111010001;
        end
        1390: begin
            cosine_reg0 <= 18'sb101110111101101001;
            sine_reg0   <= 18'sb011011000101100110;
        end
        1391: begin
            cosine_reg0 <= 18'sb101110111010111111;
            sine_reg0   <= 18'sb011011000011111011;
        end
        1392: begin
            cosine_reg0 <= 18'sb101110111000010101;
            sine_reg0   <= 18'sb011011000010010000;
        end
        1393: begin
            cosine_reg0 <= 18'sb101110110101101100;
            sine_reg0   <= 18'sb011011000000100100;
        end
        1394: begin
            cosine_reg0 <= 18'sb101110110011000010;
            sine_reg0   <= 18'sb011010111110111000;
        end
        1395: begin
            cosine_reg0 <= 18'sb101110110000011000;
            sine_reg0   <= 18'sb011010111101001100;
        end
        1396: begin
            cosine_reg0 <= 18'sb101110101101101111;
            sine_reg0   <= 18'sb011010111011011111;
        end
        1397: begin
            cosine_reg0 <= 18'sb101110101011000110;
            sine_reg0   <= 18'sb011010111001110011;
        end
        1398: begin
            cosine_reg0 <= 18'sb101110101000011101;
            sine_reg0   <= 18'sb011010111000000110;
        end
        1399: begin
            cosine_reg0 <= 18'sb101110100101110100;
            sine_reg0   <= 18'sb011010110110011000;
        end
        1400: begin
            cosine_reg0 <= 18'sb101110100011001100;
            sine_reg0   <= 18'sb011010110100101011;
        end
        1401: begin
            cosine_reg0 <= 18'sb101110100000100011;
            sine_reg0   <= 18'sb011010110010111101;
        end
        1402: begin
            cosine_reg0 <= 18'sb101110011101111011;
            sine_reg0   <= 18'sb011010110001001111;
        end
        1403: begin
            cosine_reg0 <= 18'sb101110011011010011;
            sine_reg0   <= 18'sb011010101111100001;
        end
        1404: begin
            cosine_reg0 <= 18'sb101110011000101011;
            sine_reg0   <= 18'sb011010101101110010;
        end
        1405: begin
            cosine_reg0 <= 18'sb101110010110000011;
            sine_reg0   <= 18'sb011010101100000100;
        end
        1406: begin
            cosine_reg0 <= 18'sb101110010011011100;
            sine_reg0   <= 18'sb011010101010010100;
        end
        1407: begin
            cosine_reg0 <= 18'sb101110010000110100;
            sine_reg0   <= 18'sb011010101000100101;
        end
        1408: begin
            cosine_reg0 <= 18'sb101110001110001101;
            sine_reg0   <= 18'sb011010100110110110;
        end
        1409: begin
            cosine_reg0 <= 18'sb101110001011100110;
            sine_reg0   <= 18'sb011010100101000110;
        end
        1410: begin
            cosine_reg0 <= 18'sb101110001000111111;
            sine_reg0   <= 18'sb011010100011010110;
        end
        1411: begin
            cosine_reg0 <= 18'sb101110000110011000;
            sine_reg0   <= 18'sb011010100001100101;
        end
        1412: begin
            cosine_reg0 <= 18'sb101110000011110010;
            sine_reg0   <= 18'sb011010011111110101;
        end
        1413: begin
            cosine_reg0 <= 18'sb101110000001001011;
            sine_reg0   <= 18'sb011010011110000100;
        end
        1414: begin
            cosine_reg0 <= 18'sb101101111110100101;
            sine_reg0   <= 18'sb011010011100010011;
        end
        1415: begin
            cosine_reg0 <= 18'sb101101111011111111;
            sine_reg0   <= 18'sb011010011010100001;
        end
        1416: begin
            cosine_reg0 <= 18'sb101101111001011001;
            sine_reg0   <= 18'sb011010011000110000;
        end
        1417: begin
            cosine_reg0 <= 18'sb101101110110110011;
            sine_reg0   <= 18'sb011010010110111110;
        end
        1418: begin
            cosine_reg0 <= 18'sb101101110100001110;
            sine_reg0   <= 18'sb011010010101001100;
        end
        1419: begin
            cosine_reg0 <= 18'sb101101110001101000;
            sine_reg0   <= 18'sb011010010011011001;
        end
        1420: begin
            cosine_reg0 <= 18'sb101101101111000011;
            sine_reg0   <= 18'sb011010010001100111;
        end
        1421: begin
            cosine_reg0 <= 18'sb101101101100011110;
            sine_reg0   <= 18'sb011010001111110100;
        end
        1422: begin
            cosine_reg0 <= 18'sb101101101001111001;
            sine_reg0   <= 18'sb011010001110000001;
        end
        1423: begin
            cosine_reg0 <= 18'sb101101100111010101;
            sine_reg0   <= 18'sb011010001100001101;
        end
        1424: begin
            cosine_reg0 <= 18'sb101101100100110000;
            sine_reg0   <= 18'sb011010001010011010;
        end
        1425: begin
            cosine_reg0 <= 18'sb101101100010001100;
            sine_reg0   <= 18'sb011010001000100110;
        end
        1426: begin
            cosine_reg0 <= 18'sb101101011111101000;
            sine_reg0   <= 18'sb011010000110110010;
        end
        1427: begin
            cosine_reg0 <= 18'sb101101011101000100;
            sine_reg0   <= 18'sb011010000100111101;
        end
        1428: begin
            cosine_reg0 <= 18'sb101101011010100000;
            sine_reg0   <= 18'sb011010000011001001;
        end
        1429: begin
            cosine_reg0 <= 18'sb101101010111111101;
            sine_reg0   <= 18'sb011010000001010100;
        end
        1430: begin
            cosine_reg0 <= 18'sb101101010101011001;
            sine_reg0   <= 18'sb011001111111011110;
        end
        1431: begin
            cosine_reg0 <= 18'sb101101010010110110;
            sine_reg0   <= 18'sb011001111101101001;
        end
        1432: begin
            cosine_reg0 <= 18'sb101101010000010011;
            sine_reg0   <= 18'sb011001111011110011;
        end
        1433: begin
            cosine_reg0 <= 18'sb101101001101110000;
            sine_reg0   <= 18'sb011001111001111110;
        end
        1434: begin
            cosine_reg0 <= 18'sb101101001011001101;
            sine_reg0   <= 18'sb011001111000000111;
        end
        1435: begin
            cosine_reg0 <= 18'sb101101001000101011;
            sine_reg0   <= 18'sb011001110110010001;
        end
        1436: begin
            cosine_reg0 <= 18'sb101101000110001001;
            sine_reg0   <= 18'sb011001110100011010;
        end
        1437: begin
            cosine_reg0 <= 18'sb101101000011100110;
            sine_reg0   <= 18'sb011001110010100011;
        end
        1438: begin
            cosine_reg0 <= 18'sb101101000001000100;
            sine_reg0   <= 18'sb011001110000101100;
        end
        1439: begin
            cosine_reg0 <= 18'sb101100111110100011;
            sine_reg0   <= 18'sb011001101110110101;
        end
        1440: begin
            cosine_reg0 <= 18'sb101100111100000001;
            sine_reg0   <= 18'sb011001101100111101;
        end
        1441: begin
            cosine_reg0 <= 18'sb101100111001100000;
            sine_reg0   <= 18'sb011001101011000101;
        end
        1442: begin
            cosine_reg0 <= 18'sb101100110110111110;
            sine_reg0   <= 18'sb011001101001001101;
        end
        1443: begin
            cosine_reg0 <= 18'sb101100110100011101;
            sine_reg0   <= 18'sb011001100111010101;
        end
        1444: begin
            cosine_reg0 <= 18'sb101100110001111101;
            sine_reg0   <= 18'sb011001100101011100;
        end
        1445: begin
            cosine_reg0 <= 18'sb101100101111011100;
            sine_reg0   <= 18'sb011001100011100011;
        end
        1446: begin
            cosine_reg0 <= 18'sb101100101100111011;
            sine_reg0   <= 18'sb011001100001101010;
        end
        1447: begin
            cosine_reg0 <= 18'sb101100101010011011;
            sine_reg0   <= 18'sb011001011111110001;
        end
        1448: begin
            cosine_reg0 <= 18'sb101100100111111011;
            sine_reg0   <= 18'sb011001011101110111;
        end
        1449: begin
            cosine_reg0 <= 18'sb101100100101011011;
            sine_reg0   <= 18'sb011001011011111101;
        end
        1450: begin
            cosine_reg0 <= 18'sb101100100010111011;
            sine_reg0   <= 18'sb011001011010000011;
        end
        1451: begin
            cosine_reg0 <= 18'sb101100100000011100;
            sine_reg0   <= 18'sb011001011000001001;
        end
        1452: begin
            cosine_reg0 <= 18'sb101100011101111101;
            sine_reg0   <= 18'sb011001010110001110;
        end
        1453: begin
            cosine_reg0 <= 18'sb101100011011011101;
            sine_reg0   <= 18'sb011001010100010011;
        end
        1454: begin
            cosine_reg0 <= 18'sb101100011000111110;
            sine_reg0   <= 18'sb011001010010011000;
        end
        1455: begin
            cosine_reg0 <= 18'sb101100010110100000;
            sine_reg0   <= 18'sb011001010000011101;
        end
        1456: begin
            cosine_reg0 <= 18'sb101100010100000001;
            sine_reg0   <= 18'sb011001001110100001;
        end
        1457: begin
            cosine_reg0 <= 18'sb101100010001100011;
            sine_reg0   <= 18'sb011001001100100110;
        end
        1458: begin
            cosine_reg0 <= 18'sb101100001111000100;
            sine_reg0   <= 18'sb011001001010101001;
        end
        1459: begin
            cosine_reg0 <= 18'sb101100001100100110;
            sine_reg0   <= 18'sb011001001000101101;
        end
        1460: begin
            cosine_reg0 <= 18'sb101100001010001000;
            sine_reg0   <= 18'sb011001000110110001;
        end
        1461: begin
            cosine_reg0 <= 18'sb101100000111101011;
            sine_reg0   <= 18'sb011001000100110100;
        end
        1462: begin
            cosine_reg0 <= 18'sb101100000101001101;
            sine_reg0   <= 18'sb011001000010110111;
        end
        1463: begin
            cosine_reg0 <= 18'sb101100000010110000;
            sine_reg0   <= 18'sb011001000000111010;
        end
        1464: begin
            cosine_reg0 <= 18'sb101100000000010011;
            sine_reg0   <= 18'sb011000111110111100;
        end
        1465: begin
            cosine_reg0 <= 18'sb101011111101110110;
            sine_reg0   <= 18'sb011000111100111110;
        end
        1466: begin
            cosine_reg0 <= 18'sb101011111011011001;
            sine_reg0   <= 18'sb011000111011000000;
        end
        1467: begin
            cosine_reg0 <= 18'sb101011111000111101;
            sine_reg0   <= 18'sb011000111001000010;
        end
        1468: begin
            cosine_reg0 <= 18'sb101011110110100001;
            sine_reg0   <= 18'sb011000110111000100;
        end
        1469: begin
            cosine_reg0 <= 18'sb101011110100000101;
            sine_reg0   <= 18'sb011000110101000101;
        end
        1470: begin
            cosine_reg0 <= 18'sb101011110001101001;
            sine_reg0   <= 18'sb011000110011000110;
        end
        1471: begin
            cosine_reg0 <= 18'sb101011101111001101;
            sine_reg0   <= 18'sb011000110001000111;
        end
        1472: begin
            cosine_reg0 <= 18'sb101011101100110001;
            sine_reg0   <= 18'sb011000101111000111;
        end
        1473: begin
            cosine_reg0 <= 18'sb101011101010010110;
            sine_reg0   <= 18'sb011000101101001000;
        end
        1474: begin
            cosine_reg0 <= 18'sb101011100111111011;
            sine_reg0   <= 18'sb011000101011001000;
        end
        1475: begin
            cosine_reg0 <= 18'sb101011100101100000;
            sine_reg0   <= 18'sb011000101001001000;
        end
        1476: begin
            cosine_reg0 <= 18'sb101011100011000101;
            sine_reg0   <= 18'sb011000100111000111;
        end
        1477: begin
            cosine_reg0 <= 18'sb101011100000101011;
            sine_reg0   <= 18'sb011000100101000111;
        end
        1478: begin
            cosine_reg0 <= 18'sb101011011110010000;
            sine_reg0   <= 18'sb011000100011000110;
        end
        1479: begin
            cosine_reg0 <= 18'sb101011011011110110;
            sine_reg0   <= 18'sb011000100001000101;
        end
        1480: begin
            cosine_reg0 <= 18'sb101011011001011100;
            sine_reg0   <= 18'sb011000011111000011;
        end
        1481: begin
            cosine_reg0 <= 18'sb101011010111000011;
            sine_reg0   <= 18'sb011000011101000010;
        end
        1482: begin
            cosine_reg0 <= 18'sb101011010100101001;
            sine_reg0   <= 18'sb011000011011000000;
        end
        1483: begin
            cosine_reg0 <= 18'sb101011010010010000;
            sine_reg0   <= 18'sb011000011000111110;
        end
        1484: begin
            cosine_reg0 <= 18'sb101011001111110111;
            sine_reg0   <= 18'sb011000010110111100;
        end
        1485: begin
            cosine_reg0 <= 18'sb101011001101011110;
            sine_reg0   <= 18'sb011000010100111001;
        end
        1486: begin
            cosine_reg0 <= 18'sb101011001011000101;
            sine_reg0   <= 18'sb011000010010110110;
        end
        1487: begin
            cosine_reg0 <= 18'sb101011001000101100;
            sine_reg0   <= 18'sb011000010000110011;
        end
        1488: begin
            cosine_reg0 <= 18'sb101011000110010100;
            sine_reg0   <= 18'sb011000001110110000;
        end
        1489: begin
            cosine_reg0 <= 18'sb101011000011111100;
            sine_reg0   <= 18'sb011000001100101101;
        end
        1490: begin
            cosine_reg0 <= 18'sb101011000001100100;
            sine_reg0   <= 18'sb011000001010101001;
        end
        1491: begin
            cosine_reg0 <= 18'sb101010111111001100;
            sine_reg0   <= 18'sb011000001000100101;
        end
        1492: begin
            cosine_reg0 <= 18'sb101010111100110101;
            sine_reg0   <= 18'sb011000000110100001;
        end
        1493: begin
            cosine_reg0 <= 18'sb101010111010011101;
            sine_reg0   <= 18'sb011000000100011101;
        end
        1494: begin
            cosine_reg0 <= 18'sb101010111000000110;
            sine_reg0   <= 18'sb011000000010011000;
        end
        1495: begin
            cosine_reg0 <= 18'sb101010110101101111;
            sine_reg0   <= 18'sb011000000000010011;
        end
        1496: begin
            cosine_reg0 <= 18'sb101010110011011001;
            sine_reg0   <= 18'sb010111111110001110;
        end
        1497: begin
            cosine_reg0 <= 18'sb101010110001000010;
            sine_reg0   <= 18'sb010111111100001001;
        end
        1498: begin
            cosine_reg0 <= 18'sb101010101110101100;
            sine_reg0   <= 18'sb010111111010000011;
        end
        1499: begin
            cosine_reg0 <= 18'sb101010101100010110;
            sine_reg0   <= 18'sb010111110111111101;
        end
        1500: begin
            cosine_reg0 <= 18'sb101010101010000000;
            sine_reg0   <= 18'sb010111110101110111;
        end
        1501: begin
            cosine_reg0 <= 18'sb101010100111101010;
            sine_reg0   <= 18'sb010111110011110001;
        end
        1502: begin
            cosine_reg0 <= 18'sb101010100101010100;
            sine_reg0   <= 18'sb010111110001101011;
        end
        1503: begin
            cosine_reg0 <= 18'sb101010100010111111;
            sine_reg0   <= 18'sb010111101111100100;
        end
        1504: begin
            cosine_reg0 <= 18'sb101010100000101010;
            sine_reg0   <= 18'sb010111101101011101;
        end
        1505: begin
            cosine_reg0 <= 18'sb101010011110010101;
            sine_reg0   <= 18'sb010111101011010110;
        end
        1506: begin
            cosine_reg0 <= 18'sb101010011100000001;
            sine_reg0   <= 18'sb010111101001001111;
        end
        1507: begin
            cosine_reg0 <= 18'sb101010011001101100;
            sine_reg0   <= 18'sb010111100111000111;
        end
        1508: begin
            cosine_reg0 <= 18'sb101010010111011000;
            sine_reg0   <= 18'sb010111100100111111;
        end
        1509: begin
            cosine_reg0 <= 18'sb101010010101000100;
            sine_reg0   <= 18'sb010111100010110111;
        end
        1510: begin
            cosine_reg0 <= 18'sb101010010010110000;
            sine_reg0   <= 18'sb010111100000101111;
        end
        1511: begin
            cosine_reg0 <= 18'sb101010010000011100;
            sine_reg0   <= 18'sb010111011110100110;
        end
        1512: begin
            cosine_reg0 <= 18'sb101010001110001001;
            sine_reg0   <= 18'sb010111011100011110;
        end
        1513: begin
            cosine_reg0 <= 18'sb101010001011110110;
            sine_reg0   <= 18'sb010111011010010101;
        end
        1514: begin
            cosine_reg0 <= 18'sb101010001001100011;
            sine_reg0   <= 18'sb010111011000001100;
        end
        1515: begin
            cosine_reg0 <= 18'sb101010000111010000;
            sine_reg0   <= 18'sb010111010110000010;
        end
        1516: begin
            cosine_reg0 <= 18'sb101010000100111101;
            sine_reg0   <= 18'sb010111010011111001;
        end
        1517: begin
            cosine_reg0 <= 18'sb101010000010101011;
            sine_reg0   <= 18'sb010111010001101111;
        end
        1518: begin
            cosine_reg0 <= 18'sb101010000000011001;
            sine_reg0   <= 18'sb010111001111100101;
        end
        1519: begin
            cosine_reg0 <= 18'sb101001111110000111;
            sine_reg0   <= 18'sb010111001101011010;
        end
        1520: begin
            cosine_reg0 <= 18'sb101001111011110101;
            sine_reg0   <= 18'sb010111001011010000;
        end
        1521: begin
            cosine_reg0 <= 18'sb101001111001100100;
            sine_reg0   <= 18'sb010111001001000101;
        end
        1522: begin
            cosine_reg0 <= 18'sb101001110111010010;
            sine_reg0   <= 18'sb010111000110111010;
        end
        1523: begin
            cosine_reg0 <= 18'sb101001110101000001;
            sine_reg0   <= 18'sb010111000100101111;
        end
        1524: begin
            cosine_reg0 <= 18'sb101001110010110000;
            sine_reg0   <= 18'sb010111000010100011;
        end
        1525: begin
            cosine_reg0 <= 18'sb101001110000100000;
            sine_reg0   <= 18'sb010111000000011000;
        end
        1526: begin
            cosine_reg0 <= 18'sb101001101110001111;
            sine_reg0   <= 18'sb010110111110001100;
        end
        1527: begin
            cosine_reg0 <= 18'sb101001101011111111;
            sine_reg0   <= 18'sb010110111100000000;
        end
        1528: begin
            cosine_reg0 <= 18'sb101001101001101111;
            sine_reg0   <= 18'sb010110111001110100;
        end
        1529: begin
            cosine_reg0 <= 18'sb101001100111011111;
            sine_reg0   <= 18'sb010110110111100111;
        end
        1530: begin
            cosine_reg0 <= 18'sb101001100101010000;
            sine_reg0   <= 18'sb010110110101011010;
        end
        1531: begin
            cosine_reg0 <= 18'sb101001100011000000;
            sine_reg0   <= 18'sb010110110011001101;
        end
        1532: begin
            cosine_reg0 <= 18'sb101001100000110001;
            sine_reg0   <= 18'sb010110110001000000;
        end
        1533: begin
            cosine_reg0 <= 18'sb101001011110100010;
            sine_reg0   <= 18'sb010110101110110011;
        end
        1534: begin
            cosine_reg0 <= 18'sb101001011100010100;
            sine_reg0   <= 18'sb010110101100100101;
        end
        1535: begin
            cosine_reg0 <= 18'sb101001011010000101;
            sine_reg0   <= 18'sb010110101010010111;
        end
        1536: begin
            cosine_reg0 <= 18'sb101001010111110111;
            sine_reg0   <= 18'sb010110101000001001;
        end
        1537: begin
            cosine_reg0 <= 18'sb101001010101101001;
            sine_reg0   <= 18'sb010110100101111011;
        end
        1538: begin
            cosine_reg0 <= 18'sb101001010011011011;
            sine_reg0   <= 18'sb010110100011101100;
        end
        1539: begin
            cosine_reg0 <= 18'sb101001010001001101;
            sine_reg0   <= 18'sb010110100001011110;
        end
        1540: begin
            cosine_reg0 <= 18'sb101001001111000000;
            sine_reg0   <= 18'sb010110011111001111;
        end
        1541: begin
            cosine_reg0 <= 18'sb101001001100110011;
            sine_reg0   <= 18'sb010110011101000000;
        end
        1542: begin
            cosine_reg0 <= 18'sb101001001010100110;
            sine_reg0   <= 18'sb010110011010110000;
        end
        1543: begin
            cosine_reg0 <= 18'sb101001001000011001;
            sine_reg0   <= 18'sb010110011000100001;
        end
        1544: begin
            cosine_reg0 <= 18'sb101001000110001100;
            sine_reg0   <= 18'sb010110010110010001;
        end
        1545: begin
            cosine_reg0 <= 18'sb101001000100000000;
            sine_reg0   <= 18'sb010110010100000001;
        end
        1546: begin
            cosine_reg0 <= 18'sb101001000001110100;
            sine_reg0   <= 18'sb010110010001110001;
        end
        1547: begin
            cosine_reg0 <= 18'sb101000111111101000;
            sine_reg0   <= 18'sb010110001111100000;
        end
        1548: begin
            cosine_reg0 <= 18'sb101000111101011101;
            sine_reg0   <= 18'sb010110001101010000;
        end
        1549: begin
            cosine_reg0 <= 18'sb101000111011010001;
            sine_reg0   <= 18'sb010110001010111111;
        end
        1550: begin
            cosine_reg0 <= 18'sb101000111001000110;
            sine_reg0   <= 18'sb010110001000101110;
        end
        1551: begin
            cosine_reg0 <= 18'sb101000110110111011;
            sine_reg0   <= 18'sb010110000110011100;
        end
        1552: begin
            cosine_reg0 <= 18'sb101000110100110000;
            sine_reg0   <= 18'sb010110000100001011;
        end
        1553: begin
            cosine_reg0 <= 18'sb101000110010100110;
            sine_reg0   <= 18'sb010110000001111001;
        end
        1554: begin
            cosine_reg0 <= 18'sb101000110000011011;
            sine_reg0   <= 18'sb010101111111100111;
        end
        1555: begin
            cosine_reg0 <= 18'sb101000101110010001;
            sine_reg0   <= 18'sb010101111101010101;
        end
        1556: begin
            cosine_reg0 <= 18'sb101000101100000111;
            sine_reg0   <= 18'sb010101111011000011;
        end
        1557: begin
            cosine_reg0 <= 18'sb101000101001111110;
            sine_reg0   <= 18'sb010101111000110000;
        end
        1558: begin
            cosine_reg0 <= 18'sb101000100111110100;
            sine_reg0   <= 18'sb010101110110011101;
        end
        1559: begin
            cosine_reg0 <= 18'sb101000100101101011;
            sine_reg0   <= 18'sb010101110100001010;
        end
        1560: begin
            cosine_reg0 <= 18'sb101000100011100010;
            sine_reg0   <= 18'sb010101110001110111;
        end
        1561: begin
            cosine_reg0 <= 18'sb101000100001011010;
            sine_reg0   <= 18'sb010101101111100100;
        end
        1562: begin
            cosine_reg0 <= 18'sb101000011111010001;
            sine_reg0   <= 18'sb010101101101010000;
        end
        1563: begin
            cosine_reg0 <= 18'sb101000011101001001;
            sine_reg0   <= 18'sb010101101010111100;
        end
        1564: begin
            cosine_reg0 <= 18'sb101000011011000001;
            sine_reg0   <= 18'sb010101101000101000;
        end
        1565: begin
            cosine_reg0 <= 18'sb101000011000111001;
            sine_reg0   <= 18'sb010101100110010100;
        end
        1566: begin
            cosine_reg0 <= 18'sb101000010110110001;
            sine_reg0   <= 18'sb010101100011111111;
        end
        1567: begin
            cosine_reg0 <= 18'sb101000010100101010;
            sine_reg0   <= 18'sb010101100001101011;
        end
        1568: begin
            cosine_reg0 <= 18'sb101000010010100011;
            sine_reg0   <= 18'sb010101011111010110;
        end
        1569: begin
            cosine_reg0 <= 18'sb101000010000011100;
            sine_reg0   <= 18'sb010101011101000001;
        end
        1570: begin
            cosine_reg0 <= 18'sb101000001110010101;
            sine_reg0   <= 18'sb010101011010101100;
        end
        1571: begin
            cosine_reg0 <= 18'sb101000001100001111;
            sine_reg0   <= 18'sb010101011000010110;
        end
        1572: begin
            cosine_reg0 <= 18'sb101000001010001001;
            sine_reg0   <= 18'sb010101010110000000;
        end
        1573: begin
            cosine_reg0 <= 18'sb101000001000000011;
            sine_reg0   <= 18'sb010101010011101010;
        end
        1574: begin
            cosine_reg0 <= 18'sb101000000101111101;
            sine_reg0   <= 18'sb010101010001010100;
        end
        1575: begin
            cosine_reg0 <= 18'sb101000000011110111;
            sine_reg0   <= 18'sb010101001110111110;
        end
        1576: begin
            cosine_reg0 <= 18'sb101000000001110010;
            sine_reg0   <= 18'sb010101001100100111;
        end
        1577: begin
            cosine_reg0 <= 18'sb100111111111101101;
            sine_reg0   <= 18'sb010101001010010001;
        end
        1578: begin
            cosine_reg0 <= 18'sb100111111101101000;
            sine_reg0   <= 18'sb010101000111111010;
        end
        1579: begin
            cosine_reg0 <= 18'sb100111111011100011;
            sine_reg0   <= 18'sb010101000101100011;
        end
        1580: begin
            cosine_reg0 <= 18'sb100111111001011111;
            sine_reg0   <= 18'sb010101000011001011;
        end
        1581: begin
            cosine_reg0 <= 18'sb100111110111011011;
            sine_reg0   <= 18'sb010101000000110100;
        end
        1582: begin
            cosine_reg0 <= 18'sb100111110101010111;
            sine_reg0   <= 18'sb010100111110011100;
        end
        1583: begin
            cosine_reg0 <= 18'sb100111110011010011;
            sine_reg0   <= 18'sb010100111100000100;
        end
        1584: begin
            cosine_reg0 <= 18'sb100111110001010000;
            sine_reg0   <= 18'sb010100111001101100;
        end
        1585: begin
            cosine_reg0 <= 18'sb100111101111001101;
            sine_reg0   <= 18'sb010100110111010100;
        end
        1586: begin
            cosine_reg0 <= 18'sb100111101101001010;
            sine_reg0   <= 18'sb010100110100111011;
        end
        1587: begin
            cosine_reg0 <= 18'sb100111101011000111;
            sine_reg0   <= 18'sb010100110010100010;
        end
        1588: begin
            cosine_reg0 <= 18'sb100111101001000100;
            sine_reg0   <= 18'sb010100110000001001;
        end
        1589: begin
            cosine_reg0 <= 18'sb100111100111000010;
            sine_reg0   <= 18'sb010100101101110000;
        end
        1590: begin
            cosine_reg0 <= 18'sb100111100101000000;
            sine_reg0   <= 18'sb010100101011010111;
        end
        1591: begin
            cosine_reg0 <= 18'sb100111100010111110;
            sine_reg0   <= 18'sb010100101000111101;
        end
        1592: begin
            cosine_reg0 <= 18'sb100111100000111101;
            sine_reg0   <= 18'sb010100100110100100;
        end
        1593: begin
            cosine_reg0 <= 18'sb100111011110111011;
            sine_reg0   <= 18'sb010100100100001010;
        end
        1594: begin
            cosine_reg0 <= 18'sb100111011100111010;
            sine_reg0   <= 18'sb010100100001110000;
        end
        1595: begin
            cosine_reg0 <= 18'sb100111011010111001;
            sine_reg0   <= 18'sb010100011111010101;
        end
        1596: begin
            cosine_reg0 <= 18'sb100111011000111001;
            sine_reg0   <= 18'sb010100011100111011;
        end
        1597: begin
            cosine_reg0 <= 18'sb100111010110111000;
            sine_reg0   <= 18'sb010100011010100000;
        end
        1598: begin
            cosine_reg0 <= 18'sb100111010100111000;
            sine_reg0   <= 18'sb010100011000000101;
        end
        1599: begin
            cosine_reg0 <= 18'sb100111010010111000;
            sine_reg0   <= 18'sb010100010101101010;
        end
        1600: begin
            cosine_reg0 <= 18'sb100111010000111001;
            sine_reg0   <= 18'sb010100010011001111;
        end
        1601: begin
            cosine_reg0 <= 18'sb100111001110111001;
            sine_reg0   <= 18'sb010100010000110011;
        end
        1602: begin
            cosine_reg0 <= 18'sb100111001100111010;
            sine_reg0   <= 18'sb010100001110010111;
        end
        1603: begin
            cosine_reg0 <= 18'sb100111001010111011;
            sine_reg0   <= 18'sb010100001011111011;
        end
        1604: begin
            cosine_reg0 <= 18'sb100111001000111100;
            sine_reg0   <= 18'sb010100001001011111;
        end
        1605: begin
            cosine_reg0 <= 18'sb100111000110111110;
            sine_reg0   <= 18'sb010100000111000011;
        end
        1606: begin
            cosine_reg0 <= 18'sb100111000101000000;
            sine_reg0   <= 18'sb010100000100100111;
        end
        1607: begin
            cosine_reg0 <= 18'sb100111000011000010;
            sine_reg0   <= 18'sb010100000010001010;
        end
        1608: begin
            cosine_reg0 <= 18'sb100111000001000100;
            sine_reg0   <= 18'sb010011111111101101;
        end
        1609: begin
            cosine_reg0 <= 18'sb100110111111000110;
            sine_reg0   <= 18'sb010011111101010000;
        end
        1610: begin
            cosine_reg0 <= 18'sb100110111101001001;
            sine_reg0   <= 18'sb010011111010110011;
        end
        1611: begin
            cosine_reg0 <= 18'sb100110111011001100;
            sine_reg0   <= 18'sb010011111000010101;
        end
        1612: begin
            cosine_reg0 <= 18'sb100110111001001111;
            sine_reg0   <= 18'sb010011110101111000;
        end
        1613: begin
            cosine_reg0 <= 18'sb100110110111010011;
            sine_reg0   <= 18'sb010011110011011010;
        end
        1614: begin
            cosine_reg0 <= 18'sb100110110101010111;
            sine_reg0   <= 18'sb010011110000111100;
        end
        1615: begin
            cosine_reg0 <= 18'sb100110110011011010;
            sine_reg0   <= 18'sb010011101110011101;
        end
        1616: begin
            cosine_reg0 <= 18'sb100110110001011111;
            sine_reg0   <= 18'sb010011101011111111;
        end
        1617: begin
            cosine_reg0 <= 18'sb100110101111100011;
            sine_reg0   <= 18'sb010011101001100000;
        end
        1618: begin
            cosine_reg0 <= 18'sb100110101101101000;
            sine_reg0   <= 18'sb010011100111000010;
        end
        1619: begin
            cosine_reg0 <= 18'sb100110101011101101;
            sine_reg0   <= 18'sb010011100100100011;
        end
        1620: begin
            cosine_reg0 <= 18'sb100110101001110010;
            sine_reg0   <= 18'sb010011100010000011;
        end
        1621: begin
            cosine_reg0 <= 18'sb100110100111110111;
            sine_reg0   <= 18'sb010011011111100100;
        end
        1622: begin
            cosine_reg0 <= 18'sb100110100101111101;
            sine_reg0   <= 18'sb010011011101000101;
        end
        1623: begin
            cosine_reg0 <= 18'sb100110100100000011;
            sine_reg0   <= 18'sb010011011010100101;
        end
        1624: begin
            cosine_reg0 <= 18'sb100110100010001001;
            sine_reg0   <= 18'sb010011011000000101;
        end
        1625: begin
            cosine_reg0 <= 18'sb100110100000001111;
            sine_reg0   <= 18'sb010011010101100101;
        end
        1626: begin
            cosine_reg0 <= 18'sb100110011110010110;
            sine_reg0   <= 18'sb010011010011000101;
        end
        1627: begin
            cosine_reg0 <= 18'sb100110011100011101;
            sine_reg0   <= 18'sb010011010000100100;
        end
        1628: begin
            cosine_reg0 <= 18'sb100110011010100100;
            sine_reg0   <= 18'sb010011001110000011;
        end
        1629: begin
            cosine_reg0 <= 18'sb100110011000101011;
            sine_reg0   <= 18'sb010011001011100011;
        end
        1630: begin
            cosine_reg0 <= 18'sb100110010110110011;
            sine_reg0   <= 18'sb010011001001000010;
        end
        1631: begin
            cosine_reg0 <= 18'sb100110010100111011;
            sine_reg0   <= 18'sb010011000110100000;
        end
        1632: begin
            cosine_reg0 <= 18'sb100110010011000011;
            sine_reg0   <= 18'sb010011000011111111;
        end
        1633: begin
            cosine_reg0 <= 18'sb100110010001001011;
            sine_reg0   <= 18'sb010011000001011101;
        end
        1634: begin
            cosine_reg0 <= 18'sb100110001111010100;
            sine_reg0   <= 18'sb010010111110111100;
        end
        1635: begin
            cosine_reg0 <= 18'sb100110001101011101;
            sine_reg0   <= 18'sb010010111100011010;
        end
        1636: begin
            cosine_reg0 <= 18'sb100110001011100110;
            sine_reg0   <= 18'sb010010111001110111;
        end
        1637: begin
            cosine_reg0 <= 18'sb100110001001101111;
            sine_reg0   <= 18'sb010010110111010101;
        end
        1638: begin
            cosine_reg0 <= 18'sb100110000111111001;
            sine_reg0   <= 18'sb010010110100110011;
        end
        1639: begin
            cosine_reg0 <= 18'sb100110000110000010;
            sine_reg0   <= 18'sb010010110010010000;
        end
        1640: begin
            cosine_reg0 <= 18'sb100110000100001101;
            sine_reg0   <= 18'sb010010101111101101;
        end
        1641: begin
            cosine_reg0 <= 18'sb100110000010010111;
            sine_reg0   <= 18'sb010010101101001010;
        end
        1642: begin
            cosine_reg0 <= 18'sb100110000000100010;
            sine_reg0   <= 18'sb010010101010100111;
        end
        1643: begin
            cosine_reg0 <= 18'sb100101111110101100;
            sine_reg0   <= 18'sb010010101000000011;
        end
        1644: begin
            cosine_reg0 <= 18'sb100101111100110111;
            sine_reg0   <= 18'sb010010100101100000;
        end
        1645: begin
            cosine_reg0 <= 18'sb100101111011000011;
            sine_reg0   <= 18'sb010010100010111100;
        end
        1646: begin
            cosine_reg0 <= 18'sb100101111001001110;
            sine_reg0   <= 18'sb010010100000011000;
        end
        1647: begin
            cosine_reg0 <= 18'sb100101110111011010;
            sine_reg0   <= 18'sb010010011101110100;
        end
        1648: begin
            cosine_reg0 <= 18'sb100101110101100110;
            sine_reg0   <= 18'sb010010011011010000;
        end
        1649: begin
            cosine_reg0 <= 18'sb100101110011110011;
            sine_reg0   <= 18'sb010010011000101011;
        end
        1650: begin
            cosine_reg0 <= 18'sb100101110001111111;
            sine_reg0   <= 18'sb010010010110000111;
        end
        1651: begin
            cosine_reg0 <= 18'sb100101110000001100;
            sine_reg0   <= 18'sb010010010011100010;
        end
        1652: begin
            cosine_reg0 <= 18'sb100101101110011001;
            sine_reg0   <= 18'sb010010010000111101;
        end
        1653: begin
            cosine_reg0 <= 18'sb100101101100100111;
            sine_reg0   <= 18'sb010010001110011000;
        end
        1654: begin
            cosine_reg0 <= 18'sb100101101010110100;
            sine_reg0   <= 18'sb010010001011110010;
        end
        1655: begin
            cosine_reg0 <= 18'sb100101101001000010;
            sine_reg0   <= 18'sb010010001001001101;
        end
        1656: begin
            cosine_reg0 <= 18'sb100101100111010000;
            sine_reg0   <= 18'sb010010000110100111;
        end
        1657: begin
            cosine_reg0 <= 18'sb100101100101011111;
            sine_reg0   <= 18'sb010010000100000001;
        end
        1658: begin
            cosine_reg0 <= 18'sb100101100011101101;
            sine_reg0   <= 18'sb010010000001011011;
        end
        1659: begin
            cosine_reg0 <= 18'sb100101100001111100;
            sine_reg0   <= 18'sb010001111110110101;
        end
        1660: begin
            cosine_reg0 <= 18'sb100101100000001011;
            sine_reg0   <= 18'sb010001111100001110;
        end
        1661: begin
            cosine_reg0 <= 18'sb100101011110011011;
            sine_reg0   <= 18'sb010001111001101000;
        end
        1662: begin
            cosine_reg0 <= 18'sb100101011100101010;
            sine_reg0   <= 18'sb010001110111000001;
        end
        1663: begin
            cosine_reg0 <= 18'sb100101011010111010;
            sine_reg0   <= 18'sb010001110100011010;
        end
        1664: begin
            cosine_reg0 <= 18'sb100101011001001010;
            sine_reg0   <= 18'sb010001110001110011;
        end
        1665: begin
            cosine_reg0 <= 18'sb100101010111011011;
            sine_reg0   <= 18'sb010001101111001100;
        end
        1666: begin
            cosine_reg0 <= 18'sb100101010101101100;
            sine_reg0   <= 18'sb010001101100100100;
        end
        1667: begin
            cosine_reg0 <= 18'sb100101010011111100;
            sine_reg0   <= 18'sb010001101001111101;
        end
        1668: begin
            cosine_reg0 <= 18'sb100101010010001110;
            sine_reg0   <= 18'sb010001100111010101;
        end
        1669: begin
            cosine_reg0 <= 18'sb100101010000011111;
            sine_reg0   <= 18'sb010001100100101101;
        end
        1670: begin
            cosine_reg0 <= 18'sb100101001110110001;
            sine_reg0   <= 18'sb010001100010000101;
        end
        1671: begin
            cosine_reg0 <= 18'sb100101001101000011;
            sine_reg0   <= 18'sb010001011111011101;
        end
        1672: begin
            cosine_reg0 <= 18'sb100101001011010101;
            sine_reg0   <= 18'sb010001011100110100;
        end
        1673: begin
            cosine_reg0 <= 18'sb100101001001101000;
            sine_reg0   <= 18'sb010001011010001100;
        end
        1674: begin
            cosine_reg0 <= 18'sb100101000111111010;
            sine_reg0   <= 18'sb010001010111100011;
        end
        1675: begin
            cosine_reg0 <= 18'sb100101000110001101;
            sine_reg0   <= 18'sb010001010100111010;
        end
        1676: begin
            cosine_reg0 <= 18'sb100101000100100001;
            sine_reg0   <= 18'sb010001010010010001;
        end
        1677: begin
            cosine_reg0 <= 18'sb100101000010110100;
            sine_reg0   <= 18'sb010001001111101000;
        end
        1678: begin
            cosine_reg0 <= 18'sb100101000001001000;
            sine_reg0   <= 18'sb010001001100111110;
        end
        1679: begin
            cosine_reg0 <= 18'sb100100111111011100;
            sine_reg0   <= 18'sb010001001010010100;
        end
        1680: begin
            cosine_reg0 <= 18'sb100100111101110000;
            sine_reg0   <= 18'sb010001000111101011;
        end
        1681: begin
            cosine_reg0 <= 18'sb100100111100000101;
            sine_reg0   <= 18'sb010001000101000001;
        end
        1682: begin
            cosine_reg0 <= 18'sb100100111010011010;
            sine_reg0   <= 18'sb010001000010010111;
        end
        1683: begin
            cosine_reg0 <= 18'sb100100111000101111;
            sine_reg0   <= 18'sb010000111111101100;
        end
        1684: begin
            cosine_reg0 <= 18'sb100100110111000100;
            sine_reg0   <= 18'sb010000111101000010;
        end
        1685: begin
            cosine_reg0 <= 18'sb100100110101011010;
            sine_reg0   <= 18'sb010000111010010111;
        end
        1686: begin
            cosine_reg0 <= 18'sb100100110011101111;
            sine_reg0   <= 18'sb010000110111101101;
        end
        1687: begin
            cosine_reg0 <= 18'sb100100110010000110;
            sine_reg0   <= 18'sb010000110101000010;
        end
        1688: begin
            cosine_reg0 <= 18'sb100100110000011100;
            sine_reg0   <= 18'sb010000110010010110;
        end
        1689: begin
            cosine_reg0 <= 18'sb100100101110110011;
            sine_reg0   <= 18'sb010000101111101011;
        end
        1690: begin
            cosine_reg0 <= 18'sb100100101101001010;
            sine_reg0   <= 18'sb010000101101000000;
        end
        1691: begin
            cosine_reg0 <= 18'sb100100101011100001;
            sine_reg0   <= 18'sb010000101010010100;
        end
        1692: begin
            cosine_reg0 <= 18'sb100100101001111000;
            sine_reg0   <= 18'sb010000100111101001;
        end
        1693: begin
            cosine_reg0 <= 18'sb100100101000010000;
            sine_reg0   <= 18'sb010000100100111101;
        end
        1694: begin
            cosine_reg0 <= 18'sb100100100110101000;
            sine_reg0   <= 18'sb010000100010010001;
        end
        1695: begin
            cosine_reg0 <= 18'sb100100100101000000;
            sine_reg0   <= 18'sb010000011111100100;
        end
        1696: begin
            cosine_reg0 <= 18'sb100100100011011001;
            sine_reg0   <= 18'sb010000011100111000;
        end
        1697: begin
            cosine_reg0 <= 18'sb100100100001110001;
            sine_reg0   <= 18'sb010000011010001011;
        end
        1698: begin
            cosine_reg0 <= 18'sb100100100000001010;
            sine_reg0   <= 18'sb010000010111011111;
        end
        1699: begin
            cosine_reg0 <= 18'sb100100011110100100;
            sine_reg0   <= 18'sb010000010100110010;
        end
        1700: begin
            cosine_reg0 <= 18'sb100100011100111101;
            sine_reg0   <= 18'sb010000010010000101;
        end
        1701: begin
            cosine_reg0 <= 18'sb100100011011010111;
            sine_reg0   <= 18'sb010000001111011000;
        end
        1702: begin
            cosine_reg0 <= 18'sb100100011001110001;
            sine_reg0   <= 18'sb010000001100101010;
        end
        1703: begin
            cosine_reg0 <= 18'sb100100011000001100;
            sine_reg0   <= 18'sb010000001001111101;
        end
        1704: begin
            cosine_reg0 <= 18'sb100100010110100110;
            sine_reg0   <= 18'sb010000000111001111;
        end
        1705: begin
            cosine_reg0 <= 18'sb100100010101000001;
            sine_reg0   <= 18'sb010000000100100001;
        end
        1706: begin
            cosine_reg0 <= 18'sb100100010011011100;
            sine_reg0   <= 18'sb010000000001110100;
        end
        1707: begin
            cosine_reg0 <= 18'sb100100010001111000;
            sine_reg0   <= 18'sb001111111111000101;
        end
        1708: begin
            cosine_reg0 <= 18'sb100100010000010011;
            sine_reg0   <= 18'sb001111111100010111;
        end
        1709: begin
            cosine_reg0 <= 18'sb100100001110101111;
            sine_reg0   <= 18'sb001111111001101001;
        end
        1710: begin
            cosine_reg0 <= 18'sb100100001101001100;
            sine_reg0   <= 18'sb001111110110111010;
        end
        1711: begin
            cosine_reg0 <= 18'sb100100001011101000;
            sine_reg0   <= 18'sb001111110100001100;
        end
        1712: begin
            cosine_reg0 <= 18'sb100100001010000101;
            sine_reg0   <= 18'sb001111110001011101;
        end
        1713: begin
            cosine_reg0 <= 18'sb100100001000100010;
            sine_reg0   <= 18'sb001111101110101110;
        end
        1714: begin
            cosine_reg0 <= 18'sb100100000110111111;
            sine_reg0   <= 18'sb001111101011111110;
        end
        1715: begin
            cosine_reg0 <= 18'sb100100000101011101;
            sine_reg0   <= 18'sb001111101001001111;
        end
        1716: begin
            cosine_reg0 <= 18'sb100100000011111011;
            sine_reg0   <= 18'sb001111100110100000;
        end
        1717: begin
            cosine_reg0 <= 18'sb100100000010011001;
            sine_reg0   <= 18'sb001111100011110000;
        end
        1718: begin
            cosine_reg0 <= 18'sb100100000000110111;
            sine_reg0   <= 18'sb001111100001000000;
        end
        1719: begin
            cosine_reg0 <= 18'sb100011111111010110;
            sine_reg0   <= 18'sb001111011110010000;
        end
        1720: begin
            cosine_reg0 <= 18'sb100011111101110101;
            sine_reg0   <= 18'sb001111011011100000;
        end
        1721: begin
            cosine_reg0 <= 18'sb100011111100010100;
            sine_reg0   <= 18'sb001111011000110000;
        end
        1722: begin
            cosine_reg0 <= 18'sb100011111010110011;
            sine_reg0   <= 18'sb001111010110000000;
        end
        1723: begin
            cosine_reg0 <= 18'sb100011111001010011;
            sine_reg0   <= 18'sb001111010011001111;
        end
        1724: begin
            cosine_reg0 <= 18'sb100011110111110011;
            sine_reg0   <= 18'sb001111010000011111;
        end
        1725: begin
            cosine_reg0 <= 18'sb100011110110010011;
            sine_reg0   <= 18'sb001111001101101110;
        end
        1726: begin
            cosine_reg0 <= 18'sb100011110100110100;
            sine_reg0   <= 18'sb001111001010111101;
        end
        1727: begin
            cosine_reg0 <= 18'sb100011110011010101;
            sine_reg0   <= 18'sb001111001000001100;
        end
        1728: begin
            cosine_reg0 <= 18'sb100011110001110110;
            sine_reg0   <= 18'sb001111000101011010;
        end
        1729: begin
            cosine_reg0 <= 18'sb100011110000010111;
            sine_reg0   <= 18'sb001111000010101001;
        end
        1730: begin
            cosine_reg0 <= 18'sb100011101110111001;
            sine_reg0   <= 18'sb001110111111111000;
        end
        1731: begin
            cosine_reg0 <= 18'sb100011101101011011;
            sine_reg0   <= 18'sb001110111101000110;
        end
        1732: begin
            cosine_reg0 <= 18'sb100011101011111101;
            sine_reg0   <= 18'sb001110111010010100;
        end
        1733: begin
            cosine_reg0 <= 18'sb100011101010011111;
            sine_reg0   <= 18'sb001110110111100010;
        end
        1734: begin
            cosine_reg0 <= 18'sb100011101001000010;
            sine_reg0   <= 18'sb001110110100110000;
        end
        1735: begin
            cosine_reg0 <= 18'sb100011100111100101;
            sine_reg0   <= 18'sb001110110001111110;
        end
        1736: begin
            cosine_reg0 <= 18'sb100011100110001000;
            sine_reg0   <= 18'sb001110101111001011;
        end
        1737: begin
            cosine_reg0 <= 18'sb100011100100101100;
            sine_reg0   <= 18'sb001110101100011001;
        end
        1738: begin
            cosine_reg0 <= 18'sb100011100011010000;
            sine_reg0   <= 18'sb001110101001100110;
        end
        1739: begin
            cosine_reg0 <= 18'sb100011100001110100;
            sine_reg0   <= 18'sb001110100110110011;
        end
        1740: begin
            cosine_reg0 <= 18'sb100011100000011000;
            sine_reg0   <= 18'sb001110100100000000;
        end
        1741: begin
            cosine_reg0 <= 18'sb100011011110111101;
            sine_reg0   <= 18'sb001110100001001101;
        end
        1742: begin
            cosine_reg0 <= 18'sb100011011101100010;
            sine_reg0   <= 18'sb001110011110011010;
        end
        1743: begin
            cosine_reg0 <= 18'sb100011011100000111;
            sine_reg0   <= 18'sb001110011011100111;
        end
        1744: begin
            cosine_reg0 <= 18'sb100011011010101100;
            sine_reg0   <= 18'sb001110011000110011;
        end
        1745: begin
            cosine_reg0 <= 18'sb100011011001010010;
            sine_reg0   <= 18'sb001110010101111111;
        end
        1746: begin
            cosine_reg0 <= 18'sb100011010111111000;
            sine_reg0   <= 18'sb001110010011001100;
        end
        1747: begin
            cosine_reg0 <= 18'sb100011010110011110;
            sine_reg0   <= 18'sb001110010000011000;
        end
        1748: begin
            cosine_reg0 <= 18'sb100011010101000101;
            sine_reg0   <= 18'sb001110001101100100;
        end
        1749: begin
            cosine_reg0 <= 18'sb100011010011101100;
            sine_reg0   <= 18'sb001110001010101111;
        end
        1750: begin
            cosine_reg0 <= 18'sb100011010010010011;
            sine_reg0   <= 18'sb001110000111111011;
        end
        1751: begin
            cosine_reg0 <= 18'sb100011010000111010;
            sine_reg0   <= 18'sb001110000101000110;
        end
        1752: begin
            cosine_reg0 <= 18'sb100011001111100010;
            sine_reg0   <= 18'sb001110000010010010;
        end
        1753: begin
            cosine_reg0 <= 18'sb100011001110001010;
            sine_reg0   <= 18'sb001101111111011101;
        end
        1754: begin
            cosine_reg0 <= 18'sb100011001100110010;
            sine_reg0   <= 18'sb001101111100101000;
        end
        1755: begin
            cosine_reg0 <= 18'sb100011001011011011;
            sine_reg0   <= 18'sb001101111001110011;
        end
        1756: begin
            cosine_reg0 <= 18'sb100011001010000011;
            sine_reg0   <= 18'sb001101110110111110;
        end
        1757: begin
            cosine_reg0 <= 18'sb100011001000101100;
            sine_reg0   <= 18'sb001101110100001001;
        end
        1758: begin
            cosine_reg0 <= 18'sb100011000111010110;
            sine_reg0   <= 18'sb001101110001010011;
        end
        1759: begin
            cosine_reg0 <= 18'sb100011000101111111;
            sine_reg0   <= 18'sb001101101110011110;
        end
        1760: begin
            cosine_reg0 <= 18'sb100011000100101001;
            sine_reg0   <= 18'sb001101101011101000;
        end
        1761: begin
            cosine_reg0 <= 18'sb100011000011010011;
            sine_reg0   <= 18'sb001101101000110010;
        end
        1762: begin
            cosine_reg0 <= 18'sb100011000001111110;
            sine_reg0   <= 18'sb001101100101111100;
        end
        1763: begin
            cosine_reg0 <= 18'sb100011000000101001;
            sine_reg0   <= 18'sb001101100011000110;
        end
        1764: begin
            cosine_reg0 <= 18'sb100010111111010100;
            sine_reg0   <= 18'sb001101100000010000;
        end
        1765: begin
            cosine_reg0 <= 18'sb100010111101111111;
            sine_reg0   <= 18'sb001101011101011010;
        end
        1766: begin
            cosine_reg0 <= 18'sb100010111100101010;
            sine_reg0   <= 18'sb001101011010100011;
        end
        1767: begin
            cosine_reg0 <= 18'sb100010111011010110;
            sine_reg0   <= 18'sb001101010111101101;
        end
        1768: begin
            cosine_reg0 <= 18'sb100010111010000010;
            sine_reg0   <= 18'sb001101010100110110;
        end
        1769: begin
            cosine_reg0 <= 18'sb100010111000101111;
            sine_reg0   <= 18'sb001101010001111111;
        end
        1770: begin
            cosine_reg0 <= 18'sb100010110111011100;
            sine_reg0   <= 18'sb001101001111001000;
        end
        1771: begin
            cosine_reg0 <= 18'sb100010110110001001;
            sine_reg0   <= 18'sb001101001100010001;
        end
        1772: begin
            cosine_reg0 <= 18'sb100010110100110110;
            sine_reg0   <= 18'sb001101001001011010;
        end
        1773: begin
            cosine_reg0 <= 18'sb100010110011100011;
            sine_reg0   <= 18'sb001101000110100010;
        end
        1774: begin
            cosine_reg0 <= 18'sb100010110010010001;
            sine_reg0   <= 18'sb001101000011101011;
        end
        1775: begin
            cosine_reg0 <= 18'sb100010110000111111;
            sine_reg0   <= 18'sb001101000000110011;
        end
        1776: begin
            cosine_reg0 <= 18'sb100010101111101110;
            sine_reg0   <= 18'sb001100111101111011;
        end
        1777: begin
            cosine_reg0 <= 18'sb100010101110011100;
            sine_reg0   <= 18'sb001100111011000100;
        end
        1778: begin
            cosine_reg0 <= 18'sb100010101101001011;
            sine_reg0   <= 18'sb001100111000001100;
        end
        1779: begin
            cosine_reg0 <= 18'sb100010101011111010;
            sine_reg0   <= 18'sb001100110101010011;
        end
        1780: begin
            cosine_reg0 <= 18'sb100010101010101010;
            sine_reg0   <= 18'sb001100110010011011;
        end
        1781: begin
            cosine_reg0 <= 18'sb100010101001011010;
            sine_reg0   <= 18'sb001100101111100011;
        end
        1782: begin
            cosine_reg0 <= 18'sb100010101000001010;
            sine_reg0   <= 18'sb001100101100101010;
        end
        1783: begin
            cosine_reg0 <= 18'sb100010100110111010;
            sine_reg0   <= 18'sb001100101001110010;
        end
        1784: begin
            cosine_reg0 <= 18'sb100010100101101011;
            sine_reg0   <= 18'sb001100100110111001;
        end
        1785: begin
            cosine_reg0 <= 18'sb100010100100011100;
            sine_reg0   <= 18'sb001100100100000000;
        end
        1786: begin
            cosine_reg0 <= 18'sb100010100011001101;
            sine_reg0   <= 18'sb001100100001000111;
        end
        1787: begin
            cosine_reg0 <= 18'sb100010100001111110;
            sine_reg0   <= 18'sb001100011110001110;
        end
        1788: begin
            cosine_reg0 <= 18'sb100010100000110000;
            sine_reg0   <= 18'sb001100011011010101;
        end
        1789: begin
            cosine_reg0 <= 18'sb100010011111100010;
            sine_reg0   <= 18'sb001100011000011011;
        end
        1790: begin
            cosine_reg0 <= 18'sb100010011110010101;
            sine_reg0   <= 18'sb001100010101100010;
        end
        1791: begin
            cosine_reg0 <= 18'sb100010011101000111;
            sine_reg0   <= 18'sb001100010010101000;
        end
        1792: begin
            cosine_reg0 <= 18'sb100010011011111010;
            sine_reg0   <= 18'sb001100001111101111;
        end
        1793: begin
            cosine_reg0 <= 18'sb100010011010101101;
            sine_reg0   <= 18'sb001100001100110101;
        end
        1794: begin
            cosine_reg0 <= 18'sb100010011001100001;
            sine_reg0   <= 18'sb001100001001111011;
        end
        1795: begin
            cosine_reg0 <= 18'sb100010011000010101;
            sine_reg0   <= 18'sb001100000111000001;
        end
        1796: begin
            cosine_reg0 <= 18'sb100010010111001001;
            sine_reg0   <= 18'sb001100000100000111;
        end
        1797: begin
            cosine_reg0 <= 18'sb100010010101111101;
            sine_reg0   <= 18'sb001100000001001100;
        end
        1798: begin
            cosine_reg0 <= 18'sb100010010100110010;
            sine_reg0   <= 18'sb001011111110010010;
        end
        1799: begin
            cosine_reg0 <= 18'sb100010010011100111;
            sine_reg0   <= 18'sb001011111011011000;
        end
        1800: begin
            cosine_reg0 <= 18'sb100010010010011100;
            sine_reg0   <= 18'sb001011111000011101;
        end
        1801: begin
            cosine_reg0 <= 18'sb100010010001010001;
            sine_reg0   <= 18'sb001011110101100010;
        end
        1802: begin
            cosine_reg0 <= 18'sb100010010000000111;
            sine_reg0   <= 18'sb001011110010100111;
        end
        1803: begin
            cosine_reg0 <= 18'sb100010001110111101;
            sine_reg0   <= 18'sb001011101111101100;
        end
        1804: begin
            cosine_reg0 <= 18'sb100010001101110011;
            sine_reg0   <= 18'sb001011101100110001;
        end
        1805: begin
            cosine_reg0 <= 18'sb100010001100101010;
            sine_reg0   <= 18'sb001011101001110110;
        end
        1806: begin
            cosine_reg0 <= 18'sb100010001011100001;
            sine_reg0   <= 18'sb001011100110111011;
        end
        1807: begin
            cosine_reg0 <= 18'sb100010001010011000;
            sine_reg0   <= 18'sb001011100011111111;
        end
        1808: begin
            cosine_reg0 <= 18'sb100010001001010000;
            sine_reg0   <= 18'sb001011100001000100;
        end
        1809: begin
            cosine_reg0 <= 18'sb100010001000000111;
            sine_reg0   <= 18'sb001011011110001000;
        end
        1810: begin
            cosine_reg0 <= 18'sb100010000111000000;
            sine_reg0   <= 18'sb001011011011001100;
        end
        1811: begin
            cosine_reg0 <= 18'sb100010000101111000;
            sine_reg0   <= 18'sb001011011000010001;
        end
        1812: begin
            cosine_reg0 <= 18'sb100010000100110001;
            sine_reg0   <= 18'sb001011010101010101;
        end
        1813: begin
            cosine_reg0 <= 18'sb100010000011101001;
            sine_reg0   <= 18'sb001011010010011000;
        end
        1814: begin
            cosine_reg0 <= 18'sb100010000010100011;
            sine_reg0   <= 18'sb001011001111011100;
        end
        1815: begin
            cosine_reg0 <= 18'sb100010000001011100;
            sine_reg0   <= 18'sb001011001100100000;
        end
        1816: begin
            cosine_reg0 <= 18'sb100010000000010110;
            sine_reg0   <= 18'sb001011001001100100;
        end
        1817: begin
            cosine_reg0 <= 18'sb100001111111010000;
            sine_reg0   <= 18'sb001011000110100111;
        end
        1818: begin
            cosine_reg0 <= 18'sb100001111110001011;
            sine_reg0   <= 18'sb001011000011101010;
        end
        1819: begin
            cosine_reg0 <= 18'sb100001111101000101;
            sine_reg0   <= 18'sb001011000000101110;
        end
        1820: begin
            cosine_reg0 <= 18'sb100001111100000000;
            sine_reg0   <= 18'sb001010111101110001;
        end
        1821: begin
            cosine_reg0 <= 18'sb100001111010111011;
            sine_reg0   <= 18'sb001010111010110100;
        end
        1822: begin
            cosine_reg0 <= 18'sb100001111001110111;
            sine_reg0   <= 18'sb001010110111110111;
        end
        1823: begin
            cosine_reg0 <= 18'sb100001111000110011;
            sine_reg0   <= 18'sb001010110100111010;
        end
        1824: begin
            cosine_reg0 <= 18'sb100001110111101111;
            sine_reg0   <= 18'sb001010110001111100;
        end
        1825: begin
            cosine_reg0 <= 18'sb100001110110101011;
            sine_reg0   <= 18'sb001010101110111111;
        end
        1826: begin
            cosine_reg0 <= 18'sb100001110101101000;
            sine_reg0   <= 18'sb001010101100000010;
        end
        1827: begin
            cosine_reg0 <= 18'sb100001110100100101;
            sine_reg0   <= 18'sb001010101001000100;
        end
        1828: begin
            cosine_reg0 <= 18'sb100001110011100010;
            sine_reg0   <= 18'sb001010100110000110;
        end
        1829: begin
            cosine_reg0 <= 18'sb100001110010100000;
            sine_reg0   <= 18'sb001010100011001001;
        end
        1830: begin
            cosine_reg0 <= 18'sb100001110001011110;
            sine_reg0   <= 18'sb001010100000001011;
        end
        1831: begin
            cosine_reg0 <= 18'sb100001110000011100;
            sine_reg0   <= 18'sb001010011101001101;
        end
        1832: begin
            cosine_reg0 <= 18'sb100001101111011010;
            sine_reg0   <= 18'sb001010011010001111;
        end
        1833: begin
            cosine_reg0 <= 18'sb100001101110011001;
            sine_reg0   <= 18'sb001010010111010001;
        end
        1834: begin
            cosine_reg0 <= 18'sb100001101101011000;
            sine_reg0   <= 18'sb001010010100010010;
        end
        1835: begin
            cosine_reg0 <= 18'sb100001101100010111;
            sine_reg0   <= 18'sb001010010001010100;
        end
        1836: begin
            cosine_reg0 <= 18'sb100001101011010111;
            sine_reg0   <= 18'sb001010001110010101;
        end
        1837: begin
            cosine_reg0 <= 18'sb100001101010010111;
            sine_reg0   <= 18'sb001010001011010111;
        end
        1838: begin
            cosine_reg0 <= 18'sb100001101001010111;
            sine_reg0   <= 18'sb001010001000011000;
        end
        1839: begin
            cosine_reg0 <= 18'sb100001101000011000;
            sine_reg0   <= 18'sb001010000101011001;
        end
        1840: begin
            cosine_reg0 <= 18'sb100001100111011000;
            sine_reg0   <= 18'sb001010000010011011;
        end
        1841: begin
            cosine_reg0 <= 18'sb100001100110011001;
            sine_reg0   <= 18'sb001001111111011100;
        end
        1842: begin
            cosine_reg0 <= 18'sb100001100101011011;
            sine_reg0   <= 18'sb001001111100011101;
        end
        1843: begin
            cosine_reg0 <= 18'sb100001100100011101;
            sine_reg0   <= 18'sb001001111001011101;
        end
        1844: begin
            cosine_reg0 <= 18'sb100001100011011110;
            sine_reg0   <= 18'sb001001110110011110;
        end
        1845: begin
            cosine_reg0 <= 18'sb100001100010100001;
            sine_reg0   <= 18'sb001001110011011111;
        end
        1846: begin
            cosine_reg0 <= 18'sb100001100001100011;
            sine_reg0   <= 18'sb001001110000011111;
        end
        1847: begin
            cosine_reg0 <= 18'sb100001100000100110;
            sine_reg0   <= 18'sb001001101101100000;
        end
        1848: begin
            cosine_reg0 <= 18'sb100001011111101001;
            sine_reg0   <= 18'sb001001101010100000;
        end
        1849: begin
            cosine_reg0 <= 18'sb100001011110101101;
            sine_reg0   <= 18'sb001001100111100001;
        end
        1850: begin
            cosine_reg0 <= 18'sb100001011101110000;
            sine_reg0   <= 18'sb001001100100100001;
        end
        1851: begin
            cosine_reg0 <= 18'sb100001011100110100;
            sine_reg0   <= 18'sb001001100001100001;
        end
        1852: begin
            cosine_reg0 <= 18'sb100001011011111001;
            sine_reg0   <= 18'sb001001011110100001;
        end
        1853: begin
            cosine_reg0 <= 18'sb100001011010111101;
            sine_reg0   <= 18'sb001001011011100001;
        end
        1854: begin
            cosine_reg0 <= 18'sb100001011010000010;
            sine_reg0   <= 18'sb001001011000100001;
        end
        1855: begin
            cosine_reg0 <= 18'sb100001011001000111;
            sine_reg0   <= 18'sb001001010101100000;
        end
        1856: begin
            cosine_reg0 <= 18'sb100001011000001101;
            sine_reg0   <= 18'sb001001010010100000;
        end
        1857: begin
            cosine_reg0 <= 18'sb100001010111010011;
            sine_reg0   <= 18'sb001001001111011111;
        end
        1858: begin
            cosine_reg0 <= 18'sb100001010110011001;
            sine_reg0   <= 18'sb001001001100011111;
        end
        1859: begin
            cosine_reg0 <= 18'sb100001010101011111;
            sine_reg0   <= 18'sb001001001001011110;
        end
        1860: begin
            cosine_reg0 <= 18'sb100001010100100110;
            sine_reg0   <= 18'sb001001000110011110;
        end
        1861: begin
            cosine_reg0 <= 18'sb100001010011101101;
            sine_reg0   <= 18'sb001001000011011101;
        end
        1862: begin
            cosine_reg0 <= 18'sb100001010010110100;
            sine_reg0   <= 18'sb001001000000011100;
        end
        1863: begin
            cosine_reg0 <= 18'sb100001010001111100;
            sine_reg0   <= 18'sb001000111101011011;
        end
        1864: begin
            cosine_reg0 <= 18'sb100001010001000011;
            sine_reg0   <= 18'sb001000111010011010;
        end
        1865: begin
            cosine_reg0 <= 18'sb100001010000001100;
            sine_reg0   <= 18'sb001000110111011001;
        end
        1866: begin
            cosine_reg0 <= 18'sb100001001111010100;
            sine_reg0   <= 18'sb001000110100010111;
        end
        1867: begin
            cosine_reg0 <= 18'sb100001001110011101;
            sine_reg0   <= 18'sb001000110001010110;
        end
        1868: begin
            cosine_reg0 <= 18'sb100001001101100110;
            sine_reg0   <= 18'sb001000101110010101;
        end
        1869: begin
            cosine_reg0 <= 18'sb100001001100101111;
            sine_reg0   <= 18'sb001000101011010011;
        end
        1870: begin
            cosine_reg0 <= 18'sb100001001011111001;
            sine_reg0   <= 18'sb001000101000010010;
        end
        1871: begin
            cosine_reg0 <= 18'sb100001001011000011;
            sine_reg0   <= 18'sb001000100101010000;
        end
        1872: begin
            cosine_reg0 <= 18'sb100001001010001101;
            sine_reg0   <= 18'sb001000100010001110;
        end
        1873: begin
            cosine_reg0 <= 18'sb100001001001010111;
            sine_reg0   <= 18'sb001000011111001100;
        end
        1874: begin
            cosine_reg0 <= 18'sb100001001000100010;
            sine_reg0   <= 18'sb001000011100001011;
        end
        1875: begin
            cosine_reg0 <= 18'sb100001000111101101;
            sine_reg0   <= 18'sb001000011001001001;
        end
        1876: begin
            cosine_reg0 <= 18'sb100001000110111001;
            sine_reg0   <= 18'sb001000010110000111;
        end
        1877: begin
            cosine_reg0 <= 18'sb100001000110000100;
            sine_reg0   <= 18'sb001000010011000100;
        end
        1878: begin
            cosine_reg0 <= 18'sb100001000101010001;
            sine_reg0   <= 18'sb001000010000000010;
        end
        1879: begin
            cosine_reg0 <= 18'sb100001000100011101;
            sine_reg0   <= 18'sb001000001101000000;
        end
        1880: begin
            cosine_reg0 <= 18'sb100001000011101001;
            sine_reg0   <= 18'sb001000001001111101;
        end
        1881: begin
            cosine_reg0 <= 18'sb100001000010110110;
            sine_reg0   <= 18'sb001000000110111011;
        end
        1882: begin
            cosine_reg0 <= 18'sb100001000010000100;
            sine_reg0   <= 18'sb001000000011111000;
        end
        1883: begin
            cosine_reg0 <= 18'sb100001000001010001;
            sine_reg0   <= 18'sb001000000000110110;
        end
        1884: begin
            cosine_reg0 <= 18'sb100001000000011111;
            sine_reg0   <= 18'sb000111111101110011;
        end
        1885: begin
            cosine_reg0 <= 18'sb100000111111101101;
            sine_reg0   <= 18'sb000111111010110000;
        end
        1886: begin
            cosine_reg0 <= 18'sb100000111110111011;
            sine_reg0   <= 18'sb000111110111101110;
        end
        1887: begin
            cosine_reg0 <= 18'sb100000111110001010;
            sine_reg0   <= 18'sb000111110100101011;
        end
        1888: begin
            cosine_reg0 <= 18'sb100000111101011001;
            sine_reg0   <= 18'sb000111110001101000;
        end
        1889: begin
            cosine_reg0 <= 18'sb100000111100101000;
            sine_reg0   <= 18'sb000111101110100101;
        end
        1890: begin
            cosine_reg0 <= 18'sb100000111011111000;
            sine_reg0   <= 18'sb000111101011100001;
        end
        1891: begin
            cosine_reg0 <= 18'sb100000111011001000;
            sine_reg0   <= 18'sb000111101000011110;
        end
        1892: begin
            cosine_reg0 <= 18'sb100000111010011000;
            sine_reg0   <= 18'sb000111100101011011;
        end
        1893: begin
            cosine_reg0 <= 18'sb100000111001101001;
            sine_reg0   <= 18'sb000111100010011000;
        end
        1894: begin
            cosine_reg0 <= 18'sb100000111000111001;
            sine_reg0   <= 18'sb000111011111010100;
        end
        1895: begin
            cosine_reg0 <= 18'sb100000111000001010;
            sine_reg0   <= 18'sb000111011100010001;
        end
        1896: begin
            cosine_reg0 <= 18'sb100000110111011100;
            sine_reg0   <= 18'sb000111011001001101;
        end
        1897: begin
            cosine_reg0 <= 18'sb100000110110101101;
            sine_reg0   <= 18'sb000111010110001001;
        end
        1898: begin
            cosine_reg0 <= 18'sb100000110101111111;
            sine_reg0   <= 18'sb000111010011000110;
        end
        1899: begin
            cosine_reg0 <= 18'sb100000110101010010;
            sine_reg0   <= 18'sb000111010000000010;
        end
        1900: begin
            cosine_reg0 <= 18'sb100000110100100100;
            sine_reg0   <= 18'sb000111001100111110;
        end
        1901: begin
            cosine_reg0 <= 18'sb100000110011110111;
            sine_reg0   <= 18'sb000111001001111010;
        end
        1902: begin
            cosine_reg0 <= 18'sb100000110011001010;
            sine_reg0   <= 18'sb000111000110110110;
        end
        1903: begin
            cosine_reg0 <= 18'sb100000110010011110;
            sine_reg0   <= 18'sb000111000011110010;
        end
        1904: begin
            cosine_reg0 <= 18'sb100000110001110010;
            sine_reg0   <= 18'sb000111000000101110;
        end
        1905: begin
            cosine_reg0 <= 18'sb100000110001000110;
            sine_reg0   <= 18'sb000110111101101010;
        end
        1906: begin
            cosine_reg0 <= 18'sb100000110000011010;
            sine_reg0   <= 18'sb000110111010100101;
        end
        1907: begin
            cosine_reg0 <= 18'sb100000101111101111;
            sine_reg0   <= 18'sb000110110111100001;
        end
        1908: begin
            cosine_reg0 <= 18'sb100000101111000100;
            sine_reg0   <= 18'sb000110110100011101;
        end
        1909: begin
            cosine_reg0 <= 18'sb100000101110011001;
            sine_reg0   <= 18'sb000110110001011000;
        end
        1910: begin
            cosine_reg0 <= 18'sb100000101101101111;
            sine_reg0   <= 18'sb000110101110010100;
        end
        1911: begin
            cosine_reg0 <= 18'sb100000101101000101;
            sine_reg0   <= 18'sb000110101011001111;
        end
        1912: begin
            cosine_reg0 <= 18'sb100000101100011011;
            sine_reg0   <= 18'sb000110101000001010;
        end
        1913: begin
            cosine_reg0 <= 18'sb100000101011110001;
            sine_reg0   <= 18'sb000110100101000110;
        end
        1914: begin
            cosine_reg0 <= 18'sb100000101011001000;
            sine_reg0   <= 18'sb000110100010000001;
        end
        1915: begin
            cosine_reg0 <= 18'sb100000101010011111;
            sine_reg0   <= 18'sb000110011110111100;
        end
        1916: begin
            cosine_reg0 <= 18'sb100000101001110111;
            sine_reg0   <= 18'sb000110011011110111;
        end
        1917: begin
            cosine_reg0 <= 18'sb100000101001001111;
            sine_reg0   <= 18'sb000110011000110010;
        end
        1918: begin
            cosine_reg0 <= 18'sb100000101000100111;
            sine_reg0   <= 18'sb000110010101101101;
        end
        1919: begin
            cosine_reg0 <= 18'sb100000100111111111;
            sine_reg0   <= 18'sb000110010010101000;
        end
        1920: begin
            cosine_reg0 <= 18'sb100000100111010111;
            sine_reg0   <= 18'sb000110001111100011;
        end
        1921: begin
            cosine_reg0 <= 18'sb100000100110110000;
            sine_reg0   <= 18'sb000110001100011101;
        end
        1922: begin
            cosine_reg0 <= 18'sb100000100110001010;
            sine_reg0   <= 18'sb000110001001011000;
        end
        1923: begin
            cosine_reg0 <= 18'sb100000100101100011;
            sine_reg0   <= 18'sb000110000110010011;
        end
        1924: begin
            cosine_reg0 <= 18'sb100000100100111101;
            sine_reg0   <= 18'sb000110000011001101;
        end
        1925: begin
            cosine_reg0 <= 18'sb100000100100010111;
            sine_reg0   <= 18'sb000110000000001000;
        end
        1926: begin
            cosine_reg0 <= 18'sb100000100011110010;
            sine_reg0   <= 18'sb000101111101000010;
        end
        1927: begin
            cosine_reg0 <= 18'sb100000100011001100;
            sine_reg0   <= 18'sb000101111001111101;
        end
        1928: begin
            cosine_reg0 <= 18'sb100000100010100111;
            sine_reg0   <= 18'sb000101110110110111;
        end
        1929: begin
            cosine_reg0 <= 18'sb100000100010000011;
            sine_reg0   <= 18'sb000101110011110010;
        end
        1930: begin
            cosine_reg0 <= 18'sb100000100001011110;
            sine_reg0   <= 18'sb000101110000101100;
        end
        1931: begin
            cosine_reg0 <= 18'sb100000100000111010;
            sine_reg0   <= 18'sb000101101101100110;
        end
        1932: begin
            cosine_reg0 <= 18'sb100000100000010111;
            sine_reg0   <= 18'sb000101101010100000;
        end
        1933: begin
            cosine_reg0 <= 18'sb100000011111110011;
            sine_reg0   <= 18'sb000101100111011010;
        end
        1934: begin
            cosine_reg0 <= 18'sb100000011111010000;
            sine_reg0   <= 18'sb000101100100010100;
        end
        1935: begin
            cosine_reg0 <= 18'sb100000011110101101;
            sine_reg0   <= 18'sb000101100001001110;
        end
        1936: begin
            cosine_reg0 <= 18'sb100000011110001011;
            sine_reg0   <= 18'sb000101011110001000;
        end
        1937: begin
            cosine_reg0 <= 18'sb100000011101101000;
            sine_reg0   <= 18'sb000101011011000010;
        end
        1938: begin
            cosine_reg0 <= 18'sb100000011101000111;
            sine_reg0   <= 18'sb000101010111111100;
        end
        1939: begin
            cosine_reg0 <= 18'sb100000011100100101;
            sine_reg0   <= 18'sb000101010100110110;
        end
        1940: begin
            cosine_reg0 <= 18'sb100000011100000100;
            sine_reg0   <= 18'sb000101010001101111;
        end
        1941: begin
            cosine_reg0 <= 18'sb100000011011100011;
            sine_reg0   <= 18'sb000101001110101001;
        end
        1942: begin
            cosine_reg0 <= 18'sb100000011011000010;
            sine_reg0   <= 18'sb000101001011100011;
        end
        1943: begin
            cosine_reg0 <= 18'sb100000011010100010;
            sine_reg0   <= 18'sb000101001000011100;
        end
        1944: begin
            cosine_reg0 <= 18'sb100000011010000001;
            sine_reg0   <= 18'sb000101000101010110;
        end
        1945: begin
            cosine_reg0 <= 18'sb100000011001100010;
            sine_reg0   <= 18'sb000101000010001111;
        end
        1946: begin
            cosine_reg0 <= 18'sb100000011001000010;
            sine_reg0   <= 18'sb000100111111001001;
        end
        1947: begin
            cosine_reg0 <= 18'sb100000011000100011;
            sine_reg0   <= 18'sb000100111100000010;
        end
        1948: begin
            cosine_reg0 <= 18'sb100000011000000100;
            sine_reg0   <= 18'sb000100111000111011;
        end
        1949: begin
            cosine_reg0 <= 18'sb100000010111100110;
            sine_reg0   <= 18'sb000100110101110101;
        end
        1950: begin
            cosine_reg0 <= 18'sb100000010111000111;
            sine_reg0   <= 18'sb000100110010101110;
        end
        1951: begin
            cosine_reg0 <= 18'sb100000010110101001;
            sine_reg0   <= 18'sb000100101111100111;
        end
        1952: begin
            cosine_reg0 <= 18'sb100000010110001100;
            sine_reg0   <= 18'sb000100101100100000;
        end
        1953: begin
            cosine_reg0 <= 18'sb100000010101101110;
            sine_reg0   <= 18'sb000100101001011001;
        end
        1954: begin
            cosine_reg0 <= 18'sb100000010101010001;
            sine_reg0   <= 18'sb000100100110010010;
        end
        1955: begin
            cosine_reg0 <= 18'sb100000010100110101;
            sine_reg0   <= 18'sb000100100011001011;
        end
        1956: begin
            cosine_reg0 <= 18'sb100000010100011000;
            sine_reg0   <= 18'sb000100100000000100;
        end
        1957: begin
            cosine_reg0 <= 18'sb100000010011111100;
            sine_reg0   <= 18'sb000100011100111101;
        end
        1958: begin
            cosine_reg0 <= 18'sb100000010011100000;
            sine_reg0   <= 18'sb000100011001110110;
        end
        1959: begin
            cosine_reg0 <= 18'sb100000010011000101;
            sine_reg0   <= 18'sb000100010110101111;
        end
        1960: begin
            cosine_reg0 <= 18'sb100000010010101001;
            sine_reg0   <= 18'sb000100010011101000;
        end
        1961: begin
            cosine_reg0 <= 18'sb100000010010001110;
            sine_reg0   <= 18'sb000100010000100000;
        end
        1962: begin
            cosine_reg0 <= 18'sb100000010001110100;
            sine_reg0   <= 18'sb000100001101011001;
        end
        1963: begin
            cosine_reg0 <= 18'sb100000010001011010;
            sine_reg0   <= 18'sb000100001010010010;
        end
        1964: begin
            cosine_reg0 <= 18'sb100000010001000000;
            sine_reg0   <= 18'sb000100000111001010;
        end
        1965: begin
            cosine_reg0 <= 18'sb100000010000100110;
            sine_reg0   <= 18'sb000100000100000011;
        end
        1966: begin
            cosine_reg0 <= 18'sb100000010000001101;
            sine_reg0   <= 18'sb000100000000111100;
        end
        1967: begin
            cosine_reg0 <= 18'sb100000001111110011;
            sine_reg0   <= 18'sb000011111101110100;
        end
        1968: begin
            cosine_reg0 <= 18'sb100000001111011011;
            sine_reg0   <= 18'sb000011111010101100;
        end
        1969: begin
            cosine_reg0 <= 18'sb100000001111000010;
            sine_reg0   <= 18'sb000011110111100101;
        end
        1970: begin
            cosine_reg0 <= 18'sb100000001110101010;
            sine_reg0   <= 18'sb000011110100011101;
        end
        1971: begin
            cosine_reg0 <= 18'sb100000001110010010;
            sine_reg0   <= 18'sb000011110001010110;
        end
        1972: begin
            cosine_reg0 <= 18'sb100000001101111011;
            sine_reg0   <= 18'sb000011101110001110;
        end
        1973: begin
            cosine_reg0 <= 18'sb100000001101100011;
            sine_reg0   <= 18'sb000011101011000110;
        end
        1974: begin
            cosine_reg0 <= 18'sb100000001101001101;
            sine_reg0   <= 18'sb000011100111111111;
        end
        1975: begin
            cosine_reg0 <= 18'sb100000001100110110;
            sine_reg0   <= 18'sb000011100100110111;
        end
        1976: begin
            cosine_reg0 <= 18'sb100000001100100000;
            sine_reg0   <= 18'sb000011100001101111;
        end
        1977: begin
            cosine_reg0 <= 18'sb100000001100001010;
            sine_reg0   <= 18'sb000011011110100111;
        end
        1978: begin
            cosine_reg0 <= 18'sb100000001011110100;
            sine_reg0   <= 18'sb000011011011011111;
        end
        1979: begin
            cosine_reg0 <= 18'sb100000001011011111;
            sine_reg0   <= 18'sb000011011000010111;
        end
        1980: begin
            cosine_reg0 <= 18'sb100000001011001001;
            sine_reg0   <= 18'sb000011010101001111;
        end
        1981: begin
            cosine_reg0 <= 18'sb100000001010110101;
            sine_reg0   <= 18'sb000011010010000111;
        end
        1982: begin
            cosine_reg0 <= 18'sb100000001010100000;
            sine_reg0   <= 18'sb000011001110111111;
        end
        1983: begin
            cosine_reg0 <= 18'sb100000001010001100;
            sine_reg0   <= 18'sb000011001011110111;
        end
        1984: begin
            cosine_reg0 <= 18'sb100000001001111000;
            sine_reg0   <= 18'sb000011001000101111;
        end
        1985: begin
            cosine_reg0 <= 18'sb100000001001100101;
            sine_reg0   <= 18'sb000011000101100111;
        end
        1986: begin
            cosine_reg0 <= 18'sb100000001001010001;
            sine_reg0   <= 18'sb000011000010011111;
        end
        1987: begin
            cosine_reg0 <= 18'sb100000001000111110;
            sine_reg0   <= 18'sb000010111111010111;
        end
        1988: begin
            cosine_reg0 <= 18'sb100000001000101100;
            sine_reg0   <= 18'sb000010111100001111;
        end
        1989: begin
            cosine_reg0 <= 18'sb100000001000011001;
            sine_reg0   <= 18'sb000010111001000110;
        end
        1990: begin
            cosine_reg0 <= 18'sb100000001000000111;
            sine_reg0   <= 18'sb000010110101111110;
        end
        1991: begin
            cosine_reg0 <= 18'sb100000000111110110;
            sine_reg0   <= 18'sb000010110010110110;
        end
        1992: begin
            cosine_reg0 <= 18'sb100000000111100100;
            sine_reg0   <= 18'sb000010101111101110;
        end
        1993: begin
            cosine_reg0 <= 18'sb100000000111010011;
            sine_reg0   <= 18'sb000010101100100101;
        end
        1994: begin
            cosine_reg0 <= 18'sb100000000111000010;
            sine_reg0   <= 18'sb000010101001011101;
        end
        1995: begin
            cosine_reg0 <= 18'sb100000000110110010;
            sine_reg0   <= 18'sb000010100110010100;
        end
        1996: begin
            cosine_reg0 <= 18'sb100000000110100010;
            sine_reg0   <= 18'sb000010100011001100;
        end
        1997: begin
            cosine_reg0 <= 18'sb100000000110010010;
            sine_reg0   <= 18'sb000010100000000100;
        end
        1998: begin
            cosine_reg0 <= 18'sb100000000110000010;
            sine_reg0   <= 18'sb000010011100111011;
        end
        1999: begin
            cosine_reg0 <= 18'sb100000000101110011;
            sine_reg0   <= 18'sb000010011001110011;
        end
        2000: begin
            cosine_reg0 <= 18'sb100000000101100100;
            sine_reg0   <= 18'sb000010010110101010;
        end
        2001: begin
            cosine_reg0 <= 18'sb100000000101010110;
            sine_reg0   <= 18'sb000010010011100010;
        end
        2002: begin
            cosine_reg0 <= 18'sb100000000101000111;
            sine_reg0   <= 18'sb000010010000011001;
        end
        2003: begin
            cosine_reg0 <= 18'sb100000000100111001;
            sine_reg0   <= 18'sb000010001101010001;
        end
        2004: begin
            cosine_reg0 <= 18'sb100000000100101011;
            sine_reg0   <= 18'sb000010001010001000;
        end
        2005: begin
            cosine_reg0 <= 18'sb100000000100011110;
            sine_reg0   <= 18'sb000010000110111111;
        end
        2006: begin
            cosine_reg0 <= 18'sb100000000100010001;
            sine_reg0   <= 18'sb000010000011110111;
        end
        2007: begin
            cosine_reg0 <= 18'sb100000000100000100;
            sine_reg0   <= 18'sb000010000000101110;
        end
        2008: begin
            cosine_reg0 <= 18'sb100000000011111000;
            sine_reg0   <= 18'sb000001111101100101;
        end
        2009: begin
            cosine_reg0 <= 18'sb100000000011101011;
            sine_reg0   <= 18'sb000001111010011101;
        end
        2010: begin
            cosine_reg0 <= 18'sb100000000011100000;
            sine_reg0   <= 18'sb000001110111010100;
        end
        2011: begin
            cosine_reg0 <= 18'sb100000000011010100;
            sine_reg0   <= 18'sb000001110100001011;
        end
        2012: begin
            cosine_reg0 <= 18'sb100000000011001001;
            sine_reg0   <= 18'sb000001110001000010;
        end
        2013: begin
            cosine_reg0 <= 18'sb100000000010111110;
            sine_reg0   <= 18'sb000001101101111010;
        end
        2014: begin
            cosine_reg0 <= 18'sb100000000010110011;
            sine_reg0   <= 18'sb000001101010110001;
        end
        2015: begin
            cosine_reg0 <= 18'sb100000000010101001;
            sine_reg0   <= 18'sb000001100111101000;
        end
        2016: begin
            cosine_reg0 <= 18'sb100000000010011111;
            sine_reg0   <= 18'sb000001100100011111;
        end
        2017: begin
            cosine_reg0 <= 18'sb100000000010010101;
            sine_reg0   <= 18'sb000001100001010111;
        end
        2018: begin
            cosine_reg0 <= 18'sb100000000010001100;
            sine_reg0   <= 18'sb000001011110001110;
        end
        2019: begin
            cosine_reg0 <= 18'sb100000000010000011;
            sine_reg0   <= 18'sb000001011011000101;
        end
        2020: begin
            cosine_reg0 <= 18'sb100000000001111010;
            sine_reg0   <= 18'sb000001010111111100;
        end
        2021: begin
            cosine_reg0 <= 18'sb100000000001110001;
            sine_reg0   <= 18'sb000001010100110011;
        end
        2022: begin
            cosine_reg0 <= 18'sb100000000001101001;
            sine_reg0   <= 18'sb000001010001101010;
        end
        2023: begin
            cosine_reg0 <= 18'sb100000000001100001;
            sine_reg0   <= 18'sb000001001110100001;
        end
        2024: begin
            cosine_reg0 <= 18'sb100000000001011010;
            sine_reg0   <= 18'sb000001001011011000;
        end
        2025: begin
            cosine_reg0 <= 18'sb100000000001010011;
            sine_reg0   <= 18'sb000001001000001111;
        end
        2026: begin
            cosine_reg0 <= 18'sb100000000001001100;
            sine_reg0   <= 18'sb000001000101000110;
        end
        2027: begin
            cosine_reg0 <= 18'sb100000000001000101;
            sine_reg0   <= 18'sb000001000001111110;
        end
        2028: begin
            cosine_reg0 <= 18'sb100000000000111111;
            sine_reg0   <= 18'sb000000111110110101;
        end
        2029: begin
            cosine_reg0 <= 18'sb100000000000111001;
            sine_reg0   <= 18'sb000000111011101100;
        end
        2030: begin
            cosine_reg0 <= 18'sb100000000000110011;
            sine_reg0   <= 18'sb000000111000100011;
        end
        2031: begin
            cosine_reg0 <= 18'sb100000000000101110;
            sine_reg0   <= 18'sb000000110101011010;
        end
        2032: begin
            cosine_reg0 <= 18'sb100000000000101000;
            sine_reg0   <= 18'sb000000110010010001;
        end
        2033: begin
            cosine_reg0 <= 18'sb100000000000100100;
            sine_reg0   <= 18'sb000000101111001000;
        end
        2034: begin
            cosine_reg0 <= 18'sb100000000000011111;
            sine_reg0   <= 18'sb000000101011111111;
        end
        2035: begin
            cosine_reg0 <= 18'sb100000000000011011;
            sine_reg0   <= 18'sb000000101000110110;
        end
        2036: begin
            cosine_reg0 <= 18'sb100000000000010111;
            sine_reg0   <= 18'sb000000100101101101;
        end
        2037: begin
            cosine_reg0 <= 18'sb100000000000010100;
            sine_reg0   <= 18'sb000000100010100100;
        end
        2038: begin
            cosine_reg0 <= 18'sb100000000000010000;
            sine_reg0   <= 18'sb000000011111011011;
        end
        2039: begin
            cosine_reg0 <= 18'sb100000000000001101;
            sine_reg0   <= 18'sb000000011100010001;
        end
        2040: begin
            cosine_reg0 <= 18'sb100000000000001011;
            sine_reg0   <= 18'sb000000011001001000;
        end
        2041: begin
            cosine_reg0 <= 18'sb100000000000001001;
            sine_reg0   <= 18'sb000000010101111111;
        end
        2042: begin
            cosine_reg0 <= 18'sb100000000000000111;
            sine_reg0   <= 18'sb000000010010110110;
        end
        2043: begin
            cosine_reg0 <= 18'sb100000000000000101;
            sine_reg0   <= 18'sb000000001111101101;
        end
        2044: begin
            cosine_reg0 <= 18'sb100000000000000011;
            sine_reg0   <= 18'sb000000001100100100;
        end
        2045: begin
            cosine_reg0 <= 18'sb100000000000000010;
            sine_reg0   <= 18'sb000000001001011011;
        end
        2046: begin
            cosine_reg0 <= 18'sb100000000000000010;
            sine_reg0   <= 18'sb000000000110010010;
        end
        2047: begin
            cosine_reg0 <= 18'sb100000000000000001;
            sine_reg0   <= 18'sb000000000011001001;
        end
        2048: begin
            cosine_reg0 <= 18'sb100000000000000001;
            sine_reg0   <= 18'sb000000000000000000;
        end
        2049: begin
            cosine_reg0 <= 18'sb100000000000000001;
            sine_reg0   <= 18'sb111111111100110111;
        end
        2050: begin
            cosine_reg0 <= 18'sb100000000000000010;
            sine_reg0   <= 18'sb111111111001101110;
        end
        2051: begin
            cosine_reg0 <= 18'sb100000000000000010;
            sine_reg0   <= 18'sb111111110110100101;
        end
        2052: begin
            cosine_reg0 <= 18'sb100000000000000011;
            sine_reg0   <= 18'sb111111110011011100;
        end
        2053: begin
            cosine_reg0 <= 18'sb100000000000000101;
            sine_reg0   <= 18'sb111111110000010011;
        end
        2054: begin
            cosine_reg0 <= 18'sb100000000000000111;
            sine_reg0   <= 18'sb111111101101001010;
        end
        2055: begin
            cosine_reg0 <= 18'sb100000000000001001;
            sine_reg0   <= 18'sb111111101010000001;
        end
        2056: begin
            cosine_reg0 <= 18'sb100000000000001011;
            sine_reg0   <= 18'sb111111100110111000;
        end
        2057: begin
            cosine_reg0 <= 18'sb100000000000001101;
            sine_reg0   <= 18'sb111111100011101111;
        end
        2058: begin
            cosine_reg0 <= 18'sb100000000000010000;
            sine_reg0   <= 18'sb111111100000100101;
        end
        2059: begin
            cosine_reg0 <= 18'sb100000000000010100;
            sine_reg0   <= 18'sb111111011101011100;
        end
        2060: begin
            cosine_reg0 <= 18'sb100000000000010111;
            sine_reg0   <= 18'sb111111011010010011;
        end
        2061: begin
            cosine_reg0 <= 18'sb100000000000011011;
            sine_reg0   <= 18'sb111111010111001010;
        end
        2062: begin
            cosine_reg0 <= 18'sb100000000000011111;
            sine_reg0   <= 18'sb111111010100000001;
        end
        2063: begin
            cosine_reg0 <= 18'sb100000000000100100;
            sine_reg0   <= 18'sb111111010000111000;
        end
        2064: begin
            cosine_reg0 <= 18'sb100000000000101000;
            sine_reg0   <= 18'sb111111001101101111;
        end
        2065: begin
            cosine_reg0 <= 18'sb100000000000101110;
            sine_reg0   <= 18'sb111111001010100110;
        end
        2066: begin
            cosine_reg0 <= 18'sb100000000000110011;
            sine_reg0   <= 18'sb111111000111011101;
        end
        2067: begin
            cosine_reg0 <= 18'sb100000000000111001;
            sine_reg0   <= 18'sb111111000100010100;
        end
        2068: begin
            cosine_reg0 <= 18'sb100000000000111111;
            sine_reg0   <= 18'sb111111000001001011;
        end
        2069: begin
            cosine_reg0 <= 18'sb100000000001000101;
            sine_reg0   <= 18'sb111110111110000010;
        end
        2070: begin
            cosine_reg0 <= 18'sb100000000001001100;
            sine_reg0   <= 18'sb111110111010111010;
        end
        2071: begin
            cosine_reg0 <= 18'sb100000000001010011;
            sine_reg0   <= 18'sb111110110111110001;
        end
        2072: begin
            cosine_reg0 <= 18'sb100000000001011010;
            sine_reg0   <= 18'sb111110110100101000;
        end
        2073: begin
            cosine_reg0 <= 18'sb100000000001100001;
            sine_reg0   <= 18'sb111110110001011111;
        end
        2074: begin
            cosine_reg0 <= 18'sb100000000001101001;
            sine_reg0   <= 18'sb111110101110010110;
        end
        2075: begin
            cosine_reg0 <= 18'sb100000000001110001;
            sine_reg0   <= 18'sb111110101011001101;
        end
        2076: begin
            cosine_reg0 <= 18'sb100000000001111010;
            sine_reg0   <= 18'sb111110101000000100;
        end
        2077: begin
            cosine_reg0 <= 18'sb100000000010000011;
            sine_reg0   <= 18'sb111110100100111011;
        end
        2078: begin
            cosine_reg0 <= 18'sb100000000010001100;
            sine_reg0   <= 18'sb111110100001110010;
        end
        2079: begin
            cosine_reg0 <= 18'sb100000000010010101;
            sine_reg0   <= 18'sb111110011110101001;
        end
        2080: begin
            cosine_reg0 <= 18'sb100000000010011111;
            sine_reg0   <= 18'sb111110011011100001;
        end
        2081: begin
            cosine_reg0 <= 18'sb100000000010101001;
            sine_reg0   <= 18'sb111110011000011000;
        end
        2082: begin
            cosine_reg0 <= 18'sb100000000010110011;
            sine_reg0   <= 18'sb111110010101001111;
        end
        2083: begin
            cosine_reg0 <= 18'sb100000000010111110;
            sine_reg0   <= 18'sb111110010010000110;
        end
        2084: begin
            cosine_reg0 <= 18'sb100000000011001001;
            sine_reg0   <= 18'sb111110001110111110;
        end
        2085: begin
            cosine_reg0 <= 18'sb100000000011010100;
            sine_reg0   <= 18'sb111110001011110101;
        end
        2086: begin
            cosine_reg0 <= 18'sb100000000011100000;
            sine_reg0   <= 18'sb111110001000101100;
        end
        2087: begin
            cosine_reg0 <= 18'sb100000000011101011;
            sine_reg0   <= 18'sb111110000101100011;
        end
        2088: begin
            cosine_reg0 <= 18'sb100000000011111000;
            sine_reg0   <= 18'sb111110000010011011;
        end
        2089: begin
            cosine_reg0 <= 18'sb100000000100000100;
            sine_reg0   <= 18'sb111101111111010010;
        end
        2090: begin
            cosine_reg0 <= 18'sb100000000100010001;
            sine_reg0   <= 18'sb111101111100001001;
        end
        2091: begin
            cosine_reg0 <= 18'sb100000000100011110;
            sine_reg0   <= 18'sb111101111001000001;
        end
        2092: begin
            cosine_reg0 <= 18'sb100000000100101011;
            sine_reg0   <= 18'sb111101110101111000;
        end
        2093: begin
            cosine_reg0 <= 18'sb100000000100111001;
            sine_reg0   <= 18'sb111101110010101111;
        end
        2094: begin
            cosine_reg0 <= 18'sb100000000101000111;
            sine_reg0   <= 18'sb111101101111100111;
        end
        2095: begin
            cosine_reg0 <= 18'sb100000000101010110;
            sine_reg0   <= 18'sb111101101100011110;
        end
        2096: begin
            cosine_reg0 <= 18'sb100000000101100100;
            sine_reg0   <= 18'sb111101101001010110;
        end
        2097: begin
            cosine_reg0 <= 18'sb100000000101110011;
            sine_reg0   <= 18'sb111101100110001101;
        end
        2098: begin
            cosine_reg0 <= 18'sb100000000110000010;
            sine_reg0   <= 18'sb111101100011000101;
        end
        2099: begin
            cosine_reg0 <= 18'sb100000000110010010;
            sine_reg0   <= 18'sb111101011111111100;
        end
        2100: begin
            cosine_reg0 <= 18'sb100000000110100010;
            sine_reg0   <= 18'sb111101011100110100;
        end
        2101: begin
            cosine_reg0 <= 18'sb100000000110110010;
            sine_reg0   <= 18'sb111101011001101100;
        end
        2102: begin
            cosine_reg0 <= 18'sb100000000111000010;
            sine_reg0   <= 18'sb111101010110100011;
        end
        2103: begin
            cosine_reg0 <= 18'sb100000000111010011;
            sine_reg0   <= 18'sb111101010011011011;
        end
        2104: begin
            cosine_reg0 <= 18'sb100000000111100100;
            sine_reg0   <= 18'sb111101010000010010;
        end
        2105: begin
            cosine_reg0 <= 18'sb100000000111110110;
            sine_reg0   <= 18'sb111101001101001010;
        end
        2106: begin
            cosine_reg0 <= 18'sb100000001000000111;
            sine_reg0   <= 18'sb111101001010000010;
        end
        2107: begin
            cosine_reg0 <= 18'sb100000001000011001;
            sine_reg0   <= 18'sb111101000110111010;
        end
        2108: begin
            cosine_reg0 <= 18'sb100000001000101100;
            sine_reg0   <= 18'sb111101000011110001;
        end
        2109: begin
            cosine_reg0 <= 18'sb100000001000111110;
            sine_reg0   <= 18'sb111101000000101001;
        end
        2110: begin
            cosine_reg0 <= 18'sb100000001001010001;
            sine_reg0   <= 18'sb111100111101100001;
        end
        2111: begin
            cosine_reg0 <= 18'sb100000001001100101;
            sine_reg0   <= 18'sb111100111010011001;
        end
        2112: begin
            cosine_reg0 <= 18'sb100000001001111000;
            sine_reg0   <= 18'sb111100110111010001;
        end
        2113: begin
            cosine_reg0 <= 18'sb100000001010001100;
            sine_reg0   <= 18'sb111100110100001001;
        end
        2114: begin
            cosine_reg0 <= 18'sb100000001010100000;
            sine_reg0   <= 18'sb111100110001000001;
        end
        2115: begin
            cosine_reg0 <= 18'sb100000001010110101;
            sine_reg0   <= 18'sb111100101101111001;
        end
        2116: begin
            cosine_reg0 <= 18'sb100000001011001001;
            sine_reg0   <= 18'sb111100101010110001;
        end
        2117: begin
            cosine_reg0 <= 18'sb100000001011011111;
            sine_reg0   <= 18'sb111100100111101001;
        end
        2118: begin
            cosine_reg0 <= 18'sb100000001011110100;
            sine_reg0   <= 18'sb111100100100100001;
        end
        2119: begin
            cosine_reg0 <= 18'sb100000001100001010;
            sine_reg0   <= 18'sb111100100001011001;
        end
        2120: begin
            cosine_reg0 <= 18'sb100000001100100000;
            sine_reg0   <= 18'sb111100011110010001;
        end
        2121: begin
            cosine_reg0 <= 18'sb100000001100110110;
            sine_reg0   <= 18'sb111100011011001001;
        end
        2122: begin
            cosine_reg0 <= 18'sb100000001101001101;
            sine_reg0   <= 18'sb111100011000000001;
        end
        2123: begin
            cosine_reg0 <= 18'sb100000001101100011;
            sine_reg0   <= 18'sb111100010100111010;
        end
        2124: begin
            cosine_reg0 <= 18'sb100000001101111011;
            sine_reg0   <= 18'sb111100010001110010;
        end
        2125: begin
            cosine_reg0 <= 18'sb100000001110010010;
            sine_reg0   <= 18'sb111100001110101010;
        end
        2126: begin
            cosine_reg0 <= 18'sb100000001110101010;
            sine_reg0   <= 18'sb111100001011100011;
        end
        2127: begin
            cosine_reg0 <= 18'sb100000001111000010;
            sine_reg0   <= 18'sb111100001000011011;
        end
        2128: begin
            cosine_reg0 <= 18'sb100000001111011011;
            sine_reg0   <= 18'sb111100000101010100;
        end
        2129: begin
            cosine_reg0 <= 18'sb100000001111110011;
            sine_reg0   <= 18'sb111100000010001100;
        end
        2130: begin
            cosine_reg0 <= 18'sb100000010000001101;
            sine_reg0   <= 18'sb111011111111000100;
        end
        2131: begin
            cosine_reg0 <= 18'sb100000010000100110;
            sine_reg0   <= 18'sb111011111011111101;
        end
        2132: begin
            cosine_reg0 <= 18'sb100000010001000000;
            sine_reg0   <= 18'sb111011111000110110;
        end
        2133: begin
            cosine_reg0 <= 18'sb100000010001011010;
            sine_reg0   <= 18'sb111011110101101110;
        end
        2134: begin
            cosine_reg0 <= 18'sb100000010001110100;
            sine_reg0   <= 18'sb111011110010100111;
        end
        2135: begin
            cosine_reg0 <= 18'sb100000010010001110;
            sine_reg0   <= 18'sb111011101111100000;
        end
        2136: begin
            cosine_reg0 <= 18'sb100000010010101001;
            sine_reg0   <= 18'sb111011101100011000;
        end
        2137: begin
            cosine_reg0 <= 18'sb100000010011000101;
            sine_reg0   <= 18'sb111011101001010001;
        end
        2138: begin
            cosine_reg0 <= 18'sb100000010011100000;
            sine_reg0   <= 18'sb111011100110001010;
        end
        2139: begin
            cosine_reg0 <= 18'sb100000010011111100;
            sine_reg0   <= 18'sb111011100011000011;
        end
        2140: begin
            cosine_reg0 <= 18'sb100000010100011000;
            sine_reg0   <= 18'sb111011011111111100;
        end
        2141: begin
            cosine_reg0 <= 18'sb100000010100110101;
            sine_reg0   <= 18'sb111011011100110101;
        end
        2142: begin
            cosine_reg0 <= 18'sb100000010101010001;
            sine_reg0   <= 18'sb111011011001101110;
        end
        2143: begin
            cosine_reg0 <= 18'sb100000010101101110;
            sine_reg0   <= 18'sb111011010110100111;
        end
        2144: begin
            cosine_reg0 <= 18'sb100000010110001100;
            sine_reg0   <= 18'sb111011010011100000;
        end
        2145: begin
            cosine_reg0 <= 18'sb100000010110101001;
            sine_reg0   <= 18'sb111011010000011001;
        end
        2146: begin
            cosine_reg0 <= 18'sb100000010111000111;
            sine_reg0   <= 18'sb111011001101010010;
        end
        2147: begin
            cosine_reg0 <= 18'sb100000010111100110;
            sine_reg0   <= 18'sb111011001010001011;
        end
        2148: begin
            cosine_reg0 <= 18'sb100000011000000100;
            sine_reg0   <= 18'sb111011000111000101;
        end
        2149: begin
            cosine_reg0 <= 18'sb100000011000100011;
            sine_reg0   <= 18'sb111011000011111110;
        end
        2150: begin
            cosine_reg0 <= 18'sb100000011001000010;
            sine_reg0   <= 18'sb111011000000110111;
        end
        2151: begin
            cosine_reg0 <= 18'sb100000011001100010;
            sine_reg0   <= 18'sb111010111101110001;
        end
        2152: begin
            cosine_reg0 <= 18'sb100000011010000001;
            sine_reg0   <= 18'sb111010111010101010;
        end
        2153: begin
            cosine_reg0 <= 18'sb100000011010100010;
            sine_reg0   <= 18'sb111010110111100100;
        end
        2154: begin
            cosine_reg0 <= 18'sb100000011011000010;
            sine_reg0   <= 18'sb111010110100011101;
        end
        2155: begin
            cosine_reg0 <= 18'sb100000011011100011;
            sine_reg0   <= 18'sb111010110001010111;
        end
        2156: begin
            cosine_reg0 <= 18'sb100000011100000100;
            sine_reg0   <= 18'sb111010101110010001;
        end
        2157: begin
            cosine_reg0 <= 18'sb100000011100100101;
            sine_reg0   <= 18'sb111010101011001010;
        end
        2158: begin
            cosine_reg0 <= 18'sb100000011101000111;
            sine_reg0   <= 18'sb111010101000000100;
        end
        2159: begin
            cosine_reg0 <= 18'sb100000011101101000;
            sine_reg0   <= 18'sb111010100100111110;
        end
        2160: begin
            cosine_reg0 <= 18'sb100000011110001011;
            sine_reg0   <= 18'sb111010100001111000;
        end
        2161: begin
            cosine_reg0 <= 18'sb100000011110101101;
            sine_reg0   <= 18'sb111010011110110010;
        end
        2162: begin
            cosine_reg0 <= 18'sb100000011111010000;
            sine_reg0   <= 18'sb111010011011101100;
        end
        2163: begin
            cosine_reg0 <= 18'sb100000011111110011;
            sine_reg0   <= 18'sb111010011000100110;
        end
        2164: begin
            cosine_reg0 <= 18'sb100000100000010111;
            sine_reg0   <= 18'sb111010010101100000;
        end
        2165: begin
            cosine_reg0 <= 18'sb100000100000111010;
            sine_reg0   <= 18'sb111010010010011010;
        end
        2166: begin
            cosine_reg0 <= 18'sb100000100001011110;
            sine_reg0   <= 18'sb111010001111010100;
        end
        2167: begin
            cosine_reg0 <= 18'sb100000100010000011;
            sine_reg0   <= 18'sb111010001100001110;
        end
        2168: begin
            cosine_reg0 <= 18'sb100000100010100111;
            sine_reg0   <= 18'sb111010001001001001;
        end
        2169: begin
            cosine_reg0 <= 18'sb100000100011001100;
            sine_reg0   <= 18'sb111010000110000011;
        end
        2170: begin
            cosine_reg0 <= 18'sb100000100011110010;
            sine_reg0   <= 18'sb111010000010111110;
        end
        2171: begin
            cosine_reg0 <= 18'sb100000100100010111;
            sine_reg0   <= 18'sb111001111111111000;
        end
        2172: begin
            cosine_reg0 <= 18'sb100000100100111101;
            sine_reg0   <= 18'sb111001111100110011;
        end
        2173: begin
            cosine_reg0 <= 18'sb100000100101100011;
            sine_reg0   <= 18'sb111001111001101101;
        end
        2174: begin
            cosine_reg0 <= 18'sb100000100110001010;
            sine_reg0   <= 18'sb111001110110101000;
        end
        2175: begin
            cosine_reg0 <= 18'sb100000100110110000;
            sine_reg0   <= 18'sb111001110011100011;
        end
        2176: begin
            cosine_reg0 <= 18'sb100000100111010111;
            sine_reg0   <= 18'sb111001110000011101;
        end
        2177: begin
            cosine_reg0 <= 18'sb100000100111111111;
            sine_reg0   <= 18'sb111001101101011000;
        end
        2178: begin
            cosine_reg0 <= 18'sb100000101000100111;
            sine_reg0   <= 18'sb111001101010010011;
        end
        2179: begin
            cosine_reg0 <= 18'sb100000101001001111;
            sine_reg0   <= 18'sb111001100111001110;
        end
        2180: begin
            cosine_reg0 <= 18'sb100000101001110111;
            sine_reg0   <= 18'sb111001100100001001;
        end
        2181: begin
            cosine_reg0 <= 18'sb100000101010011111;
            sine_reg0   <= 18'sb111001100001000100;
        end
        2182: begin
            cosine_reg0 <= 18'sb100000101011001000;
            sine_reg0   <= 18'sb111001011101111111;
        end
        2183: begin
            cosine_reg0 <= 18'sb100000101011110001;
            sine_reg0   <= 18'sb111001011010111010;
        end
        2184: begin
            cosine_reg0 <= 18'sb100000101100011011;
            sine_reg0   <= 18'sb111001010111110110;
        end
        2185: begin
            cosine_reg0 <= 18'sb100000101101000101;
            sine_reg0   <= 18'sb111001010100110001;
        end
        2186: begin
            cosine_reg0 <= 18'sb100000101101101111;
            sine_reg0   <= 18'sb111001010001101100;
        end
        2187: begin
            cosine_reg0 <= 18'sb100000101110011001;
            sine_reg0   <= 18'sb111001001110101000;
        end
        2188: begin
            cosine_reg0 <= 18'sb100000101111000100;
            sine_reg0   <= 18'sb111001001011100011;
        end
        2189: begin
            cosine_reg0 <= 18'sb100000101111101111;
            sine_reg0   <= 18'sb111001001000011111;
        end
        2190: begin
            cosine_reg0 <= 18'sb100000110000011010;
            sine_reg0   <= 18'sb111001000101011011;
        end
        2191: begin
            cosine_reg0 <= 18'sb100000110001000110;
            sine_reg0   <= 18'sb111001000010010110;
        end
        2192: begin
            cosine_reg0 <= 18'sb100000110001110010;
            sine_reg0   <= 18'sb111000111111010010;
        end
        2193: begin
            cosine_reg0 <= 18'sb100000110010011110;
            sine_reg0   <= 18'sb111000111100001110;
        end
        2194: begin
            cosine_reg0 <= 18'sb100000110011001010;
            sine_reg0   <= 18'sb111000111001001010;
        end
        2195: begin
            cosine_reg0 <= 18'sb100000110011110111;
            sine_reg0   <= 18'sb111000110110000110;
        end
        2196: begin
            cosine_reg0 <= 18'sb100000110100100100;
            sine_reg0   <= 18'sb111000110011000010;
        end
        2197: begin
            cosine_reg0 <= 18'sb100000110101010010;
            sine_reg0   <= 18'sb111000101111111110;
        end
        2198: begin
            cosine_reg0 <= 18'sb100000110101111111;
            sine_reg0   <= 18'sb111000101100111010;
        end
        2199: begin
            cosine_reg0 <= 18'sb100000110110101101;
            sine_reg0   <= 18'sb111000101001110111;
        end
        2200: begin
            cosine_reg0 <= 18'sb100000110111011100;
            sine_reg0   <= 18'sb111000100110110011;
        end
        2201: begin
            cosine_reg0 <= 18'sb100000111000001010;
            sine_reg0   <= 18'sb111000100011101111;
        end
        2202: begin
            cosine_reg0 <= 18'sb100000111000111001;
            sine_reg0   <= 18'sb111000100000101100;
        end
        2203: begin
            cosine_reg0 <= 18'sb100000111001101001;
            sine_reg0   <= 18'sb111000011101101000;
        end
        2204: begin
            cosine_reg0 <= 18'sb100000111010011000;
            sine_reg0   <= 18'sb111000011010100101;
        end
        2205: begin
            cosine_reg0 <= 18'sb100000111011001000;
            sine_reg0   <= 18'sb111000010111100010;
        end
        2206: begin
            cosine_reg0 <= 18'sb100000111011111000;
            sine_reg0   <= 18'sb111000010100011111;
        end
        2207: begin
            cosine_reg0 <= 18'sb100000111100101000;
            sine_reg0   <= 18'sb111000010001011011;
        end
        2208: begin
            cosine_reg0 <= 18'sb100000111101011001;
            sine_reg0   <= 18'sb111000001110011000;
        end
        2209: begin
            cosine_reg0 <= 18'sb100000111110001010;
            sine_reg0   <= 18'sb111000001011010101;
        end
        2210: begin
            cosine_reg0 <= 18'sb100000111110111011;
            sine_reg0   <= 18'sb111000001000010010;
        end
        2211: begin
            cosine_reg0 <= 18'sb100000111111101101;
            sine_reg0   <= 18'sb111000000101010000;
        end
        2212: begin
            cosine_reg0 <= 18'sb100001000000011111;
            sine_reg0   <= 18'sb111000000010001101;
        end
        2213: begin
            cosine_reg0 <= 18'sb100001000001010001;
            sine_reg0   <= 18'sb110111111111001010;
        end
        2214: begin
            cosine_reg0 <= 18'sb100001000010000100;
            sine_reg0   <= 18'sb110111111100001000;
        end
        2215: begin
            cosine_reg0 <= 18'sb100001000010110110;
            sine_reg0   <= 18'sb110111111001000101;
        end
        2216: begin
            cosine_reg0 <= 18'sb100001000011101001;
            sine_reg0   <= 18'sb110111110110000011;
        end
        2217: begin
            cosine_reg0 <= 18'sb100001000100011101;
            sine_reg0   <= 18'sb110111110011000000;
        end
        2218: begin
            cosine_reg0 <= 18'sb100001000101010001;
            sine_reg0   <= 18'sb110111101111111110;
        end
        2219: begin
            cosine_reg0 <= 18'sb100001000110000100;
            sine_reg0   <= 18'sb110111101100111100;
        end
        2220: begin
            cosine_reg0 <= 18'sb100001000110111001;
            sine_reg0   <= 18'sb110111101001111001;
        end
        2221: begin
            cosine_reg0 <= 18'sb100001000111101101;
            sine_reg0   <= 18'sb110111100110110111;
        end
        2222: begin
            cosine_reg0 <= 18'sb100001001000100010;
            sine_reg0   <= 18'sb110111100011110101;
        end
        2223: begin
            cosine_reg0 <= 18'sb100001001001010111;
            sine_reg0   <= 18'sb110111100000110100;
        end
        2224: begin
            cosine_reg0 <= 18'sb100001001010001101;
            sine_reg0   <= 18'sb110111011101110010;
        end
        2225: begin
            cosine_reg0 <= 18'sb100001001011000011;
            sine_reg0   <= 18'sb110111011010110000;
        end
        2226: begin
            cosine_reg0 <= 18'sb100001001011111001;
            sine_reg0   <= 18'sb110111010111101110;
        end
        2227: begin
            cosine_reg0 <= 18'sb100001001100101111;
            sine_reg0   <= 18'sb110111010100101101;
        end
        2228: begin
            cosine_reg0 <= 18'sb100001001101100110;
            sine_reg0   <= 18'sb110111010001101011;
        end
        2229: begin
            cosine_reg0 <= 18'sb100001001110011101;
            sine_reg0   <= 18'sb110111001110101010;
        end
        2230: begin
            cosine_reg0 <= 18'sb100001001111010100;
            sine_reg0   <= 18'sb110111001011101001;
        end
        2231: begin
            cosine_reg0 <= 18'sb100001010000001100;
            sine_reg0   <= 18'sb110111001000100111;
        end
        2232: begin
            cosine_reg0 <= 18'sb100001010001000011;
            sine_reg0   <= 18'sb110111000101100110;
        end
        2233: begin
            cosine_reg0 <= 18'sb100001010001111100;
            sine_reg0   <= 18'sb110111000010100101;
        end
        2234: begin
            cosine_reg0 <= 18'sb100001010010110100;
            sine_reg0   <= 18'sb110110111111100100;
        end
        2235: begin
            cosine_reg0 <= 18'sb100001010011101101;
            sine_reg0   <= 18'sb110110111100100011;
        end
        2236: begin
            cosine_reg0 <= 18'sb100001010100100110;
            sine_reg0   <= 18'sb110110111001100010;
        end
        2237: begin
            cosine_reg0 <= 18'sb100001010101011111;
            sine_reg0   <= 18'sb110110110110100010;
        end
        2238: begin
            cosine_reg0 <= 18'sb100001010110011001;
            sine_reg0   <= 18'sb110110110011100001;
        end
        2239: begin
            cosine_reg0 <= 18'sb100001010111010011;
            sine_reg0   <= 18'sb110110110000100001;
        end
        2240: begin
            cosine_reg0 <= 18'sb100001011000001101;
            sine_reg0   <= 18'sb110110101101100000;
        end
        2241: begin
            cosine_reg0 <= 18'sb100001011001000111;
            sine_reg0   <= 18'sb110110101010100000;
        end
        2242: begin
            cosine_reg0 <= 18'sb100001011010000010;
            sine_reg0   <= 18'sb110110100111011111;
        end
        2243: begin
            cosine_reg0 <= 18'sb100001011010111101;
            sine_reg0   <= 18'sb110110100100011111;
        end
        2244: begin
            cosine_reg0 <= 18'sb100001011011111001;
            sine_reg0   <= 18'sb110110100001011111;
        end
        2245: begin
            cosine_reg0 <= 18'sb100001011100110100;
            sine_reg0   <= 18'sb110110011110011111;
        end
        2246: begin
            cosine_reg0 <= 18'sb100001011101110000;
            sine_reg0   <= 18'sb110110011011011111;
        end
        2247: begin
            cosine_reg0 <= 18'sb100001011110101101;
            sine_reg0   <= 18'sb110110011000011111;
        end
        2248: begin
            cosine_reg0 <= 18'sb100001011111101001;
            sine_reg0   <= 18'sb110110010101100000;
        end
        2249: begin
            cosine_reg0 <= 18'sb100001100000100110;
            sine_reg0   <= 18'sb110110010010100000;
        end
        2250: begin
            cosine_reg0 <= 18'sb100001100001100011;
            sine_reg0   <= 18'sb110110001111100001;
        end
        2251: begin
            cosine_reg0 <= 18'sb100001100010100001;
            sine_reg0   <= 18'sb110110001100100001;
        end
        2252: begin
            cosine_reg0 <= 18'sb100001100011011110;
            sine_reg0   <= 18'sb110110001001100010;
        end
        2253: begin
            cosine_reg0 <= 18'sb100001100100011101;
            sine_reg0   <= 18'sb110110000110100011;
        end
        2254: begin
            cosine_reg0 <= 18'sb100001100101011011;
            sine_reg0   <= 18'sb110110000011100011;
        end
        2255: begin
            cosine_reg0 <= 18'sb100001100110011001;
            sine_reg0   <= 18'sb110110000000100100;
        end
        2256: begin
            cosine_reg0 <= 18'sb100001100111011000;
            sine_reg0   <= 18'sb110101111101100101;
        end
        2257: begin
            cosine_reg0 <= 18'sb100001101000011000;
            sine_reg0   <= 18'sb110101111010100111;
        end
        2258: begin
            cosine_reg0 <= 18'sb100001101001010111;
            sine_reg0   <= 18'sb110101110111101000;
        end
        2259: begin
            cosine_reg0 <= 18'sb100001101010010111;
            sine_reg0   <= 18'sb110101110100101001;
        end
        2260: begin
            cosine_reg0 <= 18'sb100001101011010111;
            sine_reg0   <= 18'sb110101110001101011;
        end
        2261: begin
            cosine_reg0 <= 18'sb100001101100010111;
            sine_reg0   <= 18'sb110101101110101100;
        end
        2262: begin
            cosine_reg0 <= 18'sb100001101101011000;
            sine_reg0   <= 18'sb110101101011101110;
        end
        2263: begin
            cosine_reg0 <= 18'sb100001101110011001;
            sine_reg0   <= 18'sb110101101000101111;
        end
        2264: begin
            cosine_reg0 <= 18'sb100001101111011010;
            sine_reg0   <= 18'sb110101100101110001;
        end
        2265: begin
            cosine_reg0 <= 18'sb100001110000011100;
            sine_reg0   <= 18'sb110101100010110011;
        end
        2266: begin
            cosine_reg0 <= 18'sb100001110001011110;
            sine_reg0   <= 18'sb110101011111110101;
        end
        2267: begin
            cosine_reg0 <= 18'sb100001110010100000;
            sine_reg0   <= 18'sb110101011100110111;
        end
        2268: begin
            cosine_reg0 <= 18'sb100001110011100010;
            sine_reg0   <= 18'sb110101011001111010;
        end
        2269: begin
            cosine_reg0 <= 18'sb100001110100100101;
            sine_reg0   <= 18'sb110101010110111100;
        end
        2270: begin
            cosine_reg0 <= 18'sb100001110101101000;
            sine_reg0   <= 18'sb110101010011111110;
        end
        2271: begin
            cosine_reg0 <= 18'sb100001110110101011;
            sine_reg0   <= 18'sb110101010001000001;
        end
        2272: begin
            cosine_reg0 <= 18'sb100001110111101111;
            sine_reg0   <= 18'sb110101001110000100;
        end
        2273: begin
            cosine_reg0 <= 18'sb100001111000110011;
            sine_reg0   <= 18'sb110101001011000110;
        end
        2274: begin
            cosine_reg0 <= 18'sb100001111001110111;
            sine_reg0   <= 18'sb110101001000001001;
        end
        2275: begin
            cosine_reg0 <= 18'sb100001111010111011;
            sine_reg0   <= 18'sb110101000101001100;
        end
        2276: begin
            cosine_reg0 <= 18'sb100001111100000000;
            sine_reg0   <= 18'sb110101000010001111;
        end
        2277: begin
            cosine_reg0 <= 18'sb100001111101000101;
            sine_reg0   <= 18'sb110100111111010010;
        end
        2278: begin
            cosine_reg0 <= 18'sb100001111110001011;
            sine_reg0   <= 18'sb110100111100010110;
        end
        2279: begin
            cosine_reg0 <= 18'sb100001111111010000;
            sine_reg0   <= 18'sb110100111001011001;
        end
        2280: begin
            cosine_reg0 <= 18'sb100010000000010110;
            sine_reg0   <= 18'sb110100110110011100;
        end
        2281: begin
            cosine_reg0 <= 18'sb100010000001011100;
            sine_reg0   <= 18'sb110100110011100000;
        end
        2282: begin
            cosine_reg0 <= 18'sb100010000010100011;
            sine_reg0   <= 18'sb110100110000100100;
        end
        2283: begin
            cosine_reg0 <= 18'sb100010000011101001;
            sine_reg0   <= 18'sb110100101101101000;
        end
        2284: begin
            cosine_reg0 <= 18'sb100010000100110001;
            sine_reg0   <= 18'sb110100101010101011;
        end
        2285: begin
            cosine_reg0 <= 18'sb100010000101111000;
            sine_reg0   <= 18'sb110100100111101111;
        end
        2286: begin
            cosine_reg0 <= 18'sb100010000111000000;
            sine_reg0   <= 18'sb110100100100110100;
        end
        2287: begin
            cosine_reg0 <= 18'sb100010001000000111;
            sine_reg0   <= 18'sb110100100001111000;
        end
        2288: begin
            cosine_reg0 <= 18'sb100010001001010000;
            sine_reg0   <= 18'sb110100011110111100;
        end
        2289: begin
            cosine_reg0 <= 18'sb100010001010011000;
            sine_reg0   <= 18'sb110100011100000001;
        end
        2290: begin
            cosine_reg0 <= 18'sb100010001011100001;
            sine_reg0   <= 18'sb110100011001000101;
        end
        2291: begin
            cosine_reg0 <= 18'sb100010001100101010;
            sine_reg0   <= 18'sb110100010110001010;
        end
        2292: begin
            cosine_reg0 <= 18'sb100010001101110011;
            sine_reg0   <= 18'sb110100010011001111;
        end
        2293: begin
            cosine_reg0 <= 18'sb100010001110111101;
            sine_reg0   <= 18'sb110100010000010100;
        end
        2294: begin
            cosine_reg0 <= 18'sb100010010000000111;
            sine_reg0   <= 18'sb110100001101011001;
        end
        2295: begin
            cosine_reg0 <= 18'sb100010010001010001;
            sine_reg0   <= 18'sb110100001010011110;
        end
        2296: begin
            cosine_reg0 <= 18'sb100010010010011100;
            sine_reg0   <= 18'sb110100000111100011;
        end
        2297: begin
            cosine_reg0 <= 18'sb100010010011100111;
            sine_reg0   <= 18'sb110100000100101000;
        end
        2298: begin
            cosine_reg0 <= 18'sb100010010100110010;
            sine_reg0   <= 18'sb110100000001101110;
        end
        2299: begin
            cosine_reg0 <= 18'sb100010010101111101;
            sine_reg0   <= 18'sb110011111110110100;
        end
        2300: begin
            cosine_reg0 <= 18'sb100010010111001001;
            sine_reg0   <= 18'sb110011111011111001;
        end
        2301: begin
            cosine_reg0 <= 18'sb100010011000010101;
            sine_reg0   <= 18'sb110011111000111111;
        end
        2302: begin
            cosine_reg0 <= 18'sb100010011001100001;
            sine_reg0   <= 18'sb110011110110000101;
        end
        2303: begin
            cosine_reg0 <= 18'sb100010011010101101;
            sine_reg0   <= 18'sb110011110011001011;
        end
        2304: begin
            cosine_reg0 <= 18'sb100010011011111010;
            sine_reg0   <= 18'sb110011110000010001;
        end
        2305: begin
            cosine_reg0 <= 18'sb100010011101000111;
            sine_reg0   <= 18'sb110011101101011000;
        end
        2306: begin
            cosine_reg0 <= 18'sb100010011110010101;
            sine_reg0   <= 18'sb110011101010011110;
        end
        2307: begin
            cosine_reg0 <= 18'sb100010011111100010;
            sine_reg0   <= 18'sb110011100111100101;
        end
        2308: begin
            cosine_reg0 <= 18'sb100010100000110000;
            sine_reg0   <= 18'sb110011100100101011;
        end
        2309: begin
            cosine_reg0 <= 18'sb100010100001111110;
            sine_reg0   <= 18'sb110011100001110010;
        end
        2310: begin
            cosine_reg0 <= 18'sb100010100011001101;
            sine_reg0   <= 18'sb110011011110111001;
        end
        2311: begin
            cosine_reg0 <= 18'sb100010100100011100;
            sine_reg0   <= 18'sb110011011100000000;
        end
        2312: begin
            cosine_reg0 <= 18'sb100010100101101011;
            sine_reg0   <= 18'sb110011011001000111;
        end
        2313: begin
            cosine_reg0 <= 18'sb100010100110111010;
            sine_reg0   <= 18'sb110011010110001110;
        end
        2314: begin
            cosine_reg0 <= 18'sb100010101000001010;
            sine_reg0   <= 18'sb110011010011010110;
        end
        2315: begin
            cosine_reg0 <= 18'sb100010101001011010;
            sine_reg0   <= 18'sb110011010000011101;
        end
        2316: begin
            cosine_reg0 <= 18'sb100010101010101010;
            sine_reg0   <= 18'sb110011001101100101;
        end
        2317: begin
            cosine_reg0 <= 18'sb100010101011111010;
            sine_reg0   <= 18'sb110011001010101101;
        end
        2318: begin
            cosine_reg0 <= 18'sb100010101101001011;
            sine_reg0   <= 18'sb110011000111110100;
        end
        2319: begin
            cosine_reg0 <= 18'sb100010101110011100;
            sine_reg0   <= 18'sb110011000100111100;
        end
        2320: begin
            cosine_reg0 <= 18'sb100010101111101110;
            sine_reg0   <= 18'sb110011000010000101;
        end
        2321: begin
            cosine_reg0 <= 18'sb100010110000111111;
            sine_reg0   <= 18'sb110010111111001101;
        end
        2322: begin
            cosine_reg0 <= 18'sb100010110010010001;
            sine_reg0   <= 18'sb110010111100010101;
        end
        2323: begin
            cosine_reg0 <= 18'sb100010110011100011;
            sine_reg0   <= 18'sb110010111001011110;
        end
        2324: begin
            cosine_reg0 <= 18'sb100010110100110110;
            sine_reg0   <= 18'sb110010110110100110;
        end
        2325: begin
            cosine_reg0 <= 18'sb100010110110001001;
            sine_reg0   <= 18'sb110010110011101111;
        end
        2326: begin
            cosine_reg0 <= 18'sb100010110111011100;
            sine_reg0   <= 18'sb110010110000111000;
        end
        2327: begin
            cosine_reg0 <= 18'sb100010111000101111;
            sine_reg0   <= 18'sb110010101110000001;
        end
        2328: begin
            cosine_reg0 <= 18'sb100010111010000010;
            sine_reg0   <= 18'sb110010101011001010;
        end
        2329: begin
            cosine_reg0 <= 18'sb100010111011010110;
            sine_reg0   <= 18'sb110010101000010011;
        end
        2330: begin
            cosine_reg0 <= 18'sb100010111100101010;
            sine_reg0   <= 18'sb110010100101011101;
        end
        2331: begin
            cosine_reg0 <= 18'sb100010111101111111;
            sine_reg0   <= 18'sb110010100010100110;
        end
        2332: begin
            cosine_reg0 <= 18'sb100010111111010100;
            sine_reg0   <= 18'sb110010011111110000;
        end
        2333: begin
            cosine_reg0 <= 18'sb100011000000101001;
            sine_reg0   <= 18'sb110010011100111010;
        end
        2334: begin
            cosine_reg0 <= 18'sb100011000001111110;
            sine_reg0   <= 18'sb110010011010000100;
        end
        2335: begin
            cosine_reg0 <= 18'sb100011000011010011;
            sine_reg0   <= 18'sb110010010111001110;
        end
        2336: begin
            cosine_reg0 <= 18'sb100011000100101001;
            sine_reg0   <= 18'sb110010010100011000;
        end
        2337: begin
            cosine_reg0 <= 18'sb100011000101111111;
            sine_reg0   <= 18'sb110010010001100010;
        end
        2338: begin
            cosine_reg0 <= 18'sb100011000111010110;
            sine_reg0   <= 18'sb110010001110101101;
        end
        2339: begin
            cosine_reg0 <= 18'sb100011001000101100;
            sine_reg0   <= 18'sb110010001011110111;
        end
        2340: begin
            cosine_reg0 <= 18'sb100011001010000011;
            sine_reg0   <= 18'sb110010001001000010;
        end
        2341: begin
            cosine_reg0 <= 18'sb100011001011011011;
            sine_reg0   <= 18'sb110010000110001101;
        end
        2342: begin
            cosine_reg0 <= 18'sb100011001100110010;
            sine_reg0   <= 18'sb110010000011011000;
        end
        2343: begin
            cosine_reg0 <= 18'sb100011001110001010;
            sine_reg0   <= 18'sb110010000000100011;
        end
        2344: begin
            cosine_reg0 <= 18'sb100011001111100010;
            sine_reg0   <= 18'sb110001111101101110;
        end
        2345: begin
            cosine_reg0 <= 18'sb100011010000111010;
            sine_reg0   <= 18'sb110001111010111010;
        end
        2346: begin
            cosine_reg0 <= 18'sb100011010010010011;
            sine_reg0   <= 18'sb110001111000000101;
        end
        2347: begin
            cosine_reg0 <= 18'sb100011010011101100;
            sine_reg0   <= 18'sb110001110101010001;
        end
        2348: begin
            cosine_reg0 <= 18'sb100011010101000101;
            sine_reg0   <= 18'sb110001110010011100;
        end
        2349: begin
            cosine_reg0 <= 18'sb100011010110011110;
            sine_reg0   <= 18'sb110001101111101000;
        end
        2350: begin
            cosine_reg0 <= 18'sb100011010111111000;
            sine_reg0   <= 18'sb110001101100110100;
        end
        2351: begin
            cosine_reg0 <= 18'sb100011011001010010;
            sine_reg0   <= 18'sb110001101010000001;
        end
        2352: begin
            cosine_reg0 <= 18'sb100011011010101100;
            sine_reg0   <= 18'sb110001100111001101;
        end
        2353: begin
            cosine_reg0 <= 18'sb100011011100000111;
            sine_reg0   <= 18'sb110001100100011001;
        end
        2354: begin
            cosine_reg0 <= 18'sb100011011101100010;
            sine_reg0   <= 18'sb110001100001100110;
        end
        2355: begin
            cosine_reg0 <= 18'sb100011011110111101;
            sine_reg0   <= 18'sb110001011110110011;
        end
        2356: begin
            cosine_reg0 <= 18'sb100011100000011000;
            sine_reg0   <= 18'sb110001011100000000;
        end
        2357: begin
            cosine_reg0 <= 18'sb100011100001110100;
            sine_reg0   <= 18'sb110001011001001101;
        end
        2358: begin
            cosine_reg0 <= 18'sb100011100011010000;
            sine_reg0   <= 18'sb110001010110011010;
        end
        2359: begin
            cosine_reg0 <= 18'sb100011100100101100;
            sine_reg0   <= 18'sb110001010011100111;
        end
        2360: begin
            cosine_reg0 <= 18'sb100011100110001000;
            sine_reg0   <= 18'sb110001010000110101;
        end
        2361: begin
            cosine_reg0 <= 18'sb100011100111100101;
            sine_reg0   <= 18'sb110001001110000010;
        end
        2362: begin
            cosine_reg0 <= 18'sb100011101001000010;
            sine_reg0   <= 18'sb110001001011010000;
        end
        2363: begin
            cosine_reg0 <= 18'sb100011101010011111;
            sine_reg0   <= 18'sb110001001000011110;
        end
        2364: begin
            cosine_reg0 <= 18'sb100011101011111101;
            sine_reg0   <= 18'sb110001000101101100;
        end
        2365: begin
            cosine_reg0 <= 18'sb100011101101011011;
            sine_reg0   <= 18'sb110001000010111010;
        end
        2366: begin
            cosine_reg0 <= 18'sb100011101110111001;
            sine_reg0   <= 18'sb110001000000001000;
        end
        2367: begin
            cosine_reg0 <= 18'sb100011110000010111;
            sine_reg0   <= 18'sb110000111101010111;
        end
        2368: begin
            cosine_reg0 <= 18'sb100011110001110110;
            sine_reg0   <= 18'sb110000111010100110;
        end
        2369: begin
            cosine_reg0 <= 18'sb100011110011010101;
            sine_reg0   <= 18'sb110000110111110100;
        end
        2370: begin
            cosine_reg0 <= 18'sb100011110100110100;
            sine_reg0   <= 18'sb110000110101000011;
        end
        2371: begin
            cosine_reg0 <= 18'sb100011110110010011;
            sine_reg0   <= 18'sb110000110010010010;
        end
        2372: begin
            cosine_reg0 <= 18'sb100011110111110011;
            sine_reg0   <= 18'sb110000101111100001;
        end
        2373: begin
            cosine_reg0 <= 18'sb100011111001010011;
            sine_reg0   <= 18'sb110000101100110001;
        end
        2374: begin
            cosine_reg0 <= 18'sb100011111010110011;
            sine_reg0   <= 18'sb110000101010000000;
        end
        2375: begin
            cosine_reg0 <= 18'sb100011111100010100;
            sine_reg0   <= 18'sb110000100111010000;
        end
        2376: begin
            cosine_reg0 <= 18'sb100011111101110101;
            sine_reg0   <= 18'sb110000100100100000;
        end
        2377: begin
            cosine_reg0 <= 18'sb100011111111010110;
            sine_reg0   <= 18'sb110000100001110000;
        end
        2378: begin
            cosine_reg0 <= 18'sb100100000000110111;
            sine_reg0   <= 18'sb110000011111000000;
        end
        2379: begin
            cosine_reg0 <= 18'sb100100000010011001;
            sine_reg0   <= 18'sb110000011100010000;
        end
        2380: begin
            cosine_reg0 <= 18'sb100100000011111011;
            sine_reg0   <= 18'sb110000011001100000;
        end
        2381: begin
            cosine_reg0 <= 18'sb100100000101011101;
            sine_reg0   <= 18'sb110000010110110001;
        end
        2382: begin
            cosine_reg0 <= 18'sb100100000110111111;
            sine_reg0   <= 18'sb110000010100000010;
        end
        2383: begin
            cosine_reg0 <= 18'sb100100001000100010;
            sine_reg0   <= 18'sb110000010001010010;
        end
        2384: begin
            cosine_reg0 <= 18'sb100100001010000101;
            sine_reg0   <= 18'sb110000001110100011;
        end
        2385: begin
            cosine_reg0 <= 18'sb100100001011101000;
            sine_reg0   <= 18'sb110000001011110100;
        end
        2386: begin
            cosine_reg0 <= 18'sb100100001101001100;
            sine_reg0   <= 18'sb110000001001000110;
        end
        2387: begin
            cosine_reg0 <= 18'sb100100001110101111;
            sine_reg0   <= 18'sb110000000110010111;
        end
        2388: begin
            cosine_reg0 <= 18'sb100100010000010011;
            sine_reg0   <= 18'sb110000000011101001;
        end
        2389: begin
            cosine_reg0 <= 18'sb100100010001111000;
            sine_reg0   <= 18'sb110000000000111011;
        end
        2390: begin
            cosine_reg0 <= 18'sb100100010011011100;
            sine_reg0   <= 18'sb101111111110001100;
        end
        2391: begin
            cosine_reg0 <= 18'sb100100010101000001;
            sine_reg0   <= 18'sb101111111011011111;
        end
        2392: begin
            cosine_reg0 <= 18'sb100100010110100110;
            sine_reg0   <= 18'sb101111111000110001;
        end
        2393: begin
            cosine_reg0 <= 18'sb100100011000001100;
            sine_reg0   <= 18'sb101111110110000011;
        end
        2394: begin
            cosine_reg0 <= 18'sb100100011001110001;
            sine_reg0   <= 18'sb101111110011010110;
        end
        2395: begin
            cosine_reg0 <= 18'sb100100011011010111;
            sine_reg0   <= 18'sb101111110000101000;
        end
        2396: begin
            cosine_reg0 <= 18'sb100100011100111101;
            sine_reg0   <= 18'sb101111101101111011;
        end
        2397: begin
            cosine_reg0 <= 18'sb100100011110100100;
            sine_reg0   <= 18'sb101111101011001110;
        end
        2398: begin
            cosine_reg0 <= 18'sb100100100000001010;
            sine_reg0   <= 18'sb101111101000100001;
        end
        2399: begin
            cosine_reg0 <= 18'sb100100100001110001;
            sine_reg0   <= 18'sb101111100101110101;
        end
        2400: begin
            cosine_reg0 <= 18'sb100100100011011001;
            sine_reg0   <= 18'sb101111100011001000;
        end
        2401: begin
            cosine_reg0 <= 18'sb100100100101000000;
            sine_reg0   <= 18'sb101111100000011100;
        end
        2402: begin
            cosine_reg0 <= 18'sb100100100110101000;
            sine_reg0   <= 18'sb101111011101101111;
        end
        2403: begin
            cosine_reg0 <= 18'sb100100101000010000;
            sine_reg0   <= 18'sb101111011011000011;
        end
        2404: begin
            cosine_reg0 <= 18'sb100100101001111000;
            sine_reg0   <= 18'sb101111011000010111;
        end
        2405: begin
            cosine_reg0 <= 18'sb100100101011100001;
            sine_reg0   <= 18'sb101111010101101100;
        end
        2406: begin
            cosine_reg0 <= 18'sb100100101101001010;
            sine_reg0   <= 18'sb101111010011000000;
        end
        2407: begin
            cosine_reg0 <= 18'sb100100101110110011;
            sine_reg0   <= 18'sb101111010000010101;
        end
        2408: begin
            cosine_reg0 <= 18'sb100100110000011100;
            sine_reg0   <= 18'sb101111001101101010;
        end
        2409: begin
            cosine_reg0 <= 18'sb100100110010000110;
            sine_reg0   <= 18'sb101111001010111110;
        end
        2410: begin
            cosine_reg0 <= 18'sb100100110011101111;
            sine_reg0   <= 18'sb101111001000010011;
        end
        2411: begin
            cosine_reg0 <= 18'sb100100110101011010;
            sine_reg0   <= 18'sb101111000101101001;
        end
        2412: begin
            cosine_reg0 <= 18'sb100100110111000100;
            sine_reg0   <= 18'sb101111000010111110;
        end
        2413: begin
            cosine_reg0 <= 18'sb100100111000101111;
            sine_reg0   <= 18'sb101111000000010100;
        end
        2414: begin
            cosine_reg0 <= 18'sb100100111010011010;
            sine_reg0   <= 18'sb101110111101101001;
        end
        2415: begin
            cosine_reg0 <= 18'sb100100111100000101;
            sine_reg0   <= 18'sb101110111010111111;
        end
        2416: begin
            cosine_reg0 <= 18'sb100100111101110000;
            sine_reg0   <= 18'sb101110111000010101;
        end
        2417: begin
            cosine_reg0 <= 18'sb100100111111011100;
            sine_reg0   <= 18'sb101110110101101100;
        end
        2418: begin
            cosine_reg0 <= 18'sb100101000001001000;
            sine_reg0   <= 18'sb101110110011000010;
        end
        2419: begin
            cosine_reg0 <= 18'sb100101000010110100;
            sine_reg0   <= 18'sb101110110000011000;
        end
        2420: begin
            cosine_reg0 <= 18'sb100101000100100001;
            sine_reg0   <= 18'sb101110101101101111;
        end
        2421: begin
            cosine_reg0 <= 18'sb100101000110001101;
            sine_reg0   <= 18'sb101110101011000110;
        end
        2422: begin
            cosine_reg0 <= 18'sb100101000111111010;
            sine_reg0   <= 18'sb101110101000011101;
        end
        2423: begin
            cosine_reg0 <= 18'sb100101001001101000;
            sine_reg0   <= 18'sb101110100101110100;
        end
        2424: begin
            cosine_reg0 <= 18'sb100101001011010101;
            sine_reg0   <= 18'sb101110100011001100;
        end
        2425: begin
            cosine_reg0 <= 18'sb100101001101000011;
            sine_reg0   <= 18'sb101110100000100011;
        end
        2426: begin
            cosine_reg0 <= 18'sb100101001110110001;
            sine_reg0   <= 18'sb101110011101111011;
        end
        2427: begin
            cosine_reg0 <= 18'sb100101010000011111;
            sine_reg0   <= 18'sb101110011011010011;
        end
        2428: begin
            cosine_reg0 <= 18'sb100101010010001110;
            sine_reg0   <= 18'sb101110011000101011;
        end
        2429: begin
            cosine_reg0 <= 18'sb100101010011111100;
            sine_reg0   <= 18'sb101110010110000011;
        end
        2430: begin
            cosine_reg0 <= 18'sb100101010101101100;
            sine_reg0   <= 18'sb101110010011011100;
        end
        2431: begin
            cosine_reg0 <= 18'sb100101010111011011;
            sine_reg0   <= 18'sb101110010000110100;
        end
        2432: begin
            cosine_reg0 <= 18'sb100101011001001010;
            sine_reg0   <= 18'sb101110001110001101;
        end
        2433: begin
            cosine_reg0 <= 18'sb100101011010111010;
            sine_reg0   <= 18'sb101110001011100110;
        end
        2434: begin
            cosine_reg0 <= 18'sb100101011100101010;
            sine_reg0   <= 18'sb101110001000111111;
        end
        2435: begin
            cosine_reg0 <= 18'sb100101011110011011;
            sine_reg0   <= 18'sb101110000110011000;
        end
        2436: begin
            cosine_reg0 <= 18'sb100101100000001011;
            sine_reg0   <= 18'sb101110000011110010;
        end
        2437: begin
            cosine_reg0 <= 18'sb100101100001111100;
            sine_reg0   <= 18'sb101110000001001011;
        end
        2438: begin
            cosine_reg0 <= 18'sb100101100011101101;
            sine_reg0   <= 18'sb101101111110100101;
        end
        2439: begin
            cosine_reg0 <= 18'sb100101100101011111;
            sine_reg0   <= 18'sb101101111011111111;
        end
        2440: begin
            cosine_reg0 <= 18'sb100101100111010000;
            sine_reg0   <= 18'sb101101111001011001;
        end
        2441: begin
            cosine_reg0 <= 18'sb100101101001000010;
            sine_reg0   <= 18'sb101101110110110011;
        end
        2442: begin
            cosine_reg0 <= 18'sb100101101010110100;
            sine_reg0   <= 18'sb101101110100001110;
        end
        2443: begin
            cosine_reg0 <= 18'sb100101101100100111;
            sine_reg0   <= 18'sb101101110001101000;
        end
        2444: begin
            cosine_reg0 <= 18'sb100101101110011001;
            sine_reg0   <= 18'sb101101101111000011;
        end
        2445: begin
            cosine_reg0 <= 18'sb100101110000001100;
            sine_reg0   <= 18'sb101101101100011110;
        end
        2446: begin
            cosine_reg0 <= 18'sb100101110001111111;
            sine_reg0   <= 18'sb101101101001111001;
        end
        2447: begin
            cosine_reg0 <= 18'sb100101110011110011;
            sine_reg0   <= 18'sb101101100111010101;
        end
        2448: begin
            cosine_reg0 <= 18'sb100101110101100110;
            sine_reg0   <= 18'sb101101100100110000;
        end
        2449: begin
            cosine_reg0 <= 18'sb100101110111011010;
            sine_reg0   <= 18'sb101101100010001100;
        end
        2450: begin
            cosine_reg0 <= 18'sb100101111001001110;
            sine_reg0   <= 18'sb101101011111101000;
        end
        2451: begin
            cosine_reg0 <= 18'sb100101111011000011;
            sine_reg0   <= 18'sb101101011101000100;
        end
        2452: begin
            cosine_reg0 <= 18'sb100101111100110111;
            sine_reg0   <= 18'sb101101011010100000;
        end
        2453: begin
            cosine_reg0 <= 18'sb100101111110101100;
            sine_reg0   <= 18'sb101101010111111101;
        end
        2454: begin
            cosine_reg0 <= 18'sb100110000000100010;
            sine_reg0   <= 18'sb101101010101011001;
        end
        2455: begin
            cosine_reg0 <= 18'sb100110000010010111;
            sine_reg0   <= 18'sb101101010010110110;
        end
        2456: begin
            cosine_reg0 <= 18'sb100110000100001101;
            sine_reg0   <= 18'sb101101010000010011;
        end
        2457: begin
            cosine_reg0 <= 18'sb100110000110000010;
            sine_reg0   <= 18'sb101101001101110000;
        end
        2458: begin
            cosine_reg0 <= 18'sb100110000111111001;
            sine_reg0   <= 18'sb101101001011001101;
        end
        2459: begin
            cosine_reg0 <= 18'sb100110001001101111;
            sine_reg0   <= 18'sb101101001000101011;
        end
        2460: begin
            cosine_reg0 <= 18'sb100110001011100110;
            sine_reg0   <= 18'sb101101000110001001;
        end
        2461: begin
            cosine_reg0 <= 18'sb100110001101011101;
            sine_reg0   <= 18'sb101101000011100110;
        end
        2462: begin
            cosine_reg0 <= 18'sb100110001111010100;
            sine_reg0   <= 18'sb101101000001000100;
        end
        2463: begin
            cosine_reg0 <= 18'sb100110010001001011;
            sine_reg0   <= 18'sb101100111110100011;
        end
        2464: begin
            cosine_reg0 <= 18'sb100110010011000011;
            sine_reg0   <= 18'sb101100111100000001;
        end
        2465: begin
            cosine_reg0 <= 18'sb100110010100111011;
            sine_reg0   <= 18'sb101100111001100000;
        end
        2466: begin
            cosine_reg0 <= 18'sb100110010110110011;
            sine_reg0   <= 18'sb101100110110111110;
        end
        2467: begin
            cosine_reg0 <= 18'sb100110011000101011;
            sine_reg0   <= 18'sb101100110100011101;
        end
        2468: begin
            cosine_reg0 <= 18'sb100110011010100100;
            sine_reg0   <= 18'sb101100110001111101;
        end
        2469: begin
            cosine_reg0 <= 18'sb100110011100011101;
            sine_reg0   <= 18'sb101100101111011100;
        end
        2470: begin
            cosine_reg0 <= 18'sb100110011110010110;
            sine_reg0   <= 18'sb101100101100111011;
        end
        2471: begin
            cosine_reg0 <= 18'sb100110100000001111;
            sine_reg0   <= 18'sb101100101010011011;
        end
        2472: begin
            cosine_reg0 <= 18'sb100110100010001001;
            sine_reg0   <= 18'sb101100100111111011;
        end
        2473: begin
            cosine_reg0 <= 18'sb100110100100000011;
            sine_reg0   <= 18'sb101100100101011011;
        end
        2474: begin
            cosine_reg0 <= 18'sb100110100101111101;
            sine_reg0   <= 18'sb101100100010111011;
        end
        2475: begin
            cosine_reg0 <= 18'sb100110100111110111;
            sine_reg0   <= 18'sb101100100000011100;
        end
        2476: begin
            cosine_reg0 <= 18'sb100110101001110010;
            sine_reg0   <= 18'sb101100011101111101;
        end
        2477: begin
            cosine_reg0 <= 18'sb100110101011101101;
            sine_reg0   <= 18'sb101100011011011101;
        end
        2478: begin
            cosine_reg0 <= 18'sb100110101101101000;
            sine_reg0   <= 18'sb101100011000111110;
        end
        2479: begin
            cosine_reg0 <= 18'sb100110101111100011;
            sine_reg0   <= 18'sb101100010110100000;
        end
        2480: begin
            cosine_reg0 <= 18'sb100110110001011111;
            sine_reg0   <= 18'sb101100010100000001;
        end
        2481: begin
            cosine_reg0 <= 18'sb100110110011011010;
            sine_reg0   <= 18'sb101100010001100011;
        end
        2482: begin
            cosine_reg0 <= 18'sb100110110101010111;
            sine_reg0   <= 18'sb101100001111000100;
        end
        2483: begin
            cosine_reg0 <= 18'sb100110110111010011;
            sine_reg0   <= 18'sb101100001100100110;
        end
        2484: begin
            cosine_reg0 <= 18'sb100110111001001111;
            sine_reg0   <= 18'sb101100001010001000;
        end
        2485: begin
            cosine_reg0 <= 18'sb100110111011001100;
            sine_reg0   <= 18'sb101100000111101011;
        end
        2486: begin
            cosine_reg0 <= 18'sb100110111101001001;
            sine_reg0   <= 18'sb101100000101001101;
        end
        2487: begin
            cosine_reg0 <= 18'sb100110111111000110;
            sine_reg0   <= 18'sb101100000010110000;
        end
        2488: begin
            cosine_reg0 <= 18'sb100111000001000100;
            sine_reg0   <= 18'sb101100000000010011;
        end
        2489: begin
            cosine_reg0 <= 18'sb100111000011000010;
            sine_reg0   <= 18'sb101011111101110110;
        end
        2490: begin
            cosine_reg0 <= 18'sb100111000101000000;
            sine_reg0   <= 18'sb101011111011011001;
        end
        2491: begin
            cosine_reg0 <= 18'sb100111000110111110;
            sine_reg0   <= 18'sb101011111000111101;
        end
        2492: begin
            cosine_reg0 <= 18'sb100111001000111100;
            sine_reg0   <= 18'sb101011110110100001;
        end
        2493: begin
            cosine_reg0 <= 18'sb100111001010111011;
            sine_reg0   <= 18'sb101011110100000101;
        end
        2494: begin
            cosine_reg0 <= 18'sb100111001100111010;
            sine_reg0   <= 18'sb101011110001101001;
        end
        2495: begin
            cosine_reg0 <= 18'sb100111001110111001;
            sine_reg0   <= 18'sb101011101111001101;
        end
        2496: begin
            cosine_reg0 <= 18'sb100111010000111001;
            sine_reg0   <= 18'sb101011101100110001;
        end
        2497: begin
            cosine_reg0 <= 18'sb100111010010111000;
            sine_reg0   <= 18'sb101011101010010110;
        end
        2498: begin
            cosine_reg0 <= 18'sb100111010100111000;
            sine_reg0   <= 18'sb101011100111111011;
        end
        2499: begin
            cosine_reg0 <= 18'sb100111010110111000;
            sine_reg0   <= 18'sb101011100101100000;
        end
        2500: begin
            cosine_reg0 <= 18'sb100111011000111001;
            sine_reg0   <= 18'sb101011100011000101;
        end
        2501: begin
            cosine_reg0 <= 18'sb100111011010111001;
            sine_reg0   <= 18'sb101011100000101011;
        end
        2502: begin
            cosine_reg0 <= 18'sb100111011100111010;
            sine_reg0   <= 18'sb101011011110010000;
        end
        2503: begin
            cosine_reg0 <= 18'sb100111011110111011;
            sine_reg0   <= 18'sb101011011011110110;
        end
        2504: begin
            cosine_reg0 <= 18'sb100111100000111101;
            sine_reg0   <= 18'sb101011011001011100;
        end
        2505: begin
            cosine_reg0 <= 18'sb100111100010111110;
            sine_reg0   <= 18'sb101011010111000011;
        end
        2506: begin
            cosine_reg0 <= 18'sb100111100101000000;
            sine_reg0   <= 18'sb101011010100101001;
        end
        2507: begin
            cosine_reg0 <= 18'sb100111100111000010;
            sine_reg0   <= 18'sb101011010010010000;
        end
        2508: begin
            cosine_reg0 <= 18'sb100111101001000100;
            sine_reg0   <= 18'sb101011001111110111;
        end
        2509: begin
            cosine_reg0 <= 18'sb100111101011000111;
            sine_reg0   <= 18'sb101011001101011110;
        end
        2510: begin
            cosine_reg0 <= 18'sb100111101101001010;
            sine_reg0   <= 18'sb101011001011000101;
        end
        2511: begin
            cosine_reg0 <= 18'sb100111101111001101;
            sine_reg0   <= 18'sb101011001000101100;
        end
        2512: begin
            cosine_reg0 <= 18'sb100111110001010000;
            sine_reg0   <= 18'sb101011000110010100;
        end
        2513: begin
            cosine_reg0 <= 18'sb100111110011010011;
            sine_reg0   <= 18'sb101011000011111100;
        end
        2514: begin
            cosine_reg0 <= 18'sb100111110101010111;
            sine_reg0   <= 18'sb101011000001100100;
        end
        2515: begin
            cosine_reg0 <= 18'sb100111110111011011;
            sine_reg0   <= 18'sb101010111111001100;
        end
        2516: begin
            cosine_reg0 <= 18'sb100111111001011111;
            sine_reg0   <= 18'sb101010111100110101;
        end
        2517: begin
            cosine_reg0 <= 18'sb100111111011100011;
            sine_reg0   <= 18'sb101010111010011101;
        end
        2518: begin
            cosine_reg0 <= 18'sb100111111101101000;
            sine_reg0   <= 18'sb101010111000000110;
        end
        2519: begin
            cosine_reg0 <= 18'sb100111111111101101;
            sine_reg0   <= 18'sb101010110101101111;
        end
        2520: begin
            cosine_reg0 <= 18'sb101000000001110010;
            sine_reg0   <= 18'sb101010110011011001;
        end
        2521: begin
            cosine_reg0 <= 18'sb101000000011110111;
            sine_reg0   <= 18'sb101010110001000010;
        end
        2522: begin
            cosine_reg0 <= 18'sb101000000101111101;
            sine_reg0   <= 18'sb101010101110101100;
        end
        2523: begin
            cosine_reg0 <= 18'sb101000001000000011;
            sine_reg0   <= 18'sb101010101100010110;
        end
        2524: begin
            cosine_reg0 <= 18'sb101000001010001001;
            sine_reg0   <= 18'sb101010101010000000;
        end
        2525: begin
            cosine_reg0 <= 18'sb101000001100001111;
            sine_reg0   <= 18'sb101010100111101010;
        end
        2526: begin
            cosine_reg0 <= 18'sb101000001110010101;
            sine_reg0   <= 18'sb101010100101010100;
        end
        2527: begin
            cosine_reg0 <= 18'sb101000010000011100;
            sine_reg0   <= 18'sb101010100010111111;
        end
        2528: begin
            cosine_reg0 <= 18'sb101000010010100011;
            sine_reg0   <= 18'sb101010100000101010;
        end
        2529: begin
            cosine_reg0 <= 18'sb101000010100101010;
            sine_reg0   <= 18'sb101010011110010101;
        end
        2530: begin
            cosine_reg0 <= 18'sb101000010110110001;
            sine_reg0   <= 18'sb101010011100000001;
        end
        2531: begin
            cosine_reg0 <= 18'sb101000011000111001;
            sine_reg0   <= 18'sb101010011001101100;
        end
        2532: begin
            cosine_reg0 <= 18'sb101000011011000001;
            sine_reg0   <= 18'sb101010010111011000;
        end
        2533: begin
            cosine_reg0 <= 18'sb101000011101001001;
            sine_reg0   <= 18'sb101010010101000100;
        end
        2534: begin
            cosine_reg0 <= 18'sb101000011111010001;
            sine_reg0   <= 18'sb101010010010110000;
        end
        2535: begin
            cosine_reg0 <= 18'sb101000100001011010;
            sine_reg0   <= 18'sb101010010000011100;
        end
        2536: begin
            cosine_reg0 <= 18'sb101000100011100010;
            sine_reg0   <= 18'sb101010001110001001;
        end
        2537: begin
            cosine_reg0 <= 18'sb101000100101101011;
            sine_reg0   <= 18'sb101010001011110110;
        end
        2538: begin
            cosine_reg0 <= 18'sb101000100111110100;
            sine_reg0   <= 18'sb101010001001100011;
        end
        2539: begin
            cosine_reg0 <= 18'sb101000101001111110;
            sine_reg0   <= 18'sb101010000111010000;
        end
        2540: begin
            cosine_reg0 <= 18'sb101000101100000111;
            sine_reg0   <= 18'sb101010000100111101;
        end
        2541: begin
            cosine_reg0 <= 18'sb101000101110010001;
            sine_reg0   <= 18'sb101010000010101011;
        end
        2542: begin
            cosine_reg0 <= 18'sb101000110000011011;
            sine_reg0   <= 18'sb101010000000011001;
        end
        2543: begin
            cosine_reg0 <= 18'sb101000110010100110;
            sine_reg0   <= 18'sb101001111110000111;
        end
        2544: begin
            cosine_reg0 <= 18'sb101000110100110000;
            sine_reg0   <= 18'sb101001111011110101;
        end
        2545: begin
            cosine_reg0 <= 18'sb101000110110111011;
            sine_reg0   <= 18'sb101001111001100100;
        end
        2546: begin
            cosine_reg0 <= 18'sb101000111001000110;
            sine_reg0   <= 18'sb101001110111010010;
        end
        2547: begin
            cosine_reg0 <= 18'sb101000111011010001;
            sine_reg0   <= 18'sb101001110101000001;
        end
        2548: begin
            cosine_reg0 <= 18'sb101000111101011101;
            sine_reg0   <= 18'sb101001110010110000;
        end
        2549: begin
            cosine_reg0 <= 18'sb101000111111101000;
            sine_reg0   <= 18'sb101001110000100000;
        end
        2550: begin
            cosine_reg0 <= 18'sb101001000001110100;
            sine_reg0   <= 18'sb101001101110001111;
        end
        2551: begin
            cosine_reg0 <= 18'sb101001000100000000;
            sine_reg0   <= 18'sb101001101011111111;
        end
        2552: begin
            cosine_reg0 <= 18'sb101001000110001100;
            sine_reg0   <= 18'sb101001101001101111;
        end
        2553: begin
            cosine_reg0 <= 18'sb101001001000011001;
            sine_reg0   <= 18'sb101001100111011111;
        end
        2554: begin
            cosine_reg0 <= 18'sb101001001010100110;
            sine_reg0   <= 18'sb101001100101010000;
        end
        2555: begin
            cosine_reg0 <= 18'sb101001001100110011;
            sine_reg0   <= 18'sb101001100011000000;
        end
        2556: begin
            cosine_reg0 <= 18'sb101001001111000000;
            sine_reg0   <= 18'sb101001100000110001;
        end
        2557: begin
            cosine_reg0 <= 18'sb101001010001001101;
            sine_reg0   <= 18'sb101001011110100010;
        end
        2558: begin
            cosine_reg0 <= 18'sb101001010011011011;
            sine_reg0   <= 18'sb101001011100010100;
        end
        2559: begin
            cosine_reg0 <= 18'sb101001010101101001;
            sine_reg0   <= 18'sb101001011010000101;
        end
        2560: begin
            cosine_reg0 <= 18'sb101001010111110111;
            sine_reg0   <= 18'sb101001010111110111;
        end
        2561: begin
            cosine_reg0 <= 18'sb101001011010000101;
            sine_reg0   <= 18'sb101001010101101001;
        end
        2562: begin
            cosine_reg0 <= 18'sb101001011100010100;
            sine_reg0   <= 18'sb101001010011011011;
        end
        2563: begin
            cosine_reg0 <= 18'sb101001011110100010;
            sine_reg0   <= 18'sb101001010001001101;
        end
        2564: begin
            cosine_reg0 <= 18'sb101001100000110001;
            sine_reg0   <= 18'sb101001001111000000;
        end
        2565: begin
            cosine_reg0 <= 18'sb101001100011000000;
            sine_reg0   <= 18'sb101001001100110011;
        end
        2566: begin
            cosine_reg0 <= 18'sb101001100101010000;
            sine_reg0   <= 18'sb101001001010100110;
        end
        2567: begin
            cosine_reg0 <= 18'sb101001100111011111;
            sine_reg0   <= 18'sb101001001000011001;
        end
        2568: begin
            cosine_reg0 <= 18'sb101001101001101111;
            sine_reg0   <= 18'sb101001000110001100;
        end
        2569: begin
            cosine_reg0 <= 18'sb101001101011111111;
            sine_reg0   <= 18'sb101001000100000000;
        end
        2570: begin
            cosine_reg0 <= 18'sb101001101110001111;
            sine_reg0   <= 18'sb101001000001110100;
        end
        2571: begin
            cosine_reg0 <= 18'sb101001110000100000;
            sine_reg0   <= 18'sb101000111111101000;
        end
        2572: begin
            cosine_reg0 <= 18'sb101001110010110000;
            sine_reg0   <= 18'sb101000111101011101;
        end
        2573: begin
            cosine_reg0 <= 18'sb101001110101000001;
            sine_reg0   <= 18'sb101000111011010001;
        end
        2574: begin
            cosine_reg0 <= 18'sb101001110111010010;
            sine_reg0   <= 18'sb101000111001000110;
        end
        2575: begin
            cosine_reg0 <= 18'sb101001111001100100;
            sine_reg0   <= 18'sb101000110110111011;
        end
        2576: begin
            cosine_reg0 <= 18'sb101001111011110101;
            sine_reg0   <= 18'sb101000110100110000;
        end
        2577: begin
            cosine_reg0 <= 18'sb101001111110000111;
            sine_reg0   <= 18'sb101000110010100110;
        end
        2578: begin
            cosine_reg0 <= 18'sb101010000000011001;
            sine_reg0   <= 18'sb101000110000011011;
        end
        2579: begin
            cosine_reg0 <= 18'sb101010000010101011;
            sine_reg0   <= 18'sb101000101110010001;
        end
        2580: begin
            cosine_reg0 <= 18'sb101010000100111101;
            sine_reg0   <= 18'sb101000101100000111;
        end
        2581: begin
            cosine_reg0 <= 18'sb101010000111010000;
            sine_reg0   <= 18'sb101000101001111110;
        end
        2582: begin
            cosine_reg0 <= 18'sb101010001001100011;
            sine_reg0   <= 18'sb101000100111110100;
        end
        2583: begin
            cosine_reg0 <= 18'sb101010001011110110;
            sine_reg0   <= 18'sb101000100101101011;
        end
        2584: begin
            cosine_reg0 <= 18'sb101010001110001001;
            sine_reg0   <= 18'sb101000100011100010;
        end
        2585: begin
            cosine_reg0 <= 18'sb101010010000011100;
            sine_reg0   <= 18'sb101000100001011010;
        end
        2586: begin
            cosine_reg0 <= 18'sb101010010010110000;
            sine_reg0   <= 18'sb101000011111010001;
        end
        2587: begin
            cosine_reg0 <= 18'sb101010010101000100;
            sine_reg0   <= 18'sb101000011101001001;
        end
        2588: begin
            cosine_reg0 <= 18'sb101010010111011000;
            sine_reg0   <= 18'sb101000011011000001;
        end
        2589: begin
            cosine_reg0 <= 18'sb101010011001101100;
            sine_reg0   <= 18'sb101000011000111001;
        end
        2590: begin
            cosine_reg0 <= 18'sb101010011100000001;
            sine_reg0   <= 18'sb101000010110110001;
        end
        2591: begin
            cosine_reg0 <= 18'sb101010011110010101;
            sine_reg0   <= 18'sb101000010100101010;
        end
        2592: begin
            cosine_reg0 <= 18'sb101010100000101010;
            sine_reg0   <= 18'sb101000010010100011;
        end
        2593: begin
            cosine_reg0 <= 18'sb101010100010111111;
            sine_reg0   <= 18'sb101000010000011100;
        end
        2594: begin
            cosine_reg0 <= 18'sb101010100101010100;
            sine_reg0   <= 18'sb101000001110010101;
        end
        2595: begin
            cosine_reg0 <= 18'sb101010100111101010;
            sine_reg0   <= 18'sb101000001100001111;
        end
        2596: begin
            cosine_reg0 <= 18'sb101010101010000000;
            sine_reg0   <= 18'sb101000001010001001;
        end
        2597: begin
            cosine_reg0 <= 18'sb101010101100010110;
            sine_reg0   <= 18'sb101000001000000011;
        end
        2598: begin
            cosine_reg0 <= 18'sb101010101110101100;
            sine_reg0   <= 18'sb101000000101111101;
        end
        2599: begin
            cosine_reg0 <= 18'sb101010110001000010;
            sine_reg0   <= 18'sb101000000011110111;
        end
        2600: begin
            cosine_reg0 <= 18'sb101010110011011001;
            sine_reg0   <= 18'sb101000000001110010;
        end
        2601: begin
            cosine_reg0 <= 18'sb101010110101101111;
            sine_reg0   <= 18'sb100111111111101101;
        end
        2602: begin
            cosine_reg0 <= 18'sb101010111000000110;
            sine_reg0   <= 18'sb100111111101101000;
        end
        2603: begin
            cosine_reg0 <= 18'sb101010111010011101;
            sine_reg0   <= 18'sb100111111011100011;
        end
        2604: begin
            cosine_reg0 <= 18'sb101010111100110101;
            sine_reg0   <= 18'sb100111111001011111;
        end
        2605: begin
            cosine_reg0 <= 18'sb101010111111001100;
            sine_reg0   <= 18'sb100111110111011011;
        end
        2606: begin
            cosine_reg0 <= 18'sb101011000001100100;
            sine_reg0   <= 18'sb100111110101010111;
        end
        2607: begin
            cosine_reg0 <= 18'sb101011000011111100;
            sine_reg0   <= 18'sb100111110011010011;
        end
        2608: begin
            cosine_reg0 <= 18'sb101011000110010100;
            sine_reg0   <= 18'sb100111110001010000;
        end
        2609: begin
            cosine_reg0 <= 18'sb101011001000101100;
            sine_reg0   <= 18'sb100111101111001101;
        end
        2610: begin
            cosine_reg0 <= 18'sb101011001011000101;
            sine_reg0   <= 18'sb100111101101001010;
        end
        2611: begin
            cosine_reg0 <= 18'sb101011001101011110;
            sine_reg0   <= 18'sb100111101011000111;
        end
        2612: begin
            cosine_reg0 <= 18'sb101011001111110111;
            sine_reg0   <= 18'sb100111101001000100;
        end
        2613: begin
            cosine_reg0 <= 18'sb101011010010010000;
            sine_reg0   <= 18'sb100111100111000010;
        end
        2614: begin
            cosine_reg0 <= 18'sb101011010100101001;
            sine_reg0   <= 18'sb100111100101000000;
        end
        2615: begin
            cosine_reg0 <= 18'sb101011010111000011;
            sine_reg0   <= 18'sb100111100010111110;
        end
        2616: begin
            cosine_reg0 <= 18'sb101011011001011100;
            sine_reg0   <= 18'sb100111100000111101;
        end
        2617: begin
            cosine_reg0 <= 18'sb101011011011110110;
            sine_reg0   <= 18'sb100111011110111011;
        end
        2618: begin
            cosine_reg0 <= 18'sb101011011110010000;
            sine_reg0   <= 18'sb100111011100111010;
        end
        2619: begin
            cosine_reg0 <= 18'sb101011100000101011;
            sine_reg0   <= 18'sb100111011010111001;
        end
        2620: begin
            cosine_reg0 <= 18'sb101011100011000101;
            sine_reg0   <= 18'sb100111011000111001;
        end
        2621: begin
            cosine_reg0 <= 18'sb101011100101100000;
            sine_reg0   <= 18'sb100111010110111000;
        end
        2622: begin
            cosine_reg0 <= 18'sb101011100111111011;
            sine_reg0   <= 18'sb100111010100111000;
        end
        2623: begin
            cosine_reg0 <= 18'sb101011101010010110;
            sine_reg0   <= 18'sb100111010010111000;
        end
        2624: begin
            cosine_reg0 <= 18'sb101011101100110001;
            sine_reg0   <= 18'sb100111010000111001;
        end
        2625: begin
            cosine_reg0 <= 18'sb101011101111001101;
            sine_reg0   <= 18'sb100111001110111001;
        end
        2626: begin
            cosine_reg0 <= 18'sb101011110001101001;
            sine_reg0   <= 18'sb100111001100111010;
        end
        2627: begin
            cosine_reg0 <= 18'sb101011110100000101;
            sine_reg0   <= 18'sb100111001010111011;
        end
        2628: begin
            cosine_reg0 <= 18'sb101011110110100001;
            sine_reg0   <= 18'sb100111001000111100;
        end
        2629: begin
            cosine_reg0 <= 18'sb101011111000111101;
            sine_reg0   <= 18'sb100111000110111110;
        end
        2630: begin
            cosine_reg0 <= 18'sb101011111011011001;
            sine_reg0   <= 18'sb100111000101000000;
        end
        2631: begin
            cosine_reg0 <= 18'sb101011111101110110;
            sine_reg0   <= 18'sb100111000011000010;
        end
        2632: begin
            cosine_reg0 <= 18'sb101100000000010011;
            sine_reg0   <= 18'sb100111000001000100;
        end
        2633: begin
            cosine_reg0 <= 18'sb101100000010110000;
            sine_reg0   <= 18'sb100110111111000110;
        end
        2634: begin
            cosine_reg0 <= 18'sb101100000101001101;
            sine_reg0   <= 18'sb100110111101001001;
        end
        2635: begin
            cosine_reg0 <= 18'sb101100000111101011;
            sine_reg0   <= 18'sb100110111011001100;
        end
        2636: begin
            cosine_reg0 <= 18'sb101100001010001000;
            sine_reg0   <= 18'sb100110111001001111;
        end
        2637: begin
            cosine_reg0 <= 18'sb101100001100100110;
            sine_reg0   <= 18'sb100110110111010011;
        end
        2638: begin
            cosine_reg0 <= 18'sb101100001111000100;
            sine_reg0   <= 18'sb100110110101010111;
        end
        2639: begin
            cosine_reg0 <= 18'sb101100010001100011;
            sine_reg0   <= 18'sb100110110011011010;
        end
        2640: begin
            cosine_reg0 <= 18'sb101100010100000001;
            sine_reg0   <= 18'sb100110110001011111;
        end
        2641: begin
            cosine_reg0 <= 18'sb101100010110100000;
            sine_reg0   <= 18'sb100110101111100011;
        end
        2642: begin
            cosine_reg0 <= 18'sb101100011000111110;
            sine_reg0   <= 18'sb100110101101101000;
        end
        2643: begin
            cosine_reg0 <= 18'sb101100011011011101;
            sine_reg0   <= 18'sb100110101011101101;
        end
        2644: begin
            cosine_reg0 <= 18'sb101100011101111101;
            sine_reg0   <= 18'sb100110101001110010;
        end
        2645: begin
            cosine_reg0 <= 18'sb101100100000011100;
            sine_reg0   <= 18'sb100110100111110111;
        end
        2646: begin
            cosine_reg0 <= 18'sb101100100010111011;
            sine_reg0   <= 18'sb100110100101111101;
        end
        2647: begin
            cosine_reg0 <= 18'sb101100100101011011;
            sine_reg0   <= 18'sb100110100100000011;
        end
        2648: begin
            cosine_reg0 <= 18'sb101100100111111011;
            sine_reg0   <= 18'sb100110100010001001;
        end
        2649: begin
            cosine_reg0 <= 18'sb101100101010011011;
            sine_reg0   <= 18'sb100110100000001111;
        end
        2650: begin
            cosine_reg0 <= 18'sb101100101100111011;
            sine_reg0   <= 18'sb100110011110010110;
        end
        2651: begin
            cosine_reg0 <= 18'sb101100101111011100;
            sine_reg0   <= 18'sb100110011100011101;
        end
        2652: begin
            cosine_reg0 <= 18'sb101100110001111101;
            sine_reg0   <= 18'sb100110011010100100;
        end
        2653: begin
            cosine_reg0 <= 18'sb101100110100011101;
            sine_reg0   <= 18'sb100110011000101011;
        end
        2654: begin
            cosine_reg0 <= 18'sb101100110110111110;
            sine_reg0   <= 18'sb100110010110110011;
        end
        2655: begin
            cosine_reg0 <= 18'sb101100111001100000;
            sine_reg0   <= 18'sb100110010100111011;
        end
        2656: begin
            cosine_reg0 <= 18'sb101100111100000001;
            sine_reg0   <= 18'sb100110010011000011;
        end
        2657: begin
            cosine_reg0 <= 18'sb101100111110100011;
            sine_reg0   <= 18'sb100110010001001011;
        end
        2658: begin
            cosine_reg0 <= 18'sb101101000001000100;
            sine_reg0   <= 18'sb100110001111010100;
        end
        2659: begin
            cosine_reg0 <= 18'sb101101000011100110;
            sine_reg0   <= 18'sb100110001101011101;
        end
        2660: begin
            cosine_reg0 <= 18'sb101101000110001001;
            sine_reg0   <= 18'sb100110001011100110;
        end
        2661: begin
            cosine_reg0 <= 18'sb101101001000101011;
            sine_reg0   <= 18'sb100110001001101111;
        end
        2662: begin
            cosine_reg0 <= 18'sb101101001011001101;
            sine_reg0   <= 18'sb100110000111111001;
        end
        2663: begin
            cosine_reg0 <= 18'sb101101001101110000;
            sine_reg0   <= 18'sb100110000110000010;
        end
        2664: begin
            cosine_reg0 <= 18'sb101101010000010011;
            sine_reg0   <= 18'sb100110000100001101;
        end
        2665: begin
            cosine_reg0 <= 18'sb101101010010110110;
            sine_reg0   <= 18'sb100110000010010111;
        end
        2666: begin
            cosine_reg0 <= 18'sb101101010101011001;
            sine_reg0   <= 18'sb100110000000100010;
        end
        2667: begin
            cosine_reg0 <= 18'sb101101010111111101;
            sine_reg0   <= 18'sb100101111110101100;
        end
        2668: begin
            cosine_reg0 <= 18'sb101101011010100000;
            sine_reg0   <= 18'sb100101111100110111;
        end
        2669: begin
            cosine_reg0 <= 18'sb101101011101000100;
            sine_reg0   <= 18'sb100101111011000011;
        end
        2670: begin
            cosine_reg0 <= 18'sb101101011111101000;
            sine_reg0   <= 18'sb100101111001001110;
        end
        2671: begin
            cosine_reg0 <= 18'sb101101100010001100;
            sine_reg0   <= 18'sb100101110111011010;
        end
        2672: begin
            cosine_reg0 <= 18'sb101101100100110000;
            sine_reg0   <= 18'sb100101110101100110;
        end
        2673: begin
            cosine_reg0 <= 18'sb101101100111010101;
            sine_reg0   <= 18'sb100101110011110011;
        end
        2674: begin
            cosine_reg0 <= 18'sb101101101001111001;
            sine_reg0   <= 18'sb100101110001111111;
        end
        2675: begin
            cosine_reg0 <= 18'sb101101101100011110;
            sine_reg0   <= 18'sb100101110000001100;
        end
        2676: begin
            cosine_reg0 <= 18'sb101101101111000011;
            sine_reg0   <= 18'sb100101101110011001;
        end
        2677: begin
            cosine_reg0 <= 18'sb101101110001101000;
            sine_reg0   <= 18'sb100101101100100111;
        end
        2678: begin
            cosine_reg0 <= 18'sb101101110100001110;
            sine_reg0   <= 18'sb100101101010110100;
        end
        2679: begin
            cosine_reg0 <= 18'sb101101110110110011;
            sine_reg0   <= 18'sb100101101001000010;
        end
        2680: begin
            cosine_reg0 <= 18'sb101101111001011001;
            sine_reg0   <= 18'sb100101100111010000;
        end
        2681: begin
            cosine_reg0 <= 18'sb101101111011111111;
            sine_reg0   <= 18'sb100101100101011111;
        end
        2682: begin
            cosine_reg0 <= 18'sb101101111110100101;
            sine_reg0   <= 18'sb100101100011101101;
        end
        2683: begin
            cosine_reg0 <= 18'sb101110000001001011;
            sine_reg0   <= 18'sb100101100001111100;
        end
        2684: begin
            cosine_reg0 <= 18'sb101110000011110010;
            sine_reg0   <= 18'sb100101100000001011;
        end
        2685: begin
            cosine_reg0 <= 18'sb101110000110011000;
            sine_reg0   <= 18'sb100101011110011011;
        end
        2686: begin
            cosine_reg0 <= 18'sb101110001000111111;
            sine_reg0   <= 18'sb100101011100101010;
        end
        2687: begin
            cosine_reg0 <= 18'sb101110001011100110;
            sine_reg0   <= 18'sb100101011010111010;
        end
        2688: begin
            cosine_reg0 <= 18'sb101110001110001101;
            sine_reg0   <= 18'sb100101011001001010;
        end
        2689: begin
            cosine_reg0 <= 18'sb101110010000110100;
            sine_reg0   <= 18'sb100101010111011011;
        end
        2690: begin
            cosine_reg0 <= 18'sb101110010011011100;
            sine_reg0   <= 18'sb100101010101101100;
        end
        2691: begin
            cosine_reg0 <= 18'sb101110010110000011;
            sine_reg0   <= 18'sb100101010011111100;
        end
        2692: begin
            cosine_reg0 <= 18'sb101110011000101011;
            sine_reg0   <= 18'sb100101010010001110;
        end
        2693: begin
            cosine_reg0 <= 18'sb101110011011010011;
            sine_reg0   <= 18'sb100101010000011111;
        end
        2694: begin
            cosine_reg0 <= 18'sb101110011101111011;
            sine_reg0   <= 18'sb100101001110110001;
        end
        2695: begin
            cosine_reg0 <= 18'sb101110100000100011;
            sine_reg0   <= 18'sb100101001101000011;
        end
        2696: begin
            cosine_reg0 <= 18'sb101110100011001100;
            sine_reg0   <= 18'sb100101001011010101;
        end
        2697: begin
            cosine_reg0 <= 18'sb101110100101110100;
            sine_reg0   <= 18'sb100101001001101000;
        end
        2698: begin
            cosine_reg0 <= 18'sb101110101000011101;
            sine_reg0   <= 18'sb100101000111111010;
        end
        2699: begin
            cosine_reg0 <= 18'sb101110101011000110;
            sine_reg0   <= 18'sb100101000110001101;
        end
        2700: begin
            cosine_reg0 <= 18'sb101110101101101111;
            sine_reg0   <= 18'sb100101000100100001;
        end
        2701: begin
            cosine_reg0 <= 18'sb101110110000011000;
            sine_reg0   <= 18'sb100101000010110100;
        end
        2702: begin
            cosine_reg0 <= 18'sb101110110011000010;
            sine_reg0   <= 18'sb100101000001001000;
        end
        2703: begin
            cosine_reg0 <= 18'sb101110110101101100;
            sine_reg0   <= 18'sb100100111111011100;
        end
        2704: begin
            cosine_reg0 <= 18'sb101110111000010101;
            sine_reg0   <= 18'sb100100111101110000;
        end
        2705: begin
            cosine_reg0 <= 18'sb101110111010111111;
            sine_reg0   <= 18'sb100100111100000101;
        end
        2706: begin
            cosine_reg0 <= 18'sb101110111101101001;
            sine_reg0   <= 18'sb100100111010011010;
        end
        2707: begin
            cosine_reg0 <= 18'sb101111000000010100;
            sine_reg0   <= 18'sb100100111000101111;
        end
        2708: begin
            cosine_reg0 <= 18'sb101111000010111110;
            sine_reg0   <= 18'sb100100110111000100;
        end
        2709: begin
            cosine_reg0 <= 18'sb101111000101101001;
            sine_reg0   <= 18'sb100100110101011010;
        end
        2710: begin
            cosine_reg0 <= 18'sb101111001000010011;
            sine_reg0   <= 18'sb100100110011101111;
        end
        2711: begin
            cosine_reg0 <= 18'sb101111001010111110;
            sine_reg0   <= 18'sb100100110010000110;
        end
        2712: begin
            cosine_reg0 <= 18'sb101111001101101010;
            sine_reg0   <= 18'sb100100110000011100;
        end
        2713: begin
            cosine_reg0 <= 18'sb101111010000010101;
            sine_reg0   <= 18'sb100100101110110011;
        end
        2714: begin
            cosine_reg0 <= 18'sb101111010011000000;
            sine_reg0   <= 18'sb100100101101001010;
        end
        2715: begin
            cosine_reg0 <= 18'sb101111010101101100;
            sine_reg0   <= 18'sb100100101011100001;
        end
        2716: begin
            cosine_reg0 <= 18'sb101111011000010111;
            sine_reg0   <= 18'sb100100101001111000;
        end
        2717: begin
            cosine_reg0 <= 18'sb101111011011000011;
            sine_reg0   <= 18'sb100100101000010000;
        end
        2718: begin
            cosine_reg0 <= 18'sb101111011101101111;
            sine_reg0   <= 18'sb100100100110101000;
        end
        2719: begin
            cosine_reg0 <= 18'sb101111100000011100;
            sine_reg0   <= 18'sb100100100101000000;
        end
        2720: begin
            cosine_reg0 <= 18'sb101111100011001000;
            sine_reg0   <= 18'sb100100100011011001;
        end
        2721: begin
            cosine_reg0 <= 18'sb101111100101110101;
            sine_reg0   <= 18'sb100100100001110001;
        end
        2722: begin
            cosine_reg0 <= 18'sb101111101000100001;
            sine_reg0   <= 18'sb100100100000001010;
        end
        2723: begin
            cosine_reg0 <= 18'sb101111101011001110;
            sine_reg0   <= 18'sb100100011110100100;
        end
        2724: begin
            cosine_reg0 <= 18'sb101111101101111011;
            sine_reg0   <= 18'sb100100011100111101;
        end
        2725: begin
            cosine_reg0 <= 18'sb101111110000101000;
            sine_reg0   <= 18'sb100100011011010111;
        end
        2726: begin
            cosine_reg0 <= 18'sb101111110011010110;
            sine_reg0   <= 18'sb100100011001110001;
        end
        2727: begin
            cosine_reg0 <= 18'sb101111110110000011;
            sine_reg0   <= 18'sb100100011000001100;
        end
        2728: begin
            cosine_reg0 <= 18'sb101111111000110001;
            sine_reg0   <= 18'sb100100010110100110;
        end
        2729: begin
            cosine_reg0 <= 18'sb101111111011011111;
            sine_reg0   <= 18'sb100100010101000001;
        end
        2730: begin
            cosine_reg0 <= 18'sb101111111110001100;
            sine_reg0   <= 18'sb100100010011011100;
        end
        2731: begin
            cosine_reg0 <= 18'sb110000000000111011;
            sine_reg0   <= 18'sb100100010001111000;
        end
        2732: begin
            cosine_reg0 <= 18'sb110000000011101001;
            sine_reg0   <= 18'sb100100010000010011;
        end
        2733: begin
            cosine_reg0 <= 18'sb110000000110010111;
            sine_reg0   <= 18'sb100100001110101111;
        end
        2734: begin
            cosine_reg0 <= 18'sb110000001001000110;
            sine_reg0   <= 18'sb100100001101001100;
        end
        2735: begin
            cosine_reg0 <= 18'sb110000001011110100;
            sine_reg0   <= 18'sb100100001011101000;
        end
        2736: begin
            cosine_reg0 <= 18'sb110000001110100011;
            sine_reg0   <= 18'sb100100001010000101;
        end
        2737: begin
            cosine_reg0 <= 18'sb110000010001010010;
            sine_reg0   <= 18'sb100100001000100010;
        end
        2738: begin
            cosine_reg0 <= 18'sb110000010100000010;
            sine_reg0   <= 18'sb100100000110111111;
        end
        2739: begin
            cosine_reg0 <= 18'sb110000010110110001;
            sine_reg0   <= 18'sb100100000101011101;
        end
        2740: begin
            cosine_reg0 <= 18'sb110000011001100000;
            sine_reg0   <= 18'sb100100000011111011;
        end
        2741: begin
            cosine_reg0 <= 18'sb110000011100010000;
            sine_reg0   <= 18'sb100100000010011001;
        end
        2742: begin
            cosine_reg0 <= 18'sb110000011111000000;
            sine_reg0   <= 18'sb100100000000110111;
        end
        2743: begin
            cosine_reg0 <= 18'sb110000100001110000;
            sine_reg0   <= 18'sb100011111111010110;
        end
        2744: begin
            cosine_reg0 <= 18'sb110000100100100000;
            sine_reg0   <= 18'sb100011111101110101;
        end
        2745: begin
            cosine_reg0 <= 18'sb110000100111010000;
            sine_reg0   <= 18'sb100011111100010100;
        end
        2746: begin
            cosine_reg0 <= 18'sb110000101010000000;
            sine_reg0   <= 18'sb100011111010110011;
        end
        2747: begin
            cosine_reg0 <= 18'sb110000101100110001;
            sine_reg0   <= 18'sb100011111001010011;
        end
        2748: begin
            cosine_reg0 <= 18'sb110000101111100001;
            sine_reg0   <= 18'sb100011110111110011;
        end
        2749: begin
            cosine_reg0 <= 18'sb110000110010010010;
            sine_reg0   <= 18'sb100011110110010011;
        end
        2750: begin
            cosine_reg0 <= 18'sb110000110101000011;
            sine_reg0   <= 18'sb100011110100110100;
        end
        2751: begin
            cosine_reg0 <= 18'sb110000110111110100;
            sine_reg0   <= 18'sb100011110011010101;
        end
        2752: begin
            cosine_reg0 <= 18'sb110000111010100110;
            sine_reg0   <= 18'sb100011110001110110;
        end
        2753: begin
            cosine_reg0 <= 18'sb110000111101010111;
            sine_reg0   <= 18'sb100011110000010111;
        end
        2754: begin
            cosine_reg0 <= 18'sb110001000000001000;
            sine_reg0   <= 18'sb100011101110111001;
        end
        2755: begin
            cosine_reg0 <= 18'sb110001000010111010;
            sine_reg0   <= 18'sb100011101101011011;
        end
        2756: begin
            cosine_reg0 <= 18'sb110001000101101100;
            sine_reg0   <= 18'sb100011101011111101;
        end
        2757: begin
            cosine_reg0 <= 18'sb110001001000011110;
            sine_reg0   <= 18'sb100011101010011111;
        end
        2758: begin
            cosine_reg0 <= 18'sb110001001011010000;
            sine_reg0   <= 18'sb100011101001000010;
        end
        2759: begin
            cosine_reg0 <= 18'sb110001001110000010;
            sine_reg0   <= 18'sb100011100111100101;
        end
        2760: begin
            cosine_reg0 <= 18'sb110001010000110101;
            sine_reg0   <= 18'sb100011100110001000;
        end
        2761: begin
            cosine_reg0 <= 18'sb110001010011100111;
            sine_reg0   <= 18'sb100011100100101100;
        end
        2762: begin
            cosine_reg0 <= 18'sb110001010110011010;
            sine_reg0   <= 18'sb100011100011010000;
        end
        2763: begin
            cosine_reg0 <= 18'sb110001011001001101;
            sine_reg0   <= 18'sb100011100001110100;
        end
        2764: begin
            cosine_reg0 <= 18'sb110001011100000000;
            sine_reg0   <= 18'sb100011100000011000;
        end
        2765: begin
            cosine_reg0 <= 18'sb110001011110110011;
            sine_reg0   <= 18'sb100011011110111101;
        end
        2766: begin
            cosine_reg0 <= 18'sb110001100001100110;
            sine_reg0   <= 18'sb100011011101100010;
        end
        2767: begin
            cosine_reg0 <= 18'sb110001100100011001;
            sine_reg0   <= 18'sb100011011100000111;
        end
        2768: begin
            cosine_reg0 <= 18'sb110001100111001101;
            sine_reg0   <= 18'sb100011011010101100;
        end
        2769: begin
            cosine_reg0 <= 18'sb110001101010000001;
            sine_reg0   <= 18'sb100011011001010010;
        end
        2770: begin
            cosine_reg0 <= 18'sb110001101100110100;
            sine_reg0   <= 18'sb100011010111111000;
        end
        2771: begin
            cosine_reg0 <= 18'sb110001101111101000;
            sine_reg0   <= 18'sb100011010110011110;
        end
        2772: begin
            cosine_reg0 <= 18'sb110001110010011100;
            sine_reg0   <= 18'sb100011010101000101;
        end
        2773: begin
            cosine_reg0 <= 18'sb110001110101010001;
            sine_reg0   <= 18'sb100011010011101100;
        end
        2774: begin
            cosine_reg0 <= 18'sb110001111000000101;
            sine_reg0   <= 18'sb100011010010010011;
        end
        2775: begin
            cosine_reg0 <= 18'sb110001111010111010;
            sine_reg0   <= 18'sb100011010000111010;
        end
        2776: begin
            cosine_reg0 <= 18'sb110001111101101110;
            sine_reg0   <= 18'sb100011001111100010;
        end
        2777: begin
            cosine_reg0 <= 18'sb110010000000100011;
            sine_reg0   <= 18'sb100011001110001010;
        end
        2778: begin
            cosine_reg0 <= 18'sb110010000011011000;
            sine_reg0   <= 18'sb100011001100110010;
        end
        2779: begin
            cosine_reg0 <= 18'sb110010000110001101;
            sine_reg0   <= 18'sb100011001011011011;
        end
        2780: begin
            cosine_reg0 <= 18'sb110010001001000010;
            sine_reg0   <= 18'sb100011001010000011;
        end
        2781: begin
            cosine_reg0 <= 18'sb110010001011110111;
            sine_reg0   <= 18'sb100011001000101100;
        end
        2782: begin
            cosine_reg0 <= 18'sb110010001110101101;
            sine_reg0   <= 18'sb100011000111010110;
        end
        2783: begin
            cosine_reg0 <= 18'sb110010010001100010;
            sine_reg0   <= 18'sb100011000101111111;
        end
        2784: begin
            cosine_reg0 <= 18'sb110010010100011000;
            sine_reg0   <= 18'sb100011000100101001;
        end
        2785: begin
            cosine_reg0 <= 18'sb110010010111001110;
            sine_reg0   <= 18'sb100011000011010011;
        end
        2786: begin
            cosine_reg0 <= 18'sb110010011010000100;
            sine_reg0   <= 18'sb100011000001111110;
        end
        2787: begin
            cosine_reg0 <= 18'sb110010011100111010;
            sine_reg0   <= 18'sb100011000000101001;
        end
        2788: begin
            cosine_reg0 <= 18'sb110010011111110000;
            sine_reg0   <= 18'sb100010111111010100;
        end
        2789: begin
            cosine_reg0 <= 18'sb110010100010100110;
            sine_reg0   <= 18'sb100010111101111111;
        end
        2790: begin
            cosine_reg0 <= 18'sb110010100101011101;
            sine_reg0   <= 18'sb100010111100101010;
        end
        2791: begin
            cosine_reg0 <= 18'sb110010101000010011;
            sine_reg0   <= 18'sb100010111011010110;
        end
        2792: begin
            cosine_reg0 <= 18'sb110010101011001010;
            sine_reg0   <= 18'sb100010111010000010;
        end
        2793: begin
            cosine_reg0 <= 18'sb110010101110000001;
            sine_reg0   <= 18'sb100010111000101111;
        end
        2794: begin
            cosine_reg0 <= 18'sb110010110000111000;
            sine_reg0   <= 18'sb100010110111011100;
        end
        2795: begin
            cosine_reg0 <= 18'sb110010110011101111;
            sine_reg0   <= 18'sb100010110110001001;
        end
        2796: begin
            cosine_reg0 <= 18'sb110010110110100110;
            sine_reg0   <= 18'sb100010110100110110;
        end
        2797: begin
            cosine_reg0 <= 18'sb110010111001011110;
            sine_reg0   <= 18'sb100010110011100011;
        end
        2798: begin
            cosine_reg0 <= 18'sb110010111100010101;
            sine_reg0   <= 18'sb100010110010010001;
        end
        2799: begin
            cosine_reg0 <= 18'sb110010111111001101;
            sine_reg0   <= 18'sb100010110000111111;
        end
        2800: begin
            cosine_reg0 <= 18'sb110011000010000101;
            sine_reg0   <= 18'sb100010101111101110;
        end
        2801: begin
            cosine_reg0 <= 18'sb110011000100111100;
            sine_reg0   <= 18'sb100010101110011100;
        end
        2802: begin
            cosine_reg0 <= 18'sb110011000111110100;
            sine_reg0   <= 18'sb100010101101001011;
        end
        2803: begin
            cosine_reg0 <= 18'sb110011001010101101;
            sine_reg0   <= 18'sb100010101011111010;
        end
        2804: begin
            cosine_reg0 <= 18'sb110011001101100101;
            sine_reg0   <= 18'sb100010101010101010;
        end
        2805: begin
            cosine_reg0 <= 18'sb110011010000011101;
            sine_reg0   <= 18'sb100010101001011010;
        end
        2806: begin
            cosine_reg0 <= 18'sb110011010011010110;
            sine_reg0   <= 18'sb100010101000001010;
        end
        2807: begin
            cosine_reg0 <= 18'sb110011010110001110;
            sine_reg0   <= 18'sb100010100110111010;
        end
        2808: begin
            cosine_reg0 <= 18'sb110011011001000111;
            sine_reg0   <= 18'sb100010100101101011;
        end
        2809: begin
            cosine_reg0 <= 18'sb110011011100000000;
            sine_reg0   <= 18'sb100010100100011100;
        end
        2810: begin
            cosine_reg0 <= 18'sb110011011110111001;
            sine_reg0   <= 18'sb100010100011001101;
        end
        2811: begin
            cosine_reg0 <= 18'sb110011100001110010;
            sine_reg0   <= 18'sb100010100001111110;
        end
        2812: begin
            cosine_reg0 <= 18'sb110011100100101011;
            sine_reg0   <= 18'sb100010100000110000;
        end
        2813: begin
            cosine_reg0 <= 18'sb110011100111100101;
            sine_reg0   <= 18'sb100010011111100010;
        end
        2814: begin
            cosine_reg0 <= 18'sb110011101010011110;
            sine_reg0   <= 18'sb100010011110010101;
        end
        2815: begin
            cosine_reg0 <= 18'sb110011101101011000;
            sine_reg0   <= 18'sb100010011101000111;
        end
        2816: begin
            cosine_reg0 <= 18'sb110011110000010001;
            sine_reg0   <= 18'sb100010011011111010;
        end
        2817: begin
            cosine_reg0 <= 18'sb110011110011001011;
            sine_reg0   <= 18'sb100010011010101101;
        end
        2818: begin
            cosine_reg0 <= 18'sb110011110110000101;
            sine_reg0   <= 18'sb100010011001100001;
        end
        2819: begin
            cosine_reg0 <= 18'sb110011111000111111;
            sine_reg0   <= 18'sb100010011000010101;
        end
        2820: begin
            cosine_reg0 <= 18'sb110011111011111001;
            sine_reg0   <= 18'sb100010010111001001;
        end
        2821: begin
            cosine_reg0 <= 18'sb110011111110110100;
            sine_reg0   <= 18'sb100010010101111101;
        end
        2822: begin
            cosine_reg0 <= 18'sb110100000001101110;
            sine_reg0   <= 18'sb100010010100110010;
        end
        2823: begin
            cosine_reg0 <= 18'sb110100000100101000;
            sine_reg0   <= 18'sb100010010011100111;
        end
        2824: begin
            cosine_reg0 <= 18'sb110100000111100011;
            sine_reg0   <= 18'sb100010010010011100;
        end
        2825: begin
            cosine_reg0 <= 18'sb110100001010011110;
            sine_reg0   <= 18'sb100010010001010001;
        end
        2826: begin
            cosine_reg0 <= 18'sb110100001101011001;
            sine_reg0   <= 18'sb100010010000000111;
        end
        2827: begin
            cosine_reg0 <= 18'sb110100010000010100;
            sine_reg0   <= 18'sb100010001110111101;
        end
        2828: begin
            cosine_reg0 <= 18'sb110100010011001111;
            sine_reg0   <= 18'sb100010001101110011;
        end
        2829: begin
            cosine_reg0 <= 18'sb110100010110001010;
            sine_reg0   <= 18'sb100010001100101010;
        end
        2830: begin
            cosine_reg0 <= 18'sb110100011001000101;
            sine_reg0   <= 18'sb100010001011100001;
        end
        2831: begin
            cosine_reg0 <= 18'sb110100011100000001;
            sine_reg0   <= 18'sb100010001010011000;
        end
        2832: begin
            cosine_reg0 <= 18'sb110100011110111100;
            sine_reg0   <= 18'sb100010001001010000;
        end
        2833: begin
            cosine_reg0 <= 18'sb110100100001111000;
            sine_reg0   <= 18'sb100010001000000111;
        end
        2834: begin
            cosine_reg0 <= 18'sb110100100100110100;
            sine_reg0   <= 18'sb100010000111000000;
        end
        2835: begin
            cosine_reg0 <= 18'sb110100100111101111;
            sine_reg0   <= 18'sb100010000101111000;
        end
        2836: begin
            cosine_reg0 <= 18'sb110100101010101011;
            sine_reg0   <= 18'sb100010000100110001;
        end
        2837: begin
            cosine_reg0 <= 18'sb110100101101101000;
            sine_reg0   <= 18'sb100010000011101001;
        end
        2838: begin
            cosine_reg0 <= 18'sb110100110000100100;
            sine_reg0   <= 18'sb100010000010100011;
        end
        2839: begin
            cosine_reg0 <= 18'sb110100110011100000;
            sine_reg0   <= 18'sb100010000001011100;
        end
        2840: begin
            cosine_reg0 <= 18'sb110100110110011100;
            sine_reg0   <= 18'sb100010000000010110;
        end
        2841: begin
            cosine_reg0 <= 18'sb110100111001011001;
            sine_reg0   <= 18'sb100001111111010000;
        end
        2842: begin
            cosine_reg0 <= 18'sb110100111100010110;
            sine_reg0   <= 18'sb100001111110001011;
        end
        2843: begin
            cosine_reg0 <= 18'sb110100111111010010;
            sine_reg0   <= 18'sb100001111101000101;
        end
        2844: begin
            cosine_reg0 <= 18'sb110101000010001111;
            sine_reg0   <= 18'sb100001111100000000;
        end
        2845: begin
            cosine_reg0 <= 18'sb110101000101001100;
            sine_reg0   <= 18'sb100001111010111011;
        end
        2846: begin
            cosine_reg0 <= 18'sb110101001000001001;
            sine_reg0   <= 18'sb100001111001110111;
        end
        2847: begin
            cosine_reg0 <= 18'sb110101001011000110;
            sine_reg0   <= 18'sb100001111000110011;
        end
        2848: begin
            cosine_reg0 <= 18'sb110101001110000100;
            sine_reg0   <= 18'sb100001110111101111;
        end
        2849: begin
            cosine_reg0 <= 18'sb110101010001000001;
            sine_reg0   <= 18'sb100001110110101011;
        end
        2850: begin
            cosine_reg0 <= 18'sb110101010011111110;
            sine_reg0   <= 18'sb100001110101101000;
        end
        2851: begin
            cosine_reg0 <= 18'sb110101010110111100;
            sine_reg0   <= 18'sb100001110100100101;
        end
        2852: begin
            cosine_reg0 <= 18'sb110101011001111010;
            sine_reg0   <= 18'sb100001110011100010;
        end
        2853: begin
            cosine_reg0 <= 18'sb110101011100110111;
            sine_reg0   <= 18'sb100001110010100000;
        end
        2854: begin
            cosine_reg0 <= 18'sb110101011111110101;
            sine_reg0   <= 18'sb100001110001011110;
        end
        2855: begin
            cosine_reg0 <= 18'sb110101100010110011;
            sine_reg0   <= 18'sb100001110000011100;
        end
        2856: begin
            cosine_reg0 <= 18'sb110101100101110001;
            sine_reg0   <= 18'sb100001101111011010;
        end
        2857: begin
            cosine_reg0 <= 18'sb110101101000101111;
            sine_reg0   <= 18'sb100001101110011001;
        end
        2858: begin
            cosine_reg0 <= 18'sb110101101011101110;
            sine_reg0   <= 18'sb100001101101011000;
        end
        2859: begin
            cosine_reg0 <= 18'sb110101101110101100;
            sine_reg0   <= 18'sb100001101100010111;
        end
        2860: begin
            cosine_reg0 <= 18'sb110101110001101011;
            sine_reg0   <= 18'sb100001101011010111;
        end
        2861: begin
            cosine_reg0 <= 18'sb110101110100101001;
            sine_reg0   <= 18'sb100001101010010111;
        end
        2862: begin
            cosine_reg0 <= 18'sb110101110111101000;
            sine_reg0   <= 18'sb100001101001010111;
        end
        2863: begin
            cosine_reg0 <= 18'sb110101111010100111;
            sine_reg0   <= 18'sb100001101000011000;
        end
        2864: begin
            cosine_reg0 <= 18'sb110101111101100101;
            sine_reg0   <= 18'sb100001100111011000;
        end
        2865: begin
            cosine_reg0 <= 18'sb110110000000100100;
            sine_reg0   <= 18'sb100001100110011001;
        end
        2866: begin
            cosine_reg0 <= 18'sb110110000011100011;
            sine_reg0   <= 18'sb100001100101011011;
        end
        2867: begin
            cosine_reg0 <= 18'sb110110000110100011;
            sine_reg0   <= 18'sb100001100100011101;
        end
        2868: begin
            cosine_reg0 <= 18'sb110110001001100010;
            sine_reg0   <= 18'sb100001100011011110;
        end
        2869: begin
            cosine_reg0 <= 18'sb110110001100100001;
            sine_reg0   <= 18'sb100001100010100001;
        end
        2870: begin
            cosine_reg0 <= 18'sb110110001111100001;
            sine_reg0   <= 18'sb100001100001100011;
        end
        2871: begin
            cosine_reg0 <= 18'sb110110010010100000;
            sine_reg0   <= 18'sb100001100000100110;
        end
        2872: begin
            cosine_reg0 <= 18'sb110110010101100000;
            sine_reg0   <= 18'sb100001011111101001;
        end
        2873: begin
            cosine_reg0 <= 18'sb110110011000011111;
            sine_reg0   <= 18'sb100001011110101101;
        end
        2874: begin
            cosine_reg0 <= 18'sb110110011011011111;
            sine_reg0   <= 18'sb100001011101110000;
        end
        2875: begin
            cosine_reg0 <= 18'sb110110011110011111;
            sine_reg0   <= 18'sb100001011100110100;
        end
        2876: begin
            cosine_reg0 <= 18'sb110110100001011111;
            sine_reg0   <= 18'sb100001011011111001;
        end
        2877: begin
            cosine_reg0 <= 18'sb110110100100011111;
            sine_reg0   <= 18'sb100001011010111101;
        end
        2878: begin
            cosine_reg0 <= 18'sb110110100111011111;
            sine_reg0   <= 18'sb100001011010000010;
        end
        2879: begin
            cosine_reg0 <= 18'sb110110101010100000;
            sine_reg0   <= 18'sb100001011001000111;
        end
        2880: begin
            cosine_reg0 <= 18'sb110110101101100000;
            sine_reg0   <= 18'sb100001011000001101;
        end
        2881: begin
            cosine_reg0 <= 18'sb110110110000100001;
            sine_reg0   <= 18'sb100001010111010011;
        end
        2882: begin
            cosine_reg0 <= 18'sb110110110011100001;
            sine_reg0   <= 18'sb100001010110011001;
        end
        2883: begin
            cosine_reg0 <= 18'sb110110110110100010;
            sine_reg0   <= 18'sb100001010101011111;
        end
        2884: begin
            cosine_reg0 <= 18'sb110110111001100010;
            sine_reg0   <= 18'sb100001010100100110;
        end
        2885: begin
            cosine_reg0 <= 18'sb110110111100100011;
            sine_reg0   <= 18'sb100001010011101101;
        end
        2886: begin
            cosine_reg0 <= 18'sb110110111111100100;
            sine_reg0   <= 18'sb100001010010110100;
        end
        2887: begin
            cosine_reg0 <= 18'sb110111000010100101;
            sine_reg0   <= 18'sb100001010001111100;
        end
        2888: begin
            cosine_reg0 <= 18'sb110111000101100110;
            sine_reg0   <= 18'sb100001010001000011;
        end
        2889: begin
            cosine_reg0 <= 18'sb110111001000100111;
            sine_reg0   <= 18'sb100001010000001100;
        end
        2890: begin
            cosine_reg0 <= 18'sb110111001011101001;
            sine_reg0   <= 18'sb100001001111010100;
        end
        2891: begin
            cosine_reg0 <= 18'sb110111001110101010;
            sine_reg0   <= 18'sb100001001110011101;
        end
        2892: begin
            cosine_reg0 <= 18'sb110111010001101011;
            sine_reg0   <= 18'sb100001001101100110;
        end
        2893: begin
            cosine_reg0 <= 18'sb110111010100101101;
            sine_reg0   <= 18'sb100001001100101111;
        end
        2894: begin
            cosine_reg0 <= 18'sb110111010111101110;
            sine_reg0   <= 18'sb100001001011111001;
        end
        2895: begin
            cosine_reg0 <= 18'sb110111011010110000;
            sine_reg0   <= 18'sb100001001011000011;
        end
        2896: begin
            cosine_reg0 <= 18'sb110111011101110010;
            sine_reg0   <= 18'sb100001001010001101;
        end
        2897: begin
            cosine_reg0 <= 18'sb110111100000110100;
            sine_reg0   <= 18'sb100001001001010111;
        end
        2898: begin
            cosine_reg0 <= 18'sb110111100011110101;
            sine_reg0   <= 18'sb100001001000100010;
        end
        2899: begin
            cosine_reg0 <= 18'sb110111100110110111;
            sine_reg0   <= 18'sb100001000111101101;
        end
        2900: begin
            cosine_reg0 <= 18'sb110111101001111001;
            sine_reg0   <= 18'sb100001000110111001;
        end
        2901: begin
            cosine_reg0 <= 18'sb110111101100111100;
            sine_reg0   <= 18'sb100001000110000100;
        end
        2902: begin
            cosine_reg0 <= 18'sb110111101111111110;
            sine_reg0   <= 18'sb100001000101010001;
        end
        2903: begin
            cosine_reg0 <= 18'sb110111110011000000;
            sine_reg0   <= 18'sb100001000100011101;
        end
        2904: begin
            cosine_reg0 <= 18'sb110111110110000011;
            sine_reg0   <= 18'sb100001000011101001;
        end
        2905: begin
            cosine_reg0 <= 18'sb110111111001000101;
            sine_reg0   <= 18'sb100001000010110110;
        end
        2906: begin
            cosine_reg0 <= 18'sb110111111100001000;
            sine_reg0   <= 18'sb100001000010000100;
        end
        2907: begin
            cosine_reg0 <= 18'sb110111111111001010;
            sine_reg0   <= 18'sb100001000001010001;
        end
        2908: begin
            cosine_reg0 <= 18'sb111000000010001101;
            sine_reg0   <= 18'sb100001000000011111;
        end
        2909: begin
            cosine_reg0 <= 18'sb111000000101010000;
            sine_reg0   <= 18'sb100000111111101101;
        end
        2910: begin
            cosine_reg0 <= 18'sb111000001000010010;
            sine_reg0   <= 18'sb100000111110111011;
        end
        2911: begin
            cosine_reg0 <= 18'sb111000001011010101;
            sine_reg0   <= 18'sb100000111110001010;
        end
        2912: begin
            cosine_reg0 <= 18'sb111000001110011000;
            sine_reg0   <= 18'sb100000111101011001;
        end
        2913: begin
            cosine_reg0 <= 18'sb111000010001011011;
            sine_reg0   <= 18'sb100000111100101000;
        end
        2914: begin
            cosine_reg0 <= 18'sb111000010100011111;
            sine_reg0   <= 18'sb100000111011111000;
        end
        2915: begin
            cosine_reg0 <= 18'sb111000010111100010;
            sine_reg0   <= 18'sb100000111011001000;
        end
        2916: begin
            cosine_reg0 <= 18'sb111000011010100101;
            sine_reg0   <= 18'sb100000111010011000;
        end
        2917: begin
            cosine_reg0 <= 18'sb111000011101101000;
            sine_reg0   <= 18'sb100000111001101001;
        end
        2918: begin
            cosine_reg0 <= 18'sb111000100000101100;
            sine_reg0   <= 18'sb100000111000111001;
        end
        2919: begin
            cosine_reg0 <= 18'sb111000100011101111;
            sine_reg0   <= 18'sb100000111000001010;
        end
        2920: begin
            cosine_reg0 <= 18'sb111000100110110011;
            sine_reg0   <= 18'sb100000110111011100;
        end
        2921: begin
            cosine_reg0 <= 18'sb111000101001110111;
            sine_reg0   <= 18'sb100000110110101101;
        end
        2922: begin
            cosine_reg0 <= 18'sb111000101100111010;
            sine_reg0   <= 18'sb100000110101111111;
        end
        2923: begin
            cosine_reg0 <= 18'sb111000101111111110;
            sine_reg0   <= 18'sb100000110101010010;
        end
        2924: begin
            cosine_reg0 <= 18'sb111000110011000010;
            sine_reg0   <= 18'sb100000110100100100;
        end
        2925: begin
            cosine_reg0 <= 18'sb111000110110000110;
            sine_reg0   <= 18'sb100000110011110111;
        end
        2926: begin
            cosine_reg0 <= 18'sb111000111001001010;
            sine_reg0   <= 18'sb100000110011001010;
        end
        2927: begin
            cosine_reg0 <= 18'sb111000111100001110;
            sine_reg0   <= 18'sb100000110010011110;
        end
        2928: begin
            cosine_reg0 <= 18'sb111000111111010010;
            sine_reg0   <= 18'sb100000110001110010;
        end
        2929: begin
            cosine_reg0 <= 18'sb111001000010010110;
            sine_reg0   <= 18'sb100000110001000110;
        end
        2930: begin
            cosine_reg0 <= 18'sb111001000101011011;
            sine_reg0   <= 18'sb100000110000011010;
        end
        2931: begin
            cosine_reg0 <= 18'sb111001001000011111;
            sine_reg0   <= 18'sb100000101111101111;
        end
        2932: begin
            cosine_reg0 <= 18'sb111001001011100011;
            sine_reg0   <= 18'sb100000101111000100;
        end
        2933: begin
            cosine_reg0 <= 18'sb111001001110101000;
            sine_reg0   <= 18'sb100000101110011001;
        end
        2934: begin
            cosine_reg0 <= 18'sb111001010001101100;
            sine_reg0   <= 18'sb100000101101101111;
        end
        2935: begin
            cosine_reg0 <= 18'sb111001010100110001;
            sine_reg0   <= 18'sb100000101101000101;
        end
        2936: begin
            cosine_reg0 <= 18'sb111001010111110110;
            sine_reg0   <= 18'sb100000101100011011;
        end
        2937: begin
            cosine_reg0 <= 18'sb111001011010111010;
            sine_reg0   <= 18'sb100000101011110001;
        end
        2938: begin
            cosine_reg0 <= 18'sb111001011101111111;
            sine_reg0   <= 18'sb100000101011001000;
        end
        2939: begin
            cosine_reg0 <= 18'sb111001100001000100;
            sine_reg0   <= 18'sb100000101010011111;
        end
        2940: begin
            cosine_reg0 <= 18'sb111001100100001001;
            sine_reg0   <= 18'sb100000101001110111;
        end
        2941: begin
            cosine_reg0 <= 18'sb111001100111001110;
            sine_reg0   <= 18'sb100000101001001111;
        end
        2942: begin
            cosine_reg0 <= 18'sb111001101010010011;
            sine_reg0   <= 18'sb100000101000100111;
        end
        2943: begin
            cosine_reg0 <= 18'sb111001101101011000;
            sine_reg0   <= 18'sb100000100111111111;
        end
        2944: begin
            cosine_reg0 <= 18'sb111001110000011101;
            sine_reg0   <= 18'sb100000100111010111;
        end
        2945: begin
            cosine_reg0 <= 18'sb111001110011100011;
            sine_reg0   <= 18'sb100000100110110000;
        end
        2946: begin
            cosine_reg0 <= 18'sb111001110110101000;
            sine_reg0   <= 18'sb100000100110001010;
        end
        2947: begin
            cosine_reg0 <= 18'sb111001111001101101;
            sine_reg0   <= 18'sb100000100101100011;
        end
        2948: begin
            cosine_reg0 <= 18'sb111001111100110011;
            sine_reg0   <= 18'sb100000100100111101;
        end
        2949: begin
            cosine_reg0 <= 18'sb111001111111111000;
            sine_reg0   <= 18'sb100000100100010111;
        end
        2950: begin
            cosine_reg0 <= 18'sb111010000010111110;
            sine_reg0   <= 18'sb100000100011110010;
        end
        2951: begin
            cosine_reg0 <= 18'sb111010000110000011;
            sine_reg0   <= 18'sb100000100011001100;
        end
        2952: begin
            cosine_reg0 <= 18'sb111010001001001001;
            sine_reg0   <= 18'sb100000100010100111;
        end
        2953: begin
            cosine_reg0 <= 18'sb111010001100001110;
            sine_reg0   <= 18'sb100000100010000011;
        end
        2954: begin
            cosine_reg0 <= 18'sb111010001111010100;
            sine_reg0   <= 18'sb100000100001011110;
        end
        2955: begin
            cosine_reg0 <= 18'sb111010010010011010;
            sine_reg0   <= 18'sb100000100000111010;
        end
        2956: begin
            cosine_reg0 <= 18'sb111010010101100000;
            sine_reg0   <= 18'sb100000100000010111;
        end
        2957: begin
            cosine_reg0 <= 18'sb111010011000100110;
            sine_reg0   <= 18'sb100000011111110011;
        end
        2958: begin
            cosine_reg0 <= 18'sb111010011011101100;
            sine_reg0   <= 18'sb100000011111010000;
        end
        2959: begin
            cosine_reg0 <= 18'sb111010011110110010;
            sine_reg0   <= 18'sb100000011110101101;
        end
        2960: begin
            cosine_reg0 <= 18'sb111010100001111000;
            sine_reg0   <= 18'sb100000011110001011;
        end
        2961: begin
            cosine_reg0 <= 18'sb111010100100111110;
            sine_reg0   <= 18'sb100000011101101000;
        end
        2962: begin
            cosine_reg0 <= 18'sb111010101000000100;
            sine_reg0   <= 18'sb100000011101000111;
        end
        2963: begin
            cosine_reg0 <= 18'sb111010101011001010;
            sine_reg0   <= 18'sb100000011100100101;
        end
        2964: begin
            cosine_reg0 <= 18'sb111010101110010001;
            sine_reg0   <= 18'sb100000011100000100;
        end
        2965: begin
            cosine_reg0 <= 18'sb111010110001010111;
            sine_reg0   <= 18'sb100000011011100011;
        end
        2966: begin
            cosine_reg0 <= 18'sb111010110100011101;
            sine_reg0   <= 18'sb100000011011000010;
        end
        2967: begin
            cosine_reg0 <= 18'sb111010110111100100;
            sine_reg0   <= 18'sb100000011010100010;
        end
        2968: begin
            cosine_reg0 <= 18'sb111010111010101010;
            sine_reg0   <= 18'sb100000011010000001;
        end
        2969: begin
            cosine_reg0 <= 18'sb111010111101110001;
            sine_reg0   <= 18'sb100000011001100010;
        end
        2970: begin
            cosine_reg0 <= 18'sb111011000000110111;
            sine_reg0   <= 18'sb100000011001000010;
        end
        2971: begin
            cosine_reg0 <= 18'sb111011000011111110;
            sine_reg0   <= 18'sb100000011000100011;
        end
        2972: begin
            cosine_reg0 <= 18'sb111011000111000101;
            sine_reg0   <= 18'sb100000011000000100;
        end
        2973: begin
            cosine_reg0 <= 18'sb111011001010001011;
            sine_reg0   <= 18'sb100000010111100110;
        end
        2974: begin
            cosine_reg0 <= 18'sb111011001101010010;
            sine_reg0   <= 18'sb100000010111000111;
        end
        2975: begin
            cosine_reg0 <= 18'sb111011010000011001;
            sine_reg0   <= 18'sb100000010110101001;
        end
        2976: begin
            cosine_reg0 <= 18'sb111011010011100000;
            sine_reg0   <= 18'sb100000010110001100;
        end
        2977: begin
            cosine_reg0 <= 18'sb111011010110100111;
            sine_reg0   <= 18'sb100000010101101110;
        end
        2978: begin
            cosine_reg0 <= 18'sb111011011001101110;
            sine_reg0   <= 18'sb100000010101010001;
        end
        2979: begin
            cosine_reg0 <= 18'sb111011011100110101;
            sine_reg0   <= 18'sb100000010100110101;
        end
        2980: begin
            cosine_reg0 <= 18'sb111011011111111100;
            sine_reg0   <= 18'sb100000010100011000;
        end
        2981: begin
            cosine_reg0 <= 18'sb111011100011000011;
            sine_reg0   <= 18'sb100000010011111100;
        end
        2982: begin
            cosine_reg0 <= 18'sb111011100110001010;
            sine_reg0   <= 18'sb100000010011100000;
        end
        2983: begin
            cosine_reg0 <= 18'sb111011101001010001;
            sine_reg0   <= 18'sb100000010011000101;
        end
        2984: begin
            cosine_reg0 <= 18'sb111011101100011000;
            sine_reg0   <= 18'sb100000010010101001;
        end
        2985: begin
            cosine_reg0 <= 18'sb111011101111100000;
            sine_reg0   <= 18'sb100000010010001110;
        end
        2986: begin
            cosine_reg0 <= 18'sb111011110010100111;
            sine_reg0   <= 18'sb100000010001110100;
        end
        2987: begin
            cosine_reg0 <= 18'sb111011110101101110;
            sine_reg0   <= 18'sb100000010001011010;
        end
        2988: begin
            cosine_reg0 <= 18'sb111011111000110110;
            sine_reg0   <= 18'sb100000010001000000;
        end
        2989: begin
            cosine_reg0 <= 18'sb111011111011111101;
            sine_reg0   <= 18'sb100000010000100110;
        end
        2990: begin
            cosine_reg0 <= 18'sb111011111111000100;
            sine_reg0   <= 18'sb100000010000001101;
        end
        2991: begin
            cosine_reg0 <= 18'sb111100000010001100;
            sine_reg0   <= 18'sb100000001111110011;
        end
        2992: begin
            cosine_reg0 <= 18'sb111100000101010100;
            sine_reg0   <= 18'sb100000001111011011;
        end
        2993: begin
            cosine_reg0 <= 18'sb111100001000011011;
            sine_reg0   <= 18'sb100000001111000010;
        end
        2994: begin
            cosine_reg0 <= 18'sb111100001011100011;
            sine_reg0   <= 18'sb100000001110101010;
        end
        2995: begin
            cosine_reg0 <= 18'sb111100001110101010;
            sine_reg0   <= 18'sb100000001110010010;
        end
        2996: begin
            cosine_reg0 <= 18'sb111100010001110010;
            sine_reg0   <= 18'sb100000001101111011;
        end
        2997: begin
            cosine_reg0 <= 18'sb111100010100111010;
            sine_reg0   <= 18'sb100000001101100011;
        end
        2998: begin
            cosine_reg0 <= 18'sb111100011000000001;
            sine_reg0   <= 18'sb100000001101001101;
        end
        2999: begin
            cosine_reg0 <= 18'sb111100011011001001;
            sine_reg0   <= 18'sb100000001100110110;
        end
        3000: begin
            cosine_reg0 <= 18'sb111100011110010001;
            sine_reg0   <= 18'sb100000001100100000;
        end
        3001: begin
            cosine_reg0 <= 18'sb111100100001011001;
            sine_reg0   <= 18'sb100000001100001010;
        end
        3002: begin
            cosine_reg0 <= 18'sb111100100100100001;
            sine_reg0   <= 18'sb100000001011110100;
        end
        3003: begin
            cosine_reg0 <= 18'sb111100100111101001;
            sine_reg0   <= 18'sb100000001011011111;
        end
        3004: begin
            cosine_reg0 <= 18'sb111100101010110001;
            sine_reg0   <= 18'sb100000001011001001;
        end
        3005: begin
            cosine_reg0 <= 18'sb111100101101111001;
            sine_reg0   <= 18'sb100000001010110101;
        end
        3006: begin
            cosine_reg0 <= 18'sb111100110001000001;
            sine_reg0   <= 18'sb100000001010100000;
        end
        3007: begin
            cosine_reg0 <= 18'sb111100110100001001;
            sine_reg0   <= 18'sb100000001010001100;
        end
        3008: begin
            cosine_reg0 <= 18'sb111100110111010001;
            sine_reg0   <= 18'sb100000001001111000;
        end
        3009: begin
            cosine_reg0 <= 18'sb111100111010011001;
            sine_reg0   <= 18'sb100000001001100101;
        end
        3010: begin
            cosine_reg0 <= 18'sb111100111101100001;
            sine_reg0   <= 18'sb100000001001010001;
        end
        3011: begin
            cosine_reg0 <= 18'sb111101000000101001;
            sine_reg0   <= 18'sb100000001000111110;
        end
        3012: begin
            cosine_reg0 <= 18'sb111101000011110001;
            sine_reg0   <= 18'sb100000001000101100;
        end
        3013: begin
            cosine_reg0 <= 18'sb111101000110111010;
            sine_reg0   <= 18'sb100000001000011001;
        end
        3014: begin
            cosine_reg0 <= 18'sb111101001010000010;
            sine_reg0   <= 18'sb100000001000000111;
        end
        3015: begin
            cosine_reg0 <= 18'sb111101001101001010;
            sine_reg0   <= 18'sb100000000111110110;
        end
        3016: begin
            cosine_reg0 <= 18'sb111101010000010010;
            sine_reg0   <= 18'sb100000000111100100;
        end
        3017: begin
            cosine_reg0 <= 18'sb111101010011011011;
            sine_reg0   <= 18'sb100000000111010011;
        end
        3018: begin
            cosine_reg0 <= 18'sb111101010110100011;
            sine_reg0   <= 18'sb100000000111000010;
        end
        3019: begin
            cosine_reg0 <= 18'sb111101011001101100;
            sine_reg0   <= 18'sb100000000110110010;
        end
        3020: begin
            cosine_reg0 <= 18'sb111101011100110100;
            sine_reg0   <= 18'sb100000000110100010;
        end
        3021: begin
            cosine_reg0 <= 18'sb111101011111111100;
            sine_reg0   <= 18'sb100000000110010010;
        end
        3022: begin
            cosine_reg0 <= 18'sb111101100011000101;
            sine_reg0   <= 18'sb100000000110000010;
        end
        3023: begin
            cosine_reg0 <= 18'sb111101100110001101;
            sine_reg0   <= 18'sb100000000101110011;
        end
        3024: begin
            cosine_reg0 <= 18'sb111101101001010110;
            sine_reg0   <= 18'sb100000000101100100;
        end
        3025: begin
            cosine_reg0 <= 18'sb111101101100011110;
            sine_reg0   <= 18'sb100000000101010110;
        end
        3026: begin
            cosine_reg0 <= 18'sb111101101111100111;
            sine_reg0   <= 18'sb100000000101000111;
        end
        3027: begin
            cosine_reg0 <= 18'sb111101110010101111;
            sine_reg0   <= 18'sb100000000100111001;
        end
        3028: begin
            cosine_reg0 <= 18'sb111101110101111000;
            sine_reg0   <= 18'sb100000000100101011;
        end
        3029: begin
            cosine_reg0 <= 18'sb111101111001000001;
            sine_reg0   <= 18'sb100000000100011110;
        end
        3030: begin
            cosine_reg0 <= 18'sb111101111100001001;
            sine_reg0   <= 18'sb100000000100010001;
        end
        3031: begin
            cosine_reg0 <= 18'sb111101111111010010;
            sine_reg0   <= 18'sb100000000100000100;
        end
        3032: begin
            cosine_reg0 <= 18'sb111110000010011011;
            sine_reg0   <= 18'sb100000000011111000;
        end
        3033: begin
            cosine_reg0 <= 18'sb111110000101100011;
            sine_reg0   <= 18'sb100000000011101011;
        end
        3034: begin
            cosine_reg0 <= 18'sb111110001000101100;
            sine_reg0   <= 18'sb100000000011100000;
        end
        3035: begin
            cosine_reg0 <= 18'sb111110001011110101;
            sine_reg0   <= 18'sb100000000011010100;
        end
        3036: begin
            cosine_reg0 <= 18'sb111110001110111110;
            sine_reg0   <= 18'sb100000000011001001;
        end
        3037: begin
            cosine_reg0 <= 18'sb111110010010000110;
            sine_reg0   <= 18'sb100000000010111110;
        end
        3038: begin
            cosine_reg0 <= 18'sb111110010101001111;
            sine_reg0   <= 18'sb100000000010110011;
        end
        3039: begin
            cosine_reg0 <= 18'sb111110011000011000;
            sine_reg0   <= 18'sb100000000010101001;
        end
        3040: begin
            cosine_reg0 <= 18'sb111110011011100001;
            sine_reg0   <= 18'sb100000000010011111;
        end
        3041: begin
            cosine_reg0 <= 18'sb111110011110101001;
            sine_reg0   <= 18'sb100000000010010101;
        end
        3042: begin
            cosine_reg0 <= 18'sb111110100001110010;
            sine_reg0   <= 18'sb100000000010001100;
        end
        3043: begin
            cosine_reg0 <= 18'sb111110100100111011;
            sine_reg0   <= 18'sb100000000010000011;
        end
        3044: begin
            cosine_reg0 <= 18'sb111110101000000100;
            sine_reg0   <= 18'sb100000000001111010;
        end
        3045: begin
            cosine_reg0 <= 18'sb111110101011001101;
            sine_reg0   <= 18'sb100000000001110001;
        end
        3046: begin
            cosine_reg0 <= 18'sb111110101110010110;
            sine_reg0   <= 18'sb100000000001101001;
        end
        3047: begin
            cosine_reg0 <= 18'sb111110110001011111;
            sine_reg0   <= 18'sb100000000001100001;
        end
        3048: begin
            cosine_reg0 <= 18'sb111110110100101000;
            sine_reg0   <= 18'sb100000000001011010;
        end
        3049: begin
            cosine_reg0 <= 18'sb111110110111110001;
            sine_reg0   <= 18'sb100000000001010011;
        end
        3050: begin
            cosine_reg0 <= 18'sb111110111010111010;
            sine_reg0   <= 18'sb100000000001001100;
        end
        3051: begin
            cosine_reg0 <= 18'sb111110111110000010;
            sine_reg0   <= 18'sb100000000001000101;
        end
        3052: begin
            cosine_reg0 <= 18'sb111111000001001011;
            sine_reg0   <= 18'sb100000000000111111;
        end
        3053: begin
            cosine_reg0 <= 18'sb111111000100010100;
            sine_reg0   <= 18'sb100000000000111001;
        end
        3054: begin
            cosine_reg0 <= 18'sb111111000111011101;
            sine_reg0   <= 18'sb100000000000110011;
        end
        3055: begin
            cosine_reg0 <= 18'sb111111001010100110;
            sine_reg0   <= 18'sb100000000000101110;
        end
        3056: begin
            cosine_reg0 <= 18'sb111111001101101111;
            sine_reg0   <= 18'sb100000000000101000;
        end
        3057: begin
            cosine_reg0 <= 18'sb111111010000111000;
            sine_reg0   <= 18'sb100000000000100100;
        end
        3058: begin
            cosine_reg0 <= 18'sb111111010100000001;
            sine_reg0   <= 18'sb100000000000011111;
        end
        3059: begin
            cosine_reg0 <= 18'sb111111010111001010;
            sine_reg0   <= 18'sb100000000000011011;
        end
        3060: begin
            cosine_reg0 <= 18'sb111111011010010011;
            sine_reg0   <= 18'sb100000000000010111;
        end
        3061: begin
            cosine_reg0 <= 18'sb111111011101011100;
            sine_reg0   <= 18'sb100000000000010100;
        end
        3062: begin
            cosine_reg0 <= 18'sb111111100000100101;
            sine_reg0   <= 18'sb100000000000010000;
        end
        3063: begin
            cosine_reg0 <= 18'sb111111100011101111;
            sine_reg0   <= 18'sb100000000000001101;
        end
        3064: begin
            cosine_reg0 <= 18'sb111111100110111000;
            sine_reg0   <= 18'sb100000000000001011;
        end
        3065: begin
            cosine_reg0 <= 18'sb111111101010000001;
            sine_reg0   <= 18'sb100000000000001001;
        end
        3066: begin
            cosine_reg0 <= 18'sb111111101101001010;
            sine_reg0   <= 18'sb100000000000000111;
        end
        3067: begin
            cosine_reg0 <= 18'sb111111110000010011;
            sine_reg0   <= 18'sb100000000000000101;
        end
        3068: begin
            cosine_reg0 <= 18'sb111111110011011100;
            sine_reg0   <= 18'sb100000000000000011;
        end
        3069: begin
            cosine_reg0 <= 18'sb111111110110100101;
            sine_reg0   <= 18'sb100000000000000010;
        end
        3070: begin
            cosine_reg0 <= 18'sb111111111001101110;
            sine_reg0   <= 18'sb100000000000000010;
        end
        3071: begin
            cosine_reg0 <= 18'sb111111111100110111;
            sine_reg0   <= 18'sb100000000000000001;
        end
        3072: begin
            cosine_reg0 <= 18'sb000000000000000000;
            sine_reg0   <= 18'sb100000000000000001;
        end
        3073: begin
            cosine_reg0 <= 18'sb000000000011001001;
            sine_reg0   <= 18'sb100000000000000001;
        end
        3074: begin
            cosine_reg0 <= 18'sb000000000110010010;
            sine_reg0   <= 18'sb100000000000000010;
        end
        3075: begin
            cosine_reg0 <= 18'sb000000001001011011;
            sine_reg0   <= 18'sb100000000000000010;
        end
        3076: begin
            cosine_reg0 <= 18'sb000000001100100100;
            sine_reg0   <= 18'sb100000000000000011;
        end
        3077: begin
            cosine_reg0 <= 18'sb000000001111101101;
            sine_reg0   <= 18'sb100000000000000101;
        end
        3078: begin
            cosine_reg0 <= 18'sb000000010010110110;
            sine_reg0   <= 18'sb100000000000000111;
        end
        3079: begin
            cosine_reg0 <= 18'sb000000010101111111;
            sine_reg0   <= 18'sb100000000000001001;
        end
        3080: begin
            cosine_reg0 <= 18'sb000000011001001000;
            sine_reg0   <= 18'sb100000000000001011;
        end
        3081: begin
            cosine_reg0 <= 18'sb000000011100010001;
            sine_reg0   <= 18'sb100000000000001101;
        end
        3082: begin
            cosine_reg0 <= 18'sb000000011111011011;
            sine_reg0   <= 18'sb100000000000010000;
        end
        3083: begin
            cosine_reg0 <= 18'sb000000100010100100;
            sine_reg0   <= 18'sb100000000000010100;
        end
        3084: begin
            cosine_reg0 <= 18'sb000000100101101101;
            sine_reg0   <= 18'sb100000000000010111;
        end
        3085: begin
            cosine_reg0 <= 18'sb000000101000110110;
            sine_reg0   <= 18'sb100000000000011011;
        end
        3086: begin
            cosine_reg0 <= 18'sb000000101011111111;
            sine_reg0   <= 18'sb100000000000011111;
        end
        3087: begin
            cosine_reg0 <= 18'sb000000101111001000;
            sine_reg0   <= 18'sb100000000000100100;
        end
        3088: begin
            cosine_reg0 <= 18'sb000000110010010001;
            sine_reg0   <= 18'sb100000000000101000;
        end
        3089: begin
            cosine_reg0 <= 18'sb000000110101011010;
            sine_reg0   <= 18'sb100000000000101110;
        end
        3090: begin
            cosine_reg0 <= 18'sb000000111000100011;
            sine_reg0   <= 18'sb100000000000110011;
        end
        3091: begin
            cosine_reg0 <= 18'sb000000111011101100;
            sine_reg0   <= 18'sb100000000000111001;
        end
        3092: begin
            cosine_reg0 <= 18'sb000000111110110101;
            sine_reg0   <= 18'sb100000000000111111;
        end
        3093: begin
            cosine_reg0 <= 18'sb000001000001111110;
            sine_reg0   <= 18'sb100000000001000101;
        end
        3094: begin
            cosine_reg0 <= 18'sb000001000101000110;
            sine_reg0   <= 18'sb100000000001001100;
        end
        3095: begin
            cosine_reg0 <= 18'sb000001001000001111;
            sine_reg0   <= 18'sb100000000001010011;
        end
        3096: begin
            cosine_reg0 <= 18'sb000001001011011000;
            sine_reg0   <= 18'sb100000000001011010;
        end
        3097: begin
            cosine_reg0 <= 18'sb000001001110100001;
            sine_reg0   <= 18'sb100000000001100001;
        end
        3098: begin
            cosine_reg0 <= 18'sb000001010001101010;
            sine_reg0   <= 18'sb100000000001101001;
        end
        3099: begin
            cosine_reg0 <= 18'sb000001010100110011;
            sine_reg0   <= 18'sb100000000001110001;
        end
        3100: begin
            cosine_reg0 <= 18'sb000001010111111100;
            sine_reg0   <= 18'sb100000000001111010;
        end
        3101: begin
            cosine_reg0 <= 18'sb000001011011000101;
            sine_reg0   <= 18'sb100000000010000011;
        end
        3102: begin
            cosine_reg0 <= 18'sb000001011110001110;
            sine_reg0   <= 18'sb100000000010001100;
        end
        3103: begin
            cosine_reg0 <= 18'sb000001100001010111;
            sine_reg0   <= 18'sb100000000010010101;
        end
        3104: begin
            cosine_reg0 <= 18'sb000001100100011111;
            sine_reg0   <= 18'sb100000000010011111;
        end
        3105: begin
            cosine_reg0 <= 18'sb000001100111101000;
            sine_reg0   <= 18'sb100000000010101001;
        end
        3106: begin
            cosine_reg0 <= 18'sb000001101010110001;
            sine_reg0   <= 18'sb100000000010110011;
        end
        3107: begin
            cosine_reg0 <= 18'sb000001101101111010;
            sine_reg0   <= 18'sb100000000010111110;
        end
        3108: begin
            cosine_reg0 <= 18'sb000001110001000010;
            sine_reg0   <= 18'sb100000000011001001;
        end
        3109: begin
            cosine_reg0 <= 18'sb000001110100001011;
            sine_reg0   <= 18'sb100000000011010100;
        end
        3110: begin
            cosine_reg0 <= 18'sb000001110111010100;
            sine_reg0   <= 18'sb100000000011100000;
        end
        3111: begin
            cosine_reg0 <= 18'sb000001111010011101;
            sine_reg0   <= 18'sb100000000011101011;
        end
        3112: begin
            cosine_reg0 <= 18'sb000001111101100101;
            sine_reg0   <= 18'sb100000000011111000;
        end
        3113: begin
            cosine_reg0 <= 18'sb000010000000101110;
            sine_reg0   <= 18'sb100000000100000100;
        end
        3114: begin
            cosine_reg0 <= 18'sb000010000011110111;
            sine_reg0   <= 18'sb100000000100010001;
        end
        3115: begin
            cosine_reg0 <= 18'sb000010000110111111;
            sine_reg0   <= 18'sb100000000100011110;
        end
        3116: begin
            cosine_reg0 <= 18'sb000010001010001000;
            sine_reg0   <= 18'sb100000000100101011;
        end
        3117: begin
            cosine_reg0 <= 18'sb000010001101010001;
            sine_reg0   <= 18'sb100000000100111001;
        end
        3118: begin
            cosine_reg0 <= 18'sb000010010000011001;
            sine_reg0   <= 18'sb100000000101000111;
        end
        3119: begin
            cosine_reg0 <= 18'sb000010010011100010;
            sine_reg0   <= 18'sb100000000101010110;
        end
        3120: begin
            cosine_reg0 <= 18'sb000010010110101010;
            sine_reg0   <= 18'sb100000000101100100;
        end
        3121: begin
            cosine_reg0 <= 18'sb000010011001110011;
            sine_reg0   <= 18'sb100000000101110011;
        end
        3122: begin
            cosine_reg0 <= 18'sb000010011100111011;
            sine_reg0   <= 18'sb100000000110000010;
        end
        3123: begin
            cosine_reg0 <= 18'sb000010100000000100;
            sine_reg0   <= 18'sb100000000110010010;
        end
        3124: begin
            cosine_reg0 <= 18'sb000010100011001100;
            sine_reg0   <= 18'sb100000000110100010;
        end
        3125: begin
            cosine_reg0 <= 18'sb000010100110010100;
            sine_reg0   <= 18'sb100000000110110010;
        end
        3126: begin
            cosine_reg0 <= 18'sb000010101001011101;
            sine_reg0   <= 18'sb100000000111000010;
        end
        3127: begin
            cosine_reg0 <= 18'sb000010101100100101;
            sine_reg0   <= 18'sb100000000111010011;
        end
        3128: begin
            cosine_reg0 <= 18'sb000010101111101110;
            sine_reg0   <= 18'sb100000000111100100;
        end
        3129: begin
            cosine_reg0 <= 18'sb000010110010110110;
            sine_reg0   <= 18'sb100000000111110110;
        end
        3130: begin
            cosine_reg0 <= 18'sb000010110101111110;
            sine_reg0   <= 18'sb100000001000000111;
        end
        3131: begin
            cosine_reg0 <= 18'sb000010111001000110;
            sine_reg0   <= 18'sb100000001000011001;
        end
        3132: begin
            cosine_reg0 <= 18'sb000010111100001111;
            sine_reg0   <= 18'sb100000001000101100;
        end
        3133: begin
            cosine_reg0 <= 18'sb000010111111010111;
            sine_reg0   <= 18'sb100000001000111110;
        end
        3134: begin
            cosine_reg0 <= 18'sb000011000010011111;
            sine_reg0   <= 18'sb100000001001010001;
        end
        3135: begin
            cosine_reg0 <= 18'sb000011000101100111;
            sine_reg0   <= 18'sb100000001001100101;
        end
        3136: begin
            cosine_reg0 <= 18'sb000011001000101111;
            sine_reg0   <= 18'sb100000001001111000;
        end
        3137: begin
            cosine_reg0 <= 18'sb000011001011110111;
            sine_reg0   <= 18'sb100000001010001100;
        end
        3138: begin
            cosine_reg0 <= 18'sb000011001110111111;
            sine_reg0   <= 18'sb100000001010100000;
        end
        3139: begin
            cosine_reg0 <= 18'sb000011010010000111;
            sine_reg0   <= 18'sb100000001010110101;
        end
        3140: begin
            cosine_reg0 <= 18'sb000011010101001111;
            sine_reg0   <= 18'sb100000001011001001;
        end
        3141: begin
            cosine_reg0 <= 18'sb000011011000010111;
            sine_reg0   <= 18'sb100000001011011111;
        end
        3142: begin
            cosine_reg0 <= 18'sb000011011011011111;
            sine_reg0   <= 18'sb100000001011110100;
        end
        3143: begin
            cosine_reg0 <= 18'sb000011011110100111;
            sine_reg0   <= 18'sb100000001100001010;
        end
        3144: begin
            cosine_reg0 <= 18'sb000011100001101111;
            sine_reg0   <= 18'sb100000001100100000;
        end
        3145: begin
            cosine_reg0 <= 18'sb000011100100110111;
            sine_reg0   <= 18'sb100000001100110110;
        end
        3146: begin
            cosine_reg0 <= 18'sb000011100111111111;
            sine_reg0   <= 18'sb100000001101001101;
        end
        3147: begin
            cosine_reg0 <= 18'sb000011101011000110;
            sine_reg0   <= 18'sb100000001101100011;
        end
        3148: begin
            cosine_reg0 <= 18'sb000011101110001110;
            sine_reg0   <= 18'sb100000001101111011;
        end
        3149: begin
            cosine_reg0 <= 18'sb000011110001010110;
            sine_reg0   <= 18'sb100000001110010010;
        end
        3150: begin
            cosine_reg0 <= 18'sb000011110100011101;
            sine_reg0   <= 18'sb100000001110101010;
        end
        3151: begin
            cosine_reg0 <= 18'sb000011110111100101;
            sine_reg0   <= 18'sb100000001111000010;
        end
        3152: begin
            cosine_reg0 <= 18'sb000011111010101100;
            sine_reg0   <= 18'sb100000001111011011;
        end
        3153: begin
            cosine_reg0 <= 18'sb000011111101110100;
            sine_reg0   <= 18'sb100000001111110011;
        end
        3154: begin
            cosine_reg0 <= 18'sb000100000000111100;
            sine_reg0   <= 18'sb100000010000001101;
        end
        3155: begin
            cosine_reg0 <= 18'sb000100000100000011;
            sine_reg0   <= 18'sb100000010000100110;
        end
        3156: begin
            cosine_reg0 <= 18'sb000100000111001010;
            sine_reg0   <= 18'sb100000010001000000;
        end
        3157: begin
            cosine_reg0 <= 18'sb000100001010010010;
            sine_reg0   <= 18'sb100000010001011010;
        end
        3158: begin
            cosine_reg0 <= 18'sb000100001101011001;
            sine_reg0   <= 18'sb100000010001110100;
        end
        3159: begin
            cosine_reg0 <= 18'sb000100010000100000;
            sine_reg0   <= 18'sb100000010010001110;
        end
        3160: begin
            cosine_reg0 <= 18'sb000100010011101000;
            sine_reg0   <= 18'sb100000010010101001;
        end
        3161: begin
            cosine_reg0 <= 18'sb000100010110101111;
            sine_reg0   <= 18'sb100000010011000101;
        end
        3162: begin
            cosine_reg0 <= 18'sb000100011001110110;
            sine_reg0   <= 18'sb100000010011100000;
        end
        3163: begin
            cosine_reg0 <= 18'sb000100011100111101;
            sine_reg0   <= 18'sb100000010011111100;
        end
        3164: begin
            cosine_reg0 <= 18'sb000100100000000100;
            sine_reg0   <= 18'sb100000010100011000;
        end
        3165: begin
            cosine_reg0 <= 18'sb000100100011001011;
            sine_reg0   <= 18'sb100000010100110101;
        end
        3166: begin
            cosine_reg0 <= 18'sb000100100110010010;
            sine_reg0   <= 18'sb100000010101010001;
        end
        3167: begin
            cosine_reg0 <= 18'sb000100101001011001;
            sine_reg0   <= 18'sb100000010101101110;
        end
        3168: begin
            cosine_reg0 <= 18'sb000100101100100000;
            sine_reg0   <= 18'sb100000010110001100;
        end
        3169: begin
            cosine_reg0 <= 18'sb000100101111100111;
            sine_reg0   <= 18'sb100000010110101001;
        end
        3170: begin
            cosine_reg0 <= 18'sb000100110010101110;
            sine_reg0   <= 18'sb100000010111000111;
        end
        3171: begin
            cosine_reg0 <= 18'sb000100110101110101;
            sine_reg0   <= 18'sb100000010111100110;
        end
        3172: begin
            cosine_reg0 <= 18'sb000100111000111011;
            sine_reg0   <= 18'sb100000011000000100;
        end
        3173: begin
            cosine_reg0 <= 18'sb000100111100000010;
            sine_reg0   <= 18'sb100000011000100011;
        end
        3174: begin
            cosine_reg0 <= 18'sb000100111111001001;
            sine_reg0   <= 18'sb100000011001000010;
        end
        3175: begin
            cosine_reg0 <= 18'sb000101000010001111;
            sine_reg0   <= 18'sb100000011001100010;
        end
        3176: begin
            cosine_reg0 <= 18'sb000101000101010110;
            sine_reg0   <= 18'sb100000011010000001;
        end
        3177: begin
            cosine_reg0 <= 18'sb000101001000011100;
            sine_reg0   <= 18'sb100000011010100010;
        end
        3178: begin
            cosine_reg0 <= 18'sb000101001011100011;
            sine_reg0   <= 18'sb100000011011000010;
        end
        3179: begin
            cosine_reg0 <= 18'sb000101001110101001;
            sine_reg0   <= 18'sb100000011011100011;
        end
        3180: begin
            cosine_reg0 <= 18'sb000101010001101111;
            sine_reg0   <= 18'sb100000011100000100;
        end
        3181: begin
            cosine_reg0 <= 18'sb000101010100110110;
            sine_reg0   <= 18'sb100000011100100101;
        end
        3182: begin
            cosine_reg0 <= 18'sb000101010111111100;
            sine_reg0   <= 18'sb100000011101000111;
        end
        3183: begin
            cosine_reg0 <= 18'sb000101011011000010;
            sine_reg0   <= 18'sb100000011101101000;
        end
        3184: begin
            cosine_reg0 <= 18'sb000101011110001000;
            sine_reg0   <= 18'sb100000011110001011;
        end
        3185: begin
            cosine_reg0 <= 18'sb000101100001001110;
            sine_reg0   <= 18'sb100000011110101101;
        end
        3186: begin
            cosine_reg0 <= 18'sb000101100100010100;
            sine_reg0   <= 18'sb100000011111010000;
        end
        3187: begin
            cosine_reg0 <= 18'sb000101100111011010;
            sine_reg0   <= 18'sb100000011111110011;
        end
        3188: begin
            cosine_reg0 <= 18'sb000101101010100000;
            sine_reg0   <= 18'sb100000100000010111;
        end
        3189: begin
            cosine_reg0 <= 18'sb000101101101100110;
            sine_reg0   <= 18'sb100000100000111010;
        end
        3190: begin
            cosine_reg0 <= 18'sb000101110000101100;
            sine_reg0   <= 18'sb100000100001011110;
        end
        3191: begin
            cosine_reg0 <= 18'sb000101110011110010;
            sine_reg0   <= 18'sb100000100010000011;
        end
        3192: begin
            cosine_reg0 <= 18'sb000101110110110111;
            sine_reg0   <= 18'sb100000100010100111;
        end
        3193: begin
            cosine_reg0 <= 18'sb000101111001111101;
            sine_reg0   <= 18'sb100000100011001100;
        end
        3194: begin
            cosine_reg0 <= 18'sb000101111101000010;
            sine_reg0   <= 18'sb100000100011110010;
        end
        3195: begin
            cosine_reg0 <= 18'sb000110000000001000;
            sine_reg0   <= 18'sb100000100100010111;
        end
        3196: begin
            cosine_reg0 <= 18'sb000110000011001101;
            sine_reg0   <= 18'sb100000100100111101;
        end
        3197: begin
            cosine_reg0 <= 18'sb000110000110010011;
            sine_reg0   <= 18'sb100000100101100011;
        end
        3198: begin
            cosine_reg0 <= 18'sb000110001001011000;
            sine_reg0   <= 18'sb100000100110001010;
        end
        3199: begin
            cosine_reg0 <= 18'sb000110001100011101;
            sine_reg0   <= 18'sb100000100110110000;
        end
        3200: begin
            cosine_reg0 <= 18'sb000110001111100011;
            sine_reg0   <= 18'sb100000100111010111;
        end
        3201: begin
            cosine_reg0 <= 18'sb000110010010101000;
            sine_reg0   <= 18'sb100000100111111111;
        end
        3202: begin
            cosine_reg0 <= 18'sb000110010101101101;
            sine_reg0   <= 18'sb100000101000100111;
        end
        3203: begin
            cosine_reg0 <= 18'sb000110011000110010;
            sine_reg0   <= 18'sb100000101001001111;
        end
        3204: begin
            cosine_reg0 <= 18'sb000110011011110111;
            sine_reg0   <= 18'sb100000101001110111;
        end
        3205: begin
            cosine_reg0 <= 18'sb000110011110111100;
            sine_reg0   <= 18'sb100000101010011111;
        end
        3206: begin
            cosine_reg0 <= 18'sb000110100010000001;
            sine_reg0   <= 18'sb100000101011001000;
        end
        3207: begin
            cosine_reg0 <= 18'sb000110100101000110;
            sine_reg0   <= 18'sb100000101011110001;
        end
        3208: begin
            cosine_reg0 <= 18'sb000110101000001010;
            sine_reg0   <= 18'sb100000101100011011;
        end
        3209: begin
            cosine_reg0 <= 18'sb000110101011001111;
            sine_reg0   <= 18'sb100000101101000101;
        end
        3210: begin
            cosine_reg0 <= 18'sb000110101110010100;
            sine_reg0   <= 18'sb100000101101101111;
        end
        3211: begin
            cosine_reg0 <= 18'sb000110110001011000;
            sine_reg0   <= 18'sb100000101110011001;
        end
        3212: begin
            cosine_reg0 <= 18'sb000110110100011101;
            sine_reg0   <= 18'sb100000101111000100;
        end
        3213: begin
            cosine_reg0 <= 18'sb000110110111100001;
            sine_reg0   <= 18'sb100000101111101111;
        end
        3214: begin
            cosine_reg0 <= 18'sb000110111010100101;
            sine_reg0   <= 18'sb100000110000011010;
        end
        3215: begin
            cosine_reg0 <= 18'sb000110111101101010;
            sine_reg0   <= 18'sb100000110001000110;
        end
        3216: begin
            cosine_reg0 <= 18'sb000111000000101110;
            sine_reg0   <= 18'sb100000110001110010;
        end
        3217: begin
            cosine_reg0 <= 18'sb000111000011110010;
            sine_reg0   <= 18'sb100000110010011110;
        end
        3218: begin
            cosine_reg0 <= 18'sb000111000110110110;
            sine_reg0   <= 18'sb100000110011001010;
        end
        3219: begin
            cosine_reg0 <= 18'sb000111001001111010;
            sine_reg0   <= 18'sb100000110011110111;
        end
        3220: begin
            cosine_reg0 <= 18'sb000111001100111110;
            sine_reg0   <= 18'sb100000110100100100;
        end
        3221: begin
            cosine_reg0 <= 18'sb000111010000000010;
            sine_reg0   <= 18'sb100000110101010010;
        end
        3222: begin
            cosine_reg0 <= 18'sb000111010011000110;
            sine_reg0   <= 18'sb100000110101111111;
        end
        3223: begin
            cosine_reg0 <= 18'sb000111010110001001;
            sine_reg0   <= 18'sb100000110110101101;
        end
        3224: begin
            cosine_reg0 <= 18'sb000111011001001101;
            sine_reg0   <= 18'sb100000110111011100;
        end
        3225: begin
            cosine_reg0 <= 18'sb000111011100010001;
            sine_reg0   <= 18'sb100000111000001010;
        end
        3226: begin
            cosine_reg0 <= 18'sb000111011111010100;
            sine_reg0   <= 18'sb100000111000111001;
        end
        3227: begin
            cosine_reg0 <= 18'sb000111100010011000;
            sine_reg0   <= 18'sb100000111001101001;
        end
        3228: begin
            cosine_reg0 <= 18'sb000111100101011011;
            sine_reg0   <= 18'sb100000111010011000;
        end
        3229: begin
            cosine_reg0 <= 18'sb000111101000011110;
            sine_reg0   <= 18'sb100000111011001000;
        end
        3230: begin
            cosine_reg0 <= 18'sb000111101011100001;
            sine_reg0   <= 18'sb100000111011111000;
        end
        3231: begin
            cosine_reg0 <= 18'sb000111101110100101;
            sine_reg0   <= 18'sb100000111100101000;
        end
        3232: begin
            cosine_reg0 <= 18'sb000111110001101000;
            sine_reg0   <= 18'sb100000111101011001;
        end
        3233: begin
            cosine_reg0 <= 18'sb000111110100101011;
            sine_reg0   <= 18'sb100000111110001010;
        end
        3234: begin
            cosine_reg0 <= 18'sb000111110111101110;
            sine_reg0   <= 18'sb100000111110111011;
        end
        3235: begin
            cosine_reg0 <= 18'sb000111111010110000;
            sine_reg0   <= 18'sb100000111111101101;
        end
        3236: begin
            cosine_reg0 <= 18'sb000111111101110011;
            sine_reg0   <= 18'sb100001000000011111;
        end
        3237: begin
            cosine_reg0 <= 18'sb001000000000110110;
            sine_reg0   <= 18'sb100001000001010001;
        end
        3238: begin
            cosine_reg0 <= 18'sb001000000011111000;
            sine_reg0   <= 18'sb100001000010000100;
        end
        3239: begin
            cosine_reg0 <= 18'sb001000000110111011;
            sine_reg0   <= 18'sb100001000010110110;
        end
        3240: begin
            cosine_reg0 <= 18'sb001000001001111101;
            sine_reg0   <= 18'sb100001000011101001;
        end
        3241: begin
            cosine_reg0 <= 18'sb001000001101000000;
            sine_reg0   <= 18'sb100001000100011101;
        end
        3242: begin
            cosine_reg0 <= 18'sb001000010000000010;
            sine_reg0   <= 18'sb100001000101010001;
        end
        3243: begin
            cosine_reg0 <= 18'sb001000010011000100;
            sine_reg0   <= 18'sb100001000110000100;
        end
        3244: begin
            cosine_reg0 <= 18'sb001000010110000111;
            sine_reg0   <= 18'sb100001000110111001;
        end
        3245: begin
            cosine_reg0 <= 18'sb001000011001001001;
            sine_reg0   <= 18'sb100001000111101101;
        end
        3246: begin
            cosine_reg0 <= 18'sb001000011100001011;
            sine_reg0   <= 18'sb100001001000100010;
        end
        3247: begin
            cosine_reg0 <= 18'sb001000011111001100;
            sine_reg0   <= 18'sb100001001001010111;
        end
        3248: begin
            cosine_reg0 <= 18'sb001000100010001110;
            sine_reg0   <= 18'sb100001001010001101;
        end
        3249: begin
            cosine_reg0 <= 18'sb001000100101010000;
            sine_reg0   <= 18'sb100001001011000011;
        end
        3250: begin
            cosine_reg0 <= 18'sb001000101000010010;
            sine_reg0   <= 18'sb100001001011111001;
        end
        3251: begin
            cosine_reg0 <= 18'sb001000101011010011;
            sine_reg0   <= 18'sb100001001100101111;
        end
        3252: begin
            cosine_reg0 <= 18'sb001000101110010101;
            sine_reg0   <= 18'sb100001001101100110;
        end
        3253: begin
            cosine_reg0 <= 18'sb001000110001010110;
            sine_reg0   <= 18'sb100001001110011101;
        end
        3254: begin
            cosine_reg0 <= 18'sb001000110100010111;
            sine_reg0   <= 18'sb100001001111010100;
        end
        3255: begin
            cosine_reg0 <= 18'sb001000110111011001;
            sine_reg0   <= 18'sb100001010000001100;
        end
        3256: begin
            cosine_reg0 <= 18'sb001000111010011010;
            sine_reg0   <= 18'sb100001010001000011;
        end
        3257: begin
            cosine_reg0 <= 18'sb001000111101011011;
            sine_reg0   <= 18'sb100001010001111100;
        end
        3258: begin
            cosine_reg0 <= 18'sb001001000000011100;
            sine_reg0   <= 18'sb100001010010110100;
        end
        3259: begin
            cosine_reg0 <= 18'sb001001000011011101;
            sine_reg0   <= 18'sb100001010011101101;
        end
        3260: begin
            cosine_reg0 <= 18'sb001001000110011110;
            sine_reg0   <= 18'sb100001010100100110;
        end
        3261: begin
            cosine_reg0 <= 18'sb001001001001011110;
            sine_reg0   <= 18'sb100001010101011111;
        end
        3262: begin
            cosine_reg0 <= 18'sb001001001100011111;
            sine_reg0   <= 18'sb100001010110011001;
        end
        3263: begin
            cosine_reg0 <= 18'sb001001001111011111;
            sine_reg0   <= 18'sb100001010111010011;
        end
        3264: begin
            cosine_reg0 <= 18'sb001001010010100000;
            sine_reg0   <= 18'sb100001011000001101;
        end
        3265: begin
            cosine_reg0 <= 18'sb001001010101100000;
            sine_reg0   <= 18'sb100001011001000111;
        end
        3266: begin
            cosine_reg0 <= 18'sb001001011000100001;
            sine_reg0   <= 18'sb100001011010000010;
        end
        3267: begin
            cosine_reg0 <= 18'sb001001011011100001;
            sine_reg0   <= 18'sb100001011010111101;
        end
        3268: begin
            cosine_reg0 <= 18'sb001001011110100001;
            sine_reg0   <= 18'sb100001011011111001;
        end
        3269: begin
            cosine_reg0 <= 18'sb001001100001100001;
            sine_reg0   <= 18'sb100001011100110100;
        end
        3270: begin
            cosine_reg0 <= 18'sb001001100100100001;
            sine_reg0   <= 18'sb100001011101110000;
        end
        3271: begin
            cosine_reg0 <= 18'sb001001100111100001;
            sine_reg0   <= 18'sb100001011110101101;
        end
        3272: begin
            cosine_reg0 <= 18'sb001001101010100000;
            sine_reg0   <= 18'sb100001011111101001;
        end
        3273: begin
            cosine_reg0 <= 18'sb001001101101100000;
            sine_reg0   <= 18'sb100001100000100110;
        end
        3274: begin
            cosine_reg0 <= 18'sb001001110000011111;
            sine_reg0   <= 18'sb100001100001100011;
        end
        3275: begin
            cosine_reg0 <= 18'sb001001110011011111;
            sine_reg0   <= 18'sb100001100010100001;
        end
        3276: begin
            cosine_reg0 <= 18'sb001001110110011110;
            sine_reg0   <= 18'sb100001100011011110;
        end
        3277: begin
            cosine_reg0 <= 18'sb001001111001011101;
            sine_reg0   <= 18'sb100001100100011101;
        end
        3278: begin
            cosine_reg0 <= 18'sb001001111100011101;
            sine_reg0   <= 18'sb100001100101011011;
        end
        3279: begin
            cosine_reg0 <= 18'sb001001111111011100;
            sine_reg0   <= 18'sb100001100110011001;
        end
        3280: begin
            cosine_reg0 <= 18'sb001010000010011011;
            sine_reg0   <= 18'sb100001100111011000;
        end
        3281: begin
            cosine_reg0 <= 18'sb001010000101011001;
            sine_reg0   <= 18'sb100001101000011000;
        end
        3282: begin
            cosine_reg0 <= 18'sb001010001000011000;
            sine_reg0   <= 18'sb100001101001010111;
        end
        3283: begin
            cosine_reg0 <= 18'sb001010001011010111;
            sine_reg0   <= 18'sb100001101010010111;
        end
        3284: begin
            cosine_reg0 <= 18'sb001010001110010101;
            sine_reg0   <= 18'sb100001101011010111;
        end
        3285: begin
            cosine_reg0 <= 18'sb001010010001010100;
            sine_reg0   <= 18'sb100001101100010111;
        end
        3286: begin
            cosine_reg0 <= 18'sb001010010100010010;
            sine_reg0   <= 18'sb100001101101011000;
        end
        3287: begin
            cosine_reg0 <= 18'sb001010010111010001;
            sine_reg0   <= 18'sb100001101110011001;
        end
        3288: begin
            cosine_reg0 <= 18'sb001010011010001111;
            sine_reg0   <= 18'sb100001101111011010;
        end
        3289: begin
            cosine_reg0 <= 18'sb001010011101001101;
            sine_reg0   <= 18'sb100001110000011100;
        end
        3290: begin
            cosine_reg0 <= 18'sb001010100000001011;
            sine_reg0   <= 18'sb100001110001011110;
        end
        3291: begin
            cosine_reg0 <= 18'sb001010100011001001;
            sine_reg0   <= 18'sb100001110010100000;
        end
        3292: begin
            cosine_reg0 <= 18'sb001010100110000110;
            sine_reg0   <= 18'sb100001110011100010;
        end
        3293: begin
            cosine_reg0 <= 18'sb001010101001000100;
            sine_reg0   <= 18'sb100001110100100101;
        end
        3294: begin
            cosine_reg0 <= 18'sb001010101100000010;
            sine_reg0   <= 18'sb100001110101101000;
        end
        3295: begin
            cosine_reg0 <= 18'sb001010101110111111;
            sine_reg0   <= 18'sb100001110110101011;
        end
        3296: begin
            cosine_reg0 <= 18'sb001010110001111100;
            sine_reg0   <= 18'sb100001110111101111;
        end
        3297: begin
            cosine_reg0 <= 18'sb001010110100111010;
            sine_reg0   <= 18'sb100001111000110011;
        end
        3298: begin
            cosine_reg0 <= 18'sb001010110111110111;
            sine_reg0   <= 18'sb100001111001110111;
        end
        3299: begin
            cosine_reg0 <= 18'sb001010111010110100;
            sine_reg0   <= 18'sb100001111010111011;
        end
        3300: begin
            cosine_reg0 <= 18'sb001010111101110001;
            sine_reg0   <= 18'sb100001111100000000;
        end
        3301: begin
            cosine_reg0 <= 18'sb001011000000101110;
            sine_reg0   <= 18'sb100001111101000101;
        end
        3302: begin
            cosine_reg0 <= 18'sb001011000011101010;
            sine_reg0   <= 18'sb100001111110001011;
        end
        3303: begin
            cosine_reg0 <= 18'sb001011000110100111;
            sine_reg0   <= 18'sb100001111111010000;
        end
        3304: begin
            cosine_reg0 <= 18'sb001011001001100100;
            sine_reg0   <= 18'sb100010000000010110;
        end
        3305: begin
            cosine_reg0 <= 18'sb001011001100100000;
            sine_reg0   <= 18'sb100010000001011100;
        end
        3306: begin
            cosine_reg0 <= 18'sb001011001111011100;
            sine_reg0   <= 18'sb100010000010100011;
        end
        3307: begin
            cosine_reg0 <= 18'sb001011010010011000;
            sine_reg0   <= 18'sb100010000011101001;
        end
        3308: begin
            cosine_reg0 <= 18'sb001011010101010101;
            sine_reg0   <= 18'sb100010000100110001;
        end
        3309: begin
            cosine_reg0 <= 18'sb001011011000010001;
            sine_reg0   <= 18'sb100010000101111000;
        end
        3310: begin
            cosine_reg0 <= 18'sb001011011011001100;
            sine_reg0   <= 18'sb100010000111000000;
        end
        3311: begin
            cosine_reg0 <= 18'sb001011011110001000;
            sine_reg0   <= 18'sb100010001000000111;
        end
        3312: begin
            cosine_reg0 <= 18'sb001011100001000100;
            sine_reg0   <= 18'sb100010001001010000;
        end
        3313: begin
            cosine_reg0 <= 18'sb001011100011111111;
            sine_reg0   <= 18'sb100010001010011000;
        end
        3314: begin
            cosine_reg0 <= 18'sb001011100110111011;
            sine_reg0   <= 18'sb100010001011100001;
        end
        3315: begin
            cosine_reg0 <= 18'sb001011101001110110;
            sine_reg0   <= 18'sb100010001100101010;
        end
        3316: begin
            cosine_reg0 <= 18'sb001011101100110001;
            sine_reg0   <= 18'sb100010001101110011;
        end
        3317: begin
            cosine_reg0 <= 18'sb001011101111101100;
            sine_reg0   <= 18'sb100010001110111101;
        end
        3318: begin
            cosine_reg0 <= 18'sb001011110010100111;
            sine_reg0   <= 18'sb100010010000000111;
        end
        3319: begin
            cosine_reg0 <= 18'sb001011110101100010;
            sine_reg0   <= 18'sb100010010001010001;
        end
        3320: begin
            cosine_reg0 <= 18'sb001011111000011101;
            sine_reg0   <= 18'sb100010010010011100;
        end
        3321: begin
            cosine_reg0 <= 18'sb001011111011011000;
            sine_reg0   <= 18'sb100010010011100111;
        end
        3322: begin
            cosine_reg0 <= 18'sb001011111110010010;
            sine_reg0   <= 18'sb100010010100110010;
        end
        3323: begin
            cosine_reg0 <= 18'sb001100000001001100;
            sine_reg0   <= 18'sb100010010101111101;
        end
        3324: begin
            cosine_reg0 <= 18'sb001100000100000111;
            sine_reg0   <= 18'sb100010010111001001;
        end
        3325: begin
            cosine_reg0 <= 18'sb001100000111000001;
            sine_reg0   <= 18'sb100010011000010101;
        end
        3326: begin
            cosine_reg0 <= 18'sb001100001001111011;
            sine_reg0   <= 18'sb100010011001100001;
        end
        3327: begin
            cosine_reg0 <= 18'sb001100001100110101;
            sine_reg0   <= 18'sb100010011010101101;
        end
        3328: begin
            cosine_reg0 <= 18'sb001100001111101111;
            sine_reg0   <= 18'sb100010011011111010;
        end
        3329: begin
            cosine_reg0 <= 18'sb001100010010101000;
            sine_reg0   <= 18'sb100010011101000111;
        end
        3330: begin
            cosine_reg0 <= 18'sb001100010101100010;
            sine_reg0   <= 18'sb100010011110010101;
        end
        3331: begin
            cosine_reg0 <= 18'sb001100011000011011;
            sine_reg0   <= 18'sb100010011111100010;
        end
        3332: begin
            cosine_reg0 <= 18'sb001100011011010101;
            sine_reg0   <= 18'sb100010100000110000;
        end
        3333: begin
            cosine_reg0 <= 18'sb001100011110001110;
            sine_reg0   <= 18'sb100010100001111110;
        end
        3334: begin
            cosine_reg0 <= 18'sb001100100001000111;
            sine_reg0   <= 18'sb100010100011001101;
        end
        3335: begin
            cosine_reg0 <= 18'sb001100100100000000;
            sine_reg0   <= 18'sb100010100100011100;
        end
        3336: begin
            cosine_reg0 <= 18'sb001100100110111001;
            sine_reg0   <= 18'sb100010100101101011;
        end
        3337: begin
            cosine_reg0 <= 18'sb001100101001110010;
            sine_reg0   <= 18'sb100010100110111010;
        end
        3338: begin
            cosine_reg0 <= 18'sb001100101100101010;
            sine_reg0   <= 18'sb100010101000001010;
        end
        3339: begin
            cosine_reg0 <= 18'sb001100101111100011;
            sine_reg0   <= 18'sb100010101001011010;
        end
        3340: begin
            cosine_reg0 <= 18'sb001100110010011011;
            sine_reg0   <= 18'sb100010101010101010;
        end
        3341: begin
            cosine_reg0 <= 18'sb001100110101010011;
            sine_reg0   <= 18'sb100010101011111010;
        end
        3342: begin
            cosine_reg0 <= 18'sb001100111000001100;
            sine_reg0   <= 18'sb100010101101001011;
        end
        3343: begin
            cosine_reg0 <= 18'sb001100111011000100;
            sine_reg0   <= 18'sb100010101110011100;
        end
        3344: begin
            cosine_reg0 <= 18'sb001100111101111011;
            sine_reg0   <= 18'sb100010101111101110;
        end
        3345: begin
            cosine_reg0 <= 18'sb001101000000110011;
            sine_reg0   <= 18'sb100010110000111111;
        end
        3346: begin
            cosine_reg0 <= 18'sb001101000011101011;
            sine_reg0   <= 18'sb100010110010010001;
        end
        3347: begin
            cosine_reg0 <= 18'sb001101000110100010;
            sine_reg0   <= 18'sb100010110011100011;
        end
        3348: begin
            cosine_reg0 <= 18'sb001101001001011010;
            sine_reg0   <= 18'sb100010110100110110;
        end
        3349: begin
            cosine_reg0 <= 18'sb001101001100010001;
            sine_reg0   <= 18'sb100010110110001001;
        end
        3350: begin
            cosine_reg0 <= 18'sb001101001111001000;
            sine_reg0   <= 18'sb100010110111011100;
        end
        3351: begin
            cosine_reg0 <= 18'sb001101010001111111;
            sine_reg0   <= 18'sb100010111000101111;
        end
        3352: begin
            cosine_reg0 <= 18'sb001101010100110110;
            sine_reg0   <= 18'sb100010111010000010;
        end
        3353: begin
            cosine_reg0 <= 18'sb001101010111101101;
            sine_reg0   <= 18'sb100010111011010110;
        end
        3354: begin
            cosine_reg0 <= 18'sb001101011010100011;
            sine_reg0   <= 18'sb100010111100101010;
        end
        3355: begin
            cosine_reg0 <= 18'sb001101011101011010;
            sine_reg0   <= 18'sb100010111101111111;
        end
        3356: begin
            cosine_reg0 <= 18'sb001101100000010000;
            sine_reg0   <= 18'sb100010111111010100;
        end
        3357: begin
            cosine_reg0 <= 18'sb001101100011000110;
            sine_reg0   <= 18'sb100011000000101001;
        end
        3358: begin
            cosine_reg0 <= 18'sb001101100101111100;
            sine_reg0   <= 18'sb100011000001111110;
        end
        3359: begin
            cosine_reg0 <= 18'sb001101101000110010;
            sine_reg0   <= 18'sb100011000011010011;
        end
        3360: begin
            cosine_reg0 <= 18'sb001101101011101000;
            sine_reg0   <= 18'sb100011000100101001;
        end
        3361: begin
            cosine_reg0 <= 18'sb001101101110011110;
            sine_reg0   <= 18'sb100011000101111111;
        end
        3362: begin
            cosine_reg0 <= 18'sb001101110001010011;
            sine_reg0   <= 18'sb100011000111010110;
        end
        3363: begin
            cosine_reg0 <= 18'sb001101110100001001;
            sine_reg0   <= 18'sb100011001000101100;
        end
        3364: begin
            cosine_reg0 <= 18'sb001101110110111110;
            sine_reg0   <= 18'sb100011001010000011;
        end
        3365: begin
            cosine_reg0 <= 18'sb001101111001110011;
            sine_reg0   <= 18'sb100011001011011011;
        end
        3366: begin
            cosine_reg0 <= 18'sb001101111100101000;
            sine_reg0   <= 18'sb100011001100110010;
        end
        3367: begin
            cosine_reg0 <= 18'sb001101111111011101;
            sine_reg0   <= 18'sb100011001110001010;
        end
        3368: begin
            cosine_reg0 <= 18'sb001110000010010010;
            sine_reg0   <= 18'sb100011001111100010;
        end
        3369: begin
            cosine_reg0 <= 18'sb001110000101000110;
            sine_reg0   <= 18'sb100011010000111010;
        end
        3370: begin
            cosine_reg0 <= 18'sb001110000111111011;
            sine_reg0   <= 18'sb100011010010010011;
        end
        3371: begin
            cosine_reg0 <= 18'sb001110001010101111;
            sine_reg0   <= 18'sb100011010011101100;
        end
        3372: begin
            cosine_reg0 <= 18'sb001110001101100100;
            sine_reg0   <= 18'sb100011010101000101;
        end
        3373: begin
            cosine_reg0 <= 18'sb001110010000011000;
            sine_reg0   <= 18'sb100011010110011110;
        end
        3374: begin
            cosine_reg0 <= 18'sb001110010011001100;
            sine_reg0   <= 18'sb100011010111111000;
        end
        3375: begin
            cosine_reg0 <= 18'sb001110010101111111;
            sine_reg0   <= 18'sb100011011001010010;
        end
        3376: begin
            cosine_reg0 <= 18'sb001110011000110011;
            sine_reg0   <= 18'sb100011011010101100;
        end
        3377: begin
            cosine_reg0 <= 18'sb001110011011100111;
            sine_reg0   <= 18'sb100011011100000111;
        end
        3378: begin
            cosine_reg0 <= 18'sb001110011110011010;
            sine_reg0   <= 18'sb100011011101100010;
        end
        3379: begin
            cosine_reg0 <= 18'sb001110100001001101;
            sine_reg0   <= 18'sb100011011110111101;
        end
        3380: begin
            cosine_reg0 <= 18'sb001110100100000000;
            sine_reg0   <= 18'sb100011100000011000;
        end
        3381: begin
            cosine_reg0 <= 18'sb001110100110110011;
            sine_reg0   <= 18'sb100011100001110100;
        end
        3382: begin
            cosine_reg0 <= 18'sb001110101001100110;
            sine_reg0   <= 18'sb100011100011010000;
        end
        3383: begin
            cosine_reg0 <= 18'sb001110101100011001;
            sine_reg0   <= 18'sb100011100100101100;
        end
        3384: begin
            cosine_reg0 <= 18'sb001110101111001011;
            sine_reg0   <= 18'sb100011100110001000;
        end
        3385: begin
            cosine_reg0 <= 18'sb001110110001111110;
            sine_reg0   <= 18'sb100011100111100101;
        end
        3386: begin
            cosine_reg0 <= 18'sb001110110100110000;
            sine_reg0   <= 18'sb100011101001000010;
        end
        3387: begin
            cosine_reg0 <= 18'sb001110110111100010;
            sine_reg0   <= 18'sb100011101010011111;
        end
        3388: begin
            cosine_reg0 <= 18'sb001110111010010100;
            sine_reg0   <= 18'sb100011101011111101;
        end
        3389: begin
            cosine_reg0 <= 18'sb001110111101000110;
            sine_reg0   <= 18'sb100011101101011011;
        end
        3390: begin
            cosine_reg0 <= 18'sb001110111111111000;
            sine_reg0   <= 18'sb100011101110111001;
        end
        3391: begin
            cosine_reg0 <= 18'sb001111000010101001;
            sine_reg0   <= 18'sb100011110000010111;
        end
        3392: begin
            cosine_reg0 <= 18'sb001111000101011010;
            sine_reg0   <= 18'sb100011110001110110;
        end
        3393: begin
            cosine_reg0 <= 18'sb001111001000001100;
            sine_reg0   <= 18'sb100011110011010101;
        end
        3394: begin
            cosine_reg0 <= 18'sb001111001010111101;
            sine_reg0   <= 18'sb100011110100110100;
        end
        3395: begin
            cosine_reg0 <= 18'sb001111001101101110;
            sine_reg0   <= 18'sb100011110110010011;
        end
        3396: begin
            cosine_reg0 <= 18'sb001111010000011111;
            sine_reg0   <= 18'sb100011110111110011;
        end
        3397: begin
            cosine_reg0 <= 18'sb001111010011001111;
            sine_reg0   <= 18'sb100011111001010011;
        end
        3398: begin
            cosine_reg0 <= 18'sb001111010110000000;
            sine_reg0   <= 18'sb100011111010110011;
        end
        3399: begin
            cosine_reg0 <= 18'sb001111011000110000;
            sine_reg0   <= 18'sb100011111100010100;
        end
        3400: begin
            cosine_reg0 <= 18'sb001111011011100000;
            sine_reg0   <= 18'sb100011111101110101;
        end
        3401: begin
            cosine_reg0 <= 18'sb001111011110010000;
            sine_reg0   <= 18'sb100011111111010110;
        end
        3402: begin
            cosine_reg0 <= 18'sb001111100001000000;
            sine_reg0   <= 18'sb100100000000110111;
        end
        3403: begin
            cosine_reg0 <= 18'sb001111100011110000;
            sine_reg0   <= 18'sb100100000010011001;
        end
        3404: begin
            cosine_reg0 <= 18'sb001111100110100000;
            sine_reg0   <= 18'sb100100000011111011;
        end
        3405: begin
            cosine_reg0 <= 18'sb001111101001001111;
            sine_reg0   <= 18'sb100100000101011101;
        end
        3406: begin
            cosine_reg0 <= 18'sb001111101011111110;
            sine_reg0   <= 18'sb100100000110111111;
        end
        3407: begin
            cosine_reg0 <= 18'sb001111101110101110;
            sine_reg0   <= 18'sb100100001000100010;
        end
        3408: begin
            cosine_reg0 <= 18'sb001111110001011101;
            sine_reg0   <= 18'sb100100001010000101;
        end
        3409: begin
            cosine_reg0 <= 18'sb001111110100001100;
            sine_reg0   <= 18'sb100100001011101000;
        end
        3410: begin
            cosine_reg0 <= 18'sb001111110110111010;
            sine_reg0   <= 18'sb100100001101001100;
        end
        3411: begin
            cosine_reg0 <= 18'sb001111111001101001;
            sine_reg0   <= 18'sb100100001110101111;
        end
        3412: begin
            cosine_reg0 <= 18'sb001111111100010111;
            sine_reg0   <= 18'sb100100010000010011;
        end
        3413: begin
            cosine_reg0 <= 18'sb001111111111000101;
            sine_reg0   <= 18'sb100100010001111000;
        end
        3414: begin
            cosine_reg0 <= 18'sb010000000001110100;
            sine_reg0   <= 18'sb100100010011011100;
        end
        3415: begin
            cosine_reg0 <= 18'sb010000000100100001;
            sine_reg0   <= 18'sb100100010101000001;
        end
        3416: begin
            cosine_reg0 <= 18'sb010000000111001111;
            sine_reg0   <= 18'sb100100010110100110;
        end
        3417: begin
            cosine_reg0 <= 18'sb010000001001111101;
            sine_reg0   <= 18'sb100100011000001100;
        end
        3418: begin
            cosine_reg0 <= 18'sb010000001100101010;
            sine_reg0   <= 18'sb100100011001110001;
        end
        3419: begin
            cosine_reg0 <= 18'sb010000001111011000;
            sine_reg0   <= 18'sb100100011011010111;
        end
        3420: begin
            cosine_reg0 <= 18'sb010000010010000101;
            sine_reg0   <= 18'sb100100011100111101;
        end
        3421: begin
            cosine_reg0 <= 18'sb010000010100110010;
            sine_reg0   <= 18'sb100100011110100100;
        end
        3422: begin
            cosine_reg0 <= 18'sb010000010111011111;
            sine_reg0   <= 18'sb100100100000001010;
        end
        3423: begin
            cosine_reg0 <= 18'sb010000011010001011;
            sine_reg0   <= 18'sb100100100001110001;
        end
        3424: begin
            cosine_reg0 <= 18'sb010000011100111000;
            sine_reg0   <= 18'sb100100100011011001;
        end
        3425: begin
            cosine_reg0 <= 18'sb010000011111100100;
            sine_reg0   <= 18'sb100100100101000000;
        end
        3426: begin
            cosine_reg0 <= 18'sb010000100010010001;
            sine_reg0   <= 18'sb100100100110101000;
        end
        3427: begin
            cosine_reg0 <= 18'sb010000100100111101;
            sine_reg0   <= 18'sb100100101000010000;
        end
        3428: begin
            cosine_reg0 <= 18'sb010000100111101001;
            sine_reg0   <= 18'sb100100101001111000;
        end
        3429: begin
            cosine_reg0 <= 18'sb010000101010010100;
            sine_reg0   <= 18'sb100100101011100001;
        end
        3430: begin
            cosine_reg0 <= 18'sb010000101101000000;
            sine_reg0   <= 18'sb100100101101001010;
        end
        3431: begin
            cosine_reg0 <= 18'sb010000101111101011;
            sine_reg0   <= 18'sb100100101110110011;
        end
        3432: begin
            cosine_reg0 <= 18'sb010000110010010110;
            sine_reg0   <= 18'sb100100110000011100;
        end
        3433: begin
            cosine_reg0 <= 18'sb010000110101000010;
            sine_reg0   <= 18'sb100100110010000110;
        end
        3434: begin
            cosine_reg0 <= 18'sb010000110111101101;
            sine_reg0   <= 18'sb100100110011101111;
        end
        3435: begin
            cosine_reg0 <= 18'sb010000111010010111;
            sine_reg0   <= 18'sb100100110101011010;
        end
        3436: begin
            cosine_reg0 <= 18'sb010000111101000010;
            sine_reg0   <= 18'sb100100110111000100;
        end
        3437: begin
            cosine_reg0 <= 18'sb010000111111101100;
            sine_reg0   <= 18'sb100100111000101111;
        end
        3438: begin
            cosine_reg0 <= 18'sb010001000010010111;
            sine_reg0   <= 18'sb100100111010011010;
        end
        3439: begin
            cosine_reg0 <= 18'sb010001000101000001;
            sine_reg0   <= 18'sb100100111100000101;
        end
        3440: begin
            cosine_reg0 <= 18'sb010001000111101011;
            sine_reg0   <= 18'sb100100111101110000;
        end
        3441: begin
            cosine_reg0 <= 18'sb010001001010010100;
            sine_reg0   <= 18'sb100100111111011100;
        end
        3442: begin
            cosine_reg0 <= 18'sb010001001100111110;
            sine_reg0   <= 18'sb100101000001001000;
        end
        3443: begin
            cosine_reg0 <= 18'sb010001001111101000;
            sine_reg0   <= 18'sb100101000010110100;
        end
        3444: begin
            cosine_reg0 <= 18'sb010001010010010001;
            sine_reg0   <= 18'sb100101000100100001;
        end
        3445: begin
            cosine_reg0 <= 18'sb010001010100111010;
            sine_reg0   <= 18'sb100101000110001101;
        end
        3446: begin
            cosine_reg0 <= 18'sb010001010111100011;
            sine_reg0   <= 18'sb100101000111111010;
        end
        3447: begin
            cosine_reg0 <= 18'sb010001011010001100;
            sine_reg0   <= 18'sb100101001001101000;
        end
        3448: begin
            cosine_reg0 <= 18'sb010001011100110100;
            sine_reg0   <= 18'sb100101001011010101;
        end
        3449: begin
            cosine_reg0 <= 18'sb010001011111011101;
            sine_reg0   <= 18'sb100101001101000011;
        end
        3450: begin
            cosine_reg0 <= 18'sb010001100010000101;
            sine_reg0   <= 18'sb100101001110110001;
        end
        3451: begin
            cosine_reg0 <= 18'sb010001100100101101;
            sine_reg0   <= 18'sb100101010000011111;
        end
        3452: begin
            cosine_reg0 <= 18'sb010001100111010101;
            sine_reg0   <= 18'sb100101010010001110;
        end
        3453: begin
            cosine_reg0 <= 18'sb010001101001111101;
            sine_reg0   <= 18'sb100101010011111100;
        end
        3454: begin
            cosine_reg0 <= 18'sb010001101100100100;
            sine_reg0   <= 18'sb100101010101101100;
        end
        3455: begin
            cosine_reg0 <= 18'sb010001101111001100;
            sine_reg0   <= 18'sb100101010111011011;
        end
        3456: begin
            cosine_reg0 <= 18'sb010001110001110011;
            sine_reg0   <= 18'sb100101011001001010;
        end
        3457: begin
            cosine_reg0 <= 18'sb010001110100011010;
            sine_reg0   <= 18'sb100101011010111010;
        end
        3458: begin
            cosine_reg0 <= 18'sb010001110111000001;
            sine_reg0   <= 18'sb100101011100101010;
        end
        3459: begin
            cosine_reg0 <= 18'sb010001111001101000;
            sine_reg0   <= 18'sb100101011110011011;
        end
        3460: begin
            cosine_reg0 <= 18'sb010001111100001110;
            sine_reg0   <= 18'sb100101100000001011;
        end
        3461: begin
            cosine_reg0 <= 18'sb010001111110110101;
            sine_reg0   <= 18'sb100101100001111100;
        end
        3462: begin
            cosine_reg0 <= 18'sb010010000001011011;
            sine_reg0   <= 18'sb100101100011101101;
        end
        3463: begin
            cosine_reg0 <= 18'sb010010000100000001;
            sine_reg0   <= 18'sb100101100101011111;
        end
        3464: begin
            cosine_reg0 <= 18'sb010010000110100111;
            sine_reg0   <= 18'sb100101100111010000;
        end
        3465: begin
            cosine_reg0 <= 18'sb010010001001001101;
            sine_reg0   <= 18'sb100101101001000010;
        end
        3466: begin
            cosine_reg0 <= 18'sb010010001011110010;
            sine_reg0   <= 18'sb100101101010110100;
        end
        3467: begin
            cosine_reg0 <= 18'sb010010001110011000;
            sine_reg0   <= 18'sb100101101100100111;
        end
        3468: begin
            cosine_reg0 <= 18'sb010010010000111101;
            sine_reg0   <= 18'sb100101101110011001;
        end
        3469: begin
            cosine_reg0 <= 18'sb010010010011100010;
            sine_reg0   <= 18'sb100101110000001100;
        end
        3470: begin
            cosine_reg0 <= 18'sb010010010110000111;
            sine_reg0   <= 18'sb100101110001111111;
        end
        3471: begin
            cosine_reg0 <= 18'sb010010011000101011;
            sine_reg0   <= 18'sb100101110011110011;
        end
        3472: begin
            cosine_reg0 <= 18'sb010010011011010000;
            sine_reg0   <= 18'sb100101110101100110;
        end
        3473: begin
            cosine_reg0 <= 18'sb010010011101110100;
            sine_reg0   <= 18'sb100101110111011010;
        end
        3474: begin
            cosine_reg0 <= 18'sb010010100000011000;
            sine_reg0   <= 18'sb100101111001001110;
        end
        3475: begin
            cosine_reg0 <= 18'sb010010100010111100;
            sine_reg0   <= 18'sb100101111011000011;
        end
        3476: begin
            cosine_reg0 <= 18'sb010010100101100000;
            sine_reg0   <= 18'sb100101111100110111;
        end
        3477: begin
            cosine_reg0 <= 18'sb010010101000000011;
            sine_reg0   <= 18'sb100101111110101100;
        end
        3478: begin
            cosine_reg0 <= 18'sb010010101010100111;
            sine_reg0   <= 18'sb100110000000100010;
        end
        3479: begin
            cosine_reg0 <= 18'sb010010101101001010;
            sine_reg0   <= 18'sb100110000010010111;
        end
        3480: begin
            cosine_reg0 <= 18'sb010010101111101101;
            sine_reg0   <= 18'sb100110000100001101;
        end
        3481: begin
            cosine_reg0 <= 18'sb010010110010010000;
            sine_reg0   <= 18'sb100110000110000010;
        end
        3482: begin
            cosine_reg0 <= 18'sb010010110100110011;
            sine_reg0   <= 18'sb100110000111111001;
        end
        3483: begin
            cosine_reg0 <= 18'sb010010110111010101;
            sine_reg0   <= 18'sb100110001001101111;
        end
        3484: begin
            cosine_reg0 <= 18'sb010010111001110111;
            sine_reg0   <= 18'sb100110001011100110;
        end
        3485: begin
            cosine_reg0 <= 18'sb010010111100011010;
            sine_reg0   <= 18'sb100110001101011101;
        end
        3486: begin
            cosine_reg0 <= 18'sb010010111110111100;
            sine_reg0   <= 18'sb100110001111010100;
        end
        3487: begin
            cosine_reg0 <= 18'sb010011000001011101;
            sine_reg0   <= 18'sb100110010001001011;
        end
        3488: begin
            cosine_reg0 <= 18'sb010011000011111111;
            sine_reg0   <= 18'sb100110010011000011;
        end
        3489: begin
            cosine_reg0 <= 18'sb010011000110100000;
            sine_reg0   <= 18'sb100110010100111011;
        end
        3490: begin
            cosine_reg0 <= 18'sb010011001001000010;
            sine_reg0   <= 18'sb100110010110110011;
        end
        3491: begin
            cosine_reg0 <= 18'sb010011001011100011;
            sine_reg0   <= 18'sb100110011000101011;
        end
        3492: begin
            cosine_reg0 <= 18'sb010011001110000011;
            sine_reg0   <= 18'sb100110011010100100;
        end
        3493: begin
            cosine_reg0 <= 18'sb010011010000100100;
            sine_reg0   <= 18'sb100110011100011101;
        end
        3494: begin
            cosine_reg0 <= 18'sb010011010011000101;
            sine_reg0   <= 18'sb100110011110010110;
        end
        3495: begin
            cosine_reg0 <= 18'sb010011010101100101;
            sine_reg0   <= 18'sb100110100000001111;
        end
        3496: begin
            cosine_reg0 <= 18'sb010011011000000101;
            sine_reg0   <= 18'sb100110100010001001;
        end
        3497: begin
            cosine_reg0 <= 18'sb010011011010100101;
            sine_reg0   <= 18'sb100110100100000011;
        end
        3498: begin
            cosine_reg0 <= 18'sb010011011101000101;
            sine_reg0   <= 18'sb100110100101111101;
        end
        3499: begin
            cosine_reg0 <= 18'sb010011011111100100;
            sine_reg0   <= 18'sb100110100111110111;
        end
        3500: begin
            cosine_reg0 <= 18'sb010011100010000011;
            sine_reg0   <= 18'sb100110101001110010;
        end
        3501: begin
            cosine_reg0 <= 18'sb010011100100100011;
            sine_reg0   <= 18'sb100110101011101101;
        end
        3502: begin
            cosine_reg0 <= 18'sb010011100111000010;
            sine_reg0   <= 18'sb100110101101101000;
        end
        3503: begin
            cosine_reg0 <= 18'sb010011101001100000;
            sine_reg0   <= 18'sb100110101111100011;
        end
        3504: begin
            cosine_reg0 <= 18'sb010011101011111111;
            sine_reg0   <= 18'sb100110110001011111;
        end
        3505: begin
            cosine_reg0 <= 18'sb010011101110011101;
            sine_reg0   <= 18'sb100110110011011010;
        end
        3506: begin
            cosine_reg0 <= 18'sb010011110000111100;
            sine_reg0   <= 18'sb100110110101010111;
        end
        3507: begin
            cosine_reg0 <= 18'sb010011110011011010;
            sine_reg0   <= 18'sb100110110111010011;
        end
        3508: begin
            cosine_reg0 <= 18'sb010011110101111000;
            sine_reg0   <= 18'sb100110111001001111;
        end
        3509: begin
            cosine_reg0 <= 18'sb010011111000010101;
            sine_reg0   <= 18'sb100110111011001100;
        end
        3510: begin
            cosine_reg0 <= 18'sb010011111010110011;
            sine_reg0   <= 18'sb100110111101001001;
        end
        3511: begin
            cosine_reg0 <= 18'sb010011111101010000;
            sine_reg0   <= 18'sb100110111111000110;
        end
        3512: begin
            cosine_reg0 <= 18'sb010011111111101101;
            sine_reg0   <= 18'sb100111000001000100;
        end
        3513: begin
            cosine_reg0 <= 18'sb010100000010001010;
            sine_reg0   <= 18'sb100111000011000010;
        end
        3514: begin
            cosine_reg0 <= 18'sb010100000100100111;
            sine_reg0   <= 18'sb100111000101000000;
        end
        3515: begin
            cosine_reg0 <= 18'sb010100000111000011;
            sine_reg0   <= 18'sb100111000110111110;
        end
        3516: begin
            cosine_reg0 <= 18'sb010100001001011111;
            sine_reg0   <= 18'sb100111001000111100;
        end
        3517: begin
            cosine_reg0 <= 18'sb010100001011111011;
            sine_reg0   <= 18'sb100111001010111011;
        end
        3518: begin
            cosine_reg0 <= 18'sb010100001110010111;
            sine_reg0   <= 18'sb100111001100111010;
        end
        3519: begin
            cosine_reg0 <= 18'sb010100010000110011;
            sine_reg0   <= 18'sb100111001110111001;
        end
        3520: begin
            cosine_reg0 <= 18'sb010100010011001111;
            sine_reg0   <= 18'sb100111010000111001;
        end
        3521: begin
            cosine_reg0 <= 18'sb010100010101101010;
            sine_reg0   <= 18'sb100111010010111000;
        end
        3522: begin
            cosine_reg0 <= 18'sb010100011000000101;
            sine_reg0   <= 18'sb100111010100111000;
        end
        3523: begin
            cosine_reg0 <= 18'sb010100011010100000;
            sine_reg0   <= 18'sb100111010110111000;
        end
        3524: begin
            cosine_reg0 <= 18'sb010100011100111011;
            sine_reg0   <= 18'sb100111011000111001;
        end
        3525: begin
            cosine_reg0 <= 18'sb010100011111010101;
            sine_reg0   <= 18'sb100111011010111001;
        end
        3526: begin
            cosine_reg0 <= 18'sb010100100001110000;
            sine_reg0   <= 18'sb100111011100111010;
        end
        3527: begin
            cosine_reg0 <= 18'sb010100100100001010;
            sine_reg0   <= 18'sb100111011110111011;
        end
        3528: begin
            cosine_reg0 <= 18'sb010100100110100100;
            sine_reg0   <= 18'sb100111100000111101;
        end
        3529: begin
            cosine_reg0 <= 18'sb010100101000111101;
            sine_reg0   <= 18'sb100111100010111110;
        end
        3530: begin
            cosine_reg0 <= 18'sb010100101011010111;
            sine_reg0   <= 18'sb100111100101000000;
        end
        3531: begin
            cosine_reg0 <= 18'sb010100101101110000;
            sine_reg0   <= 18'sb100111100111000010;
        end
        3532: begin
            cosine_reg0 <= 18'sb010100110000001001;
            sine_reg0   <= 18'sb100111101001000100;
        end
        3533: begin
            cosine_reg0 <= 18'sb010100110010100010;
            sine_reg0   <= 18'sb100111101011000111;
        end
        3534: begin
            cosine_reg0 <= 18'sb010100110100111011;
            sine_reg0   <= 18'sb100111101101001010;
        end
        3535: begin
            cosine_reg0 <= 18'sb010100110111010100;
            sine_reg0   <= 18'sb100111101111001101;
        end
        3536: begin
            cosine_reg0 <= 18'sb010100111001101100;
            sine_reg0   <= 18'sb100111110001010000;
        end
        3537: begin
            cosine_reg0 <= 18'sb010100111100000100;
            sine_reg0   <= 18'sb100111110011010011;
        end
        3538: begin
            cosine_reg0 <= 18'sb010100111110011100;
            sine_reg0   <= 18'sb100111110101010111;
        end
        3539: begin
            cosine_reg0 <= 18'sb010101000000110100;
            sine_reg0   <= 18'sb100111110111011011;
        end
        3540: begin
            cosine_reg0 <= 18'sb010101000011001011;
            sine_reg0   <= 18'sb100111111001011111;
        end
        3541: begin
            cosine_reg0 <= 18'sb010101000101100011;
            sine_reg0   <= 18'sb100111111011100011;
        end
        3542: begin
            cosine_reg0 <= 18'sb010101000111111010;
            sine_reg0   <= 18'sb100111111101101000;
        end
        3543: begin
            cosine_reg0 <= 18'sb010101001010010001;
            sine_reg0   <= 18'sb100111111111101101;
        end
        3544: begin
            cosine_reg0 <= 18'sb010101001100100111;
            sine_reg0   <= 18'sb101000000001110010;
        end
        3545: begin
            cosine_reg0 <= 18'sb010101001110111110;
            sine_reg0   <= 18'sb101000000011110111;
        end
        3546: begin
            cosine_reg0 <= 18'sb010101010001010100;
            sine_reg0   <= 18'sb101000000101111101;
        end
        3547: begin
            cosine_reg0 <= 18'sb010101010011101010;
            sine_reg0   <= 18'sb101000001000000011;
        end
        3548: begin
            cosine_reg0 <= 18'sb010101010110000000;
            sine_reg0   <= 18'sb101000001010001001;
        end
        3549: begin
            cosine_reg0 <= 18'sb010101011000010110;
            sine_reg0   <= 18'sb101000001100001111;
        end
        3550: begin
            cosine_reg0 <= 18'sb010101011010101100;
            sine_reg0   <= 18'sb101000001110010101;
        end
        3551: begin
            cosine_reg0 <= 18'sb010101011101000001;
            sine_reg0   <= 18'sb101000010000011100;
        end
        3552: begin
            cosine_reg0 <= 18'sb010101011111010110;
            sine_reg0   <= 18'sb101000010010100011;
        end
        3553: begin
            cosine_reg0 <= 18'sb010101100001101011;
            sine_reg0   <= 18'sb101000010100101010;
        end
        3554: begin
            cosine_reg0 <= 18'sb010101100011111111;
            sine_reg0   <= 18'sb101000010110110001;
        end
        3555: begin
            cosine_reg0 <= 18'sb010101100110010100;
            sine_reg0   <= 18'sb101000011000111001;
        end
        3556: begin
            cosine_reg0 <= 18'sb010101101000101000;
            sine_reg0   <= 18'sb101000011011000001;
        end
        3557: begin
            cosine_reg0 <= 18'sb010101101010111100;
            sine_reg0   <= 18'sb101000011101001001;
        end
        3558: begin
            cosine_reg0 <= 18'sb010101101101010000;
            sine_reg0   <= 18'sb101000011111010001;
        end
        3559: begin
            cosine_reg0 <= 18'sb010101101111100100;
            sine_reg0   <= 18'sb101000100001011010;
        end
        3560: begin
            cosine_reg0 <= 18'sb010101110001110111;
            sine_reg0   <= 18'sb101000100011100010;
        end
        3561: begin
            cosine_reg0 <= 18'sb010101110100001010;
            sine_reg0   <= 18'sb101000100101101011;
        end
        3562: begin
            cosine_reg0 <= 18'sb010101110110011101;
            sine_reg0   <= 18'sb101000100111110100;
        end
        3563: begin
            cosine_reg0 <= 18'sb010101111000110000;
            sine_reg0   <= 18'sb101000101001111110;
        end
        3564: begin
            cosine_reg0 <= 18'sb010101111011000011;
            sine_reg0   <= 18'sb101000101100000111;
        end
        3565: begin
            cosine_reg0 <= 18'sb010101111101010101;
            sine_reg0   <= 18'sb101000101110010001;
        end
        3566: begin
            cosine_reg0 <= 18'sb010101111111100111;
            sine_reg0   <= 18'sb101000110000011011;
        end
        3567: begin
            cosine_reg0 <= 18'sb010110000001111001;
            sine_reg0   <= 18'sb101000110010100110;
        end
        3568: begin
            cosine_reg0 <= 18'sb010110000100001011;
            sine_reg0   <= 18'sb101000110100110000;
        end
        3569: begin
            cosine_reg0 <= 18'sb010110000110011100;
            sine_reg0   <= 18'sb101000110110111011;
        end
        3570: begin
            cosine_reg0 <= 18'sb010110001000101110;
            sine_reg0   <= 18'sb101000111001000110;
        end
        3571: begin
            cosine_reg0 <= 18'sb010110001010111111;
            sine_reg0   <= 18'sb101000111011010001;
        end
        3572: begin
            cosine_reg0 <= 18'sb010110001101010000;
            sine_reg0   <= 18'sb101000111101011101;
        end
        3573: begin
            cosine_reg0 <= 18'sb010110001111100000;
            sine_reg0   <= 18'sb101000111111101000;
        end
        3574: begin
            cosine_reg0 <= 18'sb010110010001110001;
            sine_reg0   <= 18'sb101001000001110100;
        end
        3575: begin
            cosine_reg0 <= 18'sb010110010100000001;
            sine_reg0   <= 18'sb101001000100000000;
        end
        3576: begin
            cosine_reg0 <= 18'sb010110010110010001;
            sine_reg0   <= 18'sb101001000110001100;
        end
        3577: begin
            cosine_reg0 <= 18'sb010110011000100001;
            sine_reg0   <= 18'sb101001001000011001;
        end
        3578: begin
            cosine_reg0 <= 18'sb010110011010110000;
            sine_reg0   <= 18'sb101001001010100110;
        end
        3579: begin
            cosine_reg0 <= 18'sb010110011101000000;
            sine_reg0   <= 18'sb101001001100110011;
        end
        3580: begin
            cosine_reg0 <= 18'sb010110011111001111;
            sine_reg0   <= 18'sb101001001111000000;
        end
        3581: begin
            cosine_reg0 <= 18'sb010110100001011110;
            sine_reg0   <= 18'sb101001010001001101;
        end
        3582: begin
            cosine_reg0 <= 18'sb010110100011101100;
            sine_reg0   <= 18'sb101001010011011011;
        end
        3583: begin
            cosine_reg0 <= 18'sb010110100101111011;
            sine_reg0   <= 18'sb101001010101101001;
        end
        3584: begin
            cosine_reg0 <= 18'sb010110101000001001;
            sine_reg0   <= 18'sb101001010111110111;
        end
        3585: begin
            cosine_reg0 <= 18'sb010110101010010111;
            sine_reg0   <= 18'sb101001011010000101;
        end
        3586: begin
            cosine_reg0 <= 18'sb010110101100100101;
            sine_reg0   <= 18'sb101001011100010100;
        end
        3587: begin
            cosine_reg0 <= 18'sb010110101110110011;
            sine_reg0   <= 18'sb101001011110100010;
        end
        3588: begin
            cosine_reg0 <= 18'sb010110110001000000;
            sine_reg0   <= 18'sb101001100000110001;
        end
        3589: begin
            cosine_reg0 <= 18'sb010110110011001101;
            sine_reg0   <= 18'sb101001100011000000;
        end
        3590: begin
            cosine_reg0 <= 18'sb010110110101011010;
            sine_reg0   <= 18'sb101001100101010000;
        end
        3591: begin
            cosine_reg0 <= 18'sb010110110111100111;
            sine_reg0   <= 18'sb101001100111011111;
        end
        3592: begin
            cosine_reg0 <= 18'sb010110111001110100;
            sine_reg0   <= 18'sb101001101001101111;
        end
        3593: begin
            cosine_reg0 <= 18'sb010110111100000000;
            sine_reg0   <= 18'sb101001101011111111;
        end
        3594: begin
            cosine_reg0 <= 18'sb010110111110001100;
            sine_reg0   <= 18'sb101001101110001111;
        end
        3595: begin
            cosine_reg0 <= 18'sb010111000000011000;
            sine_reg0   <= 18'sb101001110000100000;
        end
        3596: begin
            cosine_reg0 <= 18'sb010111000010100011;
            sine_reg0   <= 18'sb101001110010110000;
        end
        3597: begin
            cosine_reg0 <= 18'sb010111000100101111;
            sine_reg0   <= 18'sb101001110101000001;
        end
        3598: begin
            cosine_reg0 <= 18'sb010111000110111010;
            sine_reg0   <= 18'sb101001110111010010;
        end
        3599: begin
            cosine_reg0 <= 18'sb010111001001000101;
            sine_reg0   <= 18'sb101001111001100100;
        end
        3600: begin
            cosine_reg0 <= 18'sb010111001011010000;
            sine_reg0   <= 18'sb101001111011110101;
        end
        3601: begin
            cosine_reg0 <= 18'sb010111001101011010;
            sine_reg0   <= 18'sb101001111110000111;
        end
        3602: begin
            cosine_reg0 <= 18'sb010111001111100101;
            sine_reg0   <= 18'sb101010000000011001;
        end
        3603: begin
            cosine_reg0 <= 18'sb010111010001101111;
            sine_reg0   <= 18'sb101010000010101011;
        end
        3604: begin
            cosine_reg0 <= 18'sb010111010011111001;
            sine_reg0   <= 18'sb101010000100111101;
        end
        3605: begin
            cosine_reg0 <= 18'sb010111010110000010;
            sine_reg0   <= 18'sb101010000111010000;
        end
        3606: begin
            cosine_reg0 <= 18'sb010111011000001100;
            sine_reg0   <= 18'sb101010001001100011;
        end
        3607: begin
            cosine_reg0 <= 18'sb010111011010010101;
            sine_reg0   <= 18'sb101010001011110110;
        end
        3608: begin
            cosine_reg0 <= 18'sb010111011100011110;
            sine_reg0   <= 18'sb101010001110001001;
        end
        3609: begin
            cosine_reg0 <= 18'sb010111011110100110;
            sine_reg0   <= 18'sb101010010000011100;
        end
        3610: begin
            cosine_reg0 <= 18'sb010111100000101111;
            sine_reg0   <= 18'sb101010010010110000;
        end
        3611: begin
            cosine_reg0 <= 18'sb010111100010110111;
            sine_reg0   <= 18'sb101010010101000100;
        end
        3612: begin
            cosine_reg0 <= 18'sb010111100100111111;
            sine_reg0   <= 18'sb101010010111011000;
        end
        3613: begin
            cosine_reg0 <= 18'sb010111100111000111;
            sine_reg0   <= 18'sb101010011001101100;
        end
        3614: begin
            cosine_reg0 <= 18'sb010111101001001111;
            sine_reg0   <= 18'sb101010011100000001;
        end
        3615: begin
            cosine_reg0 <= 18'sb010111101011010110;
            sine_reg0   <= 18'sb101010011110010101;
        end
        3616: begin
            cosine_reg0 <= 18'sb010111101101011101;
            sine_reg0   <= 18'sb101010100000101010;
        end
        3617: begin
            cosine_reg0 <= 18'sb010111101111100100;
            sine_reg0   <= 18'sb101010100010111111;
        end
        3618: begin
            cosine_reg0 <= 18'sb010111110001101011;
            sine_reg0   <= 18'sb101010100101010100;
        end
        3619: begin
            cosine_reg0 <= 18'sb010111110011110001;
            sine_reg0   <= 18'sb101010100111101010;
        end
        3620: begin
            cosine_reg0 <= 18'sb010111110101110111;
            sine_reg0   <= 18'sb101010101010000000;
        end
        3621: begin
            cosine_reg0 <= 18'sb010111110111111101;
            sine_reg0   <= 18'sb101010101100010110;
        end
        3622: begin
            cosine_reg0 <= 18'sb010111111010000011;
            sine_reg0   <= 18'sb101010101110101100;
        end
        3623: begin
            cosine_reg0 <= 18'sb010111111100001001;
            sine_reg0   <= 18'sb101010110001000010;
        end
        3624: begin
            cosine_reg0 <= 18'sb010111111110001110;
            sine_reg0   <= 18'sb101010110011011001;
        end
        3625: begin
            cosine_reg0 <= 18'sb011000000000010011;
            sine_reg0   <= 18'sb101010110101101111;
        end
        3626: begin
            cosine_reg0 <= 18'sb011000000010011000;
            sine_reg0   <= 18'sb101010111000000110;
        end
        3627: begin
            cosine_reg0 <= 18'sb011000000100011101;
            sine_reg0   <= 18'sb101010111010011101;
        end
        3628: begin
            cosine_reg0 <= 18'sb011000000110100001;
            sine_reg0   <= 18'sb101010111100110101;
        end
        3629: begin
            cosine_reg0 <= 18'sb011000001000100101;
            sine_reg0   <= 18'sb101010111111001100;
        end
        3630: begin
            cosine_reg0 <= 18'sb011000001010101001;
            sine_reg0   <= 18'sb101011000001100100;
        end
        3631: begin
            cosine_reg0 <= 18'sb011000001100101101;
            sine_reg0   <= 18'sb101011000011111100;
        end
        3632: begin
            cosine_reg0 <= 18'sb011000001110110000;
            sine_reg0   <= 18'sb101011000110010100;
        end
        3633: begin
            cosine_reg0 <= 18'sb011000010000110011;
            sine_reg0   <= 18'sb101011001000101100;
        end
        3634: begin
            cosine_reg0 <= 18'sb011000010010110110;
            sine_reg0   <= 18'sb101011001011000101;
        end
        3635: begin
            cosine_reg0 <= 18'sb011000010100111001;
            sine_reg0   <= 18'sb101011001101011110;
        end
        3636: begin
            cosine_reg0 <= 18'sb011000010110111100;
            sine_reg0   <= 18'sb101011001111110111;
        end
        3637: begin
            cosine_reg0 <= 18'sb011000011000111110;
            sine_reg0   <= 18'sb101011010010010000;
        end
        3638: begin
            cosine_reg0 <= 18'sb011000011011000000;
            sine_reg0   <= 18'sb101011010100101001;
        end
        3639: begin
            cosine_reg0 <= 18'sb011000011101000010;
            sine_reg0   <= 18'sb101011010111000011;
        end
        3640: begin
            cosine_reg0 <= 18'sb011000011111000011;
            sine_reg0   <= 18'sb101011011001011100;
        end
        3641: begin
            cosine_reg0 <= 18'sb011000100001000101;
            sine_reg0   <= 18'sb101011011011110110;
        end
        3642: begin
            cosine_reg0 <= 18'sb011000100011000110;
            sine_reg0   <= 18'sb101011011110010000;
        end
        3643: begin
            cosine_reg0 <= 18'sb011000100101000111;
            sine_reg0   <= 18'sb101011100000101011;
        end
        3644: begin
            cosine_reg0 <= 18'sb011000100111000111;
            sine_reg0   <= 18'sb101011100011000101;
        end
        3645: begin
            cosine_reg0 <= 18'sb011000101001001000;
            sine_reg0   <= 18'sb101011100101100000;
        end
        3646: begin
            cosine_reg0 <= 18'sb011000101011001000;
            sine_reg0   <= 18'sb101011100111111011;
        end
        3647: begin
            cosine_reg0 <= 18'sb011000101101001000;
            sine_reg0   <= 18'sb101011101010010110;
        end
        3648: begin
            cosine_reg0 <= 18'sb011000101111000111;
            sine_reg0   <= 18'sb101011101100110001;
        end
        3649: begin
            cosine_reg0 <= 18'sb011000110001000111;
            sine_reg0   <= 18'sb101011101111001101;
        end
        3650: begin
            cosine_reg0 <= 18'sb011000110011000110;
            sine_reg0   <= 18'sb101011110001101001;
        end
        3651: begin
            cosine_reg0 <= 18'sb011000110101000101;
            sine_reg0   <= 18'sb101011110100000101;
        end
        3652: begin
            cosine_reg0 <= 18'sb011000110111000100;
            sine_reg0   <= 18'sb101011110110100001;
        end
        3653: begin
            cosine_reg0 <= 18'sb011000111001000010;
            sine_reg0   <= 18'sb101011111000111101;
        end
        3654: begin
            cosine_reg0 <= 18'sb011000111011000000;
            sine_reg0   <= 18'sb101011111011011001;
        end
        3655: begin
            cosine_reg0 <= 18'sb011000111100111110;
            sine_reg0   <= 18'sb101011111101110110;
        end
        3656: begin
            cosine_reg0 <= 18'sb011000111110111100;
            sine_reg0   <= 18'sb101100000000010011;
        end
        3657: begin
            cosine_reg0 <= 18'sb011001000000111010;
            sine_reg0   <= 18'sb101100000010110000;
        end
        3658: begin
            cosine_reg0 <= 18'sb011001000010110111;
            sine_reg0   <= 18'sb101100000101001101;
        end
        3659: begin
            cosine_reg0 <= 18'sb011001000100110100;
            sine_reg0   <= 18'sb101100000111101011;
        end
        3660: begin
            cosine_reg0 <= 18'sb011001000110110001;
            sine_reg0   <= 18'sb101100001010001000;
        end
        3661: begin
            cosine_reg0 <= 18'sb011001001000101101;
            sine_reg0   <= 18'sb101100001100100110;
        end
        3662: begin
            cosine_reg0 <= 18'sb011001001010101001;
            sine_reg0   <= 18'sb101100001111000100;
        end
        3663: begin
            cosine_reg0 <= 18'sb011001001100100110;
            sine_reg0   <= 18'sb101100010001100011;
        end
        3664: begin
            cosine_reg0 <= 18'sb011001001110100001;
            sine_reg0   <= 18'sb101100010100000001;
        end
        3665: begin
            cosine_reg0 <= 18'sb011001010000011101;
            sine_reg0   <= 18'sb101100010110100000;
        end
        3666: begin
            cosine_reg0 <= 18'sb011001010010011000;
            sine_reg0   <= 18'sb101100011000111110;
        end
        3667: begin
            cosine_reg0 <= 18'sb011001010100010011;
            sine_reg0   <= 18'sb101100011011011101;
        end
        3668: begin
            cosine_reg0 <= 18'sb011001010110001110;
            sine_reg0   <= 18'sb101100011101111101;
        end
        3669: begin
            cosine_reg0 <= 18'sb011001011000001001;
            sine_reg0   <= 18'sb101100100000011100;
        end
        3670: begin
            cosine_reg0 <= 18'sb011001011010000011;
            sine_reg0   <= 18'sb101100100010111011;
        end
        3671: begin
            cosine_reg0 <= 18'sb011001011011111101;
            sine_reg0   <= 18'sb101100100101011011;
        end
        3672: begin
            cosine_reg0 <= 18'sb011001011101110111;
            sine_reg0   <= 18'sb101100100111111011;
        end
        3673: begin
            cosine_reg0 <= 18'sb011001011111110001;
            sine_reg0   <= 18'sb101100101010011011;
        end
        3674: begin
            cosine_reg0 <= 18'sb011001100001101010;
            sine_reg0   <= 18'sb101100101100111011;
        end
        3675: begin
            cosine_reg0 <= 18'sb011001100011100011;
            sine_reg0   <= 18'sb101100101111011100;
        end
        3676: begin
            cosine_reg0 <= 18'sb011001100101011100;
            sine_reg0   <= 18'sb101100110001111101;
        end
        3677: begin
            cosine_reg0 <= 18'sb011001100111010101;
            sine_reg0   <= 18'sb101100110100011101;
        end
        3678: begin
            cosine_reg0 <= 18'sb011001101001001101;
            sine_reg0   <= 18'sb101100110110111110;
        end
        3679: begin
            cosine_reg0 <= 18'sb011001101011000101;
            sine_reg0   <= 18'sb101100111001100000;
        end
        3680: begin
            cosine_reg0 <= 18'sb011001101100111101;
            sine_reg0   <= 18'sb101100111100000001;
        end
        3681: begin
            cosine_reg0 <= 18'sb011001101110110101;
            sine_reg0   <= 18'sb101100111110100011;
        end
        3682: begin
            cosine_reg0 <= 18'sb011001110000101100;
            sine_reg0   <= 18'sb101101000001000100;
        end
        3683: begin
            cosine_reg0 <= 18'sb011001110010100011;
            sine_reg0   <= 18'sb101101000011100110;
        end
        3684: begin
            cosine_reg0 <= 18'sb011001110100011010;
            sine_reg0   <= 18'sb101101000110001001;
        end
        3685: begin
            cosine_reg0 <= 18'sb011001110110010001;
            sine_reg0   <= 18'sb101101001000101011;
        end
        3686: begin
            cosine_reg0 <= 18'sb011001111000000111;
            sine_reg0   <= 18'sb101101001011001101;
        end
        3687: begin
            cosine_reg0 <= 18'sb011001111001111110;
            sine_reg0   <= 18'sb101101001101110000;
        end
        3688: begin
            cosine_reg0 <= 18'sb011001111011110011;
            sine_reg0   <= 18'sb101101010000010011;
        end
        3689: begin
            cosine_reg0 <= 18'sb011001111101101001;
            sine_reg0   <= 18'sb101101010010110110;
        end
        3690: begin
            cosine_reg0 <= 18'sb011001111111011110;
            sine_reg0   <= 18'sb101101010101011001;
        end
        3691: begin
            cosine_reg0 <= 18'sb011010000001010100;
            sine_reg0   <= 18'sb101101010111111101;
        end
        3692: begin
            cosine_reg0 <= 18'sb011010000011001001;
            sine_reg0   <= 18'sb101101011010100000;
        end
        3693: begin
            cosine_reg0 <= 18'sb011010000100111101;
            sine_reg0   <= 18'sb101101011101000100;
        end
        3694: begin
            cosine_reg0 <= 18'sb011010000110110010;
            sine_reg0   <= 18'sb101101011111101000;
        end
        3695: begin
            cosine_reg0 <= 18'sb011010001000100110;
            sine_reg0   <= 18'sb101101100010001100;
        end
        3696: begin
            cosine_reg0 <= 18'sb011010001010011010;
            sine_reg0   <= 18'sb101101100100110000;
        end
        3697: begin
            cosine_reg0 <= 18'sb011010001100001101;
            sine_reg0   <= 18'sb101101100111010101;
        end
        3698: begin
            cosine_reg0 <= 18'sb011010001110000001;
            sine_reg0   <= 18'sb101101101001111001;
        end
        3699: begin
            cosine_reg0 <= 18'sb011010001111110100;
            sine_reg0   <= 18'sb101101101100011110;
        end
        3700: begin
            cosine_reg0 <= 18'sb011010010001100111;
            sine_reg0   <= 18'sb101101101111000011;
        end
        3701: begin
            cosine_reg0 <= 18'sb011010010011011001;
            sine_reg0   <= 18'sb101101110001101000;
        end
        3702: begin
            cosine_reg0 <= 18'sb011010010101001100;
            sine_reg0   <= 18'sb101101110100001110;
        end
        3703: begin
            cosine_reg0 <= 18'sb011010010110111110;
            sine_reg0   <= 18'sb101101110110110011;
        end
        3704: begin
            cosine_reg0 <= 18'sb011010011000110000;
            sine_reg0   <= 18'sb101101111001011001;
        end
        3705: begin
            cosine_reg0 <= 18'sb011010011010100001;
            sine_reg0   <= 18'sb101101111011111111;
        end
        3706: begin
            cosine_reg0 <= 18'sb011010011100010011;
            sine_reg0   <= 18'sb101101111110100101;
        end
        3707: begin
            cosine_reg0 <= 18'sb011010011110000100;
            sine_reg0   <= 18'sb101110000001001011;
        end
        3708: begin
            cosine_reg0 <= 18'sb011010011111110101;
            sine_reg0   <= 18'sb101110000011110010;
        end
        3709: begin
            cosine_reg0 <= 18'sb011010100001100101;
            sine_reg0   <= 18'sb101110000110011000;
        end
        3710: begin
            cosine_reg0 <= 18'sb011010100011010110;
            sine_reg0   <= 18'sb101110001000111111;
        end
        3711: begin
            cosine_reg0 <= 18'sb011010100101000110;
            sine_reg0   <= 18'sb101110001011100110;
        end
        3712: begin
            cosine_reg0 <= 18'sb011010100110110110;
            sine_reg0   <= 18'sb101110001110001101;
        end
        3713: begin
            cosine_reg0 <= 18'sb011010101000100101;
            sine_reg0   <= 18'sb101110010000110100;
        end
        3714: begin
            cosine_reg0 <= 18'sb011010101010010100;
            sine_reg0   <= 18'sb101110010011011100;
        end
        3715: begin
            cosine_reg0 <= 18'sb011010101100000100;
            sine_reg0   <= 18'sb101110010110000011;
        end
        3716: begin
            cosine_reg0 <= 18'sb011010101101110010;
            sine_reg0   <= 18'sb101110011000101011;
        end
        3717: begin
            cosine_reg0 <= 18'sb011010101111100001;
            sine_reg0   <= 18'sb101110011011010011;
        end
        3718: begin
            cosine_reg0 <= 18'sb011010110001001111;
            sine_reg0   <= 18'sb101110011101111011;
        end
        3719: begin
            cosine_reg0 <= 18'sb011010110010111101;
            sine_reg0   <= 18'sb101110100000100011;
        end
        3720: begin
            cosine_reg0 <= 18'sb011010110100101011;
            sine_reg0   <= 18'sb101110100011001100;
        end
        3721: begin
            cosine_reg0 <= 18'sb011010110110011000;
            sine_reg0   <= 18'sb101110100101110100;
        end
        3722: begin
            cosine_reg0 <= 18'sb011010111000000110;
            sine_reg0   <= 18'sb101110101000011101;
        end
        3723: begin
            cosine_reg0 <= 18'sb011010111001110011;
            sine_reg0   <= 18'sb101110101011000110;
        end
        3724: begin
            cosine_reg0 <= 18'sb011010111011011111;
            sine_reg0   <= 18'sb101110101101101111;
        end
        3725: begin
            cosine_reg0 <= 18'sb011010111101001100;
            sine_reg0   <= 18'sb101110110000011000;
        end
        3726: begin
            cosine_reg0 <= 18'sb011010111110111000;
            sine_reg0   <= 18'sb101110110011000010;
        end
        3727: begin
            cosine_reg0 <= 18'sb011011000000100100;
            sine_reg0   <= 18'sb101110110101101100;
        end
        3728: begin
            cosine_reg0 <= 18'sb011011000010010000;
            sine_reg0   <= 18'sb101110111000010101;
        end
        3729: begin
            cosine_reg0 <= 18'sb011011000011111011;
            sine_reg0   <= 18'sb101110111010111111;
        end
        3730: begin
            cosine_reg0 <= 18'sb011011000101100110;
            sine_reg0   <= 18'sb101110111101101001;
        end
        3731: begin
            cosine_reg0 <= 18'sb011011000111010001;
            sine_reg0   <= 18'sb101111000000010100;
        end
        3732: begin
            cosine_reg0 <= 18'sb011011001000111100;
            sine_reg0   <= 18'sb101111000010111110;
        end
        3733: begin
            cosine_reg0 <= 18'sb011011001010100110;
            sine_reg0   <= 18'sb101111000101101001;
        end
        3734: begin
            cosine_reg0 <= 18'sb011011001100010001;
            sine_reg0   <= 18'sb101111001000010011;
        end
        3735: begin
            cosine_reg0 <= 18'sb011011001101111010;
            sine_reg0   <= 18'sb101111001010111110;
        end
        3736: begin
            cosine_reg0 <= 18'sb011011001111100100;
            sine_reg0   <= 18'sb101111001101101010;
        end
        3737: begin
            cosine_reg0 <= 18'sb011011010001001101;
            sine_reg0   <= 18'sb101111010000010101;
        end
        3738: begin
            cosine_reg0 <= 18'sb011011010010110110;
            sine_reg0   <= 18'sb101111010011000000;
        end
        3739: begin
            cosine_reg0 <= 18'sb011011010100011111;
            sine_reg0   <= 18'sb101111010101101100;
        end
        3740: begin
            cosine_reg0 <= 18'sb011011010110001000;
            sine_reg0   <= 18'sb101111011000010111;
        end
        3741: begin
            cosine_reg0 <= 18'sb011011010111110000;
            sine_reg0   <= 18'sb101111011011000011;
        end
        3742: begin
            cosine_reg0 <= 18'sb011011011001011000;
            sine_reg0   <= 18'sb101111011101101111;
        end
        3743: begin
            cosine_reg0 <= 18'sb011011011011000000;
            sine_reg0   <= 18'sb101111100000011100;
        end
        3744: begin
            cosine_reg0 <= 18'sb011011011100100111;
            sine_reg0   <= 18'sb101111100011001000;
        end
        3745: begin
            cosine_reg0 <= 18'sb011011011110001111;
            sine_reg0   <= 18'sb101111100101110101;
        end
        3746: begin
            cosine_reg0 <= 18'sb011011011111110110;
            sine_reg0   <= 18'sb101111101000100001;
        end
        3747: begin
            cosine_reg0 <= 18'sb011011100001011100;
            sine_reg0   <= 18'sb101111101011001110;
        end
        3748: begin
            cosine_reg0 <= 18'sb011011100011000011;
            sine_reg0   <= 18'sb101111101101111011;
        end
        3749: begin
            cosine_reg0 <= 18'sb011011100100101001;
            sine_reg0   <= 18'sb101111110000101000;
        end
        3750: begin
            cosine_reg0 <= 18'sb011011100110001111;
            sine_reg0   <= 18'sb101111110011010110;
        end
        3751: begin
            cosine_reg0 <= 18'sb011011100111110100;
            sine_reg0   <= 18'sb101111110110000011;
        end
        3752: begin
            cosine_reg0 <= 18'sb011011101001011010;
            sine_reg0   <= 18'sb101111111000110001;
        end
        3753: begin
            cosine_reg0 <= 18'sb011011101010111111;
            sine_reg0   <= 18'sb101111111011011111;
        end
        3754: begin
            cosine_reg0 <= 18'sb011011101100100100;
            sine_reg0   <= 18'sb101111111110001100;
        end
        3755: begin
            cosine_reg0 <= 18'sb011011101110001000;
            sine_reg0   <= 18'sb110000000000111011;
        end
        3756: begin
            cosine_reg0 <= 18'sb011011101111101101;
            sine_reg0   <= 18'sb110000000011101001;
        end
        3757: begin
            cosine_reg0 <= 18'sb011011110001010001;
            sine_reg0   <= 18'sb110000000110010111;
        end
        3758: begin
            cosine_reg0 <= 18'sb011011110010110100;
            sine_reg0   <= 18'sb110000001001000110;
        end
        3759: begin
            cosine_reg0 <= 18'sb011011110100011000;
            sine_reg0   <= 18'sb110000001011110100;
        end
        3760: begin
            cosine_reg0 <= 18'sb011011110101111011;
            sine_reg0   <= 18'sb110000001110100011;
        end
        3761: begin
            cosine_reg0 <= 18'sb011011110111011110;
            sine_reg0   <= 18'sb110000010001010010;
        end
        3762: begin
            cosine_reg0 <= 18'sb011011111001000001;
            sine_reg0   <= 18'sb110000010100000010;
        end
        3763: begin
            cosine_reg0 <= 18'sb011011111010100011;
            sine_reg0   <= 18'sb110000010110110001;
        end
        3764: begin
            cosine_reg0 <= 18'sb011011111100000101;
            sine_reg0   <= 18'sb110000011001100000;
        end
        3765: begin
            cosine_reg0 <= 18'sb011011111101100111;
            sine_reg0   <= 18'sb110000011100010000;
        end
        3766: begin
            cosine_reg0 <= 18'sb011011111111001001;
            sine_reg0   <= 18'sb110000011111000000;
        end
        3767: begin
            cosine_reg0 <= 18'sb011100000000101010;
            sine_reg0   <= 18'sb110000100001110000;
        end
        3768: begin
            cosine_reg0 <= 18'sb011100000010001011;
            sine_reg0   <= 18'sb110000100100100000;
        end
        3769: begin
            cosine_reg0 <= 18'sb011100000011101100;
            sine_reg0   <= 18'sb110000100111010000;
        end
        3770: begin
            cosine_reg0 <= 18'sb011100000101001101;
            sine_reg0   <= 18'sb110000101010000000;
        end
        3771: begin
            cosine_reg0 <= 18'sb011100000110101101;
            sine_reg0   <= 18'sb110000101100110001;
        end
        3772: begin
            cosine_reg0 <= 18'sb011100001000001101;
            sine_reg0   <= 18'sb110000101111100001;
        end
        3773: begin
            cosine_reg0 <= 18'sb011100001001101101;
            sine_reg0   <= 18'sb110000110010010010;
        end
        3774: begin
            cosine_reg0 <= 18'sb011100001011001100;
            sine_reg0   <= 18'sb110000110101000011;
        end
        3775: begin
            cosine_reg0 <= 18'sb011100001100101011;
            sine_reg0   <= 18'sb110000110111110100;
        end
        3776: begin
            cosine_reg0 <= 18'sb011100001110001010;
            sine_reg0   <= 18'sb110000111010100110;
        end
        3777: begin
            cosine_reg0 <= 18'sb011100001111101001;
            sine_reg0   <= 18'sb110000111101010111;
        end
        3778: begin
            cosine_reg0 <= 18'sb011100010001000111;
            sine_reg0   <= 18'sb110001000000001000;
        end
        3779: begin
            cosine_reg0 <= 18'sb011100010010100101;
            sine_reg0   <= 18'sb110001000010111010;
        end
        3780: begin
            cosine_reg0 <= 18'sb011100010100000011;
            sine_reg0   <= 18'sb110001000101101100;
        end
        3781: begin
            cosine_reg0 <= 18'sb011100010101100001;
            sine_reg0   <= 18'sb110001001000011110;
        end
        3782: begin
            cosine_reg0 <= 18'sb011100010110111110;
            sine_reg0   <= 18'sb110001001011010000;
        end
        3783: begin
            cosine_reg0 <= 18'sb011100011000011011;
            sine_reg0   <= 18'sb110001001110000010;
        end
        3784: begin
            cosine_reg0 <= 18'sb011100011001111000;
            sine_reg0   <= 18'sb110001010000110101;
        end
        3785: begin
            cosine_reg0 <= 18'sb011100011011010100;
            sine_reg0   <= 18'sb110001010011100111;
        end
        3786: begin
            cosine_reg0 <= 18'sb011100011100110000;
            sine_reg0   <= 18'sb110001010110011010;
        end
        3787: begin
            cosine_reg0 <= 18'sb011100011110001100;
            sine_reg0   <= 18'sb110001011001001101;
        end
        3788: begin
            cosine_reg0 <= 18'sb011100011111101000;
            sine_reg0   <= 18'sb110001011100000000;
        end
        3789: begin
            cosine_reg0 <= 18'sb011100100001000011;
            sine_reg0   <= 18'sb110001011110110011;
        end
        3790: begin
            cosine_reg0 <= 18'sb011100100010011110;
            sine_reg0   <= 18'sb110001100001100110;
        end
        3791: begin
            cosine_reg0 <= 18'sb011100100011111001;
            sine_reg0   <= 18'sb110001100100011001;
        end
        3792: begin
            cosine_reg0 <= 18'sb011100100101010100;
            sine_reg0   <= 18'sb110001100111001101;
        end
        3793: begin
            cosine_reg0 <= 18'sb011100100110101110;
            sine_reg0   <= 18'sb110001101010000001;
        end
        3794: begin
            cosine_reg0 <= 18'sb011100101000001000;
            sine_reg0   <= 18'sb110001101100110100;
        end
        3795: begin
            cosine_reg0 <= 18'sb011100101001100010;
            sine_reg0   <= 18'sb110001101111101000;
        end
        3796: begin
            cosine_reg0 <= 18'sb011100101010111011;
            sine_reg0   <= 18'sb110001110010011100;
        end
        3797: begin
            cosine_reg0 <= 18'sb011100101100010100;
            sine_reg0   <= 18'sb110001110101010001;
        end
        3798: begin
            cosine_reg0 <= 18'sb011100101101101101;
            sine_reg0   <= 18'sb110001111000000101;
        end
        3799: begin
            cosine_reg0 <= 18'sb011100101111000110;
            sine_reg0   <= 18'sb110001111010111010;
        end
        3800: begin
            cosine_reg0 <= 18'sb011100110000011110;
            sine_reg0   <= 18'sb110001111101101110;
        end
        3801: begin
            cosine_reg0 <= 18'sb011100110001110110;
            sine_reg0   <= 18'sb110010000000100011;
        end
        3802: begin
            cosine_reg0 <= 18'sb011100110011001110;
            sine_reg0   <= 18'sb110010000011011000;
        end
        3803: begin
            cosine_reg0 <= 18'sb011100110100100101;
            sine_reg0   <= 18'sb110010000110001101;
        end
        3804: begin
            cosine_reg0 <= 18'sb011100110101111101;
            sine_reg0   <= 18'sb110010001001000010;
        end
        3805: begin
            cosine_reg0 <= 18'sb011100110111010100;
            sine_reg0   <= 18'sb110010001011110111;
        end
        3806: begin
            cosine_reg0 <= 18'sb011100111000101010;
            sine_reg0   <= 18'sb110010001110101101;
        end
        3807: begin
            cosine_reg0 <= 18'sb011100111010000001;
            sine_reg0   <= 18'sb110010010001100010;
        end
        3808: begin
            cosine_reg0 <= 18'sb011100111011010111;
            sine_reg0   <= 18'sb110010010100011000;
        end
        3809: begin
            cosine_reg0 <= 18'sb011100111100101101;
            sine_reg0   <= 18'sb110010010111001110;
        end
        3810: begin
            cosine_reg0 <= 18'sb011100111110000010;
            sine_reg0   <= 18'sb110010011010000100;
        end
        3811: begin
            cosine_reg0 <= 18'sb011100111111010111;
            sine_reg0   <= 18'sb110010011100111010;
        end
        3812: begin
            cosine_reg0 <= 18'sb011101000000101100;
            sine_reg0   <= 18'sb110010011111110000;
        end
        3813: begin
            cosine_reg0 <= 18'sb011101000010000001;
            sine_reg0   <= 18'sb110010100010100110;
        end
        3814: begin
            cosine_reg0 <= 18'sb011101000011010110;
            sine_reg0   <= 18'sb110010100101011101;
        end
        3815: begin
            cosine_reg0 <= 18'sb011101000100101010;
            sine_reg0   <= 18'sb110010101000010011;
        end
        3816: begin
            cosine_reg0 <= 18'sb011101000101111110;
            sine_reg0   <= 18'sb110010101011001010;
        end
        3817: begin
            cosine_reg0 <= 18'sb011101000111010001;
            sine_reg0   <= 18'sb110010101110000001;
        end
        3818: begin
            cosine_reg0 <= 18'sb011101001000100100;
            sine_reg0   <= 18'sb110010110000111000;
        end
        3819: begin
            cosine_reg0 <= 18'sb011101001001110111;
            sine_reg0   <= 18'sb110010110011101111;
        end
        3820: begin
            cosine_reg0 <= 18'sb011101001011001010;
            sine_reg0   <= 18'sb110010110110100110;
        end
        3821: begin
            cosine_reg0 <= 18'sb011101001100011101;
            sine_reg0   <= 18'sb110010111001011110;
        end
        3822: begin
            cosine_reg0 <= 18'sb011101001101101111;
            sine_reg0   <= 18'sb110010111100010101;
        end
        3823: begin
            cosine_reg0 <= 18'sb011101001111000001;
            sine_reg0   <= 18'sb110010111111001101;
        end
        3824: begin
            cosine_reg0 <= 18'sb011101010000010010;
            sine_reg0   <= 18'sb110011000010000101;
        end
        3825: begin
            cosine_reg0 <= 18'sb011101010001100100;
            sine_reg0   <= 18'sb110011000100111100;
        end
        3826: begin
            cosine_reg0 <= 18'sb011101010010110101;
            sine_reg0   <= 18'sb110011000111110100;
        end
        3827: begin
            cosine_reg0 <= 18'sb011101010100000110;
            sine_reg0   <= 18'sb110011001010101101;
        end
        3828: begin
            cosine_reg0 <= 18'sb011101010101010110;
            sine_reg0   <= 18'sb110011001101100101;
        end
        3829: begin
            cosine_reg0 <= 18'sb011101010110100110;
            sine_reg0   <= 18'sb110011010000011101;
        end
        3830: begin
            cosine_reg0 <= 18'sb011101010111110110;
            sine_reg0   <= 18'sb110011010011010110;
        end
        3831: begin
            cosine_reg0 <= 18'sb011101011001000110;
            sine_reg0   <= 18'sb110011010110001110;
        end
        3832: begin
            cosine_reg0 <= 18'sb011101011010010101;
            sine_reg0   <= 18'sb110011011001000111;
        end
        3833: begin
            cosine_reg0 <= 18'sb011101011011100100;
            sine_reg0   <= 18'sb110011011100000000;
        end
        3834: begin
            cosine_reg0 <= 18'sb011101011100110011;
            sine_reg0   <= 18'sb110011011110111001;
        end
        3835: begin
            cosine_reg0 <= 18'sb011101011110000010;
            sine_reg0   <= 18'sb110011100001110010;
        end
        3836: begin
            cosine_reg0 <= 18'sb011101011111010000;
            sine_reg0   <= 18'sb110011100100101011;
        end
        3837: begin
            cosine_reg0 <= 18'sb011101100000011110;
            sine_reg0   <= 18'sb110011100111100101;
        end
        3838: begin
            cosine_reg0 <= 18'sb011101100001101011;
            sine_reg0   <= 18'sb110011101010011110;
        end
        3839: begin
            cosine_reg0 <= 18'sb011101100010111001;
            sine_reg0   <= 18'sb110011101101011000;
        end
        3840: begin
            cosine_reg0 <= 18'sb011101100100000110;
            sine_reg0   <= 18'sb110011110000010001;
        end
        3841: begin
            cosine_reg0 <= 18'sb011101100101010011;
            sine_reg0   <= 18'sb110011110011001011;
        end
        3842: begin
            cosine_reg0 <= 18'sb011101100110011111;
            sine_reg0   <= 18'sb110011110110000101;
        end
        3843: begin
            cosine_reg0 <= 18'sb011101100111101011;
            sine_reg0   <= 18'sb110011111000111111;
        end
        3844: begin
            cosine_reg0 <= 18'sb011101101000110111;
            sine_reg0   <= 18'sb110011111011111001;
        end
        3845: begin
            cosine_reg0 <= 18'sb011101101010000011;
            sine_reg0   <= 18'sb110011111110110100;
        end
        3846: begin
            cosine_reg0 <= 18'sb011101101011001110;
            sine_reg0   <= 18'sb110100000001101110;
        end
        3847: begin
            cosine_reg0 <= 18'sb011101101100011001;
            sine_reg0   <= 18'sb110100000100101000;
        end
        3848: begin
            cosine_reg0 <= 18'sb011101101101100100;
            sine_reg0   <= 18'sb110100000111100011;
        end
        3849: begin
            cosine_reg0 <= 18'sb011101101110101111;
            sine_reg0   <= 18'sb110100001010011110;
        end
        3850: begin
            cosine_reg0 <= 18'sb011101101111111001;
            sine_reg0   <= 18'sb110100001101011001;
        end
        3851: begin
            cosine_reg0 <= 18'sb011101110001000011;
            sine_reg0   <= 18'sb110100010000010100;
        end
        3852: begin
            cosine_reg0 <= 18'sb011101110010001101;
            sine_reg0   <= 18'sb110100010011001111;
        end
        3853: begin
            cosine_reg0 <= 18'sb011101110011010110;
            sine_reg0   <= 18'sb110100010110001010;
        end
        3854: begin
            cosine_reg0 <= 18'sb011101110100011111;
            sine_reg0   <= 18'sb110100011001000101;
        end
        3855: begin
            cosine_reg0 <= 18'sb011101110101101000;
            sine_reg0   <= 18'sb110100011100000001;
        end
        3856: begin
            cosine_reg0 <= 18'sb011101110110110000;
            sine_reg0   <= 18'sb110100011110111100;
        end
        3857: begin
            cosine_reg0 <= 18'sb011101110111111001;
            sine_reg0   <= 18'sb110100100001111000;
        end
        3858: begin
            cosine_reg0 <= 18'sb011101111001000000;
            sine_reg0   <= 18'sb110100100100110100;
        end
        3859: begin
            cosine_reg0 <= 18'sb011101111010001000;
            sine_reg0   <= 18'sb110100100111101111;
        end
        3860: begin
            cosine_reg0 <= 18'sb011101111011001111;
            sine_reg0   <= 18'sb110100101010101011;
        end
        3861: begin
            cosine_reg0 <= 18'sb011101111100010111;
            sine_reg0   <= 18'sb110100101101101000;
        end
        3862: begin
            cosine_reg0 <= 18'sb011101111101011101;
            sine_reg0   <= 18'sb110100110000100100;
        end
        3863: begin
            cosine_reg0 <= 18'sb011101111110100100;
            sine_reg0   <= 18'sb110100110011100000;
        end
        3864: begin
            cosine_reg0 <= 18'sb011101111111101010;
            sine_reg0   <= 18'sb110100110110011100;
        end
        3865: begin
            cosine_reg0 <= 18'sb011110000000110000;
            sine_reg0   <= 18'sb110100111001011001;
        end
        3866: begin
            cosine_reg0 <= 18'sb011110000001110101;
            sine_reg0   <= 18'sb110100111100010110;
        end
        3867: begin
            cosine_reg0 <= 18'sb011110000010111011;
            sine_reg0   <= 18'sb110100111111010010;
        end
        3868: begin
            cosine_reg0 <= 18'sb011110000100000000;
            sine_reg0   <= 18'sb110101000010001111;
        end
        3869: begin
            cosine_reg0 <= 18'sb011110000101000101;
            sine_reg0   <= 18'sb110101000101001100;
        end
        3870: begin
            cosine_reg0 <= 18'sb011110000110001001;
            sine_reg0   <= 18'sb110101001000001001;
        end
        3871: begin
            cosine_reg0 <= 18'sb011110000111001101;
            sine_reg0   <= 18'sb110101001011000110;
        end
        3872: begin
            cosine_reg0 <= 18'sb011110001000010001;
            sine_reg0   <= 18'sb110101001110000100;
        end
        3873: begin
            cosine_reg0 <= 18'sb011110001001010101;
            sine_reg0   <= 18'sb110101010001000001;
        end
        3874: begin
            cosine_reg0 <= 18'sb011110001010011000;
            sine_reg0   <= 18'sb110101010011111110;
        end
        3875: begin
            cosine_reg0 <= 18'sb011110001011011011;
            sine_reg0   <= 18'sb110101010110111100;
        end
        3876: begin
            cosine_reg0 <= 18'sb011110001100011110;
            sine_reg0   <= 18'sb110101011001111010;
        end
        3877: begin
            cosine_reg0 <= 18'sb011110001101100000;
            sine_reg0   <= 18'sb110101011100110111;
        end
        3878: begin
            cosine_reg0 <= 18'sb011110001110100010;
            sine_reg0   <= 18'sb110101011111110101;
        end
        3879: begin
            cosine_reg0 <= 18'sb011110001111100100;
            sine_reg0   <= 18'sb110101100010110011;
        end
        3880: begin
            cosine_reg0 <= 18'sb011110010000100110;
            sine_reg0   <= 18'sb110101100101110001;
        end
        3881: begin
            cosine_reg0 <= 18'sb011110010001100111;
            sine_reg0   <= 18'sb110101101000101111;
        end
        3882: begin
            cosine_reg0 <= 18'sb011110010010101000;
            sine_reg0   <= 18'sb110101101011101110;
        end
        3883: begin
            cosine_reg0 <= 18'sb011110010011101001;
            sine_reg0   <= 18'sb110101101110101100;
        end
        3884: begin
            cosine_reg0 <= 18'sb011110010100101001;
            sine_reg0   <= 18'sb110101110001101011;
        end
        3885: begin
            cosine_reg0 <= 18'sb011110010101101001;
            sine_reg0   <= 18'sb110101110100101001;
        end
        3886: begin
            cosine_reg0 <= 18'sb011110010110101001;
            sine_reg0   <= 18'sb110101110111101000;
        end
        3887: begin
            cosine_reg0 <= 18'sb011110010111101000;
            sine_reg0   <= 18'sb110101111010100111;
        end
        3888: begin
            cosine_reg0 <= 18'sb011110011000101000;
            sine_reg0   <= 18'sb110101111101100101;
        end
        3889: begin
            cosine_reg0 <= 18'sb011110011001100111;
            sine_reg0   <= 18'sb110110000000100100;
        end
        3890: begin
            cosine_reg0 <= 18'sb011110011010100101;
            sine_reg0   <= 18'sb110110000011100011;
        end
        3891: begin
            cosine_reg0 <= 18'sb011110011011100011;
            sine_reg0   <= 18'sb110110000110100011;
        end
        3892: begin
            cosine_reg0 <= 18'sb011110011100100010;
            sine_reg0   <= 18'sb110110001001100010;
        end
        3893: begin
            cosine_reg0 <= 18'sb011110011101011111;
            sine_reg0   <= 18'sb110110001100100001;
        end
        3894: begin
            cosine_reg0 <= 18'sb011110011110011101;
            sine_reg0   <= 18'sb110110001111100001;
        end
        3895: begin
            cosine_reg0 <= 18'sb011110011111011010;
            sine_reg0   <= 18'sb110110010010100000;
        end
        3896: begin
            cosine_reg0 <= 18'sb011110100000010111;
            sine_reg0   <= 18'sb110110010101100000;
        end
        3897: begin
            cosine_reg0 <= 18'sb011110100001010011;
            sine_reg0   <= 18'sb110110011000011111;
        end
        3898: begin
            cosine_reg0 <= 18'sb011110100010010000;
            sine_reg0   <= 18'sb110110011011011111;
        end
        3899: begin
            cosine_reg0 <= 18'sb011110100011001100;
            sine_reg0   <= 18'sb110110011110011111;
        end
        3900: begin
            cosine_reg0 <= 18'sb011110100100000111;
            sine_reg0   <= 18'sb110110100001011111;
        end
        3901: begin
            cosine_reg0 <= 18'sb011110100101000011;
            sine_reg0   <= 18'sb110110100100011111;
        end
        3902: begin
            cosine_reg0 <= 18'sb011110100101111110;
            sine_reg0   <= 18'sb110110100111011111;
        end
        3903: begin
            cosine_reg0 <= 18'sb011110100110111001;
            sine_reg0   <= 18'sb110110101010100000;
        end
        3904: begin
            cosine_reg0 <= 18'sb011110100111110011;
            sine_reg0   <= 18'sb110110101101100000;
        end
        3905: begin
            cosine_reg0 <= 18'sb011110101000101101;
            sine_reg0   <= 18'sb110110110000100001;
        end
        3906: begin
            cosine_reg0 <= 18'sb011110101001100111;
            sine_reg0   <= 18'sb110110110011100001;
        end
        3907: begin
            cosine_reg0 <= 18'sb011110101010100001;
            sine_reg0   <= 18'sb110110110110100010;
        end
        3908: begin
            cosine_reg0 <= 18'sb011110101011011010;
            sine_reg0   <= 18'sb110110111001100010;
        end
        3909: begin
            cosine_reg0 <= 18'sb011110101100010011;
            sine_reg0   <= 18'sb110110111100100011;
        end
        3910: begin
            cosine_reg0 <= 18'sb011110101101001100;
            sine_reg0   <= 18'sb110110111111100100;
        end
        3911: begin
            cosine_reg0 <= 18'sb011110101110000100;
            sine_reg0   <= 18'sb110111000010100101;
        end
        3912: begin
            cosine_reg0 <= 18'sb011110101110111101;
            sine_reg0   <= 18'sb110111000101100110;
        end
        3913: begin
            cosine_reg0 <= 18'sb011110101111110100;
            sine_reg0   <= 18'sb110111001000100111;
        end
        3914: begin
            cosine_reg0 <= 18'sb011110110000101100;
            sine_reg0   <= 18'sb110111001011101001;
        end
        3915: begin
            cosine_reg0 <= 18'sb011110110001100011;
            sine_reg0   <= 18'sb110111001110101010;
        end
        3916: begin
            cosine_reg0 <= 18'sb011110110010011010;
            sine_reg0   <= 18'sb110111010001101011;
        end
        3917: begin
            cosine_reg0 <= 18'sb011110110011010001;
            sine_reg0   <= 18'sb110111010100101101;
        end
        3918: begin
            cosine_reg0 <= 18'sb011110110100000111;
            sine_reg0   <= 18'sb110111010111101110;
        end
        3919: begin
            cosine_reg0 <= 18'sb011110110100111101;
            sine_reg0   <= 18'sb110111011010110000;
        end
        3920: begin
            cosine_reg0 <= 18'sb011110110101110011;
            sine_reg0   <= 18'sb110111011101110010;
        end
        3921: begin
            cosine_reg0 <= 18'sb011110110110101001;
            sine_reg0   <= 18'sb110111100000110100;
        end
        3922: begin
            cosine_reg0 <= 18'sb011110110111011110;
            sine_reg0   <= 18'sb110111100011110101;
        end
        3923: begin
            cosine_reg0 <= 18'sb011110111000010011;
            sine_reg0   <= 18'sb110111100110110111;
        end
        3924: begin
            cosine_reg0 <= 18'sb011110111001000111;
            sine_reg0   <= 18'sb110111101001111001;
        end
        3925: begin
            cosine_reg0 <= 18'sb011110111001111100;
            sine_reg0   <= 18'sb110111101100111100;
        end
        3926: begin
            cosine_reg0 <= 18'sb011110111010101111;
            sine_reg0   <= 18'sb110111101111111110;
        end
        3927: begin
            cosine_reg0 <= 18'sb011110111011100011;
            sine_reg0   <= 18'sb110111110011000000;
        end
        3928: begin
            cosine_reg0 <= 18'sb011110111100010111;
            sine_reg0   <= 18'sb110111110110000011;
        end
        3929: begin
            cosine_reg0 <= 18'sb011110111101001010;
            sine_reg0   <= 18'sb110111111001000101;
        end
        3930: begin
            cosine_reg0 <= 18'sb011110111101111100;
            sine_reg0   <= 18'sb110111111100001000;
        end
        3931: begin
            cosine_reg0 <= 18'sb011110111110101111;
            sine_reg0   <= 18'sb110111111111001010;
        end
        3932: begin
            cosine_reg0 <= 18'sb011110111111100001;
            sine_reg0   <= 18'sb111000000010001101;
        end
        3933: begin
            cosine_reg0 <= 18'sb011111000000010011;
            sine_reg0   <= 18'sb111000000101010000;
        end
        3934: begin
            cosine_reg0 <= 18'sb011111000001000101;
            sine_reg0   <= 18'sb111000001000010010;
        end
        3935: begin
            cosine_reg0 <= 18'sb011111000001110110;
            sine_reg0   <= 18'sb111000001011010101;
        end
        3936: begin
            cosine_reg0 <= 18'sb011111000010100111;
            sine_reg0   <= 18'sb111000001110011000;
        end
        3937: begin
            cosine_reg0 <= 18'sb011111000011011000;
            sine_reg0   <= 18'sb111000010001011011;
        end
        3938: begin
            cosine_reg0 <= 18'sb011111000100001000;
            sine_reg0   <= 18'sb111000010100011111;
        end
        3939: begin
            cosine_reg0 <= 18'sb011111000100111000;
            sine_reg0   <= 18'sb111000010111100010;
        end
        3940: begin
            cosine_reg0 <= 18'sb011111000101101000;
            sine_reg0   <= 18'sb111000011010100101;
        end
        3941: begin
            cosine_reg0 <= 18'sb011111000110010111;
            sine_reg0   <= 18'sb111000011101101000;
        end
        3942: begin
            cosine_reg0 <= 18'sb011111000111000111;
            sine_reg0   <= 18'sb111000100000101100;
        end
        3943: begin
            cosine_reg0 <= 18'sb011111000111110110;
            sine_reg0   <= 18'sb111000100011101111;
        end
        3944: begin
            cosine_reg0 <= 18'sb011111001000100100;
            sine_reg0   <= 18'sb111000100110110011;
        end
        3945: begin
            cosine_reg0 <= 18'sb011111001001010011;
            sine_reg0   <= 18'sb111000101001110111;
        end
        3946: begin
            cosine_reg0 <= 18'sb011111001010000001;
            sine_reg0   <= 18'sb111000101100111010;
        end
        3947: begin
            cosine_reg0 <= 18'sb011111001010101110;
            sine_reg0   <= 18'sb111000101111111110;
        end
        3948: begin
            cosine_reg0 <= 18'sb011111001011011100;
            sine_reg0   <= 18'sb111000110011000010;
        end
        3949: begin
            cosine_reg0 <= 18'sb011111001100001001;
            sine_reg0   <= 18'sb111000110110000110;
        end
        3950: begin
            cosine_reg0 <= 18'sb011111001100110110;
            sine_reg0   <= 18'sb111000111001001010;
        end
        3951: begin
            cosine_reg0 <= 18'sb011111001101100010;
            sine_reg0   <= 18'sb111000111100001110;
        end
        3952: begin
            cosine_reg0 <= 18'sb011111001110001110;
            sine_reg0   <= 18'sb111000111111010010;
        end
        3953: begin
            cosine_reg0 <= 18'sb011111001110111010;
            sine_reg0   <= 18'sb111001000010010110;
        end
        3954: begin
            cosine_reg0 <= 18'sb011111001111100110;
            sine_reg0   <= 18'sb111001000101011011;
        end
        3955: begin
            cosine_reg0 <= 18'sb011111010000010001;
            sine_reg0   <= 18'sb111001001000011111;
        end
        3956: begin
            cosine_reg0 <= 18'sb011111010000111100;
            sine_reg0   <= 18'sb111001001011100011;
        end
        3957: begin
            cosine_reg0 <= 18'sb011111010001100111;
            sine_reg0   <= 18'sb111001001110101000;
        end
        3958: begin
            cosine_reg0 <= 18'sb011111010010010001;
            sine_reg0   <= 18'sb111001010001101100;
        end
        3959: begin
            cosine_reg0 <= 18'sb011111010010111011;
            sine_reg0   <= 18'sb111001010100110001;
        end
        3960: begin
            cosine_reg0 <= 18'sb011111010011100101;
            sine_reg0   <= 18'sb111001010111110110;
        end
        3961: begin
            cosine_reg0 <= 18'sb011111010100001111;
            sine_reg0   <= 18'sb111001011010111010;
        end
        3962: begin
            cosine_reg0 <= 18'sb011111010100111000;
            sine_reg0   <= 18'sb111001011101111111;
        end
        3963: begin
            cosine_reg0 <= 18'sb011111010101100001;
            sine_reg0   <= 18'sb111001100001000100;
        end
        3964: begin
            cosine_reg0 <= 18'sb011111010110001001;
            sine_reg0   <= 18'sb111001100100001001;
        end
        3965: begin
            cosine_reg0 <= 18'sb011111010110110001;
            sine_reg0   <= 18'sb111001100111001110;
        end
        3966: begin
            cosine_reg0 <= 18'sb011111010111011001;
            sine_reg0   <= 18'sb111001101010010011;
        end
        3967: begin
            cosine_reg0 <= 18'sb011111011000000001;
            sine_reg0   <= 18'sb111001101101011000;
        end
        3968: begin
            cosine_reg0 <= 18'sb011111011000101001;
            sine_reg0   <= 18'sb111001110000011101;
        end
        3969: begin
            cosine_reg0 <= 18'sb011111011001010000;
            sine_reg0   <= 18'sb111001110011100011;
        end
        3970: begin
            cosine_reg0 <= 18'sb011111011001110110;
            sine_reg0   <= 18'sb111001110110101000;
        end
        3971: begin
            cosine_reg0 <= 18'sb011111011010011101;
            sine_reg0   <= 18'sb111001111001101101;
        end
        3972: begin
            cosine_reg0 <= 18'sb011111011011000011;
            sine_reg0   <= 18'sb111001111100110011;
        end
        3973: begin
            cosine_reg0 <= 18'sb011111011011101001;
            sine_reg0   <= 18'sb111001111111111000;
        end
        3974: begin
            cosine_reg0 <= 18'sb011111011100001110;
            sine_reg0   <= 18'sb111010000010111110;
        end
        3975: begin
            cosine_reg0 <= 18'sb011111011100110100;
            sine_reg0   <= 18'sb111010000110000011;
        end
        3976: begin
            cosine_reg0 <= 18'sb011111011101011001;
            sine_reg0   <= 18'sb111010001001001001;
        end
        3977: begin
            cosine_reg0 <= 18'sb011111011101111101;
            sine_reg0   <= 18'sb111010001100001110;
        end
        3978: begin
            cosine_reg0 <= 18'sb011111011110100010;
            sine_reg0   <= 18'sb111010001111010100;
        end
        3979: begin
            cosine_reg0 <= 18'sb011111011111000110;
            sine_reg0   <= 18'sb111010010010011010;
        end
        3980: begin
            cosine_reg0 <= 18'sb011111011111101001;
            sine_reg0   <= 18'sb111010010101100000;
        end
        3981: begin
            cosine_reg0 <= 18'sb011111100000001101;
            sine_reg0   <= 18'sb111010011000100110;
        end
        3982: begin
            cosine_reg0 <= 18'sb011111100000110000;
            sine_reg0   <= 18'sb111010011011101100;
        end
        3983: begin
            cosine_reg0 <= 18'sb011111100001010011;
            sine_reg0   <= 18'sb111010011110110010;
        end
        3984: begin
            cosine_reg0 <= 18'sb011111100001110101;
            sine_reg0   <= 18'sb111010100001111000;
        end
        3985: begin
            cosine_reg0 <= 18'sb011111100010011000;
            sine_reg0   <= 18'sb111010100100111110;
        end
        3986: begin
            cosine_reg0 <= 18'sb011111100010111001;
            sine_reg0   <= 18'sb111010101000000100;
        end
        3987: begin
            cosine_reg0 <= 18'sb011111100011011011;
            sine_reg0   <= 18'sb111010101011001010;
        end
        3988: begin
            cosine_reg0 <= 18'sb011111100011111100;
            sine_reg0   <= 18'sb111010101110010001;
        end
        3989: begin
            cosine_reg0 <= 18'sb011111100100011101;
            sine_reg0   <= 18'sb111010110001010111;
        end
        3990: begin
            cosine_reg0 <= 18'sb011111100100111110;
            sine_reg0   <= 18'sb111010110100011101;
        end
        3991: begin
            cosine_reg0 <= 18'sb011111100101011110;
            sine_reg0   <= 18'sb111010110111100100;
        end
        3992: begin
            cosine_reg0 <= 18'sb011111100101111111;
            sine_reg0   <= 18'sb111010111010101010;
        end
        3993: begin
            cosine_reg0 <= 18'sb011111100110011110;
            sine_reg0   <= 18'sb111010111101110001;
        end
        3994: begin
            cosine_reg0 <= 18'sb011111100110111110;
            sine_reg0   <= 18'sb111011000000110111;
        end
        3995: begin
            cosine_reg0 <= 18'sb011111100111011101;
            sine_reg0   <= 18'sb111011000011111110;
        end
        3996: begin
            cosine_reg0 <= 18'sb011111100111111100;
            sine_reg0   <= 18'sb111011000111000101;
        end
        3997: begin
            cosine_reg0 <= 18'sb011111101000011010;
            sine_reg0   <= 18'sb111011001010001011;
        end
        3998: begin
            cosine_reg0 <= 18'sb011111101000111001;
            sine_reg0   <= 18'sb111011001101010010;
        end
        3999: begin
            cosine_reg0 <= 18'sb011111101001010111;
            sine_reg0   <= 18'sb111011010000011001;
        end
        4000: begin
            cosine_reg0 <= 18'sb011111101001110100;
            sine_reg0   <= 18'sb111011010011100000;
        end
        4001: begin
            cosine_reg0 <= 18'sb011111101010010010;
            sine_reg0   <= 18'sb111011010110100111;
        end
        4002: begin
            cosine_reg0 <= 18'sb011111101010101111;
            sine_reg0   <= 18'sb111011011001101110;
        end
        4003: begin
            cosine_reg0 <= 18'sb011111101011001011;
            sine_reg0   <= 18'sb111011011100110101;
        end
        4004: begin
            cosine_reg0 <= 18'sb011111101011101000;
            sine_reg0   <= 18'sb111011011111111100;
        end
        4005: begin
            cosine_reg0 <= 18'sb011111101100000100;
            sine_reg0   <= 18'sb111011100011000011;
        end
        4006: begin
            cosine_reg0 <= 18'sb011111101100100000;
            sine_reg0   <= 18'sb111011100110001010;
        end
        4007: begin
            cosine_reg0 <= 18'sb011111101100111011;
            sine_reg0   <= 18'sb111011101001010001;
        end
        4008: begin
            cosine_reg0 <= 18'sb011111101101010111;
            sine_reg0   <= 18'sb111011101100011000;
        end
        4009: begin
            cosine_reg0 <= 18'sb011111101101110010;
            sine_reg0   <= 18'sb111011101111100000;
        end
        4010: begin
            cosine_reg0 <= 18'sb011111101110001100;
            sine_reg0   <= 18'sb111011110010100111;
        end
        4011: begin
            cosine_reg0 <= 18'sb011111101110100110;
            sine_reg0   <= 18'sb111011110101101110;
        end
        4012: begin
            cosine_reg0 <= 18'sb011111101111000000;
            sine_reg0   <= 18'sb111011111000110110;
        end
        4013: begin
            cosine_reg0 <= 18'sb011111101111011010;
            sine_reg0   <= 18'sb111011111011111101;
        end
        4014: begin
            cosine_reg0 <= 18'sb011111101111110011;
            sine_reg0   <= 18'sb111011111111000100;
        end
        4015: begin
            cosine_reg0 <= 18'sb011111110000001101;
            sine_reg0   <= 18'sb111100000010001100;
        end
        4016: begin
            cosine_reg0 <= 18'sb011111110000100101;
            sine_reg0   <= 18'sb111100000101010100;
        end
        4017: begin
            cosine_reg0 <= 18'sb011111110000111110;
            sine_reg0   <= 18'sb111100001000011011;
        end
        4018: begin
            cosine_reg0 <= 18'sb011111110001010110;
            sine_reg0   <= 18'sb111100001011100011;
        end
        4019: begin
            cosine_reg0 <= 18'sb011111110001101110;
            sine_reg0   <= 18'sb111100001110101010;
        end
        4020: begin
            cosine_reg0 <= 18'sb011111110010000101;
            sine_reg0   <= 18'sb111100010001110010;
        end
        4021: begin
            cosine_reg0 <= 18'sb011111110010011101;
            sine_reg0   <= 18'sb111100010100111010;
        end
        4022: begin
            cosine_reg0 <= 18'sb011111110010110011;
            sine_reg0   <= 18'sb111100011000000001;
        end
        4023: begin
            cosine_reg0 <= 18'sb011111110011001010;
            sine_reg0   <= 18'sb111100011011001001;
        end
        4024: begin
            cosine_reg0 <= 18'sb011111110011100000;
            sine_reg0   <= 18'sb111100011110010001;
        end
        4025: begin
            cosine_reg0 <= 18'sb011111110011110110;
            sine_reg0   <= 18'sb111100100001011001;
        end
        4026: begin
            cosine_reg0 <= 18'sb011111110100001100;
            sine_reg0   <= 18'sb111100100100100001;
        end
        4027: begin
            cosine_reg0 <= 18'sb011111110100100001;
            sine_reg0   <= 18'sb111100100111101001;
        end
        4028: begin
            cosine_reg0 <= 18'sb011111110100110111;
            sine_reg0   <= 18'sb111100101010110001;
        end
        4029: begin
            cosine_reg0 <= 18'sb011111110101001011;
            sine_reg0   <= 18'sb111100101101111001;
        end
        4030: begin
            cosine_reg0 <= 18'sb011111110101100000;
            sine_reg0   <= 18'sb111100110001000001;
        end
        4031: begin
            cosine_reg0 <= 18'sb011111110101110100;
            sine_reg0   <= 18'sb111100110100001001;
        end
        4032: begin
            cosine_reg0 <= 18'sb011111110110001000;
            sine_reg0   <= 18'sb111100110111010001;
        end
        4033: begin
            cosine_reg0 <= 18'sb011111110110011011;
            sine_reg0   <= 18'sb111100111010011001;
        end
        4034: begin
            cosine_reg0 <= 18'sb011111110110101111;
            sine_reg0   <= 18'sb111100111101100001;
        end
        4035: begin
            cosine_reg0 <= 18'sb011111110111000010;
            sine_reg0   <= 18'sb111101000000101001;
        end
        4036: begin
            cosine_reg0 <= 18'sb011111110111010100;
            sine_reg0   <= 18'sb111101000011110001;
        end
        4037: begin
            cosine_reg0 <= 18'sb011111110111100111;
            sine_reg0   <= 18'sb111101000110111010;
        end
        4038: begin
            cosine_reg0 <= 18'sb011111110111111001;
            sine_reg0   <= 18'sb111101001010000010;
        end
        4039: begin
            cosine_reg0 <= 18'sb011111111000001010;
            sine_reg0   <= 18'sb111101001101001010;
        end
        4040: begin
            cosine_reg0 <= 18'sb011111111000011100;
            sine_reg0   <= 18'sb111101010000010010;
        end
        4041: begin
            cosine_reg0 <= 18'sb011111111000101101;
            sine_reg0   <= 18'sb111101010011011011;
        end
        4042: begin
            cosine_reg0 <= 18'sb011111111000111110;
            sine_reg0   <= 18'sb111101010110100011;
        end
        4043: begin
            cosine_reg0 <= 18'sb011111111001001110;
            sine_reg0   <= 18'sb111101011001101100;
        end
        4044: begin
            cosine_reg0 <= 18'sb011111111001011110;
            sine_reg0   <= 18'sb111101011100110100;
        end
        4045: begin
            cosine_reg0 <= 18'sb011111111001101110;
            sine_reg0   <= 18'sb111101011111111100;
        end
        4046: begin
            cosine_reg0 <= 18'sb011111111001111110;
            sine_reg0   <= 18'sb111101100011000101;
        end
        4047: begin
            cosine_reg0 <= 18'sb011111111010001101;
            sine_reg0   <= 18'sb111101100110001101;
        end
        4048: begin
            cosine_reg0 <= 18'sb011111111010011100;
            sine_reg0   <= 18'sb111101101001010110;
        end
        4049: begin
            cosine_reg0 <= 18'sb011111111010101010;
            sine_reg0   <= 18'sb111101101100011110;
        end
        4050: begin
            cosine_reg0 <= 18'sb011111111010111001;
            sine_reg0   <= 18'sb111101101111100111;
        end
        4051: begin
            cosine_reg0 <= 18'sb011111111011000111;
            sine_reg0   <= 18'sb111101110010101111;
        end
        4052: begin
            cosine_reg0 <= 18'sb011111111011010101;
            sine_reg0   <= 18'sb111101110101111000;
        end
        4053: begin
            cosine_reg0 <= 18'sb011111111011100010;
            sine_reg0   <= 18'sb111101111001000001;
        end
        4054: begin
            cosine_reg0 <= 18'sb011111111011101111;
            sine_reg0   <= 18'sb111101111100001001;
        end
        4055: begin
            cosine_reg0 <= 18'sb011111111011111100;
            sine_reg0   <= 18'sb111101111111010010;
        end
        4056: begin
            cosine_reg0 <= 18'sb011111111100001000;
            sine_reg0   <= 18'sb111110000010011011;
        end
        4057: begin
            cosine_reg0 <= 18'sb011111111100010101;
            sine_reg0   <= 18'sb111110000101100011;
        end
        4058: begin
            cosine_reg0 <= 18'sb011111111100100000;
            sine_reg0   <= 18'sb111110001000101100;
        end
        4059: begin
            cosine_reg0 <= 18'sb011111111100101100;
            sine_reg0   <= 18'sb111110001011110101;
        end
        4060: begin
            cosine_reg0 <= 18'sb011111111100110111;
            sine_reg0   <= 18'sb111110001110111110;
        end
        4061: begin
            cosine_reg0 <= 18'sb011111111101000010;
            sine_reg0   <= 18'sb111110010010000110;
        end
        4062: begin
            cosine_reg0 <= 18'sb011111111101001101;
            sine_reg0   <= 18'sb111110010101001111;
        end
        4063: begin
            cosine_reg0 <= 18'sb011111111101010111;
            sine_reg0   <= 18'sb111110011000011000;
        end
        4064: begin
            cosine_reg0 <= 18'sb011111111101100001;
            sine_reg0   <= 18'sb111110011011100001;
        end
        4065: begin
            cosine_reg0 <= 18'sb011111111101101011;
            sine_reg0   <= 18'sb111110011110101001;
        end
        4066: begin
            cosine_reg0 <= 18'sb011111111101110100;
            sine_reg0   <= 18'sb111110100001110010;
        end
        4067: begin
            cosine_reg0 <= 18'sb011111111101111101;
            sine_reg0   <= 18'sb111110100100111011;
        end
        4068: begin
            cosine_reg0 <= 18'sb011111111110000110;
            sine_reg0   <= 18'sb111110101000000100;
        end
        4069: begin
            cosine_reg0 <= 18'sb011111111110001111;
            sine_reg0   <= 18'sb111110101011001101;
        end
        4070: begin
            cosine_reg0 <= 18'sb011111111110010111;
            sine_reg0   <= 18'sb111110101110010110;
        end
        4071: begin
            cosine_reg0 <= 18'sb011111111110011111;
            sine_reg0   <= 18'sb111110110001011111;
        end
        4072: begin
            cosine_reg0 <= 18'sb011111111110100110;
            sine_reg0   <= 18'sb111110110100101000;
        end
        4073: begin
            cosine_reg0 <= 18'sb011111111110101101;
            sine_reg0   <= 18'sb111110110111110001;
        end
        4074: begin
            cosine_reg0 <= 18'sb011111111110110100;
            sine_reg0   <= 18'sb111110111010111010;
        end
        4075: begin
            cosine_reg0 <= 18'sb011111111110111011;
            sine_reg0   <= 18'sb111110111110000010;
        end
        4076: begin
            cosine_reg0 <= 18'sb011111111111000001;
            sine_reg0   <= 18'sb111111000001001011;
        end
        4077: begin
            cosine_reg0 <= 18'sb011111111111000111;
            sine_reg0   <= 18'sb111111000100010100;
        end
        4078: begin
            cosine_reg0 <= 18'sb011111111111001101;
            sine_reg0   <= 18'sb111111000111011101;
        end
        4079: begin
            cosine_reg0 <= 18'sb011111111111010010;
            sine_reg0   <= 18'sb111111001010100110;
        end
        4080: begin
            cosine_reg0 <= 18'sb011111111111011000;
            sine_reg0   <= 18'sb111111001101101111;
        end
        4081: begin
            cosine_reg0 <= 18'sb011111111111011100;
            sine_reg0   <= 18'sb111111010000111000;
        end
        4082: begin
            cosine_reg0 <= 18'sb011111111111100001;
            sine_reg0   <= 18'sb111111010100000001;
        end
        4083: begin
            cosine_reg0 <= 18'sb011111111111100101;
            sine_reg0   <= 18'sb111111010111001010;
        end
        4084: begin
            cosine_reg0 <= 18'sb011111111111101001;
            sine_reg0   <= 18'sb111111011010010011;
        end
        4085: begin
            cosine_reg0 <= 18'sb011111111111101100;
            sine_reg0   <= 18'sb111111011101011100;
        end
        4086: begin
            cosine_reg0 <= 18'sb011111111111110000;
            sine_reg0   <= 18'sb111111100000100101;
        end
        4087: begin
            cosine_reg0 <= 18'sb011111111111110011;
            sine_reg0   <= 18'sb111111100011101111;
        end
        4088: begin
            cosine_reg0 <= 18'sb011111111111110101;
            sine_reg0   <= 18'sb111111100110111000;
        end
        4089: begin
            cosine_reg0 <= 18'sb011111111111110111;
            sine_reg0   <= 18'sb111111101010000001;
        end
        4090: begin
            cosine_reg0 <= 18'sb011111111111111001;
            sine_reg0   <= 18'sb111111101101001010;
        end
        4091: begin
            cosine_reg0 <= 18'sb011111111111111011;
            sine_reg0   <= 18'sb111111110000010011;
        end
        4092: begin
            cosine_reg0 <= 18'sb011111111111111101;
            sine_reg0   <= 18'sb111111110011011100;
        end
        4093: begin
            cosine_reg0 <= 18'sb011111111111111110;
            sine_reg0   <= 18'sb111111110110100101;
        end
        4094: begin
            cosine_reg0 <= 18'sb011111111111111110;
            sine_reg0   <= 18'sb111111111001101110;
        end
        default: begin
            cosine_reg0 <= 18'sb011111111111111111;
            sine_reg0   <= 18'sb111111111100110111;
        end
        endcase
    end
end

// Perform Correction
logic signed [WIDTH-1:0] cosine_reg1;
logic signed [WIDTH-1:0] sine_reg1;

logic signed [WIDTH-1:0] cosine_reg2;
logic signed [WIDTH-1:0] sine_reg2;

always_ff @ (posedge i_clock) begin
    if (i_ready == 1'b1) begin
        // Pipeline Stage 1
        cosine_reg1 <= cosine_reg0;
        sine_reg1 <= sine_reg0;

        // Pipeline Stage 2
        cosine_reg2 <= cosine_reg1;
        sine_reg2 <= sine_reg1;

        // Pipeline Stage 3
        o_cosine_data <= cosine_reg2;
        o_sine_data <= sine_reg2;
    end
end

endmodule: rx_chmod_dds

`default_nettype wire
