# Acceptance report, campaign sweep

samples: 13600; correctness checks: 2720

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_native | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.896..1.000 | 0 | 2000/2000 |
| pureblas_lbt | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.793..1.000 | 0 | 2000/2000 |
| ulmblas | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.993..1.000 | 0 | n/a |
| accelerate | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.534..1.000 | 0 | n/a |
| blis_pr921 | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.680..1.000 | 0 | n/a |
| openblas | 1 | 3 | 80 | 240/240 | 0.078 | 0.014 | 240/240 | 0.931..1.000 | 0 | n/a |
| openblas_brew | 1 | 3 | 80 | 240/240 | 0.078 | 0.014 | 240/240 | 0.616..1.000 | 0 | n/a |
| blis_jll | 1 | 3 | 80 | 240/240 | 0.078 | 0.014 | 240/240 | 0.526..1.000 | 0 | n/a |

Input CRC identical across backends for 400/400 (n, round) pairs.
Largest absolute difference of sum(C) between backends over all (n, round): 1.02e-10 (sum of n^2 floating-point entries; entrywise correctness is the check above).
Clock anchor (scalar loop): median 1.548 ms, p01 1.404, p99 1.830.

Samples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:

| backend | samples flagged | of |
|---|---|---|
| pureblas_native | 0 | 2000 |
| pureblas_lbt | 3 | 2000 |
| ulmblas | 0 | 2000 |
| accelerate | 5 | 2000 |
| blis_pr921 | 1 | 2000 |
| openblas | 2 | 1200 |
| openblas_brew | 0 | 1200 |
| blis_jll | 94 | 1200 |

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_native t1 | 1.080 | 1.254 at n=1550 |
| pureblas_lbt t1 | 1.083 | 1.243 at n=2200 |
| ulmblas t1 | 1.064 | 1.531 at n=100 |
| accelerate t1 | 1.052 | 1.320 at n=350 |
| blis_pr921 t1 | 1.064 | 1.196 at n=2450 |
| openblas t1 | 1.041 | 1.114 at n=1850 |
| openblas_brew t1 | 1.047 | 1.122 at n=1850 |
| blis_jll t1 | 1.075 | 3.160 at n=3700 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
| pureblas_native | -0.337 |
| pureblas_lbt | -0.254 |
| ulmblas | -0.350 |
| accelerate | -0.315 |
| blis_pr921 | -0.085 |
| openblas | -0.099 |
| openblas_brew | -0.345 |
| blis_jll | -0.385 |
