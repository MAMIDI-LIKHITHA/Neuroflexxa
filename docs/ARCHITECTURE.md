# Architecture — v0.1.0-alpha

## Scope and first workload

EEG is the first target workload. The current implementation remains a generic streaming datapath exercised with synthetic engineering vectors; it is not an EEG interpretation or clinical algorithm.

## Current data path

```text
signed synthetic sample
    |
ready/valid input
    |
3-tap demonstration FIR: y[n] = (x[n] + 2x[n-1] + x[n-2]) >>> 2
    |
absolute-amplitude threshold tag
    |
one-entry elastic output register
    |
filtered sample + event flag + relative sample index
```

The FIR coefficients [1, 2, 1] / 4 and threshold are deliberately simple test values. They are not selected EEG filter coefficients or clinically meaningful thresholds.

## Flow control

A transfer occurs on a rising clock edge when both valid and ready are high. The output register accepts a new sample when empty or when the current output is consumed. While `out_valid=1` and `out_ready=0`, output payload fields remain stable and input history does not advance.

## Timestamp semantics

`out_timestamp` is a relative sample index beginning at zero after reset. It is not wall-clock time and cannot be converted to seconds until a sampling frequency is specified.

## EEG decisions still open

Channel count, sampling frequency, ADC representation, input scaling, filter passband, coefficient quantization, target FPGA and output transport are not yet specified. See [EEG workload specification](EEG_WORKLOAD_SPEC.md).

## Not implemented

No multi-channel scheduler, configurable EEG band-pass/notch filter, artifact rejection, feature-window aggregation, EEG event classifier, sensor interface, DMA, host communications, CDC, board constraints or hardware measurement flow is implemented yet.
