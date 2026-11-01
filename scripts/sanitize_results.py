#!/usr/bin/env python3
"""Removes machine-specific information from result files before they are committed: the absolute path of the
repository, and the names of other processes in the campaign logs and in environment.txt (their CPU shares stay,
as evidence of the load).  Idempotent.  Usage: scripts/sanitize_results.py [repository root, default: cwd]"""
import os, re, sys
root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
pats = [(re.compile(r"/(?:Users|home)/[^/\s\"']+/tmp/blas-comparison"), "<repo>"), (re.compile(r"~/tmp/blas-comparison"), "<repo>"),
        (re.compile(r"/private/tmp/[^\s\"']*"), "<tmp>"),
        (re.compile(r"/pfs/work9/workspace/scratch/[^/\s\"']+/blas-comparison"), "<repo>"),
        (re.compile(r"/pfs/work9/workspace/scratch/[^/\s\"']+"), "<workspace>"), (re.compile(r"/home/ul/[^\s\"']*"), "<home>"), (re.compile(r"\bul_(?:mlehn|math6)\b"), "<user>")]
def top(m):  # keep "top=100.0 <process> 8.4 <process> ..."
    return "top=" + " <process> ".join(re.findall(r"(?:^| )(\d+\.\d)(?= )", " " + m.group(1) + " ")) + " <process>"
for d, _, fs in os.walk(os.path.join(root, "results")):
    for f in fs:
        if not f.endswith((".txt", ".log", ".md", ".csv")): continue
        p = os.path.join(d, f); s = t = open(p, errors="surrogateescape").read()
        for r, x in pats: t = r.sub(x, t)
        if f == "campaign.log": t = re.sub(r"top=(.*)$", top, t, flags=re.M)
        if f == "environment.txt":
            t = re.sub(r"(?ms)^other long-running processes at record time:.*\Z", "other long-running processes at record time: removed; see docs/METHODOLOGY.md\n", t)
        if t != s: open(p, "w", errors="surrogateescape").write(t)
