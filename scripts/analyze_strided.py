#!/usr/bin/env python3
"""Row stride 2 benchmark: acceptance report, summary and plots, separate from the contiguous campaigns.
   .local/venv/bin/python scripts/analyze_strided.py
Reads results/strided2/raw and results/strided2/diagnostics; writes results/strided2/{summary.csv,
acceptance.md,diagnostics/summary.csv} and plots/strided2_*.{svg,pdf}.
Statistics as in analyze.py: median of the samples per (backend, n, round), then median and range over rounds.
The speedup is paired by round (same logical inputs): time of PureBLAS.jl / time of UlmBLAS.jl."""
import csv, glob, os, collections, statistics as st
import numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "results", "strided2"); RAW = os.path.join(OUT, "raw"); DIAG = os.path.join(OUT, "diagnostics")
PLOTS = os.path.join(ROOT, "plots"); os.makedirs(PLOTS, exist_ok=True)
PURE, ULM = "pureblas_strided2", "ulmblas_strided2"
STYLE = {PURE: ("PureBLAS.jl, gemm! (generic fallback)", "#2a78d6", "-", "o"),
         ULM:  ("UlmBLAS.jl, mul! (SME2, stride-aware)", "#eb6834", "-", "s")}
plt.rcParams.update({"font.size": 10, "axes.spines.top": False, "axes.spines.right": False, "axes.grid": True,
    "grid.color": "#e4e3df", "grid.linewidth": .6, "axes.axisbelow": True, "svg.fonttype": "none", "pdf.fonttype": 42,
    "legend.frameon": False, "legend.fontsize": 8.5, "figure.dpi": 150})
NOTE = "Row stride 2 on A, B and C (views of larger arrays), m = n = k, α = 1, β = 0, one thread"

def rd(pattern):
    rows = []
    for f in sorted(glob.glob(pattern)): rows += list(csv.DictReader(open(f)))
    return rows
# Only finished processes: a .done file marks them, so a round still running is ignored.
done = {os.path.basename(f)[:-5] for f in glob.glob(os.path.join(RAW, "*.done"))}
def rd_done(kind):
    rows = []
    for t in sorted(done):
        f = os.path.join(RAW, f"{kind}_{t}.csv")
        if os.path.exists(f): rows += list(csv.DictReader(open(f)))
    return rows
samples, checks = rd_done("samples"), rd_done("checks")
backends = [b for b in (PURE, ULM) if any(s["backend"] == b for s in samples)]
# A cell (backend, n, round) measured during a machine-wide slowdown does not enter the statistics: its median
# scalar anchor exceeds 1.25 x the lower quartile of the anchors of its process.  Raw data stay; acceptance.md lists them.
proc_an = collections.defaultdict(list); cell_an = collections.defaultdict(list); by = collections.defaultdict(list)
for s in samples:
    k = (s["backend"], int(s["n"]), s["round"]); a = float(s["anchor_ns"])
    proc_an[(s["backend"], s["round"])].append(a); cell_an[k].append(a); by[k].append(float(s["gflops"]))
q1 = {k: np.percentile(v, 25) for k, v in proc_an.items()}
excluded = sorted(k for k, v in cell_an.items() if st.median(v) > 1.25 * q1[(k[0], k[2])])
rmed = {k: st.median(v) for k, v in by.items() if k not in excluded}
def series(b):
    ns = sorted({k[1] for k in rmed if k[0] == b}); m, lo, hi = [], [], []
    for n in ns:
        v = [x for k, x in rmed.items() if k[0] == b and k[1] == n]
        m.append(st.median(v)); lo.append(min(v)); hi.append(max(v))
    return np.array(ns), np.array(m), np.array(lo), np.array(hi)

# ---- acceptance
L = []; line = L.append
line("# Acceptance report, campaign strided2 (row stride 2)\n")
line(f"samples: {len(samples)}; correctness checks: {len(checks)}\n")
line("| backend | rounds | sizes | samples per size and round | checks ok | gaps of C intact | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME kernel calls |")
line("|---|---|---|---|---|---|---|---|---|---|---|---|")
for b in backends:
    ss = [s for s in samples if s["backend"] == b]; cs = [c for c in checks if c["backend"] == b]
    cw = [float(s["cpu_per_wall"]) for s in ss]
    cnt = collections.Counter((s["n"], s["round"]) for s in ss)
    sme = "n/a" if b == ULM else str(sum(int(s["sme_calls"] or 0) for s in ss) + sum(int(c["sme_calls_first"] or 0) for c in cs))
    line(f"| {b} | {len({s['round'] for s in ss})} | {len({s['n'] for s in ss})} | {min(cnt.values())}..{max(cnt.values())} | "
         f"{sum(c['ok'] == 'true' for c in cs)}/{len(cs)} | {sum(c['gaps_intact'] == 'true' for c in cs)}/{len(cs)} | "
         f"{max(float(c['entry_ratio']) for c in cs):.3f} | {max(float(c['freivalds_ratio']) for c in cs):.3f} | "
         f"{sum(c['repeat_identical'] == 'true' for c in cs)}/{len(cs)} | {min(cw):.3f}..{max(cw):.3f} | {max(int(s['alloc_bytes']) for s in ss)} | {sme} |")
crc = collections.defaultdict(set)
for c in checks: crc[(c["n"], c["round"])].add(c["input_crc"])
line(f"\nInput CRC identical between the two libraries for {sum(len(v) == 1 for v in crc.values())}/{len(crc)} (n, round) pairs.")
ref = collections.defaultdict(set)
for c in rd(os.path.join(ROOT, "results", "sweep", "raw", "checks_*.csv")): ref[(c["n"], c["round"])].add(c["input_crc"])
common = [k for k in crc if k in ref]
line(f"Logical values identical to the contiguous sweep (same CRC) for {sum(crc[k] == ref[k] for k in common)}/{len(common)} (n, round) pairs.")
an = [float(s["anchor_ns"]) for s in samples]; mid = st.median(an)
line(f"Clock anchor: median {mid/1e6:.3f} ms, p01 {np.percentile(an,1)/1e6:.3f}, p99 {np.percentile(an,99)/1e6:.3f}.\n")
line("| backend | samples with anchor > 1.3 x median (machine-wide slowdown, kept) | of | median over sizes of (max/min round median) | worst size |")
line("|---|---|---|---|---|")
for b in backends:
    ss = [s for s in samples if s["backend"] == b]; xs, m, lo, hi = series(b); r = hi / lo
    line(f"| {b} | {sum(float(s['anchor_ns']) > 1.3*mid for s in ss)} | {len(ss)} | {np.median(r):.3f} | {r.max():.3f} at n={xs[r.argmax()]} |")
line(f"\nCells excluded from the statistics as measured during a machine-wide slowdown: {len(excluded)} of {len(by)} (raw data kept).\n")
line("| backend | round | excluded cells | sizes left without a clean round |")
line("|---|---|---|---|")
for b, r in sorted(q1):
    e = [k[1] for k in excluded if k[0] == b and k[2] == r]
    if e: line(f"| {b} | {r} | {len(e)}: n = {', '.join(map(str, sorted(e)))} | |")
for b in backends:
    miss = sorted({k[1] for k in by if k[0] == b} - {k[1] for k in rmed if k[0] == b})
    line(f"| {b} | all | | {len(miss)}{': ' + ', '.join(map(str, miss)) if miss else ''} |")
open(os.path.join(OUT, "acceptance.md"), "w").write("\n".join(L) + "\n")
with open(os.path.join(OUT, "summary.csv"), "w") as f:
    w = csv.writer(f); w.writerow(["backend", "n", "rounds", "median_gflops", "min_round_median", "max_round_median"])
    for b in backends:
        xs, m, lo, hi = series(b)
        for i, n in enumerate(xs):
            w.writerow([b, n, len([k for k in rmed if k[0] == b and k[1] == n]), f"{m[i]:.3f}", f"{lo[i]:.3f}", f"{hi[i]:.3f}"])

def save(fig, name):
    for e in ("svg", "pdf"): fig.savefig(os.path.join(PLOTS, f"{name}.{e}"), bbox_inches="tight")
    plt.close(fig)

# ---- plot 1: GFLOP/s.  Log axis: the libraries differ by more than a decade and a linear axis flattens one of them.
fig, ax = plt.subplots(figsize=(8, 4.6))
for b in backends:
    xs, m, lo, hi = series(b); lab, col, ls, mk = STYLE[b]
    ax.fill_between(xs, lo, hi, color=col, alpha=.16, lw=0)
    ax.plot(xs, m, color=col, ls=ls, lw=1.8, marker=mk, ms=4, markevery=8, label=lab)
ax.set_yscale("log"); ax.set_yticks([3, 5, 10, 20, 50, 100, 200, 500]); ax.set_yticklabels(["3", "5", "10", "20", "50", "100", "200", "500"])
ax.minorticks_off(); ax.set_xlim(0, 4050); ax.set_xlabel("Matrix size $n$"); ax.set_ylabel("GFLOP/s  ($2n^3$ / time), log scale")
ax.set_title("DGEMM with non-unit row stride\n" + NOTE + ". Band: range of rounds.", loc="left", fontsize=10)
ax.legend(loc="center right"); save(fig, "strided2_t1_gflops")

# ---- plot 2: speedup
rounds = sorted({k[2] for k in rmed})
ns = sorted({k[1] for k in rmed}); xs, md, lo, hi = [], [], [], []
for n in ns:
    v = [rmed[(ULM, n, r)] / rmed[(PURE, n, r)] for r in rounds if (PURE, n, r) in rmed and (ULM, n, r) in rmed]
    if v: xs.append(n); md.append(st.median(v)); lo.append(min(v)); hi.append(max(v))
if xs:
    fig, ax = plt.subplots(figsize=(8, 3.9)); col = STYLE[ULM][1]
    ax.fill_between(xs, lo, hi, color=col, alpha=.18, lw=0); ax.plot(xs, md, color=col, lw=1.8, marker="s", ms=4, markevery=8, label="UlmBLAS.jl / PureBLAS.jl")
    ax.axhline(1, color="#777", lw=1); ax.set_ylim(0); ax.set_xlim(0, 4050)
    ax.set_xlabel("Matrix size $n$"); ax.set_ylabel("Time of PureBLAS.jl / time of UlmBLAS.jl")
    ax.set_title("Speedup of UlmBLAS.jl relative to PureBLAS.jl, row stride 2\nPaired by round (identical logical inputs). Band: range of rounds. Line at 1 = equal.", loc="left", fontsize=10)
    save(fig, "strided2_t1_speedup_ulmblas_vs_pureblas")
    with open(os.path.join(OUT, "speedup.csv"), "w") as f:
        w = csv.writer(f); w.writerow(["n", "median_speedup", "min", "max"])
        for r in zip(xs, md, lo, hi): w.writerow([r[0]] + [f"{x:.3f}" for x in r[1:]])

# ---- diagnostics: one figure per library, median of 3 samples, one round; not part of the strided2 results
# diag_*_small.csv holds n = 50, 100, 300, repeated once the first attempt was found to be under load from other work.
d = sum((rd(os.path.join(DIAG, f"diag_{lib}{s}.csv")) for lib in ("pureblas", "ulmblas") for s in ("", "_small")), [])
if d:
    CFG = {"contiguous": ("all strides 1, on Matrix", "#2a78d6", "-", "o"),
           "copy_all": ("stride 2, copied to and from buffers (timed)", "#1baf7a", "--", "v"),
           "copy_C_only": ("stride 2, only C through a buffer (timed)", "#6250d6", "-.", "D"),
           "C1_AB2": ("C stride 1, A and B stride 2", "#e87ba4", "-", "^"),
           "C2_AB1": ("C stride 2, A and B stride 1", "#eda100", "--", "P"),
           "C2_AB2": ("all strides 2", "#eb6834", "-", "s"),
           "generic_contiguous": ("_gemm_generic! on Matrix", "#333333", ":", "x")}
    v = collections.defaultdict(list); sme = {}
    for r in d:
        v[(r["lib"], r["config"], int(r["n"]))].append(float(r["gflops"])); sme[(r["lib"], r["config"], int(r["n"]))] = r["sme_calls_per_call"]
    med = {k: st.median(x) for k, x in v.items()}
    with open(os.path.join(DIAG, "summary.csv"), "w") as f:
        w = csv.writer(f); w.writerow(["lib", "config", "n", "median_gflops", "sme_kernel_calls_per_call"])
        for k in sorted(med): w.writerow([*k, f"{med[k]:.2f}", sme[k]])
    fig, axs = plt.subplots(1, 2, figsize=(10.5, 4.6), sharey=True)
    for ax, lib, title in zip(axs, ("pureblas", "ulmblas"), ("PureBLAS.jl", "UlmBLAS.jl")):
        for c, (lab, col, ls, mk) in CFG.items():
            x = sorted(k[2] for k in med if k[0] == lib and k[1] == c)
            if x: ax.plot(x, [med[(lib, c, n)] for n in x], color=col, ls=ls, marker=mk, ms=5, lw=1.6, label=lab)
        ax.set_yscale("log"); ax.set_yticks([3, 5, 10, 20, 50, 100, 200, 500]); ax.set_yticklabels(["3", "5", "10", "20", "50", "100", "200", "500"])
        ax.minorticks_off(); ax.set_title(title, loc="left", fontsize=10); ax.set_xlabel("Matrix size $n$")
    axs[0].set_ylabel("GFLOP/s, log scale")
    fig.suptitle("Stride diagnostics, not a proposed design: full copies need O(n²) workspace (one round, three samples per point)", x=.06, ha="left", fontsize=10)
    h, l = axs[0].get_legend_handles_labels(); fig.tight_layout(rect=(0, .12, 1, 1)); fig.legend(h, l, loc="lower center", ncol=3, fontsize=8)
    save(fig, "strided2_diagnostics_routes")
print("\n".join(L))
