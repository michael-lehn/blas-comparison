# Why do UlmBLAS.jl and PureBLAS.jl differ with row stride 2?  Diagnostic only: its numbers are not part of
# the strided2 plots.  One library per process:
#   julia --project=. -t 1,0 --gcthreads=1 scripts/strided_diagnostics.jl lib=pureblas|ulmblas out=DIR
#
# Configurations (stride of C / stride of A and B).  "copy" holds strided operands and calls the library on
# contiguous buffers, with the copies inside the timed region: what a fallback-free route could reach.
using Random, LinearAlgebra, Printf, Profile
pushfirst!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))
const ARG = Dict(split(a, '=', limit = 2)[1] => split(a, '=', limit = 2)[2] for a in ARGS)
const LIB = ARG["lib"]
LIB == "pureblas" ? (@eval using PureBLAS) : (@eval using UlmBLAS)
using BlasBench, BlasBenchStrided
import BlasBench: make_inputs, verify_product, timed_sample!, anchor_ns, input_seed
import BlasBenchStrided: strided_parent, stride2view

entry!(C, A, B) = LIB == "pureblas" ? (Main.PureBLAS.gemm!(C, A, B); nothing) : (Main.UlmBLAS.mul!(C, A, B); nothing)
generic!(C, A, B) = (n = size(C, 1); Main.PureBLAS._gemm_generic!(false, false, false, false, n, n, n, 1.0, A, B, 0.0, C); nothing)

struct Buf; A::Matrix{Float64}; B::Matrix{Float64}; C::Matrix{Float64}; end
function copyinout!(C, A, B, b::Buf)
    copyto!(b.A, A); copyto!(b.B, B); entry!(b.C, b.A, b.B); copyto!(C, b.C); nothing
end
function copyC!(C, A, B, b::Buf)   # only C through a contiguous buffer: the smallest change to the gate
    entry!(b.C, A, B); copyto!(C, b.C); nothing
end

function configs(n, A0, B0)
    PA = strided_parent(A0, NaN); PB = strided_parent(B0, NaN); PC = fill(BlasBenchStrided.C_GAP, 2n, n)
    A, B, C = stride2view(PA), stride2view(PB), stride2view(PC)
    Am, Bm, Cm = copy(A0), copy(B0), zeros(n, n); b = Buf(zeros(n, n), zeros(n, n), zeros(n, n))
    cs = Any[("contiguous", entry!, Cm, Am, Bm),
             ("C2_AB2", entry!, C, A, B),
             ("C1_AB2", entry!, Cm, A, B),
             ("C2_AB1", entry!, C, Am, Bm),
             ("copy_C_only", (c, a, bb) -> copyC!(c, a, bb, b), C, A, B),
             ("copy_all", (c, a, bb) -> copyinout!(c, a, bb, b), C, A, B)]
    LIB == "pureblas" && push!(cs, ("generic_contiguous", generic!, Cm, Am, Bm))
    return cs
end

sme_count() = LIB == "pureblas" ? Main.PureBLAS._SME_CALLS[] : -1

function main()
    out = ARG["out"]; mkpath(out)
    sizes = parse.(Int, split(get(ARG, "sizes", "200,500,1000,2000,3000,4000"), ','))
    samples = parse(Int, get(ARG, "samples", "3"))
    BlasBench.set_qos_interactive()
    LIB == "pureblas" && Main.PureBLAS.set_num_threads(1)
    io = open(joinpath(out, "diag_$(LIB)$(get(ARG, "suffix", "")).csv"), "w")
    println(io, "lib,config,n,sample,calls,wall_s,cpu_s,gflops,alloc_bytes,sme_calls_per_call,anchor_ns,entry_ratio,freivalds_ratio,ok")
    for n in sizes
        A0, B0 = make_inputs(n, 1)
        for (name, f!, C, A, B) in shuffle!(Xoshiro(n), configs(n, A0, B0))
            s0 = sme_count()
            t0 = time_ns(); f!(C, A, B); per = (time_ns() - t0) * 1e-9
            sme1 = sme_count() - s0
            v = verify_product(Matrix(C), A0, B0, Xoshiro(input_seed(n, 1) + 7))
            v.ok || error("wrong result $LIB $name n=$n: $v")
            t0 = time_ns(); w = 0
            while w == 0 || (time_ns() - t0) * 1e-9 < 0.1; f!(C, A, B); w += 1; end
            per = (time_ns() - t0) * 1e-9 / w
            calls = max(1, ceil(Int, 0.05 / per))
            GC.gc(false)
            for s in 1:samples
                C .= NaN
                wall, cpu, alloc, gc = timed_sample!(f!, C, A, B, calls)
                @printf(io, "%s,%s,%d,%d,%d,%.9f,%.9f,%.4f,%d,%d,%d,%.4f,%.4f,%s\n", LIB, name, n, s, calls, wall, cpu,
                        2.0 * n^3 * calls / wall * 1e-9, alloc, sme1, anchor_ns(), v.entry_ratio, v.freivalds_ratio, v.ok)
            end
            flush(io); println(LIB, " ", name, " n=", n, " per_call=", round(per; sigdigits = 3)); flush(stdout)
        end
    end
    close(io)
    # Where the time goes: a sampled profile, self time per frame, native frames included
    n = parse(Int, get(ARG, "profile_n", "1000"))
    n == 0 && return
    A0, B0 = make_inputs(n, 1)
    for (name, f!, C, A, B) in configs(n, A0, B0)
        name in ("contiguous", "C2_AB2", "C1_AB2", "C2_AB1") || continue
        f!(C, A, B); t0 = time_ns(); r = 0
        Profile.clear(); Profile.init(n = 10_000_000, delay = 0.001)
        @profile while (time_ns() - t0) * 1e-9 < 4; f!(C, A, B); r += 1; end
        open(joinpath(out, "profile_$(LIB)_$(name)_n$n.txt"), "w") do pio
            println(pio, "# $LIB $name n=$n, $r calls, 1 ms sampling; flat, self and total sample counts")
            Profile.print(IOContext(pio, :displaysize => (200, 200)); format = :flat, C = true, sortedby = :count, mincount = 5, noisefloor = 0)
        end
    end
end
main()
