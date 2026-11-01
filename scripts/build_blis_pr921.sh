#!/bin/sh
# BLIS pull request #921 (SME2 kernels for Apple M4/M5), pinned commit, ILP64 BLAS, below .local/.
# Same recipe as the build record in UlmBLAS.jl (bench/results/2026-10-31-apple-m5-blis-build.txt),
# with Apple clang.  Nothing is installed outside the repository.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd); C=235ef8ec097c43ab8299c89071af1b5b5e180843
SRC=$ROOT/.local/src/blis-pr921
[ -d "$SRC" ] || { git clone -q https://github.com/flame/blis.git "$SRC"; }
cd "$SRC"; git fetch -q origin pull/921/head:pr921 || true; git checkout -q $C
CC=/usr/bin/clang ./configure --prefix="$ROOT/.local/blis-pr921" -t pthreads -i 64 -b 64 m4sme_p
make -j8; make install
echo "built $C: $(ls "$ROOT/.local/blis-pr921/lib/")"
