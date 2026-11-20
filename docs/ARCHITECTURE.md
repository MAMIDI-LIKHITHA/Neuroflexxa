# Architecture — v0.1.0-alpha

## Scope

The first implementation is a small, simulation-first streaming datapath. It is intended to validate basic RTL structure, signed arithmetic, ready/valid flow control, event tagging, and reproducible simulation. It is not yet a complete biosignal processor.

## Data path

```text
signed sample
    |
    v
ready/valid input
    |
    v
3-tap FIR: y[n] = (x[n] + 2x[n-1] + x[n-2]) / 4
    |
    v
absolute-amplitude threshold
    |
    +---- event flag
    |
    v
one-entry elastic output register
    |
    v
sample + event + relative sample index
```

The FIR uses coefficients [1, 2, 1] / 4. Arithmetic is signed two's-complement; the sum is widened before addition and shifted arithmetically. The event flag is asserted when the absolute filtered value is greater than or equal to the configured threshold.

## Flow control

A transfer occurs on a rising clock edge when both `valid` and `ready` are high. The output register can accept a new sample when it is empty or when the current output is being consumed. While `out_valid=1` and `out_ready=0`, output payload fields remain stable and input history does not advance.

## Timestamp semantics

`out_timestamp` is a relative sample index beginning at zero after reset. It is not wall-clock time and cannot be converted to seconds without a separately specified and validated sample rate.

## Current exclusions

This baseline does not yet implement configurable band-pass/notch filtering, artifact rejection, workload-specific event algorithms, feature-window aggregation, sensor interfaces, DMA, host communications, clock-domain crossing, or board-specific constraints. These should be added only after the first workload and interface are agreed.
