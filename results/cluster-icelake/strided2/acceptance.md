# Acceptance report, strided2 (Intel Xeon Platinum 8358 (Ice Lake))

samples: 3200; correctness checks: 640

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_strided2 | 1 | 3 | 80 | 240/240 | 0.078 | 0.014 | 240/240 | 1.00..1.00 | 0 | 1.002 | 1.056 at n=1600 |
| ulmblas_strided2 | 1 | 5 | 80 | 400/400 | 0.078 | 0.014 | 400/400 | 0.94..1.00 | 0 | 1.005 | 1.032 at n=700 |

Input CRC identical across backends for 400/400 (n, round) pairs.
Clock anchor: median 1.891 ms, p01 1.889, p99 1.948.
Cells excluded for a slow anchor (raw data kept): 0 of 640.
