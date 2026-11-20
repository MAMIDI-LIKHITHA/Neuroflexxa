# FIR fixed-point configuration and verification

## Compile-time configurability

The reusable `neuroflexxa_fir3` datapath and multi-channel FIR bank expose signed `COEFF0`, `COEFF1`, `COEFF2` and `FRAC_BITS` parameters. These are elaboration-time parameters, not runtime software-programmable registers. Changing them changes the synthesized arithmetic constants.

## Demonstration configurations

| Configuration | Coefficients | Fraction shift | Purpose |
|---|---:|---:|---|
| Default | [1, 2, 1] | 2 | Existing baseline regression |
| Alternate test | [-3, 5, -2] | 3 | Exercise negative coefficients and a different scale |

The alternate set is an artificial arithmetic test vector configuration. It is not an EEG filter design, passband, notch, or clinically validated coefficient set.

## Arithmetic contract

For each input tuple:

`acc = x0*COEFF0 + x1*COEFF1 + x2*COEFF2`

`scaled = acc >>> FRAC_BITS`

`y = scaled[OUTPUT_WIDTH-1:0]`

- Samples and coefficients are signed two's-complement values.
- Each product is `SAMPLE_WIDTH + COEFF_WIDTH` bits.
- Products are sign-extended before accumulation.
- The accumulator wraps at `ACC_WIDTH`; choose a width that prevents unintended overflow for the selected coefficient and input ranges.
- Arithmetic right shift discards fractional bits; negative values round toward negative infinity.
- Output narrowing keeps the low `OUTPUT_WIDTH` bits (two's-complement wrap). There is no rounding-to-nearest or saturation.
- `ACC_WIDTH >= SAMPLE_WIDTH + COEFF_WIDTH`, `OUTPUT_WIDTH <= ACC_WIDTH`, and `0 <= FRAC_BITS < ACC_WIDTH` are required by the current RTL structure.

## Independent golden-model regression

`tools/fir_reference.py` accepts width, coefficient, scaling, count, and seed arguments. It emits integer vectors that the Verilog testbench compares against the RTL.

- `make test-fir`: default [1, 2, 1]/4 configuration, 9 directed plus 2048 deterministic random tuples.
- `make test-fir-custom`: alternate [-3, 5, -2]/8 configuration, 9 directed plus 2048 deterministic random tuples.
- `make test`: includes both FIR regressions and all core, EEG, adapter, and multi-channel tests.

The Python model intentionally mirrors the declared bit widths and wrap behavior. Passing these tests establishes arithmetic agreement for the tested configurations; it does not establish EEG signal quality, timing closure, FPGA resource use, or clinical validity.

## Configuration selection gate

Before adopting any actual EEG filter coefficients, define the acquisition sample rate, desired passband/notch, channel requirements, ADC scaling, acceptable quantization/noise, coefficient quantization method, overflow policy, and end-to-end latency. Then derive coefficient and accumulator widths from a documented range analysis and verify against an independently reviewed signal-processing reference.
