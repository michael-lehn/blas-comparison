# Acceptance report, campaign neon

samples: 1200; correctness checks: 240

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_neon | 1 | 3 | 80 | 240/240 | 0.078 | 0.014 | 240/240 | 0.855..1.000 | 0 | 0/1200 |

Input CRC identical across backends for 240/240 (n, round) pairs.
Largest absolute difference of sum(C) between backends over all (n, round): 0.00e+00 (sum of n^2 floating-point entries; entrywise correctness is the check above).
Clock anchor (scalar loop): median 1.475 ms, p01 1.404, p99 1.642.

Samples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:

| backend | samples flagged | of |
|---|---|---|
| pureblas_neon | 1 | 1200 |

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_neon t1 | 1.037 | 1.365 at n=1150 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
| pureblas_neon | -0.163 |
