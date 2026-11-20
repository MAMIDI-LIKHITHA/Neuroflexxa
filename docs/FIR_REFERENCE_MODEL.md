# FIR reference-model regression

The portable FIR arithmetic is checked against an independent Python integer model.

## Run

`make test-fir` generates deterministic vectors and runs the RTL testbench. `make test` includes the core, synthetic EEG and FIR suites.

## Model contract

`tools/fir_reference.py` models the current regression configuration:

- Signed 16-bit samples.
- Signed 8-bit coefficients [1, 2, 1].
- 26-bit signed accumulator.
- Arithmetic right shift by two fractional bits.
- 16-bit two's-complement output wrap.

The script uses a fixed random seed and emits nine directed corner vectors plus 2,048 deterministic randomized vectors. The Verilog testbench reads the generated file and compares every RTL output against the expected value.

This is a bit-accurate check of the configured arithmetic contract, not evidence that the coefficient set is appropriate for EEG physiology. Update the Python model, RTL parameters, testbench and specification together when the numeric configuration changes.
