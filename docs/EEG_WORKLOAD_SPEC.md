# EEG first-workload specification — draft 0.1

## Decision

EEG is the first workload for the Neuroflexxa engineering prototype. The current milestone validates only a streaming digital datapath using deterministic synthetic samples. It does not implement an EEG interpretation, seizure-detection, BCI-decoding, or clinical algorithm.

## Current engineering demonstration

The existing RTL core accepts signed sample words through a ready/valid interface, applies a three-tap demonstration FIR filter, tags filtered amplitudes against a configurable threshold, and emits a relative sample index. The dedicated synthetic testbench exercises:

- A low-amplitude oscillatory sequence.
- A positive transient embedded in the sequence.
- Positive and negative arithmetic.
- Exact filtered output values and event-tag behavior.
- Sequential sample-index behavior.

The stimulus is intentionally synthetic and small. It is not a physiological EEG model and must not be described as representative patient data.

## Parameters deliberately not selected

The following require a documented system requirement or partner decision before implementation:

| Decision | Status |
|---|---|
| EEG channel count | Open |
| Sampling frequency | Open |
| ADC resolution and signed encoding | Open |
| Input voltage scaling / calibration | Open |
| Clinical or research dataset | Not selected |
| EEG passband and notch requirements | Open |
| Filter coefficients and fixed-point format | Open |
| FPGA board and device part | Open |
| Output transport / host interface | Open |
| Latency, throughput, power and resource targets | Open |

Do not infer these values from the current RTL defaults.

## Next technical stages

1. Agree channel count, sample rate, ADC representation and target FPGA.
2. Define a versioned sample format and scaling contract.
3. Select a public, appropriately licensed EEG dataset or a documented synthetic signal model.
4. Build a bit-accurate software reference model for the chosen filter.
5. Derive filter coefficients from the agreed passband and fixed-point constraints.
6. Add multi-channel framing, window aggregation and packet output only after their requirements are specified.
7. Report simulation, synthesis, timing, board-power and end-to-end measurements as separate evidence categories.

## Non-medical scope

Neuroflexxa is an engineering prototype. It is not validated for diagnosis, treatment, seizure prediction, patient monitoring, clinical decisions, or safety-critical control.
