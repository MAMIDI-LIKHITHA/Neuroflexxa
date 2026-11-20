`timescale 1ns/1ps

// Non-default signed coefficients exercise configurable arithmetic independently.
module tb_neuroflexxa_fir3_custom;
    reg signed [15:0] x0, x1, x2;
    wire signed [15:0] y;
    integer fd, scan_result, count;
    integer expected;
    integer a, b, c;
    reg [1023:0] vector_path;

    neuroflexxa_fir3 #(
        .SAMPLE_WIDTH(16), .COEFF_WIDTH(8), .OUTPUT_WIDTH(16),
        .ACC_WIDTH(26), .FRAC_BITS(3),
        .COEFF0(-3), .COEFF1(5), .COEFF2(-2)
    ) dut (.x0(x0), .x1(x1), .x2(x2), .y(y));

    initial begin
        if (!$value$plusargs("VECTORS=%s", vector_path))
            $fatal(1, "Missing +VECTORS=<path>");
        fd = $fopen(vector_path, "r");
        if (fd == 0) $fatal(1, "Could not open custom FIR vectors: %0s", vector_path);

        count = 0;
        while (!$feof(fd)) begin
            scan_result = $fscanf(fd, "%d %d %d %d\n", a, b, c, expected);
            if (scan_result == 4) begin
                x0 = a; x1 = b; x2 = c;
                #1;
                if ($signed(y) !== expected) begin
                    $display("FAIL custom FIR vector %0d: x0=%0d x1=%0d x2=%0d got=%0d expected=%0d",
                             count, a, b, c, $signed(y), expected);
                    $fatal(1);
                end
                count = count + 1;
            end else if (!$feof(fd)) begin
                $fatal(1, "Malformed custom FIR vector near row %0d", count);
            end
        end
        $fclose(fd);
        if (count < 1) $fatal(1, "No custom FIR vectors were checked");
        $display("PASS: configurable signed FIR RTL matched Python reference (%0d vectors)", count);
        $finish;
    end
endmodule
