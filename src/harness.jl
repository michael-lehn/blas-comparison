# One matrix size in one process: identical seeded inputs, correctness check, warm-up, timed samples.
const CLOCK_PROCESS_CPUTIME_ID = 12     # macOS <time.h>

function cpu_seconds()
    ts = Ref{NTuple{2,Int64}}((0, 0))
    ccall(:clock_gettime, Cint, (Cint, Ptr{NTuple{2,Int64}}), CLOCK_PROCESS_CPUTIME_ID, ts) == 0 ||
        error("clock_gettime failed")
    return ts[][1] + 1e-9 * ts[][2]
end

"QoS user-interactive: the macOS way to ask for performance cores (no affinity exists)."
set_qos_interactive() = ccall(:pthread_set_qos_class_self_np, Cint, (UInt32, Cint), 0x21, 0)

"Fixed scalar workload that touches only registers: tracks the core clock, not the matrix unit."
@noinline function anchor_ns()
    t0 = time_ns()
    x = 0x123456789abcdef
    for i in 1:2_000_000
        x = (x ⊻ (x << 13)) + UInt64(i)
    end
    t = time_ns() - t0
    x == 0 && error("unreachable")
    return Int(t)
end

function thermal_state(thermal_bin)
    isfile(thermal_bin) || return "unknown"
    return last(split(strip(read(`$thermal_bin`, String))))
end

input_seed(n::Int, round::Int) = 1_000_000 * round + n

"A and B are uniform in [-0.5, 0.5), from a seed that depends only on (n, round): same for all backends."
function make_inputs(n, round)
    rng = Xoshiro(input_seed(n, round))
    A = rand(rng, n, n) .- 0.5
    B = rand(rng, n, n) .- 0.5
    return A, B
end

const SAMPLE_HEADER = "campaign,backend,threads,round,pid,position,n,sample,calls,wall_s,cpu_s,gflops,cpu_per_wall,alloc_bytes,gc_ns,sme_calls,anchor_ns,thermal,timestamp"
const CHECK_HEADER = "campaign,backend,threads,round,pid,position,n,input_crc,method,entry_ratio,freivalds_ratio,hasnan,ok,repeat_identical,c11,c_sum,sme_calls_first"

function open_csvs(dir, tag)
    mkpath(dir)
    s = open(joinpath(dir, "samples_$tag.csv"), "w"); println(s, SAMPLE_HEADER)
    c = open(joinpath(dir, "checks_$tag.csv"), "w"); println(c, CHECK_HEADER)
    return s, c
end

function timed_sample!(f!, C, A, B, calls)
    GC.enable(false)
    g0 = Base.gc_num()
    c0 = cpu_seconds()
    t0 = time_ns()
    for _ in 1:calls
        f!(C, A, B)
    end
    t1 = time_ns()
    c1 = cpu_seconds()
    d = Base.GC_Diff(Base.gc_num(), g0)
    GC.enable(true)
    return (t1 - t0) * 1e-9, c1 - c0, d.allocd, d.total_time
end

"""
    measure_size!(...)

Timed region: `calls` GEMM calls on preallocated arrays, GC disabled.  C is filled with NaN before the
first call and before each sample (untimed): with beta = 0 a backend that reads C returns NaN.
A failed correctness check throws: no performance figure is accepted for that size.
"""
function measure_size!(f!, sme_calls, n; campaign, backend, threads, round, position, samples,
                       min_sample, warmup, thermal_bin, csv_s, csv_c, fresh_operands = false)
    A, B = make_inputs(n, round)
    C = fill(NaN, n, n)
    rng = Xoshiro(input_seed(n, round) + 7)
    crc = crc32c(reinterpret(UInt8, vec(A)), crc32c(reinterpret(UInt8, vec(B))))
    pid = getpid()
    flops = 2.0 * n^3

    s0 = sme_calls()
    f!(C, A, B)
    first_sme = ismissing(s0) ? missing : sme_calls() - s0
    v = verify_product(C, A, B, rng)
    C1 = copy(C)
    c11 = C[1, 1]; csum = sum(C)

    # warm-up, and the number of calls that makes one sample last at least min_sample
    t0 = time_ns(); wcalls = 0
    while wcalls == 0 || (time_ns() - t0) * 1e-9 < warmup
        f!(C, A, B); wcalls += 1
    end
    per_call = (time_ns() - t0) * 1e-9 / wcalls
    calls = max(1, ceil(Int, min_sample / per_call))

    GC.gc(false)
    for s in 1:samples
        if fresh_operands
            A = rand(rng, n, n) .- 0.5
            B = rand(rng, n, n) .- 0.5
        end
        fill!(C, NaN)
        sb = sme_calls()
        wall, cpu, alloc, gcns = timed_sample!(f!, C, A, B, calls)
        sd = ismissing(sb) ? "" : string(sme_calls() - sb)
        any(isnan, C) && error("NaN in C after a sample: $backend n=$n")
        @printf(csv_s, "%s,%s,%d,%d,%d,%d,%d,%d,%d,%.9f,%.9f,%.4f,%.4f,%d,%d,%s,%d,%s,%s\n",
                campaign, backend, threads, round, pid, position, n, s, calls, wall, cpu,
                flops * calls / wall * 1e-9, cpu / wall, alloc, gcns, sd, anchor_ns(), "-", "-")
    end
    identical = fresh_operands ? "n/a" : string(C == C1)
    th = thermal_state(thermal_bin)
    @printf(csv_c, "%s,%s,%d,%d,%d,%d,%d,%08x,%s,%.4f,%.4f,%s,%s,%s,%.17g,%.17g,%s\n",
            campaign, backend, threads, round, pid, position, n, crc, v.method, v.entry_ratio,
            v.freivalds_ratio, v.hasnan, v.ok, identical, c11, csum,
            ismissing(first_sme) ? "" : string(first_sme))
    flush(csv_s); flush(csv_c)
    v.ok || error("correctness check FAILED: $backend n=$n round=$round: $v")
    th in ("nominal", "unknown") || @warn "thermal state" th n backend
    return (; ok = v.ok, thermal = th)
end

function grid_sizes(spec::AbstractString)
    if occursin(':', spec)
        a, s, b = parse.(Int, split(spec, ':'))
        return collect(a:s:b)
    end
    return parse.(Int, split(spec, ','))
end

function process_metadata(info, thermal_bin)
    d = copy(info)
    d["julia"] = string(VERSION)
    d["threads_julia"] = Threads.nthreads()
    d["blas_config"] = string(BLAS.get_config())
    d["lbt_dgemm_addr"] = string(lbt_addr(), base = 16)
    d["start"] = string(now())
    d["thermal_start"] = thermal_state(thermal_bin)
    d["env"] = Dict(k => get(ENV, k, "") for k in ("OPENBLAS_NUM_THREADS", "VECLIB_MAXIMUM_THREADS",
                    "BLIS_NUM_THREADS", "OMP_NUM_THREADS", "JULIA_NUM_THREADS"))
    return d
end
