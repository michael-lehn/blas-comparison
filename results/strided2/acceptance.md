# Acceptance report, campaign strided2 (row stride 2)

samples: 2000; correctness checks: 400

| backend | rounds | sizes | samples per size and round | checks ok | gaps of C intact | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME kernel calls |
|---|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_strided2 | 2 | 80 | 5..5 | 160/160 | 160/160 | 0.056 | 0.014 | 160/160 | 0.927..1.000 | 0 | 0 |
| ulmblas_strided2 | 3 | 80 | 5..5 | 240/240 | 240/240 | 0.078 | 0.014 | 240/240 | 0.811..1.000 | 0 | n/a |

Input CRC identical between the two libraries for 240/240 (n, round) pairs.
Logical values identical to the contiguous sweep (same CRC) for 240/240 (n, round) pairs.
Clock anchor: median 1.548 ms, p01 1.404, p99 2.401.

| backend | samples with anchor > 1.3 x median (machine-wide slowdown, kept) | of | median over sizes of (max/min round median) | worst size |
|---|---|---|---|---|
| pureblas_strided2 | 55 | 800 | 1.032 | 1.352 at n=3200 |
| ulmblas_strided2 | 101 | 1200 | 1.035 | 1.102 at n=800 |

Cells excluded from the statistics as measured during a machine-wide slowdown: 29 of 400 (raw data kept).

| backend | round | excluded cells | sizes left without a clean round |
|---|---|---|---|
| pureblas_strided2 | 1 | 5: n = 1200, 1950, 2100, 3350, 3600 | |
| pureblas_strided2 | 2 | 2: n = 50, 1250 | |
| ulmblas_strided2 | 1 | 20: n = 100, 250, 300, 400, 600, 800, 1150, 1600, 1750, 2350, 2500, 2550, 2800, 2950, 3100, 3350, 3450, 3500, 3700, 3900 | |
| ulmblas_strided2 | 3 | 2: n = 3100, 3400 | |
| pureblas_strided2 | all | | 0 |
| ulmblas_strided2 | all | | 0 |
