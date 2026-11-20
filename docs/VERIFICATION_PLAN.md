# Verification plan

## Current automated smoke test

The current testbench checks the default 16-bit configuration for:

- FIR impulse-response sequence.
- Threshold event tagging at and above the configured threshold.
- Relative sample-index progression.
- Output payload stability while downstream backpressure is asserted.

The smoke test is not exhaustive verification.

## Required next tests

| Test | Purpose | Status |
|---|---|---|
| Positive impulse response | Check FIR arithmetic and history | Smoke-tested |
| Threshold equality | Confirm inclusive >= threshold behavior | Smoke-tested |
| Negative samples | Check signed arithmetic and absolute value | Planned |
| Negative full-scale corner | Check magnitude width/overflow | Planned |
| Threshold below/above boundary | Verify event transitions | Partial |
| Reset while idle | Check deterministic reset state | Planned |
| Reset during valid output | Define and verify reset behavior | Planned |
| Continuous valid stream | Check one-sample-per-cycle throughput | Planned |
| Random output stalls | Verify elastic-buffer stability | Partial |
| Timestamp rollover | Verify configured counter wrap | Planned |
| Parameter sweep | Exercise supported widths/thresholds | Planned |
| Reference-model comparison | Compare every sample against independent model | Planned |

## Evidence rules

A test is verified only when the test is executed and its result is recorded. A test listed as planned is not evidence of completion. Preserve simulator version, command line, source revision, and logs for formal review. Simulation results do not prove physical FPGA timing, power, or clinical performance.
