`timescale 1ns/1ps

// Synthetic EEG-like engineering stimulus only. These values are not clinical data.
module tb_eeg_synthetic;
    reg clk = 1'b0;
    always #5 clk = ~clk;

    reg rst_n = 1'b0;
    reg in_valid = 1'b0;
    wire in_ready;
    reg signed [15:0] in_sample = 0;
    wire out_valid;
    wire signed [15:0] out_sample;
    wire out_event;
    wire [31:0] out_timestamp;

    neuroflexxa_core #(
        .SAMPLE_WIDTH(16),
        .TIMESTAMP_WIDTH(32),
        .EVENT_THRESHOLD(100)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .in_ready(in_ready), .in_sample(in_sample),
        .out_valid(out_valid), .out_ready(1'b1),
        .out_sample(out_sample), .out_event(out_event),
        .out_timestamp(out_timestamp)
    );

    integer samples [0:13];
    integer expected [0:13];
    integer i;
    integer expected_event;

    initial begin
        // Low-amplitude oscillatory baseline followed by a synthetic transient.
        samples[0]=0;   samples[1]=10;  samples[2]=20;  samples[3]=10;
        samples[4]=0;   samples[5]=-10; samples[6]=-20; samples[7]=-10;
        samples[8]=0;   samples[9]=0;   samples[10]=0;  samples[11]=300;
        samples[12]=0;  samples[13]=0;

        // Exact integer results for y[n]=(x[n]+2*x[n-1]+x[n-2]) >>> 2.
        expected[0]=0;   expected[1]=2;   expected[2]=10;  expected[3]=15;
        expected[4]=10;  expected[5]=0;   expected[6]=-10; expected[7]=-15;
        expected[8]=-10; expected[9]=-2;  expected[10]=0; expected[11]=75;
        expected[12]=150; expected[13]=75;

        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        for (i=0; i<14; i=i+1) begin
            @(negedge clk);
            while (!in_ready) @(negedge clk);
            in_sample = samples[i];
            in_valid = 1'b1;
            @(posedge clk);
            #1;
            expected_event = (expected[i] >= 100 || expected[i] <= -100);
            if (!out_valid || $signed(out_sample) !== expected[i] ||
                out_event !== expected_event[0] || out_timestamp !== i) begin
                $display("FAIL EEG vector %0d: sample=%0d event=%0d timestamp=%0d expected=%0d event=%0d timestamp=%0d",
                    i, $signed(out_sample), out_event, out_timestamp,
                    expected[i], expected_event, i);
                $fatal(1);
            end
            @(negedge clk);
            in_valid = 1'b0;
        end

        $display("PASS: synthetic EEG-path vectors (14 samples)");
        $finish;
    end

    initial begin
        #3000;
        $fatal(1, "FAIL: EEG testbench timeout");
    end
endmodule
