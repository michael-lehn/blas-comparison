#!/usr/bin/env python3
"""Median over runs of results/microbench/ub_r*.txt; writes results/microbench/summary.csv."""
import collections, csv, glob, os, statistics as st
D = os.path.join(os.path.dirname(__file__), "..", "..", "results", "microbench")
v = collections.OrderedDict()
for path in sorted(glob.glob(os.path.join(D, "ub_r*.txt"))):
    sec = None
    for line in open(path):
        p = line.split()
        if line.startswith("# E"): sec = p[1]; continue
        if not p or line.startswith("#"): continue
        if sec == "E1": rows = [(p[0], "GFLOP/s", p[1])]
        elif sec == "E2": rows = [(f"{p[0]} {p[1]}", "GFLOP/s", p[2])]
        elif sec == "E3": rows = [(p[0], "per_tile_overhead_ns", p[6])]
        elif sec == "E4": rows = [(f"{p[0]} {p[1]} SME", "ns/load", p[2]), (f"{p[0]} {p[1]} scalar", "ns/load", p[3])]
        else: rows = [(p[0], "GFLOP/s", p[1])]
        for case, unit, x in rows: v.setdefault((sec, case, unit), []).append(float(x))
with open(os.path.join(D, "summary.csv"), "w") as f:
    w = csv.writer(f); w.writerow(["experiment", "case", "unit", "median", "min", "max", "runs"])
    for (sec, case, unit), x in v.items():
        w.writerow([sec, case, unit, f"{st.median(x):.3f}", f"{min(x):.3f}", f"{max(x):.3f}", len(x)])
