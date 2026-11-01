# Acceptance report, sweep (Intel Xeon Platinum 8358 (Ice Lake))

samples: 14000; correctness checks: 2800

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_native | 1 | 5 | 80 | 400/400 | 0.050 | 0.009 | 400/400 | 0.98..1.00 | 0 | 1.005 | 1.234 at n=400 |
| pureblas_lbt | 1 | 5 | 80 | 400/400 | 0.050 | 0.009 | 400/400 | 0.22..1.00 | 0 | 1.005 | 1.175 at n=400 |
| ulmblas_skylakex | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.90..1.00 | 0 | 1.003 | 1.032 at n=1000 |
| mkl_jll | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.99..1.00 | 0 | 1.006 | 1.156 at n=2650 |
| openblas_local | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.99..1.00 | 0 | 1.001 | 1.033 at n=250 |
| openblas | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.98..1.00 | 0 | 1.001 | 1.457 at n=2150 |
| blis_jll | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.79..1.00 | 0 | 1.004 | 1.034 at n=1250 |

Input CRC identical across backends for 400/400 (n, round) pairs.
Clock anchor: median 1.891 ms, p01 1.888, p99 1.948.
Cells excluded for a slow anchor (raw data kept): 0 of 2800.
