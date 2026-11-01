# Runs a measurement campaign: one Julia process per (backend, round), backends in a random order per
# round, matrix sizes in a random order per process, thermal guard and pause between processes.
#   .local/bin/julia scripts/campaign.jl campaign=NAME sizes=50:50:4000 rounds=5 samples=7 threads=1 \
#        backends=a,b,c [min_sample=0.05] [warmup=0.1] [fresh=0] [seed=20261101] [per_size=0]
# Finished (backend, round) pairs are skipped, so an interrupted campaign can be continued.
# per_size=1: one process per (backend, round, size).
using Random
const ARG = Dict(split(a, '=', limit = 2)[1] => split(a, '=', limit = 2)[2] for a in ARGS)
const ROOT = abspath(joinpath(@__DIR__, ".."))
const JULIA = joinpath(ROOT, ".local", "bin", "julia")
const THERMAL = joinpath(ROOT, ".local", "bin", "thermal")
campaign = ARG["campaign"]; rounds = parse(Int, get(ARG, "rounds", "5")); threads = parse(Int, get(ARG, "threads", "1"))
backends = String.(split(ARG["backends"], ',')); seed = parse(Int, get(ARG, "seed", "20261101"))
perSize = get(ARG, "per_size", "0") == "1"
out = joinpath(ROOT, "results", campaign, "raw"); mkpath(out)
logf = open(joinpath(ROOT, "results", campaign, "campaign.log"), "a")
log(s...) = (msg = string(Libc.strftime("%F %T", time()), " ", s...); println(msg); println(logf, msg); flush(logf); flush(stdout))
state() = strip(read(`$THERMAL`, String))
power() = strip(first(split(read(`pmset -g batt`, String), '\n')))
function wait_nominal()
    t0 = time(); s = state()
    while s != "nominal"
        log("thermal guard: state ", s, ", waiting"); sleep(30); s = state()
    end
    time() - t0 > 1 && log("thermal guard: nominal after ", round(Int, time() - t0), " s")
end
function env_for(b)
    t = string(threads)
    return ("OPENBLAS_NUM_THREADS" => t, "VECLIB_MAXIMUM_THREADS" => t, "BLIS_NUM_THREADS" => t,
            "OMP_NUM_THREADS" => t, "JULIA_NUM_THREADS" => t, "JULIA_DEPOT_PATH" => joinpath(ROOT, ".local", "depot"))
end
sizes_all = get(ARG, "sizes", "50:50:4000")
log("campaign ", campaign, " rounds=", rounds, " threads=", threads, " backends=", join(backends, ","), " power: ", power())
for r in 1:rounds
    order = shuffle(Xoshiro(seed + r), backends)
    log("round ", r, " order ", join(order, ","))
    for (bi, b) in enumerate(order)
        tag = "$(campaign)_$(b)_t$(threads)_r$(r)"
        done = joinpath(out, tag * ".done")
        isfile(done) && continue
        wait_nominal(); sleep(3)
        load = strip(read(`sysctl -n vm.loadavg`, String))
        top = strip(read(pipeline(`ps -Ao pcpu,comm -r`, `sed -n 2,4p`), String))
        log("start ", tag, " thermal=", state(), " load=", load, " top=", replace(top, r"\s+" => " "))
        t0 = time()
        args = ["backend=$b", "threads=$threads", "round=$r", "sizes=$sizes_all", "campaign=$campaign",
                "out=$out", "shuffle=$(hash((seed, r, b)) % 1_000_000)",
                [k * "=" * ARG[k] for k in ("samples", "min_sample", "warmup", "fresh") if haskey(ARG, k)]...]
        cmd = `$JULIA --project=$ROOT --startup-file=no -t $threads,0 --gcthreads=1 $(joinpath(ROOT, "scripts", "run_one.jl")) $args`
        ok = success(pipeline(setenv(cmd, merge(Dict(ENV), Dict(env_for(b)))), stdout = logf, stderr = logf))
        log(ok ? "done  " : "FAILED ", tag, " in ", round(Int, time() - t0), " s thermal=", state(), " power: ", power())
        ok && touch(done)
    end
end
log("campaign finished")
