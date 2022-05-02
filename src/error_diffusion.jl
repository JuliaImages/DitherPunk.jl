"""
    ErrorDiffusion(filter, offset; clamp_error=true)

Generalized error diffusion algorithm. When calling `dither` using a color palette `cs`,
this will iterate over pixels and round them to the closest color in `cs`.
The rounding error is then "diffused" over the neighborhood defined by the matrix `filter`
centered around an integer `offset`.

# Example
```julia-repl
julia> alg = FloydSteinberg() # returns ErrorDiffusion instance
ErrorDiffusion{OffsetArrays.OffsetMatrix{Rational{Int64}, Matrix{Rational{Int64}}}, ColorTypes.XYZ}(Rational{Int64}[0//1 0//1 7//16; 3//16 5//16 1//16], true)

julia> cs = ColorSchemes.PuOr_7.colors; # using ColorSchemes.jl for color palette presets

julia> dither(img, alg, cs);
```
"""

_error_diffusion_kwargs = """
# Keyword arguments
- `color_space`: Color space in which the error is diffused.
    Only used when dithering with a color palette. Defaults to `XYZ`.
    To replicate the output of other dithering libraries, set this to `RGB`.
- `clamp_error::Bool`: Clamp accumulated error on each pixel within limits of colorant
    type `color_space` before looking up the closest color. Defaults to `true`.
"""

struct ErrorDiffusion{F,C} <: AbstractDither
    filter::F
    clamp_error::Bool
end
function ErrorDiffusion(
    mat::AbstractMatrix, offset::Integer; color_space=XYZ, clamp_error=true
)
    CI = CartesianIndices(mat) .- CartesianIndex(1, offset)
    filter = [I => val for (I, val) in zip(CI, mat) if !iszero(val)]
    return ErrorDiffusion{typeof(filter),float32(color_space)}(filter, clamp_error)
end

function binarydither!(alg::ErrorDiffusion, out::GenericGrayImage, img::GenericGrayImage)
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)

    # Change from normalized intensities to Float as error will get added!
    # eagerly promote to the same type to make loop run faster
    FT = floattype(eltype(img))
    img = FT.(img)
    filter = [I => eltype(FT)(val) for (I, val) in alg.filter]
    R = CartesianIndices(img)

    FT0, FT1 = FT(0), FT(1)

    @inbounds for r in axes(img, 1)
        for c in axes(img, 2)
            I = CartesianIndex(r, c)
            px = img[I]
            alg.clamp_error && (px = clamp01(px))

            px >= 0.5 ? (col = FT1) : (col = FT0) # round to closest color
            out[I] = col # apply pixel to dither
            err = px - col  # diffuse "error" to neighborhood in filter

            for (DI, val) in filter
                N = I + DI # index of neighbor
                if N in R
                    img[N] += err * val
                end
            end
        end
    end

    return out
end

function colordither(
    alg::ErrorDiffusion{F,C},
    img::GenericImage,
    cs::AbstractVector{<:Pixel},
    metric::DifferenceMetric,
) where {F,C}
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)
    index = Matrix{UInt8}(undef, size(img)...) # allocate matrix of color indices

    # C is the `color_space` in which the error is diffused
    img = convert.(C, img)
    cs_err = C.(cs)
    cs_lab = Lab.(cs)

    # Change from normalized intensities to Float as error will get added!
    # Eagerly promote to the same type to make loop run faster.
    FT = floattype(eltype(eltype(img))) # type of Float
    filter = [I => FT(val) for (I, val) in alg.filter]
    R = CartesianIndices(img)

    @inbounds for r in axes(img, 1)
        for c in axes(img, 2)
            I = CartesianIndex(r, c)
            px = img[I]
            alg.clamp_error && (px = clamp_limits(px))

            colorindex = _closest_color_idx(px, cs_lab, metric)
            index[I] = colorindex
            err = px - cs_err[colorindex]  # diffuse "error" to neighborhood in filter

            for (DI, val) in filter
                N = I + DI # index of neighbor
                if N in R
                    img[N] += err * val
                end
            end
        end
    end
    return index
end

"""
    SimpleErrorDiffusion()

Error diffusion algorithm using the filter
```
*   1
1   0         (1//2)
```

$(_error_diffusion_kwargs)

# References
[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
SimpleErrorDiffusion(; kwargs...) = ErrorDiffusion(SIMPLE_ERROR_DIFFUSION, 1; kwargs...)
const SIMPLE_ERROR_DIFFUSION = [0 1; 1 0]//2

"""
    FloydSteinberg()

Error diffusion algorithm using the filter
```
    *   7
3   5   1     (1//16)
```

$(_error_diffusion_kwargs)

# References
[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
FloydSteinberg(; kwargs...) = ErrorDiffusion(FLOYD_STEINBERG, 2; kwargs...)
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

$(_error_diffusion_kwargs)

# References
[1]  Jarvis, J.F., C.N. Judice, and W.H. Ninke, "A Survey of Techniques for
     the Display of Continuous Tone Pictures on Bi-Level Displays," Computer
     Graphics and Image Processing, vol. 5, pp. 13-40, 1976.
"""
JarvisJudice(; kwargs...) = ErrorDiffusion(JARVIS_JUDICE, 3; kwargs...)
const JARVIS_JUDICE = [0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48

"""
    Stucki()

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

$(_error_diffusion_kwargs)

# References
[1]  Stucki, P., "MECCA - a multiple-error correcting computation algorithm
     for bilevel image hardcopy reproduction."  Research Report RZ1060, IBM
     Research Laboratory, Zurich, Switzerland, 1981.
"""
Stucki(; kwargs...) = ErrorDiffusion(STUCKI, 3; kwargs...)
const STUCKI = [0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42

"""
    Burkes()

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

$(_error_diffusion_kwargs)

# References
[1] Burkes, D., "Presentation of the Burkes error filter for use in preparing
    continuous-tone images for presentation on bi-level devices." Unpublished, 1988.
"""
Burkes(; kwargs...) = ErrorDiffusion(BURKES, 3; kwargs...)
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


$(_error_diffusion_kwargs)
"""
Sierra(; kwargs...) = ErrorDiffusion(SIERRA, 3; kwargs...)
const SIERRA = [0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32

"""
    TwoRowSierra()

Error diffusion algorithm using the filter
```
        *   4   3
1   2   3   2   1   (1//16)
```
Also known as Sierra2.

$(_error_diffusion_kwargs)
"""
TwoRowSierra(; kwargs...) = ErrorDiffusion(TWO_ROW_SIERRA, 3; kwargs...)
const TWO_ROW_SIERRA = [0 0 0 4 3; 1 2 3 2 1]//16

"""
    SierraLite()

Error diffusion algorithm using the filter
```
    *   2
1   1               (1//4)
```
Also known as Sierra-2-4A filter.

$(_error_diffusion_kwargs)
"""
SierraLite(; kwargs...) = ErrorDiffusion(SIERRA_LITE, 2; kwargs...)
const SIERRA_LITE = [0 0 2; 1 1 0]//4

"""
    Atkinson()

Error diffusion algorithm using the filter
```
    *   1   1
1   1   1
    1               (1//8)
```

$(_error_diffusion_kwargs)
"""
Atkinson(; kwargs...) = ErrorDiffusion(ATKINSON, 2; kwargs...)
const ATKINSON = [0 0 1 1; 1 1 1 0; 0 1 0 0]//8

"""
    Fan93()

Error diffusion algorithm using the filter
```
      *  7
1  3  5            (1//16)
```
A modification of the weights used in the Floyd-Steinberg algorithm.

$(_error_diffusion_kwargs)

# References
[1] Z. Fan, "A Simple Modification of Error Diffusion Weights",
    IS&T's 46th Annual Conference, May 9-14, 1993, Final Program and Advanced Printing of
    Paper Summaries, pp 113-115 (1993).
"""
Fan93(; kwargs...) = ErrorDiffusion(FAN_93, 3; kwargs...)
const FAN_93 = [0 0 0 7; 1 3 5 0]//16

"""
    ShiauFan()

Error diffusion algorithm using the filter
```
        *   4
1   1   2           (1//8)
```

$(_error_diffusion_kwargs)

# References
[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
"""
ShiauFan(; kwargs...) = ErrorDiffusion(SHIAU_FAN, 3; kwargs...)
const SHIAU_FAN = [0 0 0 4; 1 1 2 0]//8

"""
    ShiauFan2()

Error diffusion algorithm using the filter
```
            *   8
1   1   2   4       (1//16)
```

$(_error_diffusion_kwargs)

# References
[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
[2]  J. N. Shiau and Z. Fan. "A set of easily implementable coefficients in error-diffusion
     with reduced worm artifacts" Color Imaging: Device-Independent Color, Color Hard Copy,
     and Graphics Arts, volume 2658, pages 222–225. SPIE, March 1996.
"""
ShiauFan2(; kwargs...) = ErrorDiffusion(SHIAU_FAN_2, 4; kwargs...)
const SHIAU_FAN_2 = [0 0 0 0 8; 1 1 2 4 0]//16

"""
    FalseFloydSteinberg()

Error diffusion algorithm using the filter
```
*   3
3   2         (1//8)
```
Occasionally, you will see this filter erroneously called the Floyd-Steinberg filter.

$(_error_diffusion_kwargs)

# Note
There is no reason to use this algorithm, which is why DitherPunk doesn't export it.

# References
[1] http://www.efg2.com/Lab/Library/ImageProcessing/DHALF.TXT
"""
FalseFloydSteinberg(; kwargs...) = ErrorDiffusion(FALSE_FLOYD_STEINBERG, 1; kwargs...)
const FALSE_FLOYD_STEINBERG = [0 3; 3 2]//8
