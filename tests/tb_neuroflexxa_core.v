`timescale 1ns/1ps

module tb_neuroflexxa_core;
    reg clk = 1'b0;
    always #5 clk = ~clk;

    reg rst_n = 1'b0;
    reg in_valid = 1'b0;
    wire in_ready;
    reg signed [15:0] in_sample = 0;
    wire out_valid;
    reg out_ready = 1'b1;
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
        .out_valid(out_valid), .out_ready(out_ready),
        .out_sample(out_sample), .out_event(out_event),
        .out_timestamp(out_timestamp)
    );

    task send_sample;
        input integer value;
        begin
            @(negedge clk);
            while (!in_ready) @(negedge clk);
            in_sample = value;
            in_valid = 1'b1;
            @(posedge clk);
            while (!in_ready) @(posedge clk);
            @(negedge clk);
            in_valid = 1'b0;
        end
    endtask

    task check_output;
        input integer expected_sample;
        input integer expected_event;
        input integer expected_timestamp;
        begin
            wait(out_valid === 1'b1);
            #1;
            if ($signed(out_sample) !== expected_sample ||
                out_event !== expected_event[0] ||
                out_timestamp !== expected_timestamp) begin
                $display("FAIL: got sample=%0d event=%0d timestamp=%0d; expected sample=%0d event=%0d timestamp=%0d",
                    $signed(out_sample), out_event, out_timestamp,
                    expected_sample, expected_event, expected_timestamp);
                $fatal(1);
            end
            @(negedge clk);
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        send_sample(400);
        check_output(100, 1, 0);

        send_sample(0);
        check_output(200, 1, 1);

        send_sample(0);
        check_output(100, 1, 2);

        send_sample(0);
        check_output(0, 0, 3);

        // Backpressure: output must remain valid and stable until accepted.
        @(negedge clk);
        out_ready = 1'b0;
        in_sample = 40;
        in_valid = 1'b1;
        @(posedge clk);
        #1;
        if (!out_valid) $fatal(1, "FAIL: expected valid output under stall");
        begin : stable_check
            reg signed [15:0] held_sample;
            reg held_event;
            reg [31:0] held_timestamp;
            held_sample = out_sample;
            held_event = out_event;
            held_timestamp = out_timestamp;
            repeat (3) begin
                @(posedge clk);
                #1;
                if (!out_valid || out_sample !== held_sample ||
                    out_event !== held_event || out_timestamp !== held_timestamp)
                    $fatal(1, "FAIL: output changed while stalled");
            end
        end
        @(negedge clk);
        out_ready = 1'b1;
        in_valid = 1'b0;
        @(posedge clk);
        @(negedge clk);

        // Negative excursion checks signed FIR arithmetic and absolute magnitude.
        send_sample(-400);
        check_output(-80, 0, 5);
        send_sample(0);
        check_output(-190, 1, 6);
        send_sample(0);
        check_output(-100, 1, 7);

        $display("PASS: Neuroflexxa core smoke test");
        $finish;
    end

    initial begin
        #2000;
        $fatal(1, "FAIL: testbench timeout");
    end
endmodule
