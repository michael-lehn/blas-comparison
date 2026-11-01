# Acceptance report, campaign validate

samples: 72; correctness checks: 24

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |
|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_native | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.995..1.000 | 0 | 9/9 |
| pureblas_lbt | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.991..1.000 | 0 | 9/9 |
| ulmblas | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.966..1.000 | 0 | n/a |
| accelerate | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.995..1.000 | 0 | n/a |
| blis_pr921 | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.998..1.000 | 0 | n/a |
| openblas | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.979..1.000 | 0 | n/a |
| openblas_brew | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.997..1.000 | 0 | n/a |
| blis_jll | 1 | 1 | 3 | 3/3 | 0.022 | 0.003 | 3/3 | 0.995..1.000 | 0 | n/a |

Input CRC identical across backends for 3/3 (n, round) pairs.
Largest relative difference of sum(C) between backends: 2.90e-15.
Clock anchor (scalar loop): median 1.493 ms, p01 1.404, p99 1.797.

| backend | median over sizes of (max/min round median) | worst size |
|---|---|---|
| pureblas_native t1 | 1.000 | 1.000 at n=100 |
| pureblas_lbt t1 | 1.000 | 1.000 at n=100 |
| ulmblas t1 | 1.000 | 1.000 at n=100 |
| accelerate t1 | 1.000 | 1.000 at n=100 |
| blis_pr921 t1 | 1.000 | 1.000 at n=100 |
| openblas t1 | 1.000 | 1.000 at n=100 |
| openblas_brew t1 | 1.000 | 1.000 at n=100 |
| blis_jll t1 | 1.000 | 1.000 at n=100 |

| backend | correlation of position in the process with GFLOP/s relative to the size median |
|---|---|
| pureblas_native | +0.188 |
| pureblas_lbt | +0.376 |
| ulmblas | -0.379 |
| accelerate | -0.211 |
| blis_pr921 | -0.014 |
| openblas | -0.149 |
| openblas_brew | -0.322 |
| blis_jll | +0.043 |
