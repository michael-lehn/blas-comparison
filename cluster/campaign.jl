# Campaign driver on a Linux cluster node inside a Slurm allocation: one Julia process per (backend, round),
# random order of backends per round, random order of sizes per process, bound with numactl.  Same seeds and
# harness as scripts/campaign.jl; the thermal and load guards are replaced by an exclusive node and a log of
# the achieved clock.
#   julia cluster/campaign.jl dir=sweep sizes=50:50:4000 round_from=1 round_to=3 threads=1 samples=5 backends=a,b,c
# dir is relative to results/cluster-icelake.  Finished (backend, round, threads) triples are skipped.
using Random
const ARG = Dict(split(a, '=', limit = 2)[1] => split(a, '=', limit = 2)[2] for a in ARGS)
const ROOT = abspath(joinpath(@__DIR__, ".."))
const JULIA = get(ENV, "BENCH_JULIA", joinpath(ROOT, ".local", "bin", "julia"))
const PROJECT = joinpath(ROOT, "cluster")
dir = ARG["dir"]; threads = parse(Int, get(ARG, "threads", "1")); seed = parse(Int, get(ARG, "seed", "20261101"))
r1 = parse(Int, get(ARG, "round_from", "1")); r2 = parse(Int, get(ARG, "round_to", "3"))
backends = String.(split(ARG["backends"], ',')); sizes = get(ARG, "sizes", "50:50:4000")
base = joinpath(ROOT, "results", "cluster-icelake", dir); out = joinpath(base, "raw"); mkpath(out)
logf = open(joinpath(base, "campaign.log"), "a")
log(s...) = (msg = string(Libc.strftime("%F %T", time()), " ", s...); println(msg); println(logf, msg); flush(logf); flush(stdout))

# Topology from the node itself: physical cores in id order on socket 0, first hardware thread of each.
function cores()
    seen = Set{Int}(); c = Tuple{Int,Int}[]
    for l in eachline(`lscpu -p=CPU,CORE,SOCKET,NODE`)
        startswith(l, "#") && continue
        cpu, core, sock, node = parse.(Int, split(l, ','))
        sock == 0 && !(core in seen) && (push!(seen, core); push!(c, (cpu, node)))
    end
    return c
end
const CORES = cores()
# One thread: core CPU (default 3), memory on its NUMA node.  t threads: first t cores of socket 0, memory
# bound to or interleaved over the NUMA nodes of those cores.  Hardware siblings are never used.
function pin(t)
    if t == 1
        cpu = parse(Int, get(ARG, "cpu", "3")); node = only(n for (c, n) in CORES if c == cpu)
        return `numactl --physcpubind=$cpu --membind=$node`, string(cpu), string(node)
    end
    sel = CORES[1:t]; cs = join(first.(sel), ","); ns = sort!(unique(last.(sel))); nodes = join(ns, ",")
    return length(ns) == 1 ? `numactl --physcpubind=$cs --membind=$nodes` : `numactl --physcpubind=$cs --interleave=$nodes`, cs, nodes
end
function env_for(b)
    t = string(threads)
    d = Dict{String,String}("OPENBLAS_NUM_THREADS" => t, "BLIS_NUM_THREADS" => t, "OMP_NUM_THREADS" => t,
        "JULIA_NUM_THREADS" => t, "MKL_NUM_THREADS" => t, "MKL_DYNAMIC" => "FALSE",
        "JULIA_DEPOT_PATH" => joinpath(ROOT, ".local", "depot"), "JULIA_PKG_OFFLINE" => "true")
    if threads == 1
        d["MKL_THREADING_LAYER"] = "SEQUENTIAL"
    else
        d["MKL_THREADING_LAYER"] = "INTEL"; d["KMP_AFFINITY"] = "granularity=core,compact"
        d["OMP_PROC_BIND"] = "close"; d["OMP_PLACES"] = "cores"
        startswith(b, "pureblas") && get(ARG, "pure_exclusive", "0") == "1" && (d["JULIA_EXCLUSIVE"] = "1")
    end
    startswith(b, "ulmblas_") && (v = split(b, '_')[2]; v != "strided2" && (d["ULMBLAS_VARIANT"] = v))
    b == "ulmblas_strided2" && (d["ULMBLAS_VARIANT"] = get(ARG, "ulm_variant", "skylakex"))
    return d
end
cpu_cmd, cpu_list, node_list = pin(threads)
watch_cpu = first(split(cpu_list, ","))
freq(cpu) = try strip(read("/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_cur_freq", String)) catch; "?" end
load() = strip(read("/proc/loadavg", String))
log("campaign ", dir, " host=", gethostname(), " job=", get(ENV, "SLURM_JOB_ID", "?"), " rounds=", r1, "-", r2, " threads=", threads,
    " cpus=", cpu_list, " numa=", node_list, " backends=", join(backends, ","))
for r in r1:r2
    order = shuffle(Xoshiro(seed + r), backends)
    log("round ", r, " order ", join(order, ","))
    for b in order
        tag = "$(dir)_$(b)_t$(threads)_r$(r)"
        done = joinpath(out, tag * ".done")
        isfile(done) && continue
        log("start ", tag, " load=", load())
        t0 = time()
        args = ["backend=$b", "threads=$threads", "round=$r", "sizes=$sizes", "campaign=$dir", "out=$out",
                "shuffle=$(hash((seed, r, b)) % 1_000_000)",
                [k * "=" * ARG[k] for k in ("samples", "min_sample", "warmup", "budget") if haskey(ARG, k)]...]
        cmd = `$cpu_cmd $JULIA --project=$PROJECT --startup-file=no -t $threads,0 --gcthreads=1 $(joinpath(ROOT, "scripts", get(ARG, "script", "run_one.jl"))) $args`
        task = @async success(pipeline(setenv(cmd, merge(Dict(ENV), env_for(b))), stdout = logf, stderr = logf))
        # achieved clock of the measured (first) core, every 20 s; the driver itself runs on another core
        t_log = time()
        while !istaskdone(task)
            sleep(0.5)
            time() - t_log >= 20 && (t_log = time(); log("freq ", tag, " cpu", watch_cpu, "=", freq(watch_cpu), " kHz load=", load()))
        end
        ok = fetch(task)
        log(ok ? "done  " : "FAILED ", tag, " in ", round(Int, time() - t0), " s load=", load())
        ok && touch(done)
    end
end
log("campaign finished")
