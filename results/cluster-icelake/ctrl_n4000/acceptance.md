# Acceptance report, ctrl_n4000 (Intel Xeon Platinum 8358 (Ice Lake))

samples: 105; correctness checks: 21

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_native | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.004 | 1.004 at n=4000 |
| pureblas_lbt | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.004 | 1.004 at n=4000 |
| ulmblas_skylakex | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.002 | 1.002 at n=4000 |
| mkl_jll | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.000 | 1.000 at n=4000 |
| openblas_local | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.001 | 1.001 at n=4000 |
| openblas | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.000 | 1.000 at n=4000 |
| blis_jll | 1 | 3 | 1 | 3/3 | 0.000 | 0.000 | 3/3 | 1.00..1.00 | 0 | 1.001 | 1.001 at n=4000 |

Input CRC identical across backends for 3/3 (n, round) pairs.
Clock anchor: median 1.891 ms, p01 1.888, p99 1.948.
Cells excluded for a slow anchor (raw data kept): 0 of 21.
