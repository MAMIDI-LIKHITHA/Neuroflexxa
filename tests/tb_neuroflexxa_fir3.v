`timescale 1ns/1ps

module tb_neuroflexxa_fir3;
    reg signed [15:0] x0, x1, x2;
    wire signed [15:0] y;

    neuroflexxa_fir3 #(
        .SAMPLE_WIDTH(16), .COEFF_WIDTH(8), .OUTPUT_WIDTH(16),
        .ACC_WIDTH(26), .FRAC_BITS(2),
        .COEFF0(1), .COEFF1(2), .COEFF2(1)
    ) dut (.x0(x0), .x1(x1), .x2(x2), .y(y));

    task check;
        input integer a, b, c, expected;
        begin
            x0=a; x1=b; x2=c; #1;
            if ($signed(y) !== expected) begin
                $display("FAIL FIR: x0=%0d x1=%0d x2=%0d got=%0d expected=%0d",
                         a,b,c,$signed(y),expected);
                $fatal(1);
            end
        end
    endtask

    initial begin
        check(400,0,0,100);       // impulse, first tap
        check(0,400,0,200);       // impulse, middle tap
        check(0,0,400,100);       // impulse, last tap
        check(40,40,40,40);       // unity DC gain
        check(-400,0,0,-100);     // negative signed result
        check(-10,0,0,-3);        // arithmetic shift rounds toward -infinity
        check(32767,32767,32767,32767); // full-scale steady input
        check(-32768,-32768,-32768,-32768);
        check(0,0,0,0);
        $display("PASS: parameterized FIR directed vectors (9 cases)");
        $finish;
    end
endmodule
