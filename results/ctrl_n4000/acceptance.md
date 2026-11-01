# Acceptance report, campaign ctrl_n4000

samples: 45; correctness checks: 9

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_native | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.000..1.000 | 0 | 15/15 |
| ulmblas | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.000..1.000 | 0 | n/a |
| accelerate | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 0.999..1.000 | 0 | n/a |

Input CRC identical across backends for 3/3 (n, round) pairs.
Largest absolute difference of sum(C) between backends over all (n, round): 0.00e+00 (sum of n^2 floating-point entries; entrywise correctness is the check above).
Clock anchor (scalar loop): median 1.408 ms, p01 1.404, p99 1.498.

Samples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:

| backend | samples flagged | of |
|---|---|---|
| pureblas_native | 0 | 15 |
| ulmblas | 0 | 15 |
| accelerate | 0 | 15 |

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_native t1 | 1.008 | 1.008 at n=4000 |
| ulmblas t1 | 1.013 | 1.013 at n=4000 |
| accelerate t1 | 1.009 | 1.009 at n=4000 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
