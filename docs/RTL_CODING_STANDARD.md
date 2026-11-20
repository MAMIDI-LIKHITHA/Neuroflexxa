# RTL coding standard — portable baseline

This standard applies to the portable Neuroflexxa datapath.

## Language and structure

- Use Verilog-2001-compatible synthesizable constructs for the core unless a documented need justifies otherwise.
- Keep testbench language features separate from RTL language features.
- Declare widths and signedness explicitly.
- Use named port connections for module instances.
- Use nonblocking assignments in clocked sequential logic and blocking assignments in combinational logic.
- Use complete combinational assignments to avoid inferred latches.
- Avoid vendor primitives and synthesis attributes in portable core modules.

## Arithmetic

- Size intermediate expressions explicitly; do not rely on implicit expression sizing.
- Define signed extension before mixed-width operations.
- Document whether right shifts are arithmetic or logical.
- Define rounding, truncation, saturation and wraparound behavior.
- Add boundary tests for minimum negative, maximum positive, zero and threshold-adjacent values.

## Streaming protocol

- A transfer occurs only when valid and ready are both asserted at the active clock edge.
- A producer must hold valid and payload stable until transfer.
- A consumer may apply backpressure at any time.
- Tests must cover consecutive transfers, bubbles, reset and prolonged backpressure.

## Reset and clocks

- Keep the functional core on an explicit clock input.
- Do not create gated clocks in portable datapath logic.
- Document reset polarity and synchronous/asynchronous behavior at every module boundary.
- Synchronize asynchronous external reset or control signals in a platform wrapper when required.

## Verification expectations

Every new module should include:
- A self-checking testbench.
- Directed boundary cases.
- Backpressure and reset tests where applicable.
- A reproducible Makefile target and CI execution.
- A short interface and arithmetic contract in its module documentation.
