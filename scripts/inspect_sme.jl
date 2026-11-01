# PureBLAS's SME kernel: writes its LLVM IR and compiles it with llc for inspection.
# code_native shows only the wrapper, not the noinline body. llc here is an external LLVM, not Julia's,
# so scheduling and registers may differ from what the JIT emits; the instruction mix is what this is for.
# Usage: julia --project=. scripts/inspect_sme.jl results/codegen   (llc must be on PATH)
using PureBLAS
const OUT = ARGS[1]
ll = joinpath(OUT, "sme_macro_overwrite.ll"); s = joinpath(OUT, "sme_macro_overwrite.s")
write(ll, PureBLAS._sme_macro_ir(true))
run(`llc -O3 -mtriple=arm64-apple-macosx -mattr=+sme2,+sme-f64f64 $ll -o $s`)
ls = readlines(s)
open(joinpath(OUT, "sme_summary.csv"), "w") do f
    println(f, "instruction,static_count")
    for (name, r) in ["fmopa" => r"\bfmopa\b", "ld1d_to_registers" => r"\bld1d\b\s+(\{\s*)?z", "ld1d_to_za" => r"\bld1d\b\s+\{\s*za", "st1d_from_za" => r"\bst1d\b\s+\{\s*za",
                      "smstart_sm" => r"\bsmstart\b", "smstop_sm" => r"\bsmstop\b", "zero_za" => r"\bzero\b\s+\{", "whilelt" => r"\bwhilelt\b", "calls" => r"\bbl\b"]
        println(f, name, ",", count(l -> occursin(r, l), ls))
    end
end
print(read(joinpath(OUT, "sme_summary.csv"), String))
