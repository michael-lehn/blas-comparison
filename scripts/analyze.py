#!/usr/bin/env python3
"""Summaries, acceptance checks and plots of a campaign.
   .local/venv/bin/python scripts/analyze.py sweep [--plots-prefix sweep]
Statistics: median of the samples per (backend, n, round); then the median and the range over rounds.
Ratios are paired: same round means same inputs; a ratio uses only the rounds both backends have."""
import csv, glob, os, sys, collections, statistics as st
import numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
camp = sys.argv[1]; threads_filter = None
RAW = os.path.join(ROOT, "results", camp, "raw"); OUT = os.path.join(ROOT, "results", camp)
PLOTS = os.path.join(ROOT, "plots"); os.makedirs(PLOTS, exist_ok=True)

# colour, marker and line style follow the implementation in every plot (palette: dataviz skill, validated)
STYLE = {
 "pureblas_native": ("PureBLAS.jl, native API (SME)", "#2a78d6", "-",  "o"),
 "pureblas_lbt":    ("PureBLAS.jl, via LBT (SME)",    "#1baf7a", "--", "v"),
 "ulmblas":         ("UlmBLAS.jl, via LBT (SME2)",    "#eb6834", "-",  "s"),
 "accelerate":      ("Apple Accelerate",              "#6250d6", "-",  "D"),
 "blis_pr921":      ("BLIS PR #921 (SME2)",           "#e87ba4", "-",  "^"),
 "openblas":        ("OpenBLAS 0.3.30, Julia default (NEON)", "#333333", "-", "x"),
 "openblas_brew":   ("OpenBLAS 0.3.34, Homebrew (NEON)", "#eda100", "--", "+"),
 "blis_jll":        ("BLIS 2.0, blis_jll (NEON)",     "#008300", ":",  "1"),
 "pureblas_neon":   ("PureBLAS.jl, SME off (NEON)",   "#e34948", "-",  "P"),
}
ORDER = list(STYLE)
plt.rcParams.update({"font.size": 10, "axes.spines.top": False, "axes.spines.right": False, "axes.grid": True,
    "grid.color": "#e4e3df", "grid.linewidth": .6, "axes.axisbelow": True, "svg.fonttype": "none", "pdf.fonttype": 42,
    "legend.frameon": False, "legend.fontsize": 8.5, "figure.dpi": 150})

samples = []
for f in glob.glob(os.path.join(RAW, "samples_*.csv")):
    samples += list(csv.DictReader(open(f)))
checks = []
for f in glob.glob(os.path.join(RAW, "checks_*.csv")):
    checks += list(csv.DictReader(open(f)))
if not samples: sys.exit("no data")

# ---- round medians
by = collections.defaultdict(list)
for s in samples:
    by[(s["backend"], int(s["threads"]), int(s["n"]), int(s["round"]))].append(float(s["gflops"]))
rm = {k: st.median(v) for k, v in by.items()}
backends = [b for b in ORDER if any(k[0] == b for k in rm)]
thr = sorted({k[1] for k in rm})
sizes = sorted({k[2] for k in rm})

def series(b, t):
    xs, med, lo, hi = [], [], [], []
    for n in sizes:
        v = [x for k, x in rm.items() if k[0] == b and k[1] == t and k[2] == n]
        if v: xs.append(n); med.append(st.median(v)); lo.append(min(v)); hi.append(max(v))
    return map(np.array, (xs, med, lo, hi))

def ratio(b, ref, t):
    xs, med, lo, hi = [], [], [], []
    for n in sizes:
        rs = sorted({k[3] for k in rm if k[0] == b and k[1] == t and k[2] == n} & {k[3] for k in rm if k[0] == ref and k[1] == t and k[2] == n})
        if rs:
            v = [rm[(b, t, n, r)] / rm[(ref, t, n, r)] for r in rs]
            xs.append(n); med.append(st.median(v)); lo.append(min(v)); hi.append(max(v))
    return map(np.array, (xs, med, lo, hi))

# ---- summary files
with open(os.path.join(OUT, "summary.csv"), "w", newline="") as f:
    w = csv.writer(f); w.writerow("backend threads n rounds samples median_gflops min_round_median max_round_median min_sample max_sample".split())
    for b in backends:
        for t in thr:
            for n in sizes:
                rv = [x for k, x in rm.items() if k[0] == b and k[1] == t and k[2] == n]
                sv = [x for k, v in by.items() if k[0] == b and k[1] == t and k[2] == n for x in v]
                if rv: w.writerow([b, t, n, len(rv), len(sv), f"{st.median(rv):.3f}", f"{min(rv):.3f}", f"{max(rv):.3f}", f"{min(sv):.3f}", f"{max(sv):.3f}"])

# ---- acceptance checks
rep = []
def line(*a): rep.append(" ".join(str(x) for x in a))
line(f"# Acceptance report, campaign {camp}\n")
line(f"samples: {len(samples)}; correctness checks: {len(checks)}\n")
line("| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | SME calls = GEMM calls |")
line("|---|---|---|---|---|---|---|---|---|---|---|")
for b in backends:
    for t in thr:
        cs = [c for c in checks if c["backend"] == b and int(c["threads"]) == t]; ss = [s for s in samples if s["backend"] == b and int(s["threads"]) == t]
        if not ss: continue
        smes = [s for s in ss if s["sme_calls"] != ""]
        sme = "n/a" if not smes else f"{sum(int(s['sme_calls']) == int(s['calls']) for s in smes)}/{len(smes)}"
        cw = [float(s["cpu_per_wall"]) for s in ss]
        line(f"| {b} | {t} | {len({s['round'] for s in ss})} | {len({s['n'] for s in ss})} | {sum(c['ok'] == 'true' for c in cs)}/{len(cs)} | {max(float(c['entry_ratio']) for c in cs):.3f} | {max(float(c['freivalds_ratio']) for c in cs):.3f} | {sum(c['repeat_identical'] == 'true' for c in cs)}/{len(cs)} | {min(cw):.3f}..{max(cw):.3f} | {max(int(s['alloc_bytes']) for s in ss)} | {sme} |")
# identical inputs
crc = collections.defaultdict(set)
for c in checks: crc[(c["n"], c["round"])].add(c["input_crc"])
line(f"\nInput CRC identical across backends for {sum(len(v) == 1 for v in crc.values())}/{len(crc)} (n, round) pairs.")
# agreement of results between backends
sumc = collections.defaultdict(list)
for c in checks: sumc[(c["n"], c["round"])].append((float(c["c11"]), float(c["c_sum"])))
# sum(C) has random sign and can be close to zero, so it is reported as an absolute difference
worst_abs = max(max(a[1] for a in v) - min(a[1] for a in v) for v in sumc.values())
line(f"Largest absolute difference of sum(C) between backends over all (n, round): {worst_abs:.2e} (sum of n^2 floating-point entries; entrywise correctness is the check above).")
# drift
an = [float(s["anchor_ns"]) for s in samples]
line(f"Clock anchor (scalar loop): median {st.median(an)/1e6:.3f} ms, p01 {np.percentile(an,1)/1e6:.3f}, p99 {np.percentile(an,99)/1e6:.3f}.")
mid = st.median(an)
line("\nSamples during a machine-wide slowdown (scalar anchor > 1.3 x its median); kept in all statistics, medians absorb them:\n")
line("| backend | samples flagged | of |")
line("|---|---|---|")
for b in backends:
    ss = [s for s in samples if s["backend"] == b]
    line(f"| {b} | {sum(float(s['anchor_ns']) > 1.3 * mid for s in ss)} | {len(ss)} |")
# spread between rounds
line("\n| backend | median over sizes of (max/min round median) | worst size |")
line("|---|---|---|")
for b in backends:
    for t in thr:
        xs, m, lo, hi = series(b, t)
        if len(xs):
            s = hi / lo; line(f"| {b} t{t} | {np.median(s):.3f} | {s.max():.3f} at n={xs[s.argmax()]} |")
# position within the process
line("\n| backend | correlation of position in the process with GFLOP/s relative to the size median |")
line("|---|---|")
for b in backends:
    ss = [s for s in samples if s["backend"] == b]; med = {}
    for n in sizes:
        v = [float(s["gflops"]) for s in ss if int(s["n"]) == n]
        if v: med[n] = st.median(v)
    p = np.array([int(s["position"]) for s in ss], float); r = np.array([float(s["gflops"]) / med[int(s["n"])] for s in ss])
    if p.std() > 0: line(f"| {b} | {np.corrcoef(p, r)[0,1]:+.3f} |")
open(os.path.join(OUT, "acceptance.md"), "w").write("\n".join(rep) + "\n")
print("\n".join(rep))

# ---- plots
def save(fig, name):
    fig.tight_layout()
    for e in ("svg", "pdf"): fig.savefig(os.path.join(PLOTS, f"{name}.{e}"))
    plt.close(fig)

def draw(ax, get, b, *a, band=True):
    xs, m, lo, hi = get(b, *a)
    if not len(xs): return
    lab, c, ls, mk = STYLE[b]
    if band: ax.fill_between(xs, lo, hi, color=c, alpha=.14, lw=0)
    ax.plot(xs, m, color=c, ls=ls, lw=1.6, marker=mk, ms=3.5, markevery=max(1, len(xs)//10), label=lab)

prefix = camp if len(sys.argv) < 3 else sys.argv[2]
conds = {1: "one thread", 4: "4 threads requested", 10: "10 threads requested"}
for t in thr:
    tt = f"{prefix}_t{t}"; note = conds.get(t, f"{t} threads")
    sub = "Apple M5, $C := AB$, $m=n=k$, $\\alpha=1$, $\\beta=0$, " + note + ". Line: median of rounds; band: range of rounds."
    fig, ax = plt.subplots(figsize=(8.2, 5))
    for b in backends: draw(ax, series, b, t)
    ax.set(xlabel="Matrix size $n$", ylabel="GFLOP/s  ($2n^3$ / time)", ylim=(0, None), xlim=(0, max(sizes) * 1.01))
    ax.set_title("DGEMM throughput\n" + sub, fontsize=10, loc="left"); ax.legend(ncol=2, loc="center right")
    save(fig, f"{tt}_gflops")

    for ref, nm, title in (("openblas", "vs_openblas", "Speedup relative to Julia's default OpenBLAS"), ("accelerate", "vs_accelerate", "Speedup relative to Apple Accelerate")):
        if ref not in backends: continue
        fig, ax = plt.subplots(figsize=(8.2, 4.6))
        for b in backends:
            if b != ref: draw(ax, ratio, b, ref, t)
        ax.axhline(1, color="#52514e", lw=1, zorder=1)
        ax.set(xlabel="Matrix size $n$", ylabel=f"Time of {STYLE[ref][0].split(',')[0]} / time of implementation", xlim=(0, max(sizes) * 1.01), ylim=(0, None))
        ax.set_title(title + "\nPaired by round (identical inputs). Line: median; band: range. Above 1 = faster than the reference.", fontsize=10, loc="left")
        ax.legend(ncol=2); save(fig, f"{tt}_{nm}")

    if "pureblas_native" in backends and "ulmblas" in backends:
        try:
            fig, (a1, a2) = plt.subplots(2, 1, figsize=(8.2, 6.4), sharex=True, gridspec_kw={"height_ratios": [3, 2]})
            for b in ("pureblas_native", "pureblas_lbt", "ulmblas"): draw(a1, series, b, t)
            a1.set(ylabel="GFLOP/s", ylim=(0, None)); a1.legend(loc="lower right"); a1.set_title("PureBLAS.jl and UlmBLAS.jl\nBoth on the SME unit, one thread requested. Band: range of rounds.", fontsize=10, loc="left")
            xs, m, lo, hi = ratio("pureblas_native", "ulmblas", t)
            a2.fill_between(xs, lo, hi, color=STYLE["pureblas_native"][1], alpha=.14, lw=0); a2.plot(xs, m, color=STYLE["pureblas_native"][1], lw=1.6, label="PureBLAS.jl (native) / UlmBLAS.jl")
            xs, m, lo, hi = ratio("pureblas_lbt", "ulmblas", t)
            a2.plot(xs, m, color=STYLE["pureblas_lbt"][1], lw=1.2, ls="--", label="PureBLAS.jl (LBT) / UlmBLAS.jl")
            a2.axhline(1, color="#52514e", lw=1, zorder=1); a2.set(xlabel="Matrix size $n$", ylabel="Throughput ratio", xlim=(0, max(sizes) * 1.01)); a2.legend()
            save(fig, f"{tt}_pureblas_vs_ulmblas")
        except Exception as e: print("focus plot skipped:", e)
