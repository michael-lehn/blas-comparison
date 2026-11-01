# Acceptance report, campaign mt

samples: 900; correctness checks: 180

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_native | 4 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 0.804..1.000 | 0 | 150/150 |
| pureblas_lbt | 4 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 0.989..1.000 | 0 | 150/150 |
| accelerate | 4 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 0.971..1.989 | 0 | n/a |
| blis_pr921 | 4 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 2.945..3.996 | 0 | n/a |
| openblas | 4 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 2.880..4.264 | 0 | n/a |
| blis_jll | 4 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 3.170..3.997 | 0 | n/a |

Input CRC identical across backends for 30/30 (n, round) pairs.
Largest absolute difference of sum(C) between backends over all (n, round): 8.55e-11 (sum of n^2 floating-point entries; entrywise correctness is the check above).
Clock anchor (scalar loop): median 1.556 ms, p01 1.404, p99 2.028.

Samples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:

| backend | samples flagged | of |
|---|---|---|
| pureblas_native | 1 | 150 |
| pureblas_lbt | 0 | 150 |
| accelerate | 1 | 150 |
| blis_pr921 | 0 | 150 |
| openblas | 8 | 150 |
| blis_jll | 0 | 150 |

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_native t4 | 1.105 | 1.305 at n=1000 |
| pureblas_lbt t4 | 1.045 | 1.079 at n=1000 |
| accelerate t4 | 1.046 | 1.067 at n=2000 |
| blis_pr921 t4 | 1.054 | 1.241 at n=200 |
| openblas t4 | 1.050 | 1.136 at n=100 |
| blis_jll t4 | 1.079 | 1.461 at n=100 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
| pureblas_native | +0.113 |
| pureblas_lbt | -0.140 |
| accelerate | -0.234 |
| blis_pr921 | +0.167 |
| openblas | -0.242 |
| blis_jll | +0.187 |
