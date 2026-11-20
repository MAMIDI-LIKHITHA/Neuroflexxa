# Parameterized FIR module contract

## Purpose

`rtl/neuroflexxa_fir3.v` is a vendor-neutral, combinational three-tap signed FIR arithmetic block. It is separated from the streaming control so it can be reused and verified independently.

## Equation

`acc = x0*COEFF0 + x1*COEFF1 + x2*COEFF2`

`scaled = acc >>> FRAC_BITS`

`y = scaled[OUTPUT_WIDTH-1:0]`

The core currently maps the newest sample to x0, one-sample history to x1 and two-sample history to x2, with coefficients 1, 2 and 1 and FRAC_BITS=2.

## Numeric behavior

- Inputs and coefficients are signed two's-complement values.
- Each product is PRODUCT_WIDTH = SAMPLE_WIDTH + COEFF_WIDTH bits.
- Products are sign-extended to ACC_WIDTH before addition.
- The accumulator is signed; choose ACC_WIDTH large enough for the maximum sum of the three products.
- Scaling uses an arithmetic right shift. This truncates fractional bits; for negative values it rounds toward negative infinity (for example, -10 >>> 2 is -3).
- The result is truncated to OUTPUT_WIDTH low bits. Overflow wraps in two's-complement; saturation is not implemented.
- The default [1,2,1]/4 coefficient set has unity DC gain. It is a demonstration filter, not a selected EEG passband.

## Parameter constraints

Use ACC_WIDTH >= SAMPLE_WIDTH + COEFF_WIDTH and OUTPUT_WIDTH <= ACC_WIDTH. FRAC_BITS must be between zero and ACC_WIDTH-1. Coefficients and widths must be selected from a documented numeric-range analysis before changing the production configuration.

## Verification

`tests/tb_neuroflexxa_fir3.v` checks individual taps, unity gain, negative values, arithmetic-shift behavior and signed full-scale steady inputs. Run `make test-fir` or the complete `make test` suite.
