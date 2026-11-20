// Neuroflexxa v0.1.0-alpha
// Simulation-first streaming biosignal prototype.
// No clinical or hardware performance claims are implied.
module neuroflexxa_core #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer TIMESTAMP_WIDTH = 32,
    parameter integer EVENT_THRESHOLD = 100
) (
    input  wire                              clk,
    input  wire                              rst_n,

    input  wire                              in_valid,
    output wire                              in_ready,
    input  wire signed [SAMPLE_WIDTH-1:0]    in_sample,

    output reg                               out_valid,
    input  wire                              out_ready,
    output reg signed [SAMPLE_WIDTH-1:0]     out_sample,
    output reg                               out_event,
    output reg [TIMESTAMP_WIDTH-1:0]         out_timestamp
);

    // A one-entry elastic output stage. Input state advances only on
    // an accepted transfer, so the FIR history is stable during stalls.
    reg signed [SAMPLE_WIDTH-1:0] sample_d1;
    reg signed [SAMPLE_WIDTH-1:0] sample_d2;
    reg [TIMESTAMP_WIDTH-1:0] sample_count;

    wire accept_input = in_valid && in_ready;
    assign in_ready = !out_valid || out_ready;

    // Sign-extend before summing. The [1,2,1]/4 FIR has unity DC gain.
    wire signed [SAMPLE_WIDTH+1:0] x_ext =
        {{2{in_sample[SAMPLE_WIDTH-1]}}, in_sample};
    wire signed [SAMPLE_WIDTH+1:0] d1_ext =
        {{2{sample_d1[SAMPLE_WIDTH-1]}}, sample_d1};
    wire signed [SAMPLE_WIDTH+1:0] d2_ext =
        {{2{sample_d2[SAMPLE_WIDTH-1]}}, sample_d2};

    wire signed [SAMPLE_WIDTH+1:0] fir_sum =
        x_ext + (d1_ext <<< 1) + d2_ext;
    wire signed [SAMPLE_WIDTH+1:0] fir_value = fir_sum >>> 2;
    wire [SAMPLE_WIDTH+1:0] magnitude =
        fir_value[SAMPLE_WIDTH+1] ? -fir_value : fir_value;

    always @(posedge clk) begin
        if (!rst_n) begin
            sample_d1     <= {SAMPLE_WIDTH{1'b0}};
            sample_d2     <= {SAMPLE_WIDTH{1'b0}};
            sample_count  <= {TIMESTAMP_WIDTH{1'b0}};
            out_valid     <= 1'b0;
            out_sample    <= {SAMPLE_WIDTH{1'b0}};
            out_event     <= 1'b0;
            out_timestamp <= {TIMESTAMP_WIDTH{1'b0}};
        end else if (in_ready) begin
            // Replacing a consumed output or filling an empty output slot.
            out_valid <= in_valid;
            if (accept_input) begin
                out_sample    <= fir_value[SAMPLE_WIDTH-1:0];
                out_event     <= (magnitude >= EVENT_THRESHOLD);
                out_timestamp <= sample_count;
                sample_d2     <= sample_d1;
                sample_d1     <= in_sample;
                sample_count  <= sample_count + 1'b1;
            end
        end
    end

endmodule
