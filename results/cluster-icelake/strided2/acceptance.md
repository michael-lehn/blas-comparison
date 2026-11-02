# Acceptance report, strided2 (Intel Xeon Platinum 8358 (Ice Lake))

samples: 2000; correctness checks: 400

| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| pureblas_strided2 | 1 | 2 | 80 | 160/160 | 0.056 | 0.014 | 160/160 | 1.00..1.00 | 0 | 1.001 | 1.018 at n=650 |
| ulmblas_strided2 | 1 | 3 | 80 | 240/240 | 0.078 | 0.014 | 240/240 | 0.99..1.00 | 0 | 1.003 | 1.030 at n=2000 |

Input CRC identical across backends for 240/240 (n, round) pairs.
Clock anchor: median 1.891 ms, p01 1.889, p99 1.948.
Cells excluded for a slow anchor (raw data kept): 0 of 400.
