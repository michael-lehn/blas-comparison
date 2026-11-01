#!/bin/bash
# One step of the Ice Lake campaign on one exclusive node of cpu_il.  Usage: sbatch -t LIMIT -J NAME cluster/job.sbatch STEP
#SBATCH -p cpu_il
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --exclusive
#SBATCH --mem=64000mb
#SBATCH --output=.local/logs/%x-%j.out
set -u
cd "$SLURM_SUBMIT_DIR"; module purge; module load compiler/gnu/14.2
export JULIA_DEPOT_PATH=$PWD/.local/depot JULIA_PKG_OFFLINE=true
J=.local/bin/julia; BASE=results/cluster-icelake; STEP=$1
ST1=pureblas_native,pureblas_lbt,ulmblas_skylakex,openblas,openblas_local,mkl_jll,blis_jll
MT=pureblas_native,pureblas_lbt,openblas,openblas_local,mkl_jll,blis_jll
mkdir -p $BASE/nodes
cluster/record_env.sh $BASE/nodes/environment-$STEP-$SLURM_JOB_ID.txt
peak() { numactl --physcpubind=3 --membind=0 "$PEAK" > $BASE/nodes/peak-$STEP-$SLURM_JOB_ID-$1.txt 2>&1; }
peak before
case $STEP in
  sweep_a) $J cluster/campaign.jl dir=sweep sizes=50:50:4000 round_from=1 round_to=3 threads=1 samples=5 backends=$ST1 ;;
  sweep_b) $J cluster/campaign.jl dir=sweep sizes=50:50:4000 round_from=4 round_to=5 threads=1 samples=5 backends=$ST1
           for n in 1000 4000; do $J cluster/campaign.jl dir=ctrl_n$n sizes=$n round_from=1 round_to=3 threads=1 samples=5 backends=$ST1; done ;;
  mt)      for t in 16 32; do $J cluster/campaign.jl dir=mt sizes=100,200,500,1000,1500,2000,2500,3000,3500,4000 round_from=1 round_to=3 threads=$t samples=5 backends=$MT; done ;;
  strided) $J cluster/campaign.jl dir=strided2 script=run_strided.jl sizes=50:50:4000 round_from=1 round_to=3 threads=1 samples=5 backends=ulmblas_strided2,pureblas_strided2
           $J cluster/campaign.jl dir=strided2 script=run_strided.jl sizes=50:50:4000 round_from=4 round_to=5 threads=1 samples=5 backends=ulmblas_strided2 ;;
  diag)    export OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 BLIS_NUM_THREADS=1 OMP_NUM_THREADS=1
           for l in ulmblas pureblas; do numactl --physcpubind=3 --membind=0 $J --project=cluster --startup-file=no -t 1,0 --gcthreads=1 scripts/strided_diagnostics.jl lib=$l out=$BASE/strided2/diagnostics samples=3 sizes=50,100,200,300,500,1000,2000,3000,4000; done ;;
  *) echo unknown step; exit 2 ;;
esac
peak after
echo "step $STEP finished"
