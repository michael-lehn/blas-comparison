"""
    BlasBenchStrided

GEMM with row stride 2 on all three operands: separate from the contiguous benchmarks.  The parent
arrays have 2n rows; the logical matrices are `view(P, 1:2:2n, 1:n)`, with the logical values of the
contiguous campaigns (`BlasBench.make_inputs`).  Rows between the logical rows hold sentinels: NaN in
A and B, so reading them poisons the result; a fixed value in C, so writing them is detected.
"""
module BlasBenchStrided

using BlasBench, CRC32c, Dates, LinearAlgebra, Printf, Random
import BlasBench: make_inputs, input_seed, verify_product, timed_sample!, anchor_ns, thermal_state,
                  SAMPLE_HEADER, CHECK_HEADER

const C_GAP = -1234.5

function strided_parent(M::Matrix{Float64}, gap)
    n = size(M, 1)
    P = fill(gap, 2n, size(M, 2))
    P[1:2:2n, :] .= M
    return P
end
stride2view(P) = view(P, 1:2:size(P, 1), 1:size(P, 2))
gaps_intact(P) = all(==(C_GAP), view(P, 2:2:size(P, 1), :))

"""
    measure!(...)

As `BlasBench.measure_size!`: check, warm-up, `samples` timed samples of at least `min_sample` s, GC
off in the timed region, C filled with NaN before each sample (only logical rows).  The views are built
before and outside the timed region.  `budget` (seconds per size, 0 = none) is the one difference: when
one call is so slow that the samples would exceed it, fewer samples are taken and the CSV shows this.
"""
function measure!(f!, sme_calls, n; campaign, backend, threads, round, position, samples, min_sample,
                  warmup, thermal_bin, csv_s, csv_c, budget = 0.0)
    A0, B0 = make_inputs(n, round)
    PA = strided_parent(A0, NaN); PB = strided_parent(B0, NaN); PC = fill(C_GAP, 2n, n)
    A = stride2view(PA); B = stride2view(PB); C = stride2view(PC)
    (stride(A, 1), stride(B, 1), stride(C, 1)) == (2, 2, 2) || error("row stride is not 2")
    A isa SubArray && B isa SubArray && C isa SubArray || error("not views")
    (parent(A) === PA && parent(B) === PB && parent(C) === PC) || error("view does not alias its parent")
    C .= NaN
    rng = Xoshiro(input_seed(n, round) + 7)
    crc = crc32c(reinterpret(UInt8, vec(A0)), crc32c(reinterpret(UInt8, vec(B0))))
    flops = 2.0 * n^3

    s0 = sme_calls()
    t0 = time_ns()
    f!(C, A, B)
    first_call = (time_ns() - t0) * 1e-9
    first_sme = ismissing(s0) ? missing : sme_calls() - s0
    Cm = Matrix(C)
    v = verify_product(Cm, A0, B0, rng)
    intact = gaps_intact(PC)
    c11 = Cm[1, 1]; csum = sum(Cm)

    t0 = time_ns(); wcalls = 0
    while wcalls == 0 || (time_ns() - t0) * 1e-9 < warmup
        f!(C, A, B); wcalls += 1
    end
    per_call = (time_ns() - t0) * 1e-9 / wcalls
    calls = max(1, ceil(Int, min_sample / per_call))
    nsamples = budget > 0 ? clamp(floor(Int, budget / (calls * per_call)), 1, samples) : samples

    GC.gc(false)
    for s in 1:nsamples
        C .= NaN
        sb = sme_calls()
        wall, cpu, alloc, gcns = timed_sample!(f!, C, A, B, calls)
        sd = ismissing(sb) ? "" : string(sme_calls() - sb)
        any(isnan, C) && error("NaN in C after a sample: $backend n=$n")
        @printf(csv_s, "%s,%s,%d,%d,%d,%d,%d,%d,%d,%.9f,%.9f,%.4f,%.4f,%d,%d,%s,%d,%s,%s\n",
                campaign, backend, threads, round, getpid(), position, n, s, calls, wall, cpu,
                flops * calls / wall * 1e-9, cpu / wall, alloc, gcns, sd, anchor_ns(), "-", "-")
    end
    identical = Matrix(C) == Cm
    intact2 = gaps_intact(PC)
    ok = v.ok && intact && intact2
    @printf(csv_c, "%s,%s,%d,%d,%d,%d,%d,%08x,%s,%.4f,%.4f,%s,%s,%s,%.17g,%.17g,%s,%s\n",
            campaign, backend, threads, round, getpid(), position, n, crc, v.method, v.entry_ratio,
            v.freivalds_ratio, v.hasnan, ok, identical, c11, csum,
            ismissing(first_sme) ? "" : string(first_sme), intact && intact2)
    flush(csv_s); flush(csv_c)
    ok || error("correctness check FAILED: $backend n=$n round=$round: $v intact=$intact,$intact2")
    return (; first_call, per_call, nsamples, calls)
end

end
