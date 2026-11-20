`timescale 1ns/1ps

// Vendor-neutral multi-channel three-tap FIR bank.
// Each channel owns independent two-sample history. One accepted input
// produces one tagged output. Invalid channel IDs are not accepted.
module neuroflexxa_eeg_multichannel_fir #(
    parameter integer SAMPLE_WIDTH = 16,
    parameter integer CHANNELS = 4,
    parameter integer CHANNEL_ID_WIDTH = 2,
    parameter integer COEFF_WIDTH = 8,
    parameter integer OUTPUT_WIDTH = 16,
    parameter integer ACC_WIDTH = SAMPLE_WIDTH + COEFF_WIDTH + 2,
    parameter integer FRAC_BITS = 2,
    parameter signed [COEFF_WIDTH-1:0] COEFF0 = 1,
    parameter signed [COEFF_WIDTH-1:0] COEFF1 = 2,
    parameter signed [COEFF_WIDTH-1:0] COEFF2 = 1
) (
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    output wire in_ready,
    input wire signed [SAMPLE_WIDTH-1:0] in_sample,
    input wire [CHANNEL_ID_WIDTH-1:0] in_channel_id,
    output reg out_valid,
    input wire out_ready,
    output reg signed [OUTPUT_WIDTH-1:0] out_sample,
    output reg [CHANNEL_ID_WIDTH-1:0] out_channel_id
);

    reg signed [SAMPLE_WIDTH-1:0] history1 [0:CHANNELS-1];
    reg signed [SAMPLE_WIDTH-1:0] history2 [0:CHANNELS-1];
    integer i;

    wire channel_valid = (in_channel_id < CHANNELS);
    wire signed [OUTPUT_WIDTH-1:0] filtered_sample;

    assign in_ready = (!out_valid || out_ready) && channel_valid;

    neuroflexxa_fir3 #(
        .SAMPLE_WIDTH(SAMPLE_WIDTH),
        .COEFF_WIDTH(COEFF_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .FRAC_BITS(FRAC_BITS),
        .COEFF0(COEFF0),
        .COEFF1(COEFF1),
        .COEFF2(COEFF2)
    ) channel_fir (
        .x0(in_sample),
        .x1(history1[in_channel_id]),
        .x2(history2[in_channel_id]),
        .y(filtered_sample)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_sample <= {OUTPUT_WIDTH{1'b0}};
            out_channel_id <= {CHANNEL_ID_WIDTH{1'b0}};
            for (i = 0; i < CHANNELS; i = i + 1) begin
                history1[i] <= {SAMPLE_WIDTH{1'b0}};
                history2[i] <= {SAMPLE_WIDTH{1'b0}};
            end
        end else if (!out_valid || out_ready) begin
            out_valid <= in_valid && channel_valid;
            if (in_valid && channel_valid) begin
                out_sample <= filtered_sample;
                out_channel_id <= in_channel_id;
                history2[in_channel_id] <= history1[in_channel_id];
                history1[in_channel_id] <= in_sample;
            end
        end
    end

endmodule
