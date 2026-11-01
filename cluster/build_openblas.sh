#!/bin/bash
# OpenBLAS 0.3.34 for this CPU, shared, pthreads, ILP64 with the symbol suffix 64_, below .local/.  Run on a node of the target CPU.
# Usage: cluster/build_openblas.sh TARBALL   (sha256 cd7e129868320cc2d033afa920e31202dfe0b8066a5b66661900ccc0f197dfed)
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd); T=$1; B=$ROOT/.local/build; mkdir -p "$B"
echo "cd7e129868320cc2d033afa920e31202dfe0b8066a5b66661900ccc0f197dfed  $T" | sha256sum -c -
tar xzf "$T" -C "$B"; cd "$B"/OpenBLAS-0.3.34
FLAGS="USE_THREAD=1 USE_OPENMP=0 NUM_THREADS=128 NOFORTRAN=1 NO_LAPACK=1 NO_STATIC=1 INTERFACE64=1 SYMBOLSUFFIX=64_ DYNAMIC_ARCH=0"
make -j"${SLURM_CPUS_ON_NODE:-16}" $FLAGS > "$ROOT/.local/build/openblas.log" 2>&1
make PREFIX="$ROOT/.local/openblas-0.3.34" $FLAGS install >> "$ROOT/.local/build/openblas.log" 2>&1
ls "$ROOT"/.local/openblas-0.3.34/lib
