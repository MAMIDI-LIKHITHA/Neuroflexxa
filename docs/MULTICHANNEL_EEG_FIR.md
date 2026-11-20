# Multi-channel EEG FIR bank

## Purpose

`neuroflexxa_eeg_multichannel_fir` is a vendor-neutral simulation/RTL prototype that maintains independent three-sample FIR state for each configured channel. Samples may be interleaved across channels; each accepted sample updates only the selected channel's two-sample history.

## Interface and parameters

- `SAMPLE_WIDTH`: signed two's-complement input sample width (default 16).
- `CHANNELS`: number of configured channel histories (default 4, a test configuration only).
- `CHANNEL_ID_WIDTH`: width of the opaque channel ID (default 2).
- FIR coefficient, accumulator, output-width and fractional-shift parameters are passed to the existing reusable `neuroflexxa_fir3` block.
- Input and output use ready/valid. A transfer occurs on a rising edge with valid and ready high.
- The one-entry output stage permits simultaneous dequeue/enqueue and holds the tagged output stable during backpressure.
- Channel IDs greater than or equal to CHANNELS are not accepted (`in_ready=0`).

## State isolation

For every channel, the module stores its own previous and two-previous samples. The selected channel's history feeds the FIR for the current input. Only that channel's history is shifted when the input is accepted. Reset clears all channel histories and output-valid state.

## Numeric behavior

The module reuses `neuroflexxa_fir3`: default coefficients [1,2,1], arithmetic right shift by two, and two's-complement output truncation/wrap. This is a demonstration filter, not an EEG clinical filter. No ADC scaling, resampling, notch/band-pass design, or artifact rejection is performed.

## Verification

`tests/tb_neuroflexxa_eeg_multichannel_fir.v` interleaves samples across four configured channels and checks expected FIR outputs, independent channel histories, backpressure stability, and recovery. Four channels are only a simulation configuration; the actual channel count and mapping remain requirements to be confirmed. This test does not establish physiological, clinical, or hardware validity.
