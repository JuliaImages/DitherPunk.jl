"""
    OrderedDither(mat::AbstractMatrix)

Generalized ordered dithering algorithm using a threshold map.
Takes a normalized threshold matrix `mat`.

When applying the algorithm to an image, the threshold matrix is repeatedly tiled
to match the size of the image. It is then applied as a per-pixel threshold map.
Optionally, this final threshold map can be inverted by selecting `invert_map=true`.
"""
struct OrderedDither{T<:AbstractMatrix} <: AbstractDither
    mat::T
end

function binarydither!(
    alg::OrderedDither, out::GenericGrayImage, img::GenericGrayImage; invert_map=false
)
    # eagerly promote to the same eltype to make for-loop faster
    FT = floattype(eltype(img))
    if invert_map
        mat = @. FT(1 - alg.mat)
    else
        mat = FT.(alg.mat)
    end

    matsize = size(mat)
    rlookup = [mod1(i, matsize[1]) for i in 1:size(img)[1]]
    clookup = [mod1(i, matsize[2]) for i in 1:size(img)[2]]

    T = eltype(out)
    black, white = T(0), T(1)

    @inbounds @simd for i in CartesianIndices(img)
        r, c = Tuple(i)
        @inbounds out[i] = ifelse(img[i] > mat[rlookup[r], clookup[c]], white, black)
    end
    return out
end

"""
    Bayer(; level)

Ordered dithering using the Bayer matrix as a threshold matrix.
The Bayer matrix is of dimension ``2^{n+1} \\times 2^{n+1}``, where ``n`` is the `level`,
which defaults to `1`.

[1]  Bayer, B.E., "An Optimum Method for Two-Level Rendition of Continuous
     Tone Pictures," IEEE International Conference on Communications,
     Conference Records, 1973, pp. 26-11 to 26-15.
"""
function Bayer(; level=1)
    bayer = bayer_matrix(level) .+ 1
    return OrderedDither(bayer//(2^(2 * level + 2) + 1))
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
ClusteredDots() = OrderedDither(CLUSTERED_DOTS_MAT)
const CLUSTERED_DOTS_MAT =
    [
        35 30 18 22 31 36
        29 15 10 17 21 32
        14 9 5 6 16 20
        13 4 1 2 11 19
        28 8 3 7 24 25
        34 27 12 23 26 33
    ]//37

"""
    CentralWhitePoint()

Central white point ordered dithering.
Uses ``6 \\times 6`` threshold matrix `CENTRAL_WHITE_POINT_MAT`.
"""
CentralWhitePoint() = OrderedDither(CENTRAL_WHITE_POINT_MAT)
const CENTRAL_WHITE_POINT_MAT =
    [
        35 26 22 18 30 34
        31 14 10 6 13 25
        19 7 2 1 9 21
        23 11 3 4 5 17
        27 15 8 12 16 29
        36 32 20 24 28 33
    ]//37

"""
    BalancedCenteredPoint()

Balanced centered point ordered dithering.
Uses ``6 \\times 6`` threshold matrix `BALANCED_CENTERED_POINT_MAT`.
"""
BalancedCenteredPoint() = OrderedDither(BALANCED_CENTERED_POINT_MAT)
const BALANCED_CENTERED_POINT_MAT =
    [
        31 23 17 22 34 36
        25 12 8 10 27 29
        14 6 1 3 15 20
        16 4 2 5 13 19
        28 9 7 11 26 30
        33 21 18 24 32 35
    ]//37

"""
    Rhombus()

Diagonal ordered matrix with balanced centered points.
Uses ``8 \\times 8`` threshold matrix `RHOMBUS_MAT`.
"""
Rhombus() = OrderedDither(RHOMBUS_MAT)
const RHOMBUS_MAT =
    [
        14 10 6 13 19 23 27 20
        7 2 1 9 26 31 32 24
        11 3 4 5 22 30 29 28
        15 8 12 16 18 25 21 17
        19 23 27 20 14 10 6 13
        26 31 32 24 7 2 1 9
        22 30 29 28 11 3 4 5
        18 25 21 17 15 8 12 16
    ]//33
