# One backend, row stride 2, one process.  Started by scripts/campaign.jl script=run_strided.jl.
# Calls: UlmBLAS.mul!(C, A, B) -> ulmblas_dgemm_strided; PureBLAS.gemm!(C, A, B).  Neither goes through
# LBT: LinearAlgebra.BLAS rejects a row stride other than 1.
using Random, LinearAlgebra
pushfirst!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
const ARG = Dict(split(a, '=', limit = 2)[1] => split(a, '=', limit = 2)[2] for a in ARGS)
const backend = ARG["backend"]
backend == "pureblas_strided2" && @eval using PureBLAS
backend == "ulmblas_strided2" && @eval using UlmBLAS
using BlasBench, BlasBenchStrided

pb_gemm!(C, A, B) = (Main.PureBLAS.gemm!(C, A, B); nothing)
um_gemm!(C, A, B) = (Main.UlmBLAS.mul!(C, A, B); nothing)

# Spy on the C call of UlmBLAS.mul! for one call: the arguments prove that the strides of the views
# and the addresses of their parents reach the library.  Removed before anything is timed.
const SPY = Ref{NTuple{7,Int64}}((0, 0, 0, 0, 0, 0, 0))
const REAL = Ref{Ptr{Cvoid}}(C_NULL)
function spy(m::Int64, n::Int64, k::Int64, a::Float64, A::Ptr{Float64}, rA::Int64, cA::Int64, B::Ptr{Float64},
             rB::Int64, cB::Int64, b::Float64, C::Ptr{Float64}, rC::Int64, cC::Int64)
    SPY[] = (rA, cA, rB, cB, rC, cC, Int64(UInt(A) != 0))
    ccall(REAL[], Cvoid, (Int64, Int64, Int64, Float64, Ptr{Float64}, Int64, Int64, Ptr{Float64}, Int64, Int64,
                          Float64, Ptr{Float64}, Int64, Int64), m, n, k, a, A, rA, cA, B, rB, cB, b, C, rC, cC)
    return nothing
end

function setup(threads)
    meta = Dict{String,Any}("backend" => backend, "threads_requested" => threads, "operands" => "view(P, 1:2:2n, 1:n), row stride 2, column stride 2n")
    n = 40
    PA = BlasBenchStrided.strided_parent(rand(n, n), NaN); PB = BlasBenchStrided.strided_parent(rand(n, n), NaN); PC = fill(0.0, 2n, n)
    A, B, C = BlasBenchStrided.stride2view.((PA, PB, PC))
    if backend == "pureblas_strided2"
        pb = Main.PureBLAS
        pb.set_num_threads(threads)
        meta["call_path"] = "PureBLAS.gemm!(C, A, B), native API"
        meta["version"] = string(pkgversion(pb))
        meta["_strided1(view)"] = pb._strided1(A)
        pb._strided1(A) && error("expected _strided1(view) == false")
        pb.gemm!(C, A, B)
        # Route, from run-time evidence.  (A list of compiled specializations proves nothing: the compiler
        # also compiles the branches that the stride test rejects at run time.)  The gate of gemm! and of
        # _gemm_core_body! is _strided1(C), false here; the kernel counter must not move; and the method
        # receives the SubArray itself.  Profiles in results/strided2/diagnostics name the frames.
        s0 = pb._SME_CALLS[]
        pb.gemm!(C, A, B)
        pb._SME_CALLS[] == s0 || error("the SME kernel ran on a stride-2 C")
        meta["sme_kernel_calls_for_stride2_C"] = 0
        meta["method"] = string(which(pb.gemm!, (typeof(C), typeof(A), typeof(B))))
        return pb_gemm!, meta, () -> pb._SME_CALLS[]
    else
        um = Main.UlmBLAS
        threads == 1 || error("ulmBLAS is single-threaded")
        meta["call_path"] = "UlmBLAS.mul!(C, A, B) -> ulmblas_dgemm_strided"
        meta["version"] = string(pkgversion(um)); meta["library"] = um.library_path(); meta["variant"] = um.variant()
        meta["variant"] == "sme" || error("not the SME variant")
        REAL[] = um.gemm_strided_ptr[Float64]
        um.gemm_strided_ptr[Float64] = @cfunction(spy, Cvoid, (Int64, Int64, Int64, Float64, Ptr{Float64}, Int64, Int64,
                                                               Ptr{Float64}, Int64, Int64, Float64, Ptr{Float64}, Int64, Int64))
        um.mul!(C, A, B)
        um.gemm_strided_ptr[Float64] = REAL[]
        SPY[][1:6] == (2, 2n, 2, 2n, 2, 2n) || error("strides at the C call: $(SPY[])")
        meta["strides_at_c_call(rA,cA,rB,cB,rC,cC)"] = string(SPY[][1:6]) * " for n=$n"
        return um_gemm!, meta, () -> missing
    end
end

function main()
    threads = parse(Int, get(ARG, "threads", "1")); round = parse(Int, get(ARG, "round", "1"))
    sizes = BlasBench.grid_sizes(ARG["sizes"]); samples = parse(Int, get(ARG, "samples", "5"))
    min_sample = parse(Float64, get(ARG, "min_sample", "0.05")); warmup = parse(Float64, get(ARG, "warmup", "0.1"))
    budget = parse(Float64, get(ARG, "budget", "0")); campaign = get(ARG, "campaign", "strided2"); out = ARG["out"]
    thermal_bin = joinpath(@__DIR__, "..", ".local", "bin", "thermal")
    haskey(ARG, "shuffle") && shuffle!(Xoshiro(parse(Int, ARG["shuffle"])), sizes)
    BlasBench.set_qos_interactive()
    f!, meta, sme = setup(threads)
    tag = "$(campaign)_$(backend)_t$(threads)_r$(round)"
    mkpath(out)
    s = open(joinpath(out, "samples_$tag.csv"), "w"); println(s, BlasBench.SAMPLE_HEADER)
    c = open(joinpath(out, "checks_$tag.csv"), "w"); println(c, BlasBench.CHECK_HEADER, ",gaps_intact")
    meta["julia"] = string(VERSION); meta["threads_julia"] = Threads.nthreads(); meta["sizes_order"] = join(sizes, ",")
    meta["env"] = Dict(k => get(ENV, k, "") for k in ("OPENBLAS_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "BLIS_NUM_THREADS", "OMP_NUM_THREADS", "JULIA_NUM_THREADS"))
    open(joinpath(out, "meta_$tag.txt"), "w") do io
        for k in sort!(collect(keys(meta))); println(io, k, " = ", repr(meta[k])); end
    end
    for (p, n) in enumerate(sizes)
        r = BlasBenchStrided.measure!(f!, sme, n; campaign, backend, threads, round, position = p, samples, min_sample,
                                      warmup, thermal_bin, csv_s = s, csv_c = c, budget)
        println(stdout, "$backend n=$n per_call=$(round_s(r.per_call)) samples=$(r.nsamples) calls=$(r.calls)"); flush(stdout)
    end
    close(s); close(c)
end
round_s(x) = Base.round(x; sigdigits = 3)
main()
