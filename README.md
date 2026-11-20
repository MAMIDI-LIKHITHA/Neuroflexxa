# Neuroflexxa

**Simulation-first FPGA biosignal-processing prototype.**

Neuroflexxa is an early engineering prototype exploring a deterministic streaming pipeline for biosignal samples. **EEG is the first target workload**, beginning with synthetic engineering vectors only. The project is not a medical device and is not intended for diagnosis, treatment, seizure prediction, clinical decisions, or real-world prosthetic control.

## Current implementation

- Ready/valid streaming input and output.
- Three-tap demonstration FIR with coefficients [1, 2, 1] / 4.
- Absolute-amplitude threshold event tagging.
- Relative sample index.
- One-entry output register with backpressure stability.
- Core regression plus synthetic EEG-path regression.

The filter and threshold are demonstration logic, not validated EEG processing. The synthetic test vectors are not physiological recordings or a clinical signal model. This is not evidence of FPGA timing, resource utilization, power, sensor-to-action latency, or clinical performance.

## Quick start

Requirements: Icarus Verilog (`iverilog`), `vvp`, and GNU Make.

```sh
make test
```

Run only one suite:

```sh
make test-core
make test-eeg
```

Expected success messages:
- `PASS: Neuroflexxa core smoke test`
- `PASS: synthetic EEG-path vectors (14 samples)`

## Repository layout

```text
rtl/                 Synthesizable Verilog RTL
tests/               Self-checking core and synthetic EEG testbenches
docs/                Architecture, interface and EEG workload specifications
.github/workflows/   Continuous-integration smoke test
LIMITATIONS.md       Intended-use and evidence limitations
```

## Platform strategy

The RTL is being kept vendor-neutral. No FPGA board, device family or vendor toolchain has been selected. Portable synthesizable RTL and simulation are kept separate from future platform-specific clocking, pin constraints and IP wrappers. See [portability policy](docs/PORTABILITY.md) and [RTL coding standard](docs/RTL_CODING_STANDARD.md).

## Workload parameters still open

EEG channel count, sampling frequency, ADC resolution/encoding, input scaling, filter passband, fixed-point format, FPGA device/board and output interface have not been selected. Current RTL defaults are testbench conveniences only. See [docs/EEG_WORKLOAD_SPEC.md](docs/EEG_WORKLOAD_SPEC.md).

## Evidence policy

Only reproducible results with tool versions and configuration may be described as verified. Keep simulation, synthesis, FPGA timing, board power and end-to-end measurements separate. Never infer hardware or clinical performance from RTL simulation.

## Project status

**Status:** early prototype / simulation baseline.  
**Version:** 0.1.0-alpha.
