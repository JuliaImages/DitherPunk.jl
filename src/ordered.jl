abstract type AbstractOrderedDither <: AbstractDither end

"""
    dither(img::AbstractMatrix, alg::AbstractOrderedDither; to_linear=false, invert_map=false)

Ordered dithering using threshold maps.
Takes a grayscale image `img` and a normalized threshold matrix `mat`.
The threshold matrix is repeatedly tiled to match the size of `img` and is then applied
as a per-pixel threshold map.
Optionally, this final threshold map can be inverted by selecting `invert_map=true`.
"""
function dither(
    img::AbstractMatrix{<:AbstractGray},
    alg::AbstractOrderedDither;
    to_linear=false,
    invert_map=false,
)::Matrix{Gray{Bool}}
    mat = threshold_map(alg)

    # eagerly promote to the same eltype to make for-loop faster
    FT = floattype(eltype(img))
    if invert_map
        mat = @. FT(1 - mat)
    else
        mat = FT.(mat)
    end
    linear_fun = to_linear ? srgb2linear : identity
    img = @. FT.(linear_fun.(img))

    out = zeros(Gray{Bool}, size(img))
    # TODO: add Threads.@threads to this for loop further improves the performances
    #       but it has unidentified memory allocations
    @inbounds for R in TileIterator(axes(img), size(mat))
        mat_size = map(length, R)
        if mat_size == size(mat)
            # `mappedarray` creates a readonly wrapper with lazy evaluation with `srgb2linear`
            # so that original `img` data is not modified.
            out[R...] .= @views img[R...] .> mat
        else # boundary condition
            mat_inds = map(Base.OneTo, mat_size)
            out_inds = map(getindex, R, mat_inds)
            out[out_inds...] .= @views img[out_inds...] .> mat[mat_inds...]
        end
    end
    return out
end

"""
    Bayer(level)

Ordered dithering using the Bayer matrix as a threshold matrix.
The Bayer matrix is of dimension ``2^{n+1} \\times 2^{n+1}``, where ``n`` is the `level`,
which defaults to `1`.
"""
struct Bayer <: AbstractOrderedDither
    level::Integer

    function Bayer(; level=1)
        new(level)
    end
end
function threshold_map(b::Bayer)
    bayer = bayer_matrix(b.level)
    return bayer//(2^(2 * b.level + 2))
end

"""
    bayer_matrix(n::Int)::AbstractMatrix{Int}

Contruct (un-normalized) Bayer matrices of level `n` through recursive definition.
"""
function bayer_matrix(n::Int)::AbstractMatrix{Int}
    n < 0 && throw(DomainError(n, "Bayer matrix only defined for n ≥ 0."))

    if n == 0
        b = [0 2; 3 1]
    else
        bₙ₋₁ = 4 * bayer_matrix(n - 1)
        b = [(bₙ₋₁) (bₙ₋₁.+2); (bₙ₋₁.+3) (bₙ₋₁.+1)]
    end
    return b
end

"""
    ClusteredDots()

Clustered dots ordered dithering.
Uses ``6 \\times 6`` threshold matrix `CLUSTERED_DOTS_MAT`.
"""
struct ClusteredDots <: AbstractOrderedDither end
threshold_map(::ClusteredDots) = CLUSTERED_DOTS_MAT
const CLUSTERED_DOTS_MAT =
    [
        34 29 17 21 30 35
        28 14 9 16 20 31
        13 8 4 5 15 19
        12 3 0 1 10 18
        27 7 2 6 23 24
        33 26 11 22 25 32
    ]//37

"""
    CentralWhitePoint()

Central white point ordered dithering.
Uses ``6 \\times 6`` threshold matrix `CENTRAL_WHITE_POINT_MAT`.
"""
struct CentralWhitePoint <: AbstractOrderedDither end
threshold_map(::CentralWhitePoint) = CENTRAL_WHITE_POINT_MAT
const CENTRAL_WHITE_POINT_MAT =
    [
        34 25 21 17 29 33
        30 13 9 5 12 24
        18 6 1 0 8 20
        22 10 2 3 4 16
        26 14 7 11 15 28
        35 31 19 23 27 32
    ]//37

"""
    BalancedCenteredPoint()

Balanced centered point ordered dithering.
Uses ``6 \\times 6`` threshold matrix `BALANCED_CENTERED_POINT_MAT`.
"""
struct BalancedCenteredPoint  <: AbstractOrderedDither end
threshold_map(::BalancedCenteredPoint) = BALANCED_CENTERED_POINT_MAT
const BALANCED_CENTERED_POINT_MAT =
    [
        30 22 16 21 33 35
        24 11 7 9 26 28
        13 5 0 2 14 19
        15 3 1 4 12 18
        27 8 6 10 25 29
        32 20 17 23 31 34
    ]//37

"""
    Rhombus()

Diagonal ordered matrix with balanced centered points.
Uses ``8 \\times 8`` threshold matrix `RHOMBUS_MAT`.
"""
struct Rhombus  <: AbstractOrderedDither end
threshold_map(::Rhombus) = RHOMBUS_MAT
const S₁ = [
    13 9 5 12
    6 1 0 8
    10 2 3 4
    14 7 11 15
]
const S₂ = [
    18 22 26 19
    25 30 31 23
    21 29 28 27
    17 24 20 16
]
const RHOMBUS_MAT = [S₁ S₂; S₂ S₁]//33
