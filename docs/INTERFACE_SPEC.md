# Interface specification — v0.1.0-alpha

## Parameters

| Parameter | Default | Meaning |
|---|---:|---|
| `SAMPLE_WIDTH` | 16 | Signed two's-complement sample width |
| `TIMESTAMP_WIDTH` | 32 | Relative sample-index width |
| `EVENT_THRESHOLD` | 100 | Demonstration absolute-amplitude threshold |

Defaults are simulation conveniences only. They are not EEG acquisition recommendations or clinical settings.

## Input

| Signal | Direction | Description |
|---|---|---|
| `clk` | in | Single datapath clock |
| `rst_n` | in | Active-low synchronous reset |
| `in_valid` | in | Input sample is valid |
| `in_ready` | out | Core can accept a sample |
| `in_sample` | in | Signed fixed-width sample |

A sample is accepted on a rising edge when `in_valid && in_ready`.

## Output

| Signal | Direction | Description |
|---|---|---|
| `out_valid` | out | Output record is valid |
| `out_ready` | in | Downstream can consume output |
| `out_sample` | out | Filtered signed sample |
| `out_event` | out | Demonstration threshold flag |
| `out_timestamp` | out | Relative sample index |

The output record is consumed on a rising edge when `out_valid && out_ready`. All output fields remain stable while `out_valid && !out_ready`.

## Reset and timestamp

Reset is synchronous and active-low. It clears filter history, sample index and output-valid state. The first two output samples therefore include zero-valued filter history. Timestamp zero is assigned to the first accepted sample after reset.

## EEG interface decisions still open

The following are not yet defined: channel count, sampling frequency, ADC resolution/encoding, input voltage scaling, sample packing, external clocking, FPGA target and output transport. The present interface is a simulation boundary, not a sensor/ADC interface.
