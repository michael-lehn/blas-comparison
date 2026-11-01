# Acceptance report, mt (Intel Xeon Platinum 8358 (Ice Lake))

samples: 1800; correctness checks: 360

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_native | 16 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 12.75..15.91 | 0 | 1.020 | 1.138 at n=100 |
| pureblas_native | 32 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 12.72..31.74 | 0 | 1.061 | 1.503 at n=100 |
| pureblas_lbt | 16 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 1.00..1.00 | 0 | 1.002 | 1.007 at n=100 |
| pureblas_lbt | 32 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 1.00..1.00 | 0 | 1.007 | 1.012 at n=1000 |
| mkl_jll | 16 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 15.68..15.96 | 0 | 1.004 | 1.039 at n=100 |
| mkl_jll | 32 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 31.32..31.90 | 0 | 1.010 | 1.185 at n=500 |
| openblas_local | 16 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 1.00..16.23 | 0 | 1.009 | 1.033 at n=200 |
| openblas_local | 32 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 1.00..32.29 | 0 | 1.015 | 1.058 at n=500 |
| openblas | 16 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 1.00..16.24 | 0 | 1.010 | 3.953 at n=200 |
| openblas | 32 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 1.00..32.31 | 0 | 1.021 | 3.042 at n=200 |
| blis_jll | 16 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 15.63..16.21 | 0 | 1.007 | 1.078 at n=1000 |
| blis_jll | 32 | 3 | 10 | 30/30 | 0.035 | 0.003 | 30/30 | 31.11..32.41 | 0 | 1.016 | 1.074 at n=500 |

Input CRC identical across backends for 30/30 (n, round) pairs.
Clock anchor: median 1.919 ms, p01 1.889, p99 2.704.
Cells excluded for a slow anchor (raw data kept): 2 of 360.
- openblas_local, t=32, n=500, round 3
- openblas_local, t=32, n=1000, round 2
