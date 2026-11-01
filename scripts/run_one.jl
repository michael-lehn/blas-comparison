# One backend in one process.  Normally started by scripts/campaign.jl, which sets the environment.
#   julia --project=. -t 1 --gcthreads=1 scripts/run_one.jl KEY=VALUE ...
#   backend= threads= round= sizes=50:50:4000|a,b,c samples= min_sample= warmup= campaign= out= shuffle=seed fresh=0|1
using Random
pushfirst!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
const ARG = Dict(split(a, '=', limit = 2)[1] => split(a, '=', limit = 2)[2] for a in ARGS)
backend = ARG["backend"]
if startswith(backend, "pureblas"); using PureBLAS; end
if startswith(backend, "ulmblas"); using UlmBLAS; end
if backend == "blis_jll"; using blis_jll; end
if backend == "mkl_jll"; using MKL_jll; end
using BlasBench

# Resolved in this world, so the timed call is a direct compiled call, not a dynamic one.
native_gemm!(C, A, B) = (Main.PureBLAS.gemm!(C, A, B); nothing)

function main()
    threads = parse(Int, get(ARG, "threads", "1"))
    round = parse(Int, get(ARG, "round", "1"))
    sizes = BlasBench.grid_sizes(ARG["sizes"])
    samples = parse(Int, get(ARG, "samples", "7"))
    min_sample = parse(Float64, get(ARG, "min_sample", "0.05"))
    warmup = parse(Float64, get(ARG, "warmup", "0.1"))
    campaign = get(ARG, "campaign", "test")
    out = ARG["out"]
    fresh = get(ARG, "fresh", "0") == "1"
    thermal_bin = joinpath(@__DIR__, "..", ".local", "bin", "thermal")
    haskey(ARG, "shuffle") && shuffle!(Xoshiro(parse(Int, ARG["shuffle"])), sizes)

    BlasBench.set_qos_interactive()
    f!, info, sme = setup_backend(backend, threads; native_call = native_gemm!)
    tag = "$(campaign)_$(backend)_t$(threads)_r$(round)"
    s, c = open_csvs(out, tag)
    meta = process_metadata(info, thermal_bin)
    meta["sizes_order"] = join(sizes, ",")
    open(joinpath(out, "meta_$tag.txt"), "w") do io
        for k in sort!(collect(keys(meta)))
            println(io, k, " = ", repr(meta[k]))
        end
    end
    for (p, n) in enumerate(sizes)
        BlasBench.measure_size!(f!, sme, n; campaign, backend, threads, round, position = p, samples,
            min_sample, warmup, thermal_bin, csv_s = s, csv_c = c, fresh_operands = fresh)
    end
    close(s); close(c)
    return nothing
end
main()
