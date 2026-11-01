"""
    BlasBench

Harness of the DGEMM comparison.  One process measures one backend: `setup_backend` selects it
(and fails instead of substituting another one), `verify_product` checks results with code that does
not use BLAS, and `measure_size!` runs one matrix size: correctness check, warm-up, timed samples.
"""
module BlasBench

using CRC32c, Dates, Libdl, LinearAlgebra, Printf, Random, Statistics

export setup_backend, measure_size!, open_csvs, process_metadata, BACKENDS, grid_sizes

include("backends.jl")
include("verify.jl")
include("harness.jl")

end
