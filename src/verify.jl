# Correctness checks written in plain Julia: nothing here calls BLAS, so a backend cannot vouch for
# itself.  Errors are reported in units of the classical forward error bound for a product of
# length k: (k+2) * u * sum_l |a_il * b_lj|, with u = eps/2.  A ratio <= 4 is accepted (as in bench2.c
# of ulmBLAS); it is element-wise, so an algorithm with a weaker bound (Strassen) would be visible.

function matvec!(y, A, x)
    fill!(y, 0.0)
    @inbounds for j in axes(A, 2)
        xj = x[j]
        @simd for i in axes(A, 1)
            y[i] += A[i, j] * xj
        end
    end
    return y
end

"Freivalds: C*x against A*(B*x) for random x, error relative to |A|*(|B|*|x|)."
function freivalds_ratio(C, A, B, rng; vectors = 3)
    n = size(C, 1)
    u = eps(Float64) / 2
    worst = 0.0
    y = zeros(n); z = zeros(n); w = zeros(n); yb = zeros(n); zb = zeros(n)
    aA = abs.(A); aB = abs.(B)
    for _ in 1:vectors
        x = rand(rng, (-1.0, 1.0), n)
        matvec!(y, B, x); matvec!(z, A, y); matvec!(w, C, x)
        matvec!(yb, aB, abs.(x)); matvec!(zb, aA, yb)
        for i in 1:n
            worst = max(worst, abs(w[i] - z[i]) / ((n + 2) * u * zb[i] + 1e-300))
        end
    end
    return worst
end

"Neumaier-compensated dot of row i of A with column j of B, and the sum of absolute values."
@inline function exact_entry(A, B, i, j)
    s = 0.0; c = 0.0; bound = 0.0
    @inbounds for l in axes(A, 2)
        t = A[i, l] * B[l, j]
        e = muladd(A[i, l], B[l, j], -t)      # exact error of the product (FMA)
        bound += abs(t)
        ss = s + t
        c += (abs(s) >= abs(t) ? (s - ss) + t : (t - ss) + s) + e
        s = ss
    end
    return s + c, bound
end

function entry_ratio(C, A, B, i, j)
    s, bound = exact_entry(A, B, i, j)
    u = eps(Float64) / 2
    return abs(C[i, j] - s) / ((size(A, 2) + 2) * u * bound + 1e-300)
end

"""
    verify_product(C, A, B, rng) -> NamedTuple

Full element-wise check for n <= 400; above: 2000 random entries plus Freivalds.  Accepted when no
entry is NaN and both ratios are <= 4.
"""
function verify_product(C, A, B, rng)
    n = size(C, 1)
    hasnan = any(isnan, C)
    worst = 0.0
    if n <= 400
        for j in 1:n, i in 1:n
            worst = max(worst, entry_ratio(C, A, B, i, j))
        end
        method = "full"
    else
        for _ in 1:2000
            worst = max(worst, entry_ratio(C, A, B, rand(rng, 1:n), rand(rng, 1:n)))
        end
        method = "entries2000+freivalds"
    end
    fr = freivalds_ratio(C, A, B, rng)
    return (; ok = !hasnan && worst <= 4 && fr <= 4, method, entry_ratio = worst, freivalds_ratio = fr, hasnan)
end
