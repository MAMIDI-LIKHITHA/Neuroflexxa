# Development roadmap

This roadmap separates demonstrated implementation from future work. Dates and performance targets are intentionally not invented while the first workload and target platform remain undecided.

## Milestone 0 — repository and simulation baseline

- [x] Establish public project documentation and intended-use limitations.
- [x] Add a parameterized streaming RTL baseline.
- [x] Add a self-checking Icarus Verilog smoke test.
- [x] Add GitHub Actions simulation automation.
- [ ] Expand arithmetic, reset, throughput, and randomized backpressure tests.
- [ ] Review lint warnings and parameter corner cases.

## Milestone 1 — workload and interface definition

Decisions required before selecting filter coefficients or performance targets:

- First workload: EEG, EMG, or ECG.
- Channel count and sampling frequency.
- ADC resolution, signedness, scaling, and input framing.
- Required passband/stopband and filter response.
- Event definition and labelled reference data.
- Feature vector and window length.
- FPGA family, exact part, board, clock source, and I/O constraints.
- Host/output transport and packet format.

Deliverable: reviewed workload specification with numerical units and traceable requirements.

## Milestone 2 — signal-processing reference model

- Implement a bit-accurate software reference model.
- Select fixed-point formats and quantify quantization/overflow behavior.
- Compare RTL outputs against deterministic vectors.
- Add representative synthetic signals and appropriately licensed public datasets where suitable.
- Define event-level metrics before evaluating detector quality.

## Milestone 3 — pipeline development

- Split filtering, quality/artifact checks, event detection, feature extraction, and packetization into independently testable blocks.
- Add parameterized channel handling only after the first workload is fixed.
- Define pipeline latency and throughput contracts.
- Add assertions for ready/valid stability and state advancement.

## Milestone 4 — implementation evidence

- Run lint and synthesis for the exact target part.
- Record tool versions, constraints, utilization, timing, and warnings.
- Verify reset, clocking, CDC, and I/O integration.
- Measure FPGA pipeline latency separately from sensor-to-action latency.
- Measure power only on a stated board, workload, and instrument setup.

## Milestone 5 — partner evaluation

- Review the interface and evidence package with a technical design partner.
- Document reproducible setup, known limitations, and issue status.
- Do not make clinical or medical claims.
