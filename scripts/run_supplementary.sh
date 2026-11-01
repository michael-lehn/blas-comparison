#!/bin/sh
# Supplementary campaigns: why the main sweep looks as it does.  About one hour.  Run alone on the machine.
set -e
cd "$(dirname "$0")/.."
J=.local/bin/julia; export JULIA_DEPOT_PATH="$PWD/.local/depot"
FAST=pureblas_native,pureblas_lbt,ulmblas,accelerate,blis_pr921
C="$J --startup-file=no scripts/campaign.jl"
# 1. sizes of PureBLAS's own gate, including n*8 multiples of the 16 KB L1 way (absent from the 50:50:4000 grid)
$C campaign=ladder sizes=8,32,64,128,256,512,1024,2048,2100,4096 rounds=3 samples=5 backends=$FAST,openblas
# 2. fresh operands before each sample, instead of reused ones
$C campaign=fresh sizes=200,1000,2000,4000 rounds=3 samples=5 fresh=1 backends=pureblas_native,ulmblas,accelerate
# 3. one size per process, against the shuffled multi-size process of the sweep
for n in 1000 2000 4000; do
  $C campaign=ctrl_n$n sizes=$n rounds=3 samples=5 backends=pureblas_native,ulmblas,accelerate
done
# 4. PureBLAS without SME, by its own preference
$C campaign=neon sizes=50:50:4000 rounds=3 samples=5 backends=pureblas_neon
# 5. multi-threaded, separate from everything above; four threads = the four P cores of the M5.
#    UlmBLAS.jl is single-threaded: not part of this campaign.
$C campaign=mt sizes=100,200,500,1000,1500,2000,2500,3000,3500,4000 rounds=3 samples=5 threads=4 \
   backends=openblas,accelerate,blis_jll,blis_pr921,pureblas_native,pureblas_lbt
