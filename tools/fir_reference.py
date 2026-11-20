#!/usr/bin/env python3
"""Generate deterministic golden vectors for a configurable signed FIR3."""
import argparse
import random
from pathlib import Path


def signed_wrap(value: int, width: int) -> int:
    mask = (1 << width) - 1
    value &= mask
    sign = 1 << (width - 1)
    return value - (1 << width) if value & sign else value


def fir_reference(x0: int, x1: int, x2: int, *, sample_width: int,
                  coeff_width: int, acc_width: int, output_width: int,
                  frac_bits: int, coeffs: tuple[int, int, int]) -> int:
    sample_values = (x0, x1, x2)
    products = [
        signed_wrap(signed_wrap(x, sample_width) * signed_wrap(c, coeff_width),
                    sample_width + coeff_width)
        for x, c in zip(sample_values, coeffs)
    ]
    accumulator = signed_wrap(sum(products), acc_width)
    # Python's signed right shift matches Verilog arithmetic >>>.
    return signed_wrap(accumulator >> frac_bits, output_width)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--count", type=int, default=2048)
    parser.add_argument("--sample-width", type=int, default=16)
    parser.add_argument("--coeff-width", type=int, default=8)
    parser.add_argument("--acc-width", type=int, default=26)
    parser.add_argument("--output-width", type=int, default=16)
    parser.add_argument("--frac-bits", type=int, default=2)
    parser.add_argument("--coeffs", type=int, nargs=3, default=(1, 2, 1),
                        metavar=("C0", "C1", "C2"))
    parser.add_argument("--seed", type=lambda x: int(x, 0), default=0x4E465846)
    args = parser.parse_args()

    if args.count < 0:
        parser.error("--count must be non-negative")
    if not (1 <= args.sample_width <= 32 and 1 <= args.coeff_width <= 32):
        parser.error("sample and coefficient widths must be in [1, 32]")
    if not (args.sample_width + args.coeff_width <= args.acc_width <= 63):
        parser.error("accumulator width must cover a product and be <= 63")
    if not (1 <= args.output_width <= args.acc_width):
        parser.error("output width must be in [1, acc-width]")
    if not (0 <= args.frac_bits < args.acc_width):
        parser.error("frac-bits must be in [0, acc-width-1]")
    coeff_min = -(1 << (args.coeff_width - 1))
    coeff_max = (1 << (args.coeff_width - 1)) - 1
    if any(c < coeff_min or c > coeff_max for c in args.coeffs):
        parser.error("coefficient does not fit signed coefficient width")

    rng = random.Random(args.seed)
    sample_min = -(1 << (args.sample_width - 1))
    sample_max = (1 << (args.sample_width - 1)) - 1
    vectors = [
        (0, 0, 0), (sample_max, sample_max, sample_max),
        (sample_min, sample_min, sample_min),
        (sample_max, sample_min, 1), (-1, -1, -1),
        (-10, 0, 0), (0, 400, 0), (400, 0, 0), (0, 0, 400),
    ]
    vectors.extend(tuple(rng.randint(sample_min, sample_max) for _ in range(3))
                   for _ in range(args.count))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="ascii") as stream:
        for samples in vectors:
            expected = fir_reference(
                *samples, sample_width=args.sample_width,
                coeff_width=args.coeff_width, acc_width=args.acc_width,
                output_width=args.output_width, frac_bits=args.frac_bits,
                coeffs=tuple(args.coeffs))
            stream.write("{} {} {} {}\n".format(*samples, expected))
    print(f"Generated {len(vectors)} FIR vectors: coeffs={tuple(args.coeffs)}, "
          f"frac_bits={args.frac_bits}, seed={args.seed:#x}, output={args.output}")


if __name__ == "__main__":
    main()
