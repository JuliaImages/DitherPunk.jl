"""
    OrderedDither(mat::AbstractMatrix)

Generalized ordered dithering algorithm using a threshold map.
Takes a normalized threshold matrix `mat`.

When applying the algorithm to an image, the threshold matrix is repeatedly tiled
to match the size of the image. It is then applied as a per-pixel threshold map.
Optionally, this final threshold map can be inverted by selecting `invert_map=true`.
"""
struct OrderedDither{T<:AbstractMatrix} <: AbstractBinaryDither
    mat::T
end

function (alg::OrderedDither)(
    out::GenericGrayImage, img::GenericGrayImage; invert_map=false
)
    # eagerly promote to the same eltype to make for-loop faster
    FT = floattype(eltype(img))
    if invert_map
        mat = @. FT(1 - alg.mat)
    else
        mat = FT.(alg.mat)
    end

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
    Bayer(; level)

Ordered dithering using the Bayer matrix as a threshold matrix.
The Bayer matrix is of dimension ``2^{n+1} \\times 2^{n+1}``, where ``n`` is the `level`,
which defaults to `1`.

[1]  Bayer, B.E., "An Optimum Method for Two-Level Rendition of Continuous
     Tone Pictures," IEEE International Conference on Communications,
     Conference Records, 1973, pp. 26-11 to 26-15.
"""
function Bayer(; level=1)
    bayer = bayer_matrix(level)
    return OrderedDither(bayer//(2^(2 * level + 2)))
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
CentralWhitePoint() = OrderedDither(CENTRAL_WHITE_POINT_MAT)
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
BalancedCenteredPoint() = OrderedDither(BALANCED_CENTERED_POINT_MAT)
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
Rhombus() = OrderedDither(RHOMBUS_MAT)
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

## Ordered dithering matrices from ImageMagic
"""
    IM_checks()

ImageMagick's Checkerboard 2x2 dither
"""
IM_checks() = OrderedDither(CHECKS)
const CHECKS = [
    1 2
    2 1
]//3

## ImageMagic's Halftones - Angled 45 degrees
# Initially added to ImageMagick by Glenn Randers-Pehrson, IM v6.2.8-6,
# modified to be more symmetrical with intensity by Anthony, IM v6.2.9-7

"""
    IM_h4x4a()

ImageMagick's Halftone 4x4 - Angled 45 degrees

This pattern initially start as circles, but then forms diamond
patterns at the 50% threshold level, before forming negated circles,
as it approaches the other threshold extreme.
"""
IM_h4x4a() = OrderedDither(H4X4A)
const H4X4A = [
    4 2 7 5
    3 1 8 6
    7 5 4 2
    8 6 3 1
]//9

"""
    IM_h6x6a()

ImageMagick's Halftone 6x6 - Angled 45 degrees

This pattern initially start as circles, but then forms diamond
patterns at the 50% threshold level, before forming negated circles,
as it approaches the other threshold extreme.
"""
IM_h6x6a() = OrderedDither(H6X6A)
const H6X6A =
    [
        14 13 10 8 2 3
        16 18 12 7 1 4
        15 17 11 9 6 5
        8 2 3 14 13 10
        7 1 4 16 18 12
        9 6 5 15 17 11
    ]//19

"""
    IM_h8x8a()

ImageMagick's Halftone 8x8 - Angled 45 degrees

This pattern initially start as circles, but then forms diamond
patterns at the 50% threshold level, before forming negated circles,
as it approaches the other threshold extreme.
"""
IM_h8x8a() = OrderedDither(H8X8A)
const H8X8A =
    [
        13 7 8 14 17 21 22 18
        6 1 3 9 28 31 29 23
        5 2 4 10 27 32 30 24
        16 12 11 15 20 26 25 19
        17 21 22 18 13 7 8 14
        28 31 29 23 6 1 3 9
        27 32 30 24 5 2 4 10
        20 26 25 19 16 12 11 15
    ]//33

# ImageMagic's Halftones - Orthogonally Aligned, or Un-angled
# Initially added by Anthony Thyssen, IM v6.2.9-5 using techniques from
# "Dithering & Halftoning" by Gernot Haffmann
# http://www.fho-emden.de/~hoffmann/hilb010101.pdf

"""
    IM_h4x4o()

ImageMagick's Halftone 4x4 - Orthogonally Aligned

This pattern initially starts as circles, but then forms square
patterns at the 50% threshold level, before forming negated circles,
as it approaches the other threshold extreme.
"""
IM_h4x4o() = OrderedDither(H4X4O)
const H4X4O = [
    7 13 11 4
    12 16 14 8
    10 15 6 2
    5 9 3 1
]//17

"""
    IM_h6x6o()

ImageMagick's Halftone 6x6 - Orthogonally Aligned

This pattern initially starts as circles, but then forms square
patterns at the 50% threshold level, before forming negated circles,
as it approaches the other threshold extreme.
"""
IM_h6x6o() = OrderedDither(H6X6O)
const H6X6O =
    [
        7 17 27 14 9 4
        21 29 33 31 18 11
        24 32 36 34 25 22
        19 30 35 28 20 10
        8 15 26 16 6 2
        5 13 23 12 3 1
    ]//37

"""
    IM_h8x8o()

ImageMagick's Halftone 8x8 - Orthogonally Aligned

This pattern initially starts as circles, but then forms square
patterns at the 50% threshold level, before forming negated circles,
as it approaches the other threshold extreme.
"""
IM_h8x8o() = OrderedDither(H8X8O)
const H8X8O =
    [
        7 21 33 43 36 19 9 4
        16 27 51 55 49 29 14 11
        31 47 57 61 59 45 35 23
        41 53 60 64 62 52 40 38
        37 44 58 63 56 46 30 22
        15 28 48 54 50 26 17 10
        8 18 34 42 32 20 6 2
        5 13 25 39 24 12 3 1
    ]//65

## ImageMagic's Halftones - Orthogonally Expanding Circle Patterns
# Added by Glenn Randers-Pehrson, 4 Nov 2010, ImageMagick 6.6.5-6
"""
    IM_c5x5()

ImageMagick's Halftone 5x5 - Orthogonally Expanding Circle Patterns

Rather than producing a diamond 50% threshold pattern, these continue to generate larger
(overlapping) circles. They are more like a true halftone pattern formed by covering
a surface with either pure white or pure black circular dots.

Note:
True halftone patterns only use true circles even in areas of highly varying intensity.
Threshold dither patterns can generate distorted circles in such areas.
"""
IM_c5x5() = OrderedDither(C5X5)
const C5X5 = [
    1 21 16 15 4
    5 17 20 19 14
    6 21 25 24 12
    7 18 22 23 11
    2 8 9 10 3
]//26

"""
    IM_c6x6()

ImageMagick's Halftone 6x6 - Orthogonally Expanding Circle Patterns

Rather than producing a diamond 50% threshold pattern, these continue to generate larger
(overlapping) circles. They are more like a true halftone pattern formed by covering
a surface with either pure white or pure black circular dots.

Note:
True halftone patterns only use true circles even in areas of highly varying intensity.
Threshold dither patterns can generate distorted circles in such areas.
"""
IM_c6x6() = OrderedDither(C6X6)
const C6X6 =
    [
        1 5 14 13 12 4
        6 22 28 27 21 11
        15 29 35 34 26 20
        16 30 36 33 25 19
        7 23 31 32 24 10
        2 8 17 18 9 3
    ]//37

"""
    IM_c7x7()

ImageMagick's Halftone 7x7 - Orthogonally Expanding Circle Patterns

Rather than producing a diamond 50% threshold pattern, these continue to generate larger
(overlapping) circles. They are more like a true halftone pattern formed by covering
a surface with either pure white or pure black circular dots.

Note:
True halftone patterns only use true circles even in areas of highly varying intensity.
Threshold dither patterns can generate distorted circles in such areas.
"""
IM_c7x7() = OrderedDither(C7X7)
const C7X7 =
    [
        3 9 18 28 17 8 2
        10 24 33 39 32 23 7
        19 34 44 48 43 31 16
        25 40 45 49 47 38 27
        20 35 41 46 42 29 15
        11 21 36 37 28 22 6
        4 12 13 26 14 5 1
    ]//50
