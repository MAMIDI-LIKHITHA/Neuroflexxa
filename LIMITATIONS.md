# Limitations and intended use

Neuroflexxa is an early-stage engineering and educational prototype. The current implementation is simulation-first and has not been validated on physical FPGA hardware or with clinical users.

## Not for clinical use

This project is not a medical device. It must not be used for diagnosis, treatment, seizure prediction, patient monitoring, clinical decision-making, or control of a real prosthetic or other safety-critical system. No clinical safety, efficacy, regulatory approval, or medical performance is claimed.

## Evidence boundaries

- RTL simulation does not establish FPGA timing closure, resource utilization, power consumption, or real-time performance.
- A relative sample counter is not a calibrated timestamp.
- Simulated pipeline latency is not sensor-to-action latency.
- No sensor, ADC, analog front end, host link, or physical output has been integrated in this baseline.
- No recorded patient dataset or clinically labelled dataset has been validated.
- Threshold detection is a generic digital demonstration, not a clinically meaningful event detector.

Any performance claim must identify the hardware, tool versions, clock constraints, workload, input data, measurement boundary, repetitions, and raw evidence. Report median, p95, and maximum latency where appropriate, and distinguish FPGA pipeline latency from end-to-end latency.
