# Generated code of PureBLAS._gemm_generic! for each stride route, to test whether its inner loop vectorizes.
# Usage: julia --project=. scripts/inspect_generic.jl results/codegen
using PureBLAS, InteractiveUtils
const OUT = ARGS[1]
M = Matrix{Float64}
V = typeof(view(zeros(4, 4), 1:2:4, 1:4))
const CASES = ["contiguous" => (M, M, M), "C1_AB2" => (V, V, M), "C2_AB1" => (M, M, V), "C2_AB2" => (V, V, V)]
count_re(r, ls) = count(l -> occursin(r, l), ls)
open(joinpath(OUT, "generic_summary.csv"), "w") do f
    println(f, "route,instructions,scalar_fmadd,scalar_fmul_fadd,vector_2d_arith,vector_loads_stores,calls")
    for (tag, (TA, TB, TC)) in CASES
        io = IOBuffer()
        code_native(io, PureBLAS._gemm_generic!,
            (Bool, Bool, Bool, Bool, Int, Int, Int, Float64, TA, TB, Float64, TC); debuginfo = :none, dump_module = false)
        s = String(take!(io))
        write(joinpath(OUT, "generic_$tag.s"), s)
        ls = filter(l -> occursin(r"^\s+[a-z]", l) && !occursin(r"^\s+\.", l), split(s, '\n'))
        println(f, join((tag, length(ls),
            count_re(r"\bf(n?m(add|sub))\s+d\d", ls),
            count_re(r"\b(fmul|fadd)\s+d\d", ls),
            count_re(r"\b(fmla|fmls|fmul|fadd)\.2d\s", ls),
            count_re(r"\b(ldp|ldr|stp|str|ld1|st1|ld2|st2)\s+[qv]\d", ls),
            count_re(r"\b(bl|blr)\b", ls)), ","))
    end
end
print(read(joinpath(OUT, "generic_summary.csv"), String))
