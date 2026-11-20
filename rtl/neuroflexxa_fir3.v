// Portable parameterized three-tap signed FIR combinational datapath.
// Products are accumulated at ACC_WIDTH, arithmetic-shifted by FRAC_BITS,
// then truncated to OUTPUT_WIDTH (two's-complement wrap; no saturation).
module neuroflexxa_fir3 #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer COEFF_WIDTH = 8,
    parameter integer OUTPUT_WIDTH = 16,
    parameter integer ACC_WIDTH = SAMPLE_WIDTH + COEFF_WIDTH + 2,
    parameter integer FRAC_BITS = 2,
    parameter signed [COEFF_WIDTH-1:0] COEFF0 = 1,
    parameter signed [COEFF_WIDTH-1:0] COEFF1 = 2,
    parameter signed [COEFF_WIDTH-1:0] COEFF2 = 1
) (
    input  wire signed [SAMPLE_WIDTH-1:0] x0,
    input  wire signed [SAMPLE_WIDTH-1:0] x1,
    input  wire signed [SAMPLE_WIDTH-1:0] x2,
    output wire signed [OUTPUT_WIDTH-1:0] y
);
    localparam integer PRODUCT_WIDTH = SAMPLE_WIDTH + COEFF_WIDTH;

    wire signed [PRODUCT_WIDTH-1:0] product0 = x0 * COEFF0;
    wire signed [PRODUCT_WIDTH-1:0] product1 = x1 * COEFF1;
    wire signed [PRODUCT_WIDTH-1:0] product2 = x2 * COEFF2;

    wire signed [ACC_WIDTH-1:0] product0_ext =
        {{(ACC_WIDTH-PRODUCT_WIDTH){product0[PRODUCT_WIDTH-1]}}, product0};
    wire signed [ACC_WIDTH-1:0] product1_ext =
        {{(ACC_WIDTH-PRODUCT_WIDTH){product1[PRODUCT_WIDTH-1]}}, product1};
    wire signed [ACC_WIDTH-1:0] product2_ext =
        {{(ACC_WIDTH-PRODUCT_WIDTH){product2[PRODUCT_WIDTH-1]}}, product2};

    wire signed [ACC_WIDTH-1:0] accumulator =
        product0_ext + product1_ext + product2_ext;
    wire signed [ACC_WIDTH-1:0] scaled = accumulator >>> FRAC_BITS;

    assign y = scaled[OUTPUT_WIDTH-1:0];

endmodule
