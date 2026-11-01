#!/bin/bash
# Second pilot: stride path on Linux, thread pinning of PureBLAS, 32 threads, FMA peak, diagnostics smoke test.
#SBATCH -p dev_cpu_il
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --exclusive
#SBATCH --mem=64000mb
#SBATCH --time=00:20:00
#SBATCH --output=.local/logs/%x-%j.out
set -u
cd "$SLURM_SUBMIT_DIR"; module purge; module load compiler/gnu/14.2
export JULIA_DEPOT_PATH=$PWD/.local/depot JULIA_PKG_OFFLINE=true
J=.local/bin/julia; P=results/cluster-icelake
$J cluster/campaign.jl dir=pilot2_plain sizes=1000,4000 round_from=1 round_to=1 threads=16 samples=3 backends=pureblas_native
$J cluster/campaign.jl dir=pilot2_excl pure_exclusive=1 sizes=1000,4000 round_from=1 round_to=1 threads=16 samples=3 backends=pureblas_native
$J cluster/campaign.jl dir=pilot2_t32 sizes=1000,4000 round_from=1 round_to=1 threads=32 samples=3 backends=pureblas_native,mkl_jll,openblas_local
$J cluster/campaign.jl dir=pilot2_str script=run_strided.jl sizes=100,1000 round_from=1 round_to=1 threads=1 samples=3 backends=ulmblas_strided2,pureblas_strided2
numactl --physcpubind=3 --membind=0 "$PEAK" > $P/pilot/peak-$SLURM_JOB_ID.txt 2>&1
OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 OMP_NUM_THREADS=1 numactl --physcpubind=3 --membind=0 $J --project=cluster --startup-file=no -t 1,0 --gcthreads=1 scripts/strided_diagnostics.jl lib=pureblas out=$P/pilot/diag samples=1 sizes=100 profile_n=0
OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 OMP_NUM_THREADS=1 numactl --physcpubind=3 --membind=0 $J --project=cluster --startup-file=no -t 1,0 --gcthreads=1 scripts/strided_diagnostics.jl lib=ulmblas out=$P/pilot/diag samples=1 sizes=100 profile_n=0
echo pilot2-finished
