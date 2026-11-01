# Methodology

## Hardware and software

| | |
|---|---|
| Machine | MacBook Air (`Mac17,4`), passively cooled, Apple M5: 4 performance + 6 efficiency cores, 32 GB |
| Caches (performance cores) | L1d 128 KB, L2 16 MB, cache line 128 bytes, page 16 KB |
| SME | FEAT_SME, FEAT_SME2, FEAT_SME_F64F64, SVL 512 bits |
| OS | macOS 26.6 (25G72) |
| Julia | 1.13.3, local to the repository; no system-wide installation |
| PureBLAS.jl | 0.1.2, `512283276b55aa70fe59d91f98f260eba0e8244c`, pure Julia, JIT on this machine |
| UlmBLAS.jl | `c67e43196d621d45c3578e8ce2c1f8917284318c`, pinned artifact, SME variant |
| OpenBLAS (Julia default) | 0.3.30, core `neoversen1`, NEON |
| OpenBLAS (Homebrew) | 0.3.34, core `vortexm4`, NEON, OpenMP; existing installation |
| Apple Accelerate | system, ILP64 symbols `$NEWLAPACK$ILP64` |
| blis_jll | 2.0.0+2, NEON |
| BLIS PR #921 | `235ef8ec`, SME2 configuration `m4sme_p`, built locally, pthreads, 64-bit integers |
| Compiler for BLIS | Apple clang 21.0.0 |

Full record: [`results/environment.txt`](../results/environment.txt), plus one `meta_*.txt` per process in each `raw` directory.

## Threads

| Setting | Single-thread campaigns | `mt` campaign |
|---|---|---|
| `OPENBLAS_NUM_THREADS`, `VECLIB_MAXIMUM_THREADS`, `BLIS_NUM_THREADS`, `OMP_NUM_THREADS`, `JULIA_NUM_THREADS` | 1 | 4 |
| Julia | `-t 1,0 --gcthreads=1` | `-t 4,0 --gcthreads=1` |
| `PureBLAS.set_num_threads` | 1 | 4 |

Single- and multi-threaded data are never mixed in one plot. CPU time / wall time is recorded per sample, so it shows what a library really did with its threads. The process runs at interactive QoS. UlmBLAS.jl is single-threaded and refuses other settings; it is not in the `mt` campaign.

## Measurement

- **Problem:** `C := A*B`, Float64, m = n = k, column-major, α = 1, β = 0. Throughput is 2n³/time.
- **Inputs:** reproducible per (n, round) with `Xoshiro(1_000_000*round + n)`, uniform on [-0.5, 0.5). The CRC of the inputs is stored and compared across backends.
- **Isolation:** one Julia process per (backend, round). Backends are in random order per round, sizes in random order per process. This reduces thermal and order bias.
- **Per size:** correctness check, warm-up (at least one call and 0.1 s, so JIT is excluded), then 5 samples of at least 0.05 s each. GC is off in the timed region. C is reset to NaN (untimed) before each sample, so a backend that reads C with β = 0 would fail.
- **Anti-elimination:** results are used by the check and by a NaN test after each sample; every call goes through a function that the compiler can't remove.
- **Statistics:** median of samples per (backend, n, round), then median and range over rounds; ratios are paired by round.
- **Backends cannot be silently replaced:** `src/backends.jl` compares the actual LBT forward address with the library's symbol and raises an error if they differ.

## Correctness

No performance figure is accepted for a size without a passed check. For n ≤ 400, all entries are compared with a reference computation; for larger n, a sample of 2000 entries plus a Freivalds check. The ratio to a rounding-error bound must be ≤ 4. Also checked: no NaN, zero allocations in the timed region, bitwise repeatability of repeated calls, and for PureBLAS, that the SME counter matches the number of calls. Results: `results/*/acceptance.md`.

## Machine state

The measurements were done on a machine in everyday use. Three mechanisms keep this visible:

- **Thermal guard:** before each process, wait for thermal state "nominal"; logged in `campaign.log`.
- **Load guard** (added after the sweep): wait until the 1-minute load is ≤ 5, at most 30 minutes. The baseline already includes an unrelated single-threaded job at 100%.
- **Scalar anchor:** a fixed scalar loop, timed after each sample, independent of the BLAS. It exposes machine-wide slowdowns.

Rule for `strided2` only: a cell (backend, n, round) whose median anchor exceeds 1.25 × the lower quartile of its process is excluded from statistics. It stays in the raw data and is listed in `acceptance.md`. The rule was introduced after a slowdown was seen in round 1, by looking at its anchors; rounds measured later are subject to the same fixed rule.

The main `sweep` uses no exclusion: there, medians over rounds absorb the slowdowns. `acceptance.md` lists how many samples were flagged (0–5 of 1200–2000 for most backends; 94 of 1200 for `blis_jll`, nearly all in one round).

Logged process names were removed from the published logs by `scripts/sanitize_results.py`; the CPU shares stay.

## Stride benchmark

Same warm-up, sampling, thread settings and input values as the contiguous campaigns. Parents have 2n rows and logical matrices are `view(P, 1:2:2n, 1:n)`. Views are built outside the timed region. Implementation: `src/BlasBenchStrided.jl`, `scripts/run_strided.jl`. Calls: `PureBLAS.gemm!(C, A, B)`, `UlmBLAS.mul!(C, A, B)`; neither goes through LBT, because `LinearAlgebra.BLAS` rejects a row stride other than 1. Results are stored separately in `results/strided2` and `plots/strided2_*`.

## Not used in any statistic

Partially finished processes (no `.done` file) are ignored by `scripts/analyze_strided.py` and not committed. `results/validate` is an initial 3-size test.
