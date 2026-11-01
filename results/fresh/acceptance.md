# Acceptance report, campaign fresh

samples: 180; correctness checks: 36

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_native | 1 | 3 | 4 | 12/12 | 0.018 | 0.001 | 0/12 | 0.991..1.000 | 0 | 60/60 |
| ulmblas | 1 | 3 | 4 | 12/12 | 0.018 | 0.001 | 0/12 | 0.996..1.000 | 0 | n/a |
| accelerate | 1 | 3 | 4 | 12/12 | 0.018 | 0.001 | 0/12 | 0.992..1.000 | 0 | n/a |

Input CRC identical across backends for 12/12 (n, round) pairs.
Largest absolute difference of sum(C) between backends over all (n, round): 0.00e+00 (sum of n^2 floating-point entries; entrywise correctness is the check above).
Clock anchor (scalar loop): median 1.549 ms, p01 1.407, p99 1.721.

Samples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:

| backend | samples flagged | of |
|---|---|---|
| pureblas_native | 0 | 60 |
| ulmblas | 0 | 60 |
| accelerate | 0 | 60 |

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_native t1 | 1.034 | 1.070 at n=1000 |
| ulmblas t1 | 1.033 | 1.064 at n=4000 |
| accelerate t1 | 1.068 | 1.151 at n=1000 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
| pureblas_native | -0.080 |
| ulmblas | -0.106 |
| accelerate | -0.033 |
