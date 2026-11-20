`timescale 1ns/1ps

// Vendor-neutral one-entry EEG sample + channel metadata adapter.
// This block transports metadata; it does not validate channel IDs,
// resample data, scale ADC codes, or perform physiological processing.
module neuroflexxa_eeg_stream_adapter #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer CHANNEL_ID_WIDTH = 2
) (
    input  wire                              clk,
    input  wire                              rst_n,

    input  wire                              in_valid,
    output wire                              in_ready,
    input  wire signed [SAMPLE_WIDTH-1:0]    in_sample,
    input  wire [CHANNEL_ID_WIDTH-1:0]       in_channel_id,

    output reg                               out_valid,
    input  wire                              out_ready,
    output reg signed [SAMPLE_WIDTH-1:0]     out_sample,
    output reg [CHANNEL_ID_WIDTH-1:0]        out_channel_id
);

    // Elastic one-entry stage: permit simultaneous dequeue/enqueue.
    assign in_ready = !out_valid || out_ready;

    always @(posedge clk) begin
        if (!rst_n) begin
            out_valid      <= 1'b0;
            out_sample     <= {SAMPLE_WIDTH{1'b0}};
            out_channel_id <= {CHANNEL_ID_WIDTH{1'b0}};
        end else if (in_ready) begin
            out_valid <= in_valid;
            if (in_valid) begin
                out_sample     <= in_sample;
                out_channel_id <= in_channel_id;
            end
        end
    end

endmodule
