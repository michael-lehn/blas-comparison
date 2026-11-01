# Acceptance report, sweep (Intel Xeon Platinum 8358 (Ice Lake))

samples: 10400; correctness checks: 2080

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_native | 1 | 3 | 80 | 240/240 | 0.050 | 0.009 | 240/240 | 0.99..1.00 | 0 | 1.005 | 1.227 at n=400 |
| pureblas_lbt | 1 | 4 | 80 | 320/320 | 0.050 | 0.009 | 320/320 | 0.22..1.00 | 0 | 1.004 | 1.131 at n=350 |
| ulmblas_skylakex | 1 | 4 | 80 | 320/320 | 0.067 | 0.014 | 320/320 | 0.90..1.00 | 0 | 1.002 | 1.032 at n=1000 |
| mkl_jll | 1 | 4 | 80 | 320/320 | 0.067 | 0.014 | 320/320 | 1.00..1.00 | 0 | 1.005 | 1.156 at n=2650 |
| openblas_local | 1 | 3 | 80 | 240/240 | 0.067 | 0.014 | 240/240 | 0.99..1.00 | 0 | 1.001 | 1.030 at n=1100 |
| openblas | 1 | 4 | 80 | 320/320 | 0.067 | 0.014 | 320/320 | 0.98..1.00 | 0 | 1.001 | 1.457 at n=2150 |
| blis_jll | 1 | 4 | 80 | 320/320 | 0.067 | 0.014 | 320/320 | 0.99..1.00 | 0 | 1.002 | 1.013 at n=150 |

Input CRC identical across backends for 320/320 (n, round) pairs.
Clock anchor: median 1.891 ms, p01 1.888, p99 1.948.
Cells excluded for a slow anchor (raw data kept): 0 of 2080.
