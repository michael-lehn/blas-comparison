#!/bin/bash
# Configuration pilot on one exclusive Ice Lake node of the development partition: precompile on this CPU type,
# build OpenBLAS, and test every candidate at a few sizes.  Not used for statistics.
#SBATCH -p dev_cpu_il
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --exclusive
#SBATCH --mem=64000mb
#SBATCH --time=00:30:00
#SBATCH --output=.local/logs/%x-%j.out
set -u
cd "$SLURM_SUBMIT_DIR"
module purge; module load compiler/gnu/14.2
export JULIA_DEPOT_PATH=$PWD/.local/depot JULIA_PKG_OFFLINE=true BENCH_JULIA=$PWD/.local/bin/julia
P=results/cluster-icelake/pilot; mkdir -p $P
cluster/record_env.sh $P/environment-$SLURM_JOB_ID.txt
[ -f .local/openblas-0.3.34/lib/libopenblas64_.so ] || cluster/build_openblas.sh "$W_SRC"/OpenBLAS-0.3.34.tar.gz || echo FAILED openblas
.local/bin/julia --project=cluster --startup-file=no -e 'using Pkg; Pkg.precompile(); using PureBLAS
  for s in (:_L1_BYTES,:_L2_BYTES,:_L3_BYTES,:_MR,:_NR,:_KC,:_NC,:_SME_F64); println(s," = ",getproperty(PureBLAS,s)); end' > $P/pureblas-constants-$SLURM_JOB_ID.txt 2>&1
C="pureblas_native,pureblas_lbt,ulmblas_skylakex,ulmblas_haswell,openblas,openblas_local,mkl_jll,blis_jll"
.local/bin/julia cluster/campaign.jl dir=pilot sizes=100,1000,4000 round_from=1 round_to=1 threads=1 samples=3 backends=$C
.local/bin/julia cluster/campaign.jl dir=pilot sizes=1000,4000 round_from=1 round_to=1 threads=16 samples=3 backends=pureblas_native,openblas,openblas_local,mkl_jll,blis_jll
mkdir -p $P/excl
MKL_VERBOSE=1 MKL_NUM_THREADS=1 numactl --physcpubind=3 --membind=0 .local/bin/julia --project=cluster --startup-file=no -e 'using MKL_jll, LinearAlgebra; h=MKL_jll.libmkl_rt; ccall((:MKL_Set_Interface_Layer,h),Cint,(Cint,),1); BLAS.lbt_forward(h;clear=true,suffix_hint=""); A=rand(200,200); BLAS.gemm!(Char(78),Char(78),1.0,A,A,0.0,similar(A))' 2>&1 | grep -E 'MKL_VERBOSE' | head -3 > $P/mkl-verbose-$SLURM_JOB_ID.txt
.local/bin/julia --project=cluster --startup-file=no -e 'using blis_jll; v=ccall((:bli_info_get_version_str,blis_jll.blis),Cstring,()); println("blis ",unsafe_string(v)); id=ccall((:bli_arch_query_id,blis_jll.blis),Cint,()); println("arch ",unsafe_string(ccall((:bli_arch_string,blis_jll.blis),Cstring,(Cint,),id)))' > $P/blis-arch-$SLURM_JOB_ID.txt 2>&1
echo pilot-finished
