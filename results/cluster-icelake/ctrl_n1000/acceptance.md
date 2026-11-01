# Acceptance report, ctrl_n1000 (Intel Xeon Platinum 8358 (Ice Lake))

samples: 105; correctness checks: 21

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_native | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.003 | 1.003 at n=1000 |
| pureblas_lbt | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.001 | 1.001 at n=1000 |
| ulmblas_skylakex | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.002 | 1.002 at n=1000 |
| mkl_jll | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.001 | 1.001 at n=1000 |
| openblas_local | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.000 | 1.000 at n=1000 |
| openblas | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.000 | 1.000 at n=1000 |
| blis_jll | 1 | 3 | 1 | 3/3 | 0.001 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.002 | 1.002 at n=1000 |

Input CRC identical across backends for 3/3 (n, round) pairs.
Clock anchor: median 1.906 ms, p01 1.900, p99 1.909.
Cells excluded for a slow anchor (raw data kept): 0 of 21.
