`timescale 1ns/1ps

module tb_neuroflexxa_eeg_multichannel_fir;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n = 0;
    reg in_valid = 0;
    wire in_ready;
    reg signed [15:0] in_sample = 0;
    reg [1:0] in_channel_id = 0;
    wire out_valid;
    reg out_ready = 1;
    wire signed [15:0] out_sample;
    wire [1:0] out_channel_id;

    neuroflexxa_eeg_multichannel_fir #(
        .SAMPLE_WIDTH(16), .CHANNELS(4), .CHANNEL_ID_WIDTH(2)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .in_ready(in_ready),
        .in_sample(in_sample), .in_channel_id(in_channel_id),
        .out_valid(out_valid), .out_ready(out_ready),
        .out_sample(out_sample), .out_channel_id(out_channel_id)
    );

    task tick;
        begin @(posedge clk); #1; end
    endtask

    task push;
        input signed [15:0] sample;
        input [1:0] channel;
        input signed [15:0] expected;
        begin
            @(negedge clk);
            in_valid = 1;
            in_sample = sample;
            in_channel_id = channel;
            #1;
            if (!in_ready) $fatal(1, "FAIL: expected channel %0d ready", channel);
            tick();
            if (!out_valid || out_channel_id !== channel || out_sample !== expected)
                $fatal(1, "FAIL: ch%0d sample=%0d expected=%0d got=%0d",
                       channel, sample, expected, out_sample);
            @(negedge clk);
            in_valid = 0;
        end
    endtask

    initial begin
        tick();
        @(negedge clk); rst_n = 1;

        // Interleave channels. Their histories must never contaminate each other.
        push(16'sd4,   2'd0, 16'sd1);
        push(16'sd100, 2'd1, 16'sd25);
        push(16'sd8,   2'd0, 16'sd4);
        push(16'sd200, 2'd1, 16'sd100);
        push(16'sd12,  2'd0, 16'sd8);
        push(16'sd300, 2'd1, 16'sd200);

        // Third and fourth channels are independently initialized.
        push(-16'sd8,  2'd2, -16'sd2);
        push(16'sd40,  2'd3, 16'sd10);

        // Stall the output and ensure input is not accepted and payload is stable.
        @(negedge clk);
        in_valid = 1; in_sample = 16'sd16; in_channel_id = 2'd0;
        out_ready = 0;
        #1;
        if (in_ready) $fatal(1, "FAIL: accepted input while output slot is stalled");
        repeat (2) begin
            tick();
            if (!out_valid || out_sample !== 16'sd10 || out_channel_id !== 2'd3)
                $fatal(1, "FAIL: output changed under backpressure");
        end

        // Drain and accept a channel-0 sample; its own history gives (16+2*12+8)/4=12.
        @(negedge clk); out_ready = 1;
        #1;
        if (!in_ready) $fatal(1, "FAIL: did not recover from backpressure");
        tick();
        if (!out_valid || out_sample !== 16'sd12 || out_channel_id !== 2'd0)
            $fatal(1, "FAIL: channel history lost across backpressure");

        // Out-of-range channel ID is rejected (four configured channels).
        @(negedge clk);
        in_valid = 1; in_channel_id = 2'd3; in_sample = 16'sd1;
        out_ready = 1;
        #1;
        if (!in_ready) $fatal(1, "FAIL: valid channel should be ready");
        // Channel 3 is valid; verify its first-sample response.
        tick();
        if (!out_valid || out_sample !== 16'sd0 || out_channel_id !== 2'd3)
            $fatal(1, "FAIL: channel-3 independent history check");

        @(negedge clk); in_valid = 0;
        $display("PASS: multichannel FIR interleaving, independent history, and backpressure");
        $finish;
    end
endmodule
