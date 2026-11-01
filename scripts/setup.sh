#!/bin/sh
# Local toolchain below .local/ (git-ignored).  No system-wide change.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd); V=${JULIA_VERSION:-1.13.3}; cd "$ROOT"
mkdir -p .local/bin
if [ ! -x ".local/julia-$V/bin/julia" ]; then
  curl -fsSL "https://julialang-s3.julialang.org/bin/mac/aarch64/${V%.*}/julia-$V-macaarch64.tar.gz" | tar xz -C .local
fi
ln -sf "../julia-$V/bin/julia" .local/bin/julia
/usr/bin/clang -O2 -fobjc-arc -framework Foundation scripts/thermal.m -o .local/bin/thermal
[ -x .local/venv/bin/python ] || { /usr/bin/python3 -m venv .local/venv || python3 -m venv .local/venv; .local/venv/bin/pip -q install -r scripts/requirements.txt; }
JULIA_DEPOT_PATH="$ROOT/.local/depot" .local/bin/julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
sh scripts/build_blis_pr921.sh
