# Backend selection.  Every backend reports what actually runs; a mismatch is an error, never a
# fallback.  LBT backends are all called the same way: LinearAlgebra.BLAS.gemm! -> dgemm_64_ (ILP64).
const BACKENDS = ("pureblas_native", "pureblas_lbt", "ulmblas", "openblas", "openblas_brew",
                  "accelerate", "blis_jll", "blis_pr921", "pureblas_neon",
                  "ulmblas_skylakex", "ulmblas_haswell", "openblas_local", "mkl_jll")

const ACCELERATE = "/System/Library/Frameworks/Accelerate.framework/Versions/A/Accelerate"
const ACCSUFFIX  = "\$NEWLAPACK\$ILP64"
const BREW_OPENBLAS = "/opt/homebrew/opt/openblas/lib/libopenblas.dylib"

lbt_addr() = UInt(BLAS.lbt_get_forward("dgemm_", :ilp64))
sym_addr(lib, name) = UInt(dlsym(dlopen(lib), name))

function lbt_gemm!(C, A, B)
    BLAS.gemm!('N', 'N', 1.0, A, B, 0.0, C)
    return nothing
end

function require_owner(lib, sym)
    lbt_addr() == sym_addr(lib, sym) ||
        error("LBT does not forward dgemm_ to $sym of $lib: refusing to measure")
    return nothing
end

"""
    setup_backend(name, threads) -> (call!, info::Dict, sme_calls::Function)

Selects a backend in this process.  `call!(C, A, B)` computes C := A*B with alpha = 1, beta = 0.
`sme_calls()` is a counter of SME GEMM calls where the library has one, otherwise `missing`.
"""
function setup_backend(name::AbstractString, threads::Int; native_call = nothing)
    info = Dict{String,Any}("backend" => name, "threads_requested" => threads)
    sme_calls = () -> missing
    call! = lbt_gemm!
    info["call_path"] = "LinearAlgebra.BLAS.gemm! -> LBT -> dgemm (ILP64)"
    if name == "pureblas_native" || name == "pureblas_lbt" || name == "pureblas_neon"
        pb = Base.require(Main, :PureBLAS)
        Base.invokelatest(pb.set_num_threads, threads)
        info["library"] = "PureBLAS.jl (pure Julia, JIT on this host)"
        info["version"] = string(pkgversion(pb))
        info["sme_detected"] = Base.invokelatest(getproperty, pb, :_SME_F64)
        info["sme_entry_live"] = Base.invokelatest(() -> pb._SME_ENTRY[] != C_NULL)
        for s in (:_SME_LANES, :_SME_MR, :_SME_NR, :_L1_BYTES, :_L2_BYTES, :_L3_BYTES, :_MR, :_NR, :_KC, :_NC)
            info[string(s)] = getproperty(pb, s)
        end
        sme_calls = () -> Base.invokelatest(() -> pb._SME_CALLS[])
        # pureblas_neon: PureBLAS with its own switch sme_f64 = false (scripts/prefs_neon, set by campaign.jl)
        Sys.isapple() && (name == "pureblas_neon") != !info["sme_detected"] &&
            error("$name with _SME_F64 = $(info["sme_detected"]): wrong preference environment")
        Sys.isapple() || (sme_calls = () -> missing)
        if name == "pureblas_lbt"
            Base.invokelatest(pb.activate)
            Base.invokelatest(pb.is_active) || error("PureBLAS.activate() did not take effect")
        else
            call! = native_call
            info["call_path"] = "PureBLAS.gemm!(C, A, B), native Julia API (no LBT)"
        end
    elseif startswith(name, "ulmblas")
        haskey(ENV, "ULMBLAS_LIBRARY") && error("ULMBLAS_LIBRARY is set: not the pinned artifact")
        um = Base.require(Main, :UlmBLAS)
        Base.invokelatest(um.forward)
        lib = Base.invokelatest(um.library_path)
        require_owner(lib, "dgemm_64_")
        info["library"] = lib
        info["variant"] = Base.invokelatest(um.variant)
        info["version"] = string(pkgversion(um))
        # The selected build must be the one named: "sme" on the M5; ulmblas_V forces variant V through ULMBLAS_VARIANT.
        want = name == "ulmblas" ? "sme" : split(name, '_')[2]
        selected = basename(dirname(lib))
        info["library_variant_dir"] = selected
        (name == "ulmblas" ? info["variant"] : selected) == want || error("UlmBLAS selected $(info["variant"]) in $selected, not $want")
        name == "ulmblas" || get(ENV, "ULMBLAS_VARIANT", "") == want || error("ULMBLAS_VARIANT must be $want")
        threads == 1 || error("ulmBLAS is single-threaded: unsupported configuration")
    elseif name == "openblas"
        lib = first(BLAS.get_config().loaded_libs).libname
        occursin("openblas", lowercase(lib)) || error("default BLAS is not OpenBLAS: $lib")
        require_owner(lib, "dgemm_64_")
        BLAS.set_num_threads(threads)
        BLAS.get_num_threads() == threads || error("OpenBLAS thread count not applied")
        info["library"] = lib
        info["config"] = unsafe_string(ccall(dlsym(dlopen(lib), "openblas_get_config64_"), Cstring, ()))
        info["corename"] = unsafe_string(ccall(dlsym(dlopen(lib), "openblas_get_corename64_"), Cstring, ()))
    elseif name == "openblas_brew"
        isfile(BREW_OPENBLAS) || error("Homebrew OpenBLAS not found at $BREW_OPENBLAS")
        h = dlopen(BREW_OPENBLAS, RTLD_LOCAL)
        ccall(dlsym(h, "openblas_set_num_threads"), Cvoid, (Cint,), threads)
        ccall(dlsym(h, "openblas_get_num_threads"), Cint, ()) == threads || error("thread count not applied")
        info["library"] = realpath(BREW_OPENBLAS)
        info["config"] = unsafe_string(ccall(dlsym(h, "openblas_get_config"), Cstring, ()))
        info["corename"] = unsafe_string(ccall(dlsym(h, "openblas_get_corename"), Cstring, ()))
        info["call_path"] = "direct ccall of dgemm_ (LP64: LBT would need an ILP64 library)"
        f = dlsym(h, "dgemm_")
        call! = function (C, A, B)
            n = Cint(size(C, 1)); one_ = 1.0; zero_ = 0.0
            ccall(f, Cvoid, (Ref{UInt8}, Ref{UInt8}, Ref{Cint}, Ref{Cint}, Ref{Cint}, Ref{Float64},
                             Ptr{Float64}, Ref{Cint}, Ptr{Float64}, Ref{Cint}, Ref{Float64},
                             Ptr{Float64}, Ref{Cint}, Csize_t, Csize_t),
                  UInt8('N'), UInt8('N'), n, n, n, one_, A, n, B, n, zero_, C, n, 1, 1)
            return nothing
        end
    elseif name == "openblas_local"
        lib = abspath(joinpath(@__DIR__, "..", ".local", "openblas-0.3.34", "lib", "libopenblas64_.so"))
        isfile(lib) || error("local OpenBLAS is not built: run cluster/build_openblas.sh")
        BLAS.lbt_forward(lib; clear = true, verbose = false, suffix_hint = "64_")
        require_owner(lib, "dgemm_64_")
        h = dlopen(lib)
        ccall(dlsym(h, "openblas_set_num_threads64_"), Cvoid, (Cint,), threads)
        ccall(dlsym(h, "openblas_get_num_threads64_"), Cint, ()) == threads || error("thread count not applied")
        info["library"] = lib
        info["config"] = unsafe_string(ccall(dlsym(h, "openblas_get_config64_"), Cstring, ()))
        info["corename"] = unsafe_string(ccall(dlsym(h, "openblas_get_corename64_"), Cstring, ()))
    elseif name == "mkl_jll"
        get(ENV, "MKL_NUM_THREADS", "") == string(threads) || error("MKL_NUM_THREADS must be $threads")
        mj = Base.require(Main, :MKL_jll)
        lib = Base.invokelatest(() -> mj.libmkl_rt)
        h = dlopen(lib)
        ccall(dlsym(h, "MKL_Set_Interface_Layer"), Cint, (Cint,), 1)     # 1 = MKL_INTERFACE_ILP64
        layer = threads == 1 ? 1 : 0                                      # 1 = sequential, 0 = Intel OpenMP
        ccall(dlsym(h, "MKL_Set_Threading_Layer"), Cint, (Cint,), layer)
        BLAS.lbt_forward(lib; clear = true, verbose = false, suffix_hint = "")
        first(BLAS.get_config().loaded_libs).interface === :ilp64 || error("MKL is not ILP64")
        require_owner(lib, "dgemm_")
        ccall(dlsym(h, "MKL_Set_Dynamic"), Cvoid, (Cint,), 0)
        ccall(dlsym(h, "MKL_Set_Num_Threads"), Cvoid, (Cint,), threads)
        ccall(dlsym(h, "MKL_Get_Max_Threads"), Cint, ()) == threads || error("MKL thread count not applied")
        buf = zeros(UInt8, 256)
        ccall(dlsym(h, "MKL_Get_Version_String"), Cvoid, (Ptr{UInt8}, Cint), buf, 256)
        info["library"] = lib
        info["version"] = strip(String(buf[1:findfirst(==(0x00), buf)-1]))
        info["threading_layer"] = threads == 1 ? "sequential" : "intel"
    elseif name == "accelerate"
        Sys.isapple() || error("Accelerate is only available on macOS")
        get(ENV, "VECLIB_MAXIMUM_THREADS", "") == string(threads) ||
            error("VECLIB_MAXIMUM_THREADS must be set to $threads before Julia starts")
        BLAS.lbt_forward(ACCELERATE; clear = true, verbose = false, suffix_hint = "\x1a" * ACCSUFFIX)
        require_owner(ACCELERATE, "dgemm" * ACCSUFFIX)
        first(BLAS.get_config().loaded_libs).interface === :ilp64 || error("Accelerate is not ILP64")
        info["library"] = ACCELERATE
        info["symbol"] = "dgemm" * ACCSUFFIX
    elseif name == "blis_jll"
        get(ENV, "BLIS_NUM_THREADS", "") == string(threads) || error("BLIS_NUM_THREADS must be $threads")
        bj = Base.require(Main, :blis_jll)
        lib = Base.invokelatest(() -> bj.blis)
        BLAS.lbt_forward(lib; clear = true, verbose = false, suffix_hint = "64_")
        require_owner(lib, "dgemm_64_")
        info["library"] = lib
        info["version"] = string(pkgversion(bj))
    elseif name == "blis_pr921"
        get(ENV, "BLIS_NUM_THREADS", "") == string(threads) || error("BLIS_NUM_THREADS must be $threads")
        lib = abspath(joinpath(@__DIR__, "..", ".local", "blis-pr921", "lib", "libblis.dylib"))
        isfile(lib) || error("BLIS PR #921 is not built: run scripts/build_blis_pr921.sh")
        BLAS.lbt_forward(lib; clear = true, verbose = false)
        require_owner(lib, "dgemm_")
        first(BLAS.get_config().loaded_libs).interface === :ilp64 || error("BLIS PR #921 is not ILP64")
        info["library"] = lib
    else
        error("unknown backend $name; known: $(join(BACKENDS, ", "))")
    end
    return call!, info, sme_calls
end
