`timescale 1ns/1ps

module tb_neuroflexxa_eeg_stream_adapter;
    reg clk = 0;
    always #5 clk = ~clk;

    reg rst_n = 0;
    reg in_valid = 0;
    wire in_ready;
    reg signed [15:0] in_sample = 0;
    reg [1:0] in_channel_id = 0;
    wire out_valid;
    reg out_ready = 0;
    wire signed [15:0] out_sample;
    wire [1:0] out_channel_id;

    neuroflexxa_eeg_stream_adapter #(
        .SAMPLE_WIDTH(16),
        .CHANNEL_ID_WIDTH(2)
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

    task send_sample;
        input signed [15:0] sample;
        input [1:0] channel;
        begin
            @(negedge clk);
            in_valid = 1;
            in_sample = sample;
            in_channel_id = channel;
            while (!in_ready) @(negedge clk);
            tick();
            @(negedge clk);
            in_valid = 0;
        end
    endtask

    initial begin
        tick();
        @(negedge clk); rst_n = 1;

        send_sample(16'sd1234, 2'd0);
        if (!out_valid || out_sample !== 16'sd1234 || out_channel_id !== 2'd0)
            $fatal(1, "FAIL: positive sample/channel transfer");

        // Hold downstream stalled and verify the complete payload is stable.
        repeat (3) begin
            tick();
            if (!out_valid || out_sample !== 16'sd1234 || out_channel_id !== 2'd0)
                $fatal(1, "FAIL: payload changed under backpressure");
        end

        // Consume current item and enqueue a negative sample in same cycle.
        @(negedge clk);
        in_valid = 1;
        in_sample = -16'sd2048;
        in_channel_id = 2'd3;
        out_ready = 1;
        #1; // Allow the combinational ready path to settle after changing out_ready.
        if (!in_ready) $fatal(1, "FAIL: expected simultaneous dequeue/enqueue readiness");
        tick();
        if (!out_valid || out_sample !== -16'sd2048 || out_channel_id !== 2'd3)
            $fatal(1, "FAIL: simultaneous dequeue/enqueue");

        @(negedge clk);
        in_valid = 0;
        out_ready = 0;
        repeat (2) begin
            tick();
            if (!out_valid || out_sample !== -16'sd2048 || out_channel_id !== 2'd3)
                $fatal(1, "FAIL: negative payload not stable during stall");
        end

        @(negedge clk); out_ready = 1;
        tick();
        if (out_valid !== 1'b0) $fatal(1, "FAIL: output did not drain");

        // Reset clears valid state.
        @(negedge clk); out_ready = 0; rst_n = 0;
        tick();
        if (out_valid !== 1'b0) $fatal(1, "FAIL: reset did not clear valid");
        $display("PASS: EEG stream adapter reset, signed payload, channel tag, and backpressure");
        $finish;
    end
endmodule
