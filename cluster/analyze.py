#!/usr/bin/env python3
"""Ice Lake campaign: acceptance reports, summaries and plots, separate from the Apple M5 results.
   python cluster/analyze.py
Reads results/cluster-icelake/*/raw; writes summary.csv and acceptance.md per campaign, and plots/cluster-icelake_*.
Statistics as for the M5: median of the samples per (backend, threads, n, round), then median and range over rounds;
ratios are paired by round.  A cell whose median scalar anchor exceeds 1.25 x the lower quartile of its process is
excluded (same rule as strided2 on the M5), and only finished processes count."""
import collections, csv, glob, os, re, statistics as st
import numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BASE = os.path.join(ROOT, "results", "cluster-icelake"); PLOTS = os.path.join(ROOT, "plots")
STYLE = {
 "pureblas_native":   ("PureBLAS.jl, native API", "#2a78d6", "-", "o"),
 "pureblas_lbt":      ("PureBLAS.jl, via LBT", "#1baf7a", "--", "v"),
 "ulmblas_skylakex":  ("UlmBLAS.jl, skylakex variant", "#eb6834", "-", "s"),
 "mkl_jll":           ("oneMKL 2025.2", "#6250d6", "-", "D"),
 "openblas_local":    ("OpenBLAS 0.3.34, built for this CPU", "#eda100", "--", "+"),
 "openblas":          ("OpenBLAS 0.3.30, Julia default", "#333333", "-", "x"),
 "blis_jll":          ("BLIS 2.0, blis_jll (skx)", "#008300", ":", "1"),
 "pureblas_strided2": ("PureBLAS.jl, gemm! (generic fallback)", "#2a78d6", "-", "o"),
 "ulmblas_strided2":  ("UlmBLAS.jl, mul!, skylakex variant", "#eb6834", "-", "s"),
}
plt.rcParams.update({"font.size": 10, "axes.spines.top": False, "axes.spines.right": False, "axes.grid": True,
    "grid.color": "#e4e3df", "grid.linewidth": .6, "axes.axisbelow": True, "svg.fonttype": "none", "pdf.fonttype": 42,
    "legend.frameon": False, "legend.fontsize": 8.5, "figure.dpi": 150})
CPU = "Intel Xeon Platinum 8358 (Ice Lake)"

def save(fig, name):
    fig.tight_layout()
    for e in ("svg", "pdf"): fig.savefig(os.path.join(PLOTS, f"cluster-icelake_{name}.{e}"), bbox_inches="tight", metadata={"Date": None} if e == "svg" else None)
    plt.close(fig)

class Camp:
    def __init__(self, name):
        self.name = name; self.dir = os.path.join(BASE, name); raw = os.path.join(self.dir, "raw")
        self.samples, self.checks, self.host = [], [], {}
        for d in sorted(glob.glob(os.path.join(raw, "*.done"))):
            t = os.path.basename(d)[:-5]
            self.samples += list(csv.DictReader(open(os.path.join(raw, f"samples_{t}.csv"))))
            self.checks += list(csv.DictReader(open(os.path.join(raw, f"checks_{t}.csv"))))
        proc, cell, by = collections.defaultdict(list), collections.defaultdict(list), collections.defaultdict(list)
        for s in self.samples:
            k = (s["backend"], int(s["threads"]), int(s["n"]), int(s["round"])); a = float(s["anchor_ns"])
            proc[k[:2] + k[3:]].append(a); cell[k].append(a); by[k].append(float(s["gflops"]))
        q1 = {k: np.percentile(v, 25) for k, v in proc.items()}
        self.excluded = sorted(k for k, v in cell.items() if st.median(v) > 1.25 * q1[k[:2] + k[3:]])
        self.cells = {k: st.median(v) for k, v in by.items() if k not in self.excluded}
        self.backends = [b for b in STYLE if any(k[0] == b for k in self.cells)]
        self.threads = sorted({k[1] for k in self.cells})
        self.cw = collections.defaultdict(list)
        for s in self.samples: self.cw[(s["backend"], int(s["threads"]), int(s["n"]))].append(float(s["cpu_per_wall"]))
    def series(self, b, t):
        ns = sorted({k[2] for k in self.cells if k[0] == b and k[1] == t}); m, lo, hi = [], [], []
        for n in ns:
            v = [x for k, x in self.cells.items() if k[0] == b and k[1] == t and k[2] == n]
            m.append(st.median(v)); lo.append(min(v)); hi.append(max(v))
        return np.array(ns), np.array(m), np.array(lo), np.array(hi)
    def ratio(self, a, b, t):
        """Throughput a / throughput b, paired by round."""
        ns = sorted({k[2] for k in self.cells if k[0] == a and k[1] == t}); out = []
        for n in ns:
            rs = [self.cells[(a, t, n, r)] / self.cells[(b, t, n, r)] for r in range(1, 9)
                  if (a, t, n, r) in self.cells and (b, t, n, r) in self.cells]
            if rs: out.append((n, st.median(rs), min(rs), max(rs)))
        return np.array(out)
    def write(self):
        with open(os.path.join(self.dir, "summary.csv"), "w") as f:
            w = csv.writer(f); w.writerow(["backend", "threads", "n", "rounds", "median_gflops", "min_round_median", "max_round_median", "median_cpu_per_wall"])
            for b in self.backends:
                for t in self.threads:
                    ns, m, lo, hi = self.series(b, t)
                    for i, n in enumerate(ns):
                        rounds = sum(1 for k in self.cells if k[:3] == (b, t, n))
                        w.writerow([b, t, n, rounds, f"{m[i]:.3f}", f"{lo[i]:.3f}", f"{hi[i]:.3f}", f"{st.median(self.cw[(b, t, n)]):.2f}"])
        L = [f"# Acceptance report, {self.name} ({CPU})\n", f"samples: {len(self.samples)}; correctness checks: {len(self.checks)}\n",
             "| backend | threads | rounds | sizes | checks ok | worst entry ratio | worst Freivalds ratio | repeat bitwise identical | cpu/wall min..max | alloc bytes (max) | median (max/min round) | worst |",
             "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"]
        for b in self.backends:
            for t in self.threads:
                ss = [s for s in self.samples if s["backend"] == b and int(s["threads"]) == t]
                cs = [c for c in self.checks if c["backend"] == b and int(c["threads"]) == t]
                if not ss: continue
                cw = [float(s["cpu_per_wall"]) for s in ss]; ns, m, lo, hi = self.series(b, t); sp = hi / lo; wi = int(np.argmax(sp))
                L.append(f"| {b} | {t} | {len({s['round'] for s in ss})} | {len({s['n'] for s in ss})} | {sum(c['ok'] == 'true' for c in cs)}/{len(cs)} | "
                         f"{max(float(c['entry_ratio']) for c in cs):.3f} | {max(float(c['freivalds_ratio']) for c in cs):.3f} | {sum(c['repeat_identical'] == 'true' for c in cs)}/{len(cs)} | "
                         f"{min(cw):.2f}..{max(cw):.2f} | {max(int(s['alloc_bytes']) for s in ss)} | {st.median(sp):.3f} | {sp[wi]:.3f} at n={ns[wi]} |")
        crc = collections.defaultdict(set)
        for c in self.checks: crc[(c["n"], c["round"])].add(c["input_crc"])
        L.append(f"\nInput CRC identical across backends for {sum(len(v) == 1 for v in crc.values())}/{len(crc)} (n, round) pairs.")
        an = [float(s["anchor_ns"]) for s in self.samples]
        L.append(f"Clock anchor: median {st.median(an)/1e6:.3f} ms, p01 {np.percentile(an,1)/1e6:.3f}, p99 {np.percentile(an,99)/1e6:.3f}.")
        L.append(f"Cells excluded for a slow anchor (raw data kept): {len(self.excluded)} of {len(self.excluded) + len(self.cells)}.")
        for k in self.excluded: L.append(f"- {k[0]}, t={k[1]}, n={k[2]}, round {k[3]}")
        open(os.path.join(self.dir, "acceptance.md"), "w").write("\n".join(L) + "\n")

def curves(ax, c, t, band=True, backends=None):
    for b in (backends or c.backends):
        ns, m, lo, hi = c.series(b, t)
        if not len(ns): continue
        lab, col, ls, mk = STYLE[b]
        if band: ax.fill_between(ns, lo, hi, color=col, alpha=.16, lw=0)
        ax.plot(ns, m, color=col, ls=ls, lw=1.6, label=lab, marker=mk, ms=4.5, markevery=max(1, len(ns) // 10))
    ax.set_xlabel("Matrix size $n$")

def main():
    os.makedirs(PLOTS, exist_ok=True); peaks = {}
    for f in glob.glob(os.path.join(BASE, "nodes", "peak-*.txt")): peaks[os.path.basename(f)] = open(f).read()
    zmm = [float(m) for t in peaks.values() for m in re.findall(r"fma-zmm\s+([\d.]+)", t)]
    peak = st.median(zmm) if zmm else None

    s = Camp("sweep")
    if s.samples:
        s.write()
        fig, ax = plt.subplots(figsize=(9, 5)); curves(ax, s, 1)
        if peak: ax.axhline(peak, color="#888", lw=1, ls=":"); ax.text(4000, peak, f"AVX-512 FMA peak {peak:.0f}", ha="right", va="bottom", fontsize=8, color="#555")
        ax.set(ylabel="GFLOP/s", ylim=(0, None)); ax.legend(loc="lower right")
        ax.set_title(f"DGEMM, one thread, {CPU}, exclusive node, pinned core\n$C := AB$, $m=n=k$. Line: median of rounds; band: range of rounds", loc="left", fontsize=10)
        save(fig, "sweep_t1_gflops")
        fig, ax = plt.subplots(figsize=(9, 4.4))
        for b, ref in (("pureblas_native", "ulmblas_skylakex"),):
            r = s.ratio(b, ref, 1); ax.fill_between(r[:, 0], r[:, 2], r[:, 3], color=STYLE[b][1], alpha=.16, lw=0)
            ax.plot(r[:, 0], r[:, 1], color=STYLE[b][1], lw=1.6, label="PureBLAS.jl native / UlmBLAS.jl")
        ax.axhline(1, color="#555", lw=1); ax.set(xlabel="Matrix size $n$", ylabel="Throughput ratio"); ax.legend(loc="lower right")
        ax.set_title(f"PureBLAS.jl relative to UlmBLAS.jl, one thread, {CPU}\nPaired by round. Band: range of rounds. Above 1: PureBLAS.jl is faster", loc="left", fontsize=10)
        save(fig, "sweep_t1_pureblas_vs_ulmblas")
        fig, ax = plt.subplots(figsize=(9, 4.8)); best = "mkl_jll"
        for b in s.backends:
            if b == best: continue
            r = s.ratio(b, best, 1); lab, col, ls, mk = STYLE[b]; ax.plot(r[:, 0], r[:, 1], color=col, ls=ls, lw=1.6, label=lab, marker=mk, ms=4.5, markevery=8)
        ax.axhline(1, color="#555", lw=1); ax.set(xlabel="Matrix size $n$", ylabel="Throughput relative to oneMKL"); ax.legend(loc="lower right")
        ax.set_title(f"Relative to oneMKL 2025.2, one thread, {CPU}\nPaired by round. Line at 1 = oneMKL", loc="left", fontsize=10)
        save(fig, "sweep_t1_vs_mkl")
        fig, ax = plt.subplots(figsize=(9, 4.4)); curves(ax, s, 1, backends=["ulmblas_skylakex", "pureblas_native", "mkl_jll", "openblas_local"]); ax.set_xlim(0, 600)
        ax.set(ylabel="GFLOP/s", ylim=(0, None)); ax.legend(loc="lower right"); ax.set_title(f"Small sizes, one thread, {CPU}", loc="left", fontsize=10)
        save(fig, "sweep_t1_small")
    m = Camp("mt")
    if m.samples:
        m.write()
        fig, axs = plt.subplots(1, len(m.threads), figsize=(10.5, 4.6), sharey=True); axs = np.atleast_1d(axs)
        for ax, t in zip(axs, m.threads):
            curves(ax, m, t); ax.set_title(f"{t} threads, one per physical core, socket 0", loc="left", fontsize=10); ax.set_ylim(0, None)
        axs[0].set_ylabel("GFLOP/s"); h, l = axs[0].get_legend_handles_labels(); fig.tight_layout(rect=(0, .1, 1, 1)); fig.legend(h, l, loc="lower center", ncol=3, fontsize=8.5)
        save(fig, "mt_gflops")
    for n in (1000, 4000):
        c = Camp(f"ctrl_n{n}")
        if c.samples: c.write()
    d = Camp("strided2")
    if d.samples:
        d.write()
        fig, ax = plt.subplots(figsize=(9, 4.8)); curves(ax, d, 1); ax.set_yscale("log"); ax.set(ylabel="GFLOP/s, log scale")
        ax.set_yticks([2, 5, 10, 20, 50, 100]); ax.set_yticklabels(["2", "5", "10", "20", "50", "100"]); ax.minorticks_off(); ax.legend(loc="center right")
        ax.set_title(f"DGEMM with row stride 2 on A, B and C, one thread, {CPU}\nLine: median of rounds; band: range of rounds", loc="left", fontsize=10)
        save(fig, "strided2_t1_gflops")
        r = d.ratio("ulmblas_strided2", "pureblas_strided2", 1)
        if len(r):
            fig, ax = plt.subplots(figsize=(9, 4.4)); col = STYLE["ulmblas_strided2"][1]
            ax.fill_between(r[:, 0], r[:, 2], r[:, 3], color=col, alpha=.16, lw=0); ax.plot(r[:, 0], r[:, 1], color=col, lw=1.6)
            ax.set(xlabel="Matrix size $n$", ylabel="Time of PureBLAS.jl / time of UlmBLAS.jl", ylim=(0, None))
            ax.set_title(f"Speedup of UlmBLAS.jl relative to PureBLAS.jl, row stride 2, {CPU}\nPaired by round. Band: range of rounds", loc="left", fontsize=10)
            save(fig, "strided2_t1_speedup_ulmblas_vs_pureblas")
            with open(os.path.join(d.dir, "speedup.csv"), "w") as f:
                w = csv.writer(f); w.writerow(["n", "median_speedup", "min", "max"])
                for x in r: w.writerow([int(x[0])] + [f"{v:.3f}" for v in x[1:]])
    diag = []
    for f in glob.glob(os.path.join(BASE, "strided2", "diagnostics", "diag_*.csv")): diag += list(csv.DictReader(open(f)))
    if diag:
        v = collections.defaultdict(list)
        for r in diag: v[(r["lib"], r["config"], int(r["n"]))].append(float(r["gflops"]))
        med = {k: st.median(x) for k, x in v.items()}
        with open(os.path.join(BASE, "strided2", "diagnostics", "summary.csv"), "w") as f:
            w = csv.writer(f); w.writerow(["lib", "config", "n", "median_gflops"])
            for k in sorted(med): w.writerow([*k, f"{med[k]:.2f}"])
        CFG = {"contiguous": ("all strides 1, on Matrix", "#2a78d6", "-", "o"), "copy_all": ("stride 2, copied to and from buffers (timed)", "#1baf7a", "--", "v"),
               "copy_C_only": ("stride 2, only C through a buffer (timed)", "#6250d6", "-.", "D"), "C1_AB2": ("C stride 1, A and B stride 2", "#e87ba4", "-", "^"),
               "C2_AB1": ("C stride 2, A and B stride 1", "#eda100", "--", "P"), "C2_AB2": ("all strides 2", "#eb6834", "-", "s"), "generic_contiguous": ("_gemm_generic! on Matrix", "#333333", ":", "x")}
        fig, axs = plt.subplots(1, 2, figsize=(10.5, 4.6), sharey=True)
        for ax, lib, title in zip(axs, ("pureblas", "ulmblas"), ("PureBLAS.jl", "UlmBLAS.jl")):
            for c, (lab, col, ls, mk) in CFG.items():
                x = sorted(k[2] for k in med if k[0] == lib and k[1] == c)
                if x: ax.plot(x, [med[(lib, c, n)] for n in x], color=col, ls=ls, marker=mk, ms=5, lw=1.6, label=lab)
            ax.set_yscale("log"); ax.set_yticks([2, 5, 10, 20, 50, 100]); ax.set_yticklabels(["2", "5", "10", "20", "50", "100"]); ax.minorticks_off()
            ax.set_title(title, loc="left", fontsize=10); ax.set_xlabel("Matrix size $n$")
        axs[0].set_ylabel("GFLOP/s, log scale")
        fig.suptitle(f"Stride diagnostics, {CPU}; not a proposed design: full copies need O(n²) workspace", x=.06, ha="left", fontsize=10)
        h, l = axs[0].get_legend_handles_labels(); fig.tight_layout(rect=(0, .12, 1, 1)); fig.legend(h, l, loc="lower center", ncol=3, fontsize=8)
        save(fig, "strided2_diagnostics_routes")

if __name__ == "__main__":
    main()
