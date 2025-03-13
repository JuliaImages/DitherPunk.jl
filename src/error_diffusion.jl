"""
    ErrorDiffusion(filter, offset)

Generalized error diffusion algorithm. When calling `dither` using a color palette `cs`,
this will iterate over pixels and round them to the closest color in `cs`.
The rounding error is then "diffused" over the neighborhood defined by the matrix `filter`
centered around an integer `offset`.

When using `dither` or `dither!` with an ErrorDiffusion method, the keyword argument
`clamp_error` can be passed, which defaults to `true`.
When `true`, the accumulated error on each pixel is clamped within limits of the image's
colorant type before looking up the closest color.
Setting `clamp_error=false` might be desired to achieve a glitchy effect.

# Example
```julia-repl
julia> alg = FloydSteinberg() # returns ErrorDiffusion instance
ErrorDiffusion{Rational{Int64}, UnitRange{Int64}}(CartesianIndex{2}[CartesianIndex(1, 0), CartesianIndex(-1, 1), CartesianIndex(0, 1), CartesianIndex(1, 1)], Rational{Int64}[7//16, 3//16, 5//16, 1//16], (-1:1, 0:1))

julia> cs = ColorSchemes.PuOr_7  # using ColorSchemes.jl for color palette presets

julia> dither(img, alg, cs)

julia> dither(img, alg, cs; clamp_error=false)
```
"""
struct ErrorDiffusion{V<:Real,R<:AbstractUnitRange} <: AbstractDither
    inds::Vector{CartesianIndex{2}} # indices of filter
    vals::Vector{V} # values of filter
    ranges::Tuple{R,R} # range of filter: (column_range, row_range)
end
function ErrorDiffusion(inds, vals, ranges)
    length(inds) != length(vals) &&
        throw(ArgumentError("Lengths of ErrorDiffusion indices and values don't match."))
    return ErrorDiffusion{typeof(vals),typeof(ranges)}(inds, vals, ranges)
end

function ErrorDiffusion(filter::AbstractMatrix, offset::Integer)
    require_one_based_indexing(filter)
    filter = transpose(filter)
    CI = CartesianIndices(filter) .- CartesianIndex(offset, 1)
    mask = .!iszero.(filter) # only keep non-zero values
    return ErrorDiffusion(CI[mask], filter[mask], CI.indices)
end

# Returns inner range in which ED can be applied without boundschecks
function inner_range(img, alg::ErrorDiffusion)
    require_one_based_indexing(img)
    hi, wi = CartesianIndices(img).indices
    hr, wr = alg.ranges
    return CartesianIndices(
        tuple((1 - hr.start):(hi.stop - hr.stop), (1 - wr.start):(wi.stop - wr.stop))
    )
end

function binarydither!(
    alg::ErrorDiffusion, out::GrayImage, img::GrayImage; clamp_error=true
)
    # This function does not yet support OffsetArray
    require_one_based_indexing(img)

    # Change from normalized intensities to Float as error will get added!
    # Eagerly promote to the same type to make loop run faster.
    FT = floattype(eltype(img))
    img = convert.(FT, img)

    T = eltype(out)
    T0, T1 = zero(T), oneunit(T)

    vals = convert.(eltype(FT), alg.vals)
    Inner = inner_range(img, alg) # domain in which boundschecks can be skipped

    @inbounds for I in CartesianIndices(img)
        px = img[I]
        clamp_error && (px = clamp01(px))
        out[I] = ifelse(px >= 0.5, T1, T0)

        # Diffuse "error" to neighborhood in filter
        err = px - out[I]
        if I in Inner
            for i in 1:length(alg.inds)
                img[I + alg.inds[i]] += err * vals[i]
            end
        else
            for i in 1:length(alg.inds)
                N = I + alg.inds[i] # index of neighbor
                checkbounds(Bool, img, N) || continue
                img[N] += err * vals[i]
            end
        end
    end
    return out
end

function colordither!(
    out::Matrix{Int},
    alg::ErrorDiffusion,
    img::GenericImage{C},
    cs::AbstractVector{C},
    colorpicker::AbstractColorPicker{C};
    clamp_error=true,
) where {C<:ColorLike}
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)
    Inner = inner_range(img, alg) # domain in which boundschecks can be skipped

    # DitherPunk uses two different colorspaces when running Error Diffusion:
    # - one to compute the closest color: C
    # - one to diffuse the error in: E
    # This is mostly due to some color spaces like Lab being useful for 

    FT = eltype(eltype(img)) # Float type
    vals = convert.(FT, alg.vals)

    @inbounds for I in CartesianIndices(img)
        px = img[I]
        clamp_error && (px = clamp_limits(px))
        out[I] = colorpicker(px)

        # Diffuse "error" to neighborhood in filter
        err = px - cs[out[I]]  # diffuse "error" to neighborhood in filter
        if I in Inner
            for i in 1:length(alg.inds)
                img[I + alg.inds[i]] += err * vals[i]
            end
        else
            for i in 1:length(alg.inds)
                N = I + alg.inds[i] # index of neighbor
                checkbounds(Bool, img, N) || continue
                img[N] += err * vals[i]
            end
        end
    end
    return out
end

"""
    SimpleErrorDiffusion()

Error diffusion algorithm using the filter
```
*   1
1   0         (1//2)
```

# References
[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
function SimpleErrorDiffusion()
    return ErrorDiffusion(SIMPLE_ERROR_DIFFUSION, 1)
end
const SIMPLE_ERROR_DIFFUSION = [0 1; 1 0]//2

"""
    FloydSteinberg()

Error diffusion algorithm using the filter
```
    *   7
3   5   1     (1//16)
```

# References
[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
FloydSteinberg() = ErrorDiffusion(FLOYD_STEINBERG, 2)
const FLOYD_STEINBERG = [0 0 7; 3 5 1]//16

"""
    JarvisJudice()

Error diffusion algorithm using the filter
```
        *   7   5
3   5   7   5   3
1   3   5   3   1   (1//48)
```
Also known as the Jarvis, Judice, and Ninke filter.

# References
[1]  Jarvis, J.F., C.N. Judice, and W.H. Ninke, "A Survey of Techniques for
     the Display of Continuous Tone Pictures on Bi-Level Displays," Computer
     Graphics and Image Processing, vol. 5, pp. 13-40, 1976.
"""
JarvisJudice() = ErrorDiffusion(JARVIS_JUDICE, 3)
const JARVIS_JUDICE = [0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48

"""
    Stucki()

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

# References
[1]  Stucki, P., "MECCA - a multiple-error correcting computation algorithm
     for bilevel image hardcopy reproduction."  Research Report RZ1060, IBM
     Research Laboratory, Zurich, Switzerland, 1981.
"""
Stucki() = ErrorDiffusion(STUCKI, 3)
const STUCKI = [0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42

"""
    Burkes()

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

# References
[1] Burkes, D., "Presentation of the Burkes error filter for use in preparing
    continuous-tone images for presentation on bi-level devices." Unpublished, 1988.
"""
Burkes() = ErrorDiffusion(BURKES, 3)
const BURKES = [0 0 0 8 4; 2 4 8 4 2]//32

"""
    Sierra()

Error diffusion algorithm using the filter
```
        *   5   3
2   4   5   4   2
    2   3   2       (1//32)
```
Also known as Sierra3 or three-row Sierra due to the filter shape.
"""
Sierra() = ErrorDiffusion(SIERRA, 3)
const SIERRA = [0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32

"""
    TwoRowSierra()

Error diffusion algorithm using the filter
```
        *   4   3
1   2   3   2   1   (1//16)
```
Also known as Sierra2.
"""
TwoRowSierra() = ErrorDiffusion(TWO_ROW_SIERRA, 3)
const TWO_ROW_SIERRA = [0 0 0 4 3; 1 2 3 2 1]//16

"""
    SierraLite()

Error diffusion algorithm using the filter
```
    *   2
1   1               (1//4)
```
Also known as Sierra-2-4A filter.
"""
SierraLite() = ErrorDiffusion(SIERRA_LITE, 2)
const SIERRA_LITE = [0 0 2; 1 1 0]//4

"""
    Atkinson()

Error diffusion algorithm using the filter
```
    *   1   1
1   1   1
    1               (1//8)
```
"""
Atkinson() = ErrorDiffusion(ATKINSON, 2)
const ATKINSON = [0 0 1 1; 1 1 1 0; 0 1 0 0]//8

"""
    Fan93()

Error diffusion algorithm using the filter
```
      *  7
1  3  5            (1//16)
```
A modification of the weights used in the Floyd-Steinberg algorithm.

# References
[1] Z. Fan, "A Simple Modification of Error Diffusion Weights",
    IS&T's 46th Annual Conference, May 9-14, 1993, Final Program and Advanced Printing of
    Paper Summaries, pp 113-115 (1993).
"""
Fan93() = ErrorDiffusion(FAN_93, 3)
const FAN_93 = [0 0 0 7; 1 3 5 0]//16

"""
    ShiauFan()

Error diffusion algorithm using the filter
```
        *   4
1   1   2           (1//8)
```

# References
[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
"""
ShiauFan() = ErrorDiffusion(SHIAU_FAN, 3)
const SHIAU_FAN = [0 0 0 4; 1 1 2 0]//8

"""
    ShiauFan2()

Error diffusion algorithm using the filter
```
            *   8
1   1   2   4       (1//16)
```

# References
[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
[2]  J. N. Shiau and Z. Fan. "A set of easily implementable coefficients in error-diffusion
     with reduced worm artifacts" Color Imaging: Device-Independent Color, Color Hard Copy,
     and Graphics Arts, volume 2658, pages 222–225. SPIE, March 1996.
"""
ShiauFan2() = ErrorDiffusion(SHIAU_FAN_2, 4)
const SHIAU_FAN_2 = [0 0 0 0 8; 1 1 2 4 0]//16

"""
    FalseFloydSteinberg()

Error diffusion algorithm using the filter
```
*   3
3   2         (1//8)
```
Occasionally, you will see this filter erroneously called the Floyd-Steinberg filter.

# Note
There is no reason to use this algorithm, which is why DitherPunk doesn't export it.

# References
[1] http://www.efg2.com/Lab/Library/ImageProcessing/DHALF.TXT
"""
function FalseFloydSteinberg()
    return ErrorDiffusion(FALSE_FLOYD_STEINBERG, 1)
end
const FALSE_FLOYD_STEINBERG = [0 3; 3 2]//8
