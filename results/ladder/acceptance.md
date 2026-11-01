# Acceptance report, campaign ladder

samples: 900; correctness checks: 180

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_native | 1 | 3 | 10 | 30/30 | 0.137 | 0.074 | 30/30 | 0.982..1.000 | 0 | 135/150 |
| pureblas_lbt | 1 | 3 | 10 | 30/30 | 0.137 | 0.074 | 30/30 | 0.971..1.000 | 0 | 135/150 |
| ulmblas | 1 | 3 | 10 | 30/30 | 0.137 | 0.074 | 30/30 | 0.991..1.000 | 0 | n/a |
| accelerate | 1 | 3 | 10 | 30/30 | 0.177 | 0.104 | 30/30 | 0.995..1.000 | 0 | n/a |
| blis_pr921 | 1 | 3 | 10 | 30/30 | 0.137 | 0.074 | 30/30 | 0.957..1.000 | 0 | n/a |
| openblas | 1 | 3 | 10 | 30/30 | 0.137 | 0.074 | 30/30 | 0.991..1.000 | 0 | n/a |

Input CRC identical across backends for 30/30 (n, round) pairs.
Largest absolute difference of sum(C) between backends over all (n, round): 1.02e-10 (sum of n^2 floating-point entries; entrywise correctness is the check above).
Clock anchor (scalar loop): median 1.493 ms, p01 1.404, p99 1.689.

Samples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:

| backend | samples flagged | of |
|---|---|---|
| pureblas_native | 0 | 150 |
| pureblas_lbt | 1 | 150 |
| ulmblas | 0 | 150 |
| accelerate | 0 | 150 |
| blis_pr921 | 0 | 150 |
| openblas | 0 | 150 |

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_native t1 | 1.051 | 1.157 at n=512 |
| pureblas_lbt t1 | 1.079 | 1.161 at n=2100 |
| ulmblas t1 | 1.055 | 1.072 at n=2100 |
| accelerate t1 | 1.029 | 1.058 at n=256 |
| blis_pr921 t1 | 1.017 | 1.132 at n=4096 |
| openblas t1 | 1.033 | 1.048 at n=512 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
| pureblas_native | -0.256 |
| pureblas_lbt | -0.035 |
| ulmblas | -0.107 |
| accelerate | -0.135 |
| blis_pr921 | +0.066 |
| openblas | -0.363 |
