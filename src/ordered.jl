"""
    OrderedDither(mat::AbstractMatrix, [max::Integer])

Generalized ordered dithering algorithm using a threshold map.
Takes an unnormalized threshold matrix `mat` and optionally a normalization quotient `max` (defaults to `length(mat)+1`).

When applying the algorithm to an image, the threshold matrix is repeatedly tiled
to match the size of the image. It is then applied as a per-pixel threshold map.
Optionally, this final threshold map can be inverted by selecting `invert_map=true`.
"""
struct OrderedDither{I <: Integer, M <: AbstractMatrix{<:I}, R <: Real} <: AbstractDither
    mat::M
    max::I
    color_error_multiplier::R

    function OrderedDither(
            mat::M;
            max::I = convert(I, length(mat) + 1),
            invert_map = false,
            color_error_multiplier::R = 0.5,
        ) where {I <: Integer, M <: AbstractMatrix{<:I}, R <: Real}
        require_one_based_indexing(mat)
        if invert_map
            mat = max .- mat
        end
        return new{I, M, R}(mat, max, color_error_multiplier)
    end
end

function binarydither!(alg::OrderedDither, out::GrayImage, img::GrayImage)
    # eagerly promote to the same eltype to make for-loop faster
    FT = floattype(eltype(img))
    mat = FT.(alg.mat / alg.max)

    T = eltype(out)
    black, white = T(0), T(1)

    # Precompute lookup tables for modulo indexing of threshold matrix
    hm, wm = size(mat)
    hi, wi = size(img)
    rlookup = [mod1(i, hm) for i in 1:hi]
    clookup = [mod1(i, wm) for i in 1:wi]

    @inbounds @simd for i in CartesianIndices(img)
        r, c = Tuple(i)
        out[i] = ifelse(img[i] > mat[rlookup[r], clookup[c]], white, black)
    end
    return out
end

# Using Pattern Dithering by Thomas Knoll / Adobe Inc. Patent expired in 2019.
# https://patents.google.com/patent/US6606166B1/en
# Implemented according to Joel Yliluoma's pseudocode
# https://bisqwit.iki.fi/story/howto/dither/jy/
function colordither!(
    out::Matrix{Int},
    alg::OrderedDither,
    img::GenericImage{C},
    cs::AbstractVector{C},
    colorpicker::AbstractColorPicker{C},
) where {C <: ColorLike}
    cs_lab = Lab.(cs)
    T = eltype(C)
    error_multiplier = convert(T, alg.color_error_multiplier)

    # Precompute lookup tables for modulo indexing of threshold matrix
    mat = alg.mat
    nmax = maximum(mat)
    hm, wm = size(mat)
    hi, wi = size(img)
    rlookup = [mod1(i, hm) for i in 1:hi]
    clookup = [mod1(i, wm) for i in 1:wi]

    # Allocate matrices
    candidates = Array{Int}(undef, nmax)

    @inbounds for I in CartesianIndices(img)
        r, c = Tuple(I)
        err = zero(C)
        px = img[I]

        for j in 1:nmax
            col = px + error_multiplier * err
            idx = colorpicker(col)

            # We are in loop (idx ↔ err) if we already computed `idx` as the closest color
            # after the first iteration. Breaking out of this loops lets us avoid calling
            # the expensive closest color computation.
            if (j > 2) && (idx in candidates[2:(j - 1)])
                # Find the range of the loop in `candidates`:
                looprange = (findfirst(i -> i == idx, candidates[2:(j - 1)]) + 1):(j - 1)
                # Fill the rest of `candidates` with this loop:
                candidates[j:end] .= Iterators.take(
                    Iterators.cycle(candidates[looprange]), nmax - j + 1
                )
                break
            else
                candidates[j] = idx
                err = px - cs[idx]
            end
        end
        # Sort candidates by luminance (dark to bright)
        out[I] = partialsort!(candidates, mat[rlookup[r], clookup[c]]; by = i -> cs_lab[i].l)
    end
    return out
end

"""
    Bayer([level=1]; kwargs...)

Ordered dithering using the Bayer matrix as a threshold matrix.
The Bayer matrix is of dimension ``2^{n+1} \\times 2^{n+1}``, where ``n`` is the `level`,
which defaults to `1`.

[1]  Bayer, B.E., "An Optimum Method for Two-Level Rendition of Continuous
     Tone Pictures," IEEE International Conference on Communications,
     Conference Records, 1973, pp. 26-11 to 26-15.
"""
function Bayer(level = 1; kwargs...) # TODO: deprecate optional argument
    bayer = bayer_matrix(level) .+ 1
    return OrderedDither(bayer; kwargs...)
end

"""
    bayer_matrix(n::Integer)::AbstractMatrix{Int}

Contruct (un-normalized) Bayer matrices of level `n` through recursive definition.
"""
function bayer_matrix(n::Integer)
    n < 0 && throw(DomainError(n, "Bayer matrix only defined for n ≥ 0."))

    if n == 0
        b = [0 2; 3 1]
    else
        bₙ₋₁ = 4 * bayer_matrix(n - 1)
        b = [(bₙ₋₁) (bₙ₋₁ .+ 2); (bₙ₋₁ .+ 3) (bₙ₋₁ .+ 1)]
    end
    return b
end

"""
    ClusteredDots()

Clustered dots ordered dithering.
Uses ``6 \\times 6`` threshold matrix `CLUSTERED_DOTS_MAT`.
"""
ClusteredDots(; kwargs...) = OrderedDither(CLUSTERED_DOTS_MAT; kwargs...)
const CLUSTERED_DOTS_MAT = [
    35 30 18 22 31 36
    29 15 10 17 21 32
    14  9  5  6 16 20
    13  4  1  2 11 19
    28  8  3  7 24 25
    34 27 12 23 26 33
]

"""
    CentralWhitePoint()

Central white point ordered dithering.
Uses ``6 \\times 6`` threshold matrix `CENTRAL_WHITE_POINT_MAT`.
"""
CentralWhitePoint(; kwargs...) = OrderedDither(CENTRAL_WHITE_POINT_MAT; kwargs...)
const CENTRAL_WHITE_POINT_MAT = [
    35 26 22 18 30 34
    31 14 10  6 13 25
    19  7  2  1  9 21
    23 11  3  4  5 17
    27 15  8 12 16 29
    36 32 20 24 28 33
]

"""
    BalancedCenteredPoint()

Balanced centered point ordered dithering.
Uses ``6 \\times 6`` threshold matrix `BALANCED_CENTERED_POINT_MAT`.
"""
BalancedCenteredPoint(; kwargs...) = OrderedDither(BALANCED_CENTERED_POINT_MAT; kwargs...)
const BALANCED_CENTERED_POINT_MAT = [
    31 23 17 22 34 36
    25 12  8 10 27 29
    14  6  1  3 15 20
    16  4  2  5 13 19
    28  9  7 11 26 30
    33 21 18 24 32 35
]

"""
    Rhombus()

Diagonal ordered matrix with balanced centered points.
Uses ``8 \\times 8`` threshold matrix `RHOMBUS_MAT`.
"""
Rhombus(; kwargs...) = OrderedDither(RHOMBUS_MAT; max = 33, kwargs...)
const RHOMBUS_MAT = [
    14 10  6 13 19 23 27 20
    7  2  1  9 26 31 32 24
    11  3  4  5 22 30 29 28
    15  8 12 16 18 25 21 17
    19 23 27 20 14 10  6 13
    26 31 32 24  7  2  1  9
    22 30 29 28 11  3  4  5
    18 25 21 17 15  8 12 16
]
