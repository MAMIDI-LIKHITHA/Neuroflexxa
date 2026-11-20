# Interface specification — v0.1.0-alpha

## Parameters

| Parameter | Default | Meaning |
|---|---:|---|
| `SAMPLE_WIDTH` | 16 | Signed two's-complement input/output sample width |
| `TIMESTAMP_WIDTH` | 32 | Width of relative sample index |
| `EVENT_THRESHOLD` | 100 | Absolute filtered-sample threshold, in input-code units |

These defaults are testbench values only. They are not recommended clinical or sensor settings.

## Input

| Signal | Direction | Description |
|---|---|---|
| `clk` | in | Single datapath clock |
| `rst_n` | in | Active-low synchronous reset |
| `in_valid` | in | Input sample is valid |
| `in_ready` | out | Core can accept a sample |
| `in_sample` | in | Signed sample |

A sample is accepted on a rising edge when `in_valid && in_ready`.

## Output

| Signal | Direction | Description |
|---|---|---|
| `out_valid` | out | Output record is valid |
| `out_ready` | in | Downstream can consume output |
| `out_sample` | out | Filtered signed sample |
| `out_event` | out | Threshold event flag |
| `out_timestamp` | out | Relative sample index |

The output record is consumed on a rising edge when `out_valid && out_ready`. All output fields remain stable while `out_valid && !out_ready`.

## Reset

Reset is synchronous and active-low. Reset clears filter history, sample index, and output-valid state. The first two output samples after reset therefore include zero-valued filter history.

## Workload decisions still open

The project has not yet selected EEG, EMG, or ECG as its first workload. Sampling frequency, ADC resolution/encoding, channel count, physical FPGA target, output transport, and numerical thresholds remain uncommitted. Do not present the defaults as measured or validated workload parameters.
