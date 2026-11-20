# Vendor-neutral RTL portability policy

## Decision

The first implementation target is portable Verilog RTL. No FPGA vendor, development board, device part, IP catalog or toolchain is selected at this stage.

## RTL rules

- Keep the functional datapath in synthesizable Verilog; avoid vendor-specific primitives in the core.
- Do not instantiate PLLs, block RAM macros, DSP macros, transceivers, hard processors or vendor I/O cells in portable modules.
- Keep clocking, reset, pin constraints and physical I/O outside the algorithmic core.
- Use explicit signed declarations and explicit widths for arithmetic.
- Document truncation, rounding, saturation and overflow behavior for every fixed-point datapath.
- Keep simulation-only constructs in testbench files, not synthesizable RTL.
- Avoid implicit nets; declare every signal.
- Keep ready/valid behavior deterministic and verify payload stability during backpressure.
- Add vendor-specific wrappers only after a target platform is selected; preserve a portable reference implementation.

## Verification strategy

The current baseline uses Icarus Verilog and GitHub Actions. This establishes simulation portability, not synthesis portability. Before claiming a module is synthesizable across vendors, run a synthesis/lint flow and inspect inferred memories, multipliers, latches, clock enables and unsupported constructs.

## Platform decision gate

A target FPGA should be selected only after requirements are known for channel count, sample rate, ADC interface, throughput, latency, available board I/O, memory, power and development-tool access. Then add a separate platform layer containing constraints, clock generation and any vendor IP wrappers.

## Evidence labels

Use these distinct labels in reports:

1. RTL simulation passed.
2. Generic synthesis completed (name tool/version and settings).
3. Vendor synthesis completed (name tool/version, device and constraints).
4. Place-and-route timing completed (report clocks and constraints).
5. Board test completed (identify board, bitstream, test setup and measured results).

Do not describe a simulation pass as FPGA validation.
