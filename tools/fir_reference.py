#!/usr/bin/env python3
"""Generate deterministic golden vectors for Neuroflexxa's default FIR3 config."""
import argparse
import random
from pathlib import Path

SAMPLE_WIDTH = 16
COEFF_WIDTH = 8
ACC_WIDTH = 26
OUTPUT_WIDTH = 16
FRAC_BITS = 2
COEFFS = (1, 2, 1)


def signed_wrap(value: int, width: int) -> int:
    mask = (1 << width) - 1
    value &= mask
    sign = 1 << (width - 1)
    return value - (1 << width) if value & sign else value


def fir_reference(x0: int, x1: int, x2: int) -> int:
    products = [signed_wrap(x * c, SAMPLE_WIDTH + COEFF_WIDTH)
                for x, c in zip((x0, x1, x2), COEFFS)]
    accumulator = signed_wrap(sum(products), ACC_WIDTH)
    # Python right shift on a negative integer is arithmetic (floor division).
    scaled = accumulator >> FRAC_BITS
    return signed_wrap(scaled, OUTPUT_WIDTH)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--count", type=int, default=2048)
    args = parser.parse_args()

    rng = random.Random(0x4E465846)
    vectors = [
        (0, 0, 0), (32767, 32767, 32767), (-32768, -32768, -32768),
        (32767, -32768, 1), (-1, -1, -1), (-10, 0, 0),
        (0, 400, 0), (400, 0, 0), (0, 0, 400),
    ]
    vectors.extend(tuple(rng.randint(-32768, 32767) for _ in range(3))
                   for _ in range(args.count))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="ascii") as stream:
        for x0, x1, x2 in vectors:
            expected = fir_reference(x0, x1, x2)
            stream.write(f"{x0} {x1} {x2} {expected}\n")
    print(f"Generated {len(vectors)} deterministic FIR reference vectors: {args.output}")


if __name__ == "__main__":
    main()
