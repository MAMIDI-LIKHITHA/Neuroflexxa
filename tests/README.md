# Simulation tests

Run the current smoke test from the repository root:

```sh
make test
```

The testbench is `tb_neuroflexxa_core.v`. It uses Icarus Verilog and checks a short FIR response, event threshold behavior, sample indexing, and output stability during a downstream stall.

The current test is a smoke test only. See [the verification plan](../docs/VERIFICATION_PLAN.md) for required corner cases and the distinction between implemented tests and planned tests.
