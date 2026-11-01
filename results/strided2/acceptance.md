# Acceptance report, campaign strided2 (row stride 2)

samples: 800; correctness checks: 160

| backend | rounds | sizes | samples per size and round | checks ok | gaps of C intact | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME kernel calls |
|---|---|---|---|---|---|---|---|---|---|---|---|
| pureblas_strided2 | 1 | 80 | 5..5 | 80/80 | 80/80 | 0.048 | 0.014 | 80/80 | 0.975..1.000 | 0 | 0 |
| ulmblas_strided2 | 1 | 80 | 5..5 | 80/80 | 80/80 | 0.048 | 0.014 | 80/80 | 0.811..1.000 | 0 | n/a |

Input CRC identical between the two libraries for 80/80 (n, round) pairs.
Logical values identical to the contiguous sweep (same CRC) for 80/80 (n, round) pairs.
Clock anchor: median 1.613 ms, p01 1.404, p99 2.572.

| backend | samples with anchor > 1.3 x median (machine-wide slowdown, kept) | of | median over sizes of (max/min round median) | worst size |
|---|---|---|---|---|
| pureblas_strided2 | 33 | 400 | 1.000 | 1.000 at n=50 |
| ulmblas_strided2 | 64 | 400 | 1.000 | 1.000 at n=50 |

Cells excluded from the statistics as measured during a machine-wide slowdown: 25 of 160 (raw data kept).

| backend | round | excluded cells | sizes left without a clean round |
|---|---|---|---|
| pureblas_strided2 | 1 | 5: n = 1200, 1950, 2100, 3350, 3600 | |
| ulmblas_strided2 | 1 | 20: n = 100, 250, 300, 400, 600, 800, 1150, 1600, 1750, 2350, 2500, 2550, 2800, 2950, 3100, 3350, 3450, 3500, 3700, 3900 | |
| pureblas_strided2 | all | | 5: 1200, 1950, 2100, 3350, 3600 |
| ulmblas_strided2 | all | | 20: 100, 250, 300, 400, 600, 800, 1150, 1600, 1750, 2350, 2500, 2550, 2800, 2950, 3100, 3350, 3450, 3500, 3700, 3900 |
