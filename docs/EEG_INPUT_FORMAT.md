# EEG Stream Input Format and Adapter

## Purpose

The EEG stream adapter is a vendor-neutral, one-entry ready/valid transport stage. It carries a signed sample and its channel identifier together as one payload. It does not interpret the channel identifier or make assumptions about an ADC, electrode montage, sampling rate, or clinical use.

## RTL interface

Module: `neuroflexxa_eeg_stream_adapter`

| Parameter | Default | Meaning |
|---|---:|---|
| `SAMPLE_WIDTH` | 16 | Width of the two's-complement signed sample bus |
| `CHANNEL_ID_WIDTH` | 2 | Width of the opaque channel identifier |

Input payload: `in_sample`, `in_channel_id`, qualified by `in_valid && in_ready`.

Output payload: `out_sample`, `out_channel_id`, qualified by `out_valid && out_ready`.

The channel identifier is transported unchanged. With the default two-bit width, four bit patterns can be represented; this is not a decision that the product has four EEG channels. The system integrator must define which IDs are legal and how they map to physical acquisition channels.

## Handshake and reset

- A transfer occurs on a rising clock edge when valid and ready are both high.
- The adapter has one payload slot and supports simultaneous output consumption and input acceptance.
- While `out_valid=1` and `out_ready=0`, output valid and the entire payload remain stable.
- Active-low synchronous reset clears `out_valid`; payload register values after reset are zero but must be ignored while valid is low.
- No sample is silently dropped when the producer obeys ready/valid.

## Numeric contract

Samples are signed two's-complement integers. The adapter transports bits without scaling, offset correction, saturation, rounding, or unit conversion. ADC encoding and physical scaling must be specified by the acquisition interface before connecting real hardware.

## Requirements intentionally left open

The following must be decided from the intended acquisition hardware and workload; defaults in the RTL are simulation conveniences only:

- Number of EEG channels and channel-ID mapping
- Sampling frequency and clock-domain relationship
- ADC resolution, signed/unsigned encoding, offset, and input scaling
- Electrode montage/reference and acquisition front-end
- Filtering passband, notch requirements, and coefficient source
- Fixed-point precision, rounding, overflow/saturation policy
- FPGA device, board, I/O standard, and physical interface
- End-to-end latency, throughput, power, and resource targets

## Verification

`tests/tb_neuroflexxa_eeg_stream_adapter.v` checks reset, positive and negative sample transport, channel-tag preservation, payload stability under backpressure, and simultaneous dequeue/enqueue. This is RTL interface verification only; it is not EEG signal-quality, physiological, clinical, or hardware validation.
