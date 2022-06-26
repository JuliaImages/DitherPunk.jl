"""
    ErrorDiffusion(filter, offset, [colorspace=XYZ]; clamp_error=true)

Generalized error diffusion algorithm. When calling `dither` using a color palette `cs`,
this will iterate over pixels and round them to the closest color in `cs`.
The rounding error is then "diffused" over the neighborhood defined by the matrix `filter`
centered around an integer `offset`.
The error is computed in the provided `colorspace`, which defaults to `XYZ`.

# Example
```julia-repl
julia> alg = FloydSteinberg() # returns ErrorDiffusion instance
ErrorDiffusion{OffsetArrays.OffsetMatrix{Rational{Int64}, Matrix{Rational{Int64}}}, ColorTypes.XYZ}(Rational{Int64}[0//1 0//1 7//16; 3//16 5//16 1//16], true)

julia> cs = ColorSchemes.PuOr_7.colors; # using ColorSchemes.jl for color palette presets

julia> dither(img, alg, cs);
```

!!! note "Color images"
    For color images, two colorspaces are used when applying the algorithm:
    1) The `Lab` colorspace is used to find the closest color in the color scheme
        according to the provided color distance metric.
    2) The colorspace in the optional argument `colorspace=XYZ` is used to propagate the error.
        Typically a linear colorspace should be used, such as the default value of `XYZ`.
        Another common choice is `RGB`, which is most commonly used for dithering
        but strictly speaking is not a linear colorspace.
"""

# Automate method docstrings
const _error_diffusion_args = "[colorspace=XYZ]; clamp_error=true"
const _error_diffusion_details = """
# Arguments
- `colorspace`: Color space in which the error is diffused. Defaults to `XYZ`.

# Keyword arguments
- `clamp_error::Bool`: Clamp accumulated error on each pixel within limits of colorant
    of type `colorspace` before looking up the closest color. Defaults to `true`.
"""

struct ErrorDiffusion{C,I,V} <: AbstractDither
    inds::I # indices of filter
    vals::V # values of filter
    clamp_error::Bool
end
function ErrorDiffusion(colorspace, inds, vals, clamp_error)
    length(inds) != length(vals) &&
        throw(ArgumentError("Lengths of filter indices and values don't match."))
    return ErrorDiffusion{float32(colorspace),typeof(inds),typeof(vals)}(
        inds, vals, clamp_error
    )
end
function ErrorDiffusion(
    filter::AbstractMatrix, offset::Integer, colorspace=XYZ; clamp_error=true
)
    require_one_based_indexing(filter)
    CI = CartesianIndices(filter) .- CartesianIndex(1, offset)
    mask = .!iszero.(filter) # only keep non-zero values
    return ErrorDiffusion(colorspace, CI[mask], filter[mask], clamp_error)
end

function binarydither!(alg::ErrorDiffusion, out::GenericGrayImage, img::GenericGrayImage)
    # This function does not yet support OffsetArray
    require_one_based_indexing(img)

    # Change from normalized intensities to Float as error will get added!
    # Eagerly promote to the same type to make loop run faster.
    FT = floattype(eltype(img))
    img = convert.(FT, img)

    T = eltype(out)
    T0, T1 = zero(T), oneunit(T)

    vals = convert.(eltype(FT), alg.vals)

    @inbounds for r in axes(img, 1)
        for c in axes(img, 2)
            I = CartesianIndex(r, c)
            px = img[I]
            alg.clamp_error && (px = clamp01(px))

            out[I] = ifelse(px >= 0.5, T1, T0) # round to closest color
            err = px - out[I]  # diffuse "error" to neighborhood in filter
            diffuse_error!(img, err, I, alg.inds, vals)
        end
    end
    return out
end

# Diffuse error `err` in `img` around neighborhood of coordinate `I` defined by `filter`.
function diffuse_error!(img, err, I, inds, vals)
    for i in 1:length(inds)
        N = I + inds[i] # index of neighbor
        if checkbounds(Bool, img, N)
            img[N] += err * vals[i]
        end
    end
    return nothing
end

function colordither(
    alg::ErrorDiffusion{C,F},
    img::GenericImage,
    cs::AbstractVector{<:Pixel},
    metric::DifferenceMetric,
) where {C,F}
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)
    index = Matrix{Int}(undef, size(img)...) # allocate matrix of color indices

    # C is the `colorspace` in which the error is diffused
    img = convert.(C, img)
    cs_err = C.(cs)
    cs_lab = Lab.(cs)

    # Change from normalized intensities to Float as error will get added!
    # Eagerly promote to the same type to make loop run faster.
    FT = floattype(eltype(eltype(img))) # type of Float
    vals = convert.(FT, alg.vals)

    @inbounds for r in axes(img, 1)
        for c in axes(img, 2)
            I = CartesianIndex(r, c)
            px = img[I]
            alg.clamp_error && (px = clamp_limits(px))

            index[I] = _closest_color_idx(px, cs_lab, metric)
            err = px - cs_err[index[I]]  # diffuse "error" to neighborhood in filter
            diffuse_error!(img, err, I, alg.inds, vals)
        end
    end
    return index
end

"""
    SimpleErrorDiffusion($_error_diffusion_args)

Error diffusion algorithm using the filter
```
*   1
1   0         (1//2)
```

$(_error_diffusion_details)

# References
[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
function SimpleErrorDiffusion(args...; kwargs...)
    return ErrorDiffusion(SIMPLE_ERROR_DIFFUSION, 1, args...; kwargs...)
end
const SIMPLE_ERROR_DIFFUSION = [0 1; 1 0]//2

"""
    FloydSteinberg($_error_diffusion_args)

Error diffusion algorithm using the filter
```
    *   7
3   5   1     (1//16)
```

$(_error_diffusion_details)

# References
[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
FloydSteinberg(args...; kwargs...) = ErrorDiffusion(FLOYD_STEINBERG, 2, args...; kwargs...)
const FLOYD_STEINBERG = [0 0 7; 3 5 1]//16

"""
    JarvisJudice($_error_diffusion_args)

Error diffusion algorithm using the filter
```
        *   7   5
3   5   7   5   3
1   3   5   3   1   (1//48)
```
Also known as the Jarvis, Judice, and Ninke filter.

$(_error_diffusion_details)

# References
[1]  Jarvis, J.F., C.N. Judice, and W.H. Ninke, "A Survey of Techniques for
     the Display of Continuous Tone Pictures on Bi-Level Displays," Computer
     Graphics and Image Processing, vol. 5, pp. 13-40, 1976.
"""
JarvisJudice(args...; kwargs...) = ErrorDiffusion(JARVIS_JUDICE, 3, args...; kwargs...)
const JARVIS_JUDICE = [0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48

"""
    Stucki($_error_diffusion_args)

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

$(_error_diffusion_details)

# References
[1]  Stucki, P., "MECCA - a multiple-error correcting computation algorithm
     for bilevel image hardcopy reproduction."  Research Report RZ1060, IBM
     Research Laboratory, Zurich, Switzerland, 1981.
"""
Stucki(args...; kwargs...) = ErrorDiffusion(STUCKI, 3, args...; kwargs...)
const STUCKI = [0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42

"""
    Burkes($_error_diffusion_args)

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

$(_error_diffusion_details)

# References
[1] Burkes, D., "Presentation of the Burkes error filter for use in preparing
    continuous-tone images for presentation on bi-level devices." Unpublished, 1988.
"""
Burkes(args...; kwargs...) = ErrorDiffusion(BURKES, 3, args...; kwargs...)
const BURKES = [0 0 0 8 4; 2 4 8 4 2]//32

"""
    Sierra($_error_diffusion_args)

Error diffusion algorithm using the filter
```
        *   5   3
2   4   5   4   2
    2   3   2       (1//32)
```
Also known as Sierra3 or three-row Sierra due to the filter shape.


$(_error_diffusion_details)
"""
Sierra(args...; kwargs...) = ErrorDiffusion(SIERRA, 3, args...; kwargs...)
const SIERRA = [0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32

"""
    TwoRowSierra($_error_diffusion_args)

Error diffusion algorithm using the filter
```
        *   4   3
1   2   3   2   1   (1//16)
```
Also known as Sierra2.

$(_error_diffusion_details)
"""
TwoRowSierra(args...; kwargs...) = ErrorDiffusion(TWO_ROW_SIERRA, 3, args...; kwargs...)
const TWO_ROW_SIERRA = [0 0 0 4 3; 1 2 3 2 1]//16

"""
    SierraLite($_error_diffusion_args)

Error diffusion algorithm using the filter
```
    *   2
1   1               (1//4)
```
Also known as Sierra-2-4A filter.

$(_error_diffusion_details)
"""
SierraLite(args...; kwargs...) = ErrorDiffusion(SIERRA_LITE, 2, args...; kwargs...)
const SIERRA_LITE = [0 0 2; 1 1 0]//4

"""
    Atkinson($_error_diffusion_args)

Error diffusion algorithm using the filter
```
    *   1   1
1   1   1
    1               (1//8)
```

$(_error_diffusion_details)
"""
Atkinson(args...; kwargs...) = ErrorDiffusion(ATKINSON, 2, args...; kwargs...)
const ATKINSON = [0 0 1 1; 1 1 1 0; 0 1 0 0]//8

"""
    Fan93($_error_diffusion_args)

Error diffusion algorithm using the filter
```
      *  7
1  3  5            (1//16)
```
A modification of the weights used in the Floyd-Steinberg algorithm.

$(_error_diffusion_details)

# References
[1] Z. Fan, "A Simple Modification of Error Diffusion Weights",
    IS&T's 46th Annual Conference, May 9-14, 1993, Final Program and Advanced Printing of
    Paper Summaries, pp 113-115 (1993).
"""
Fan93(args...; kwargs...) = ErrorDiffusion(FAN_93, 3, args...; kwargs...)
const FAN_93 = [0 0 0 7; 1 3 5 0]//16

"""
    ShiauFan($_error_diffusion_args)

Error diffusion algorithm using the filter
```
        *   4
1   1   2           (1//8)
```

$(_error_diffusion_details)

# References
[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
"""
ShiauFan(args...; kwargs...) = ErrorDiffusion(SHIAU_FAN, 3, args...; kwargs...)
const SHIAU_FAN = [0 0 0 4; 1 1 2 0]//8

"""
    ShiauFan2($_error_diffusion_args)

Error diffusion algorithm using the filter
```
            *   8
1   1   2   4       (1//16)
```

$(_error_diffusion_details)

# References
[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
[2]  J. N. Shiau and Z. Fan. "A set of easily implementable coefficients in error-diffusion
     with reduced worm artifacts" Color Imaging: Device-Independent Color, Color Hard Copy,
     and Graphics Arts, volume 2658, pages 222–225. SPIE, March 1996.
"""
ShiauFan2(args...; kwargs...) = ErrorDiffusion(SHIAU_FAN_2, 4, args...; kwargs...)
const SHIAU_FAN_2 = [0 0 0 0 8; 1 1 2 4 0]//16

"""
    FalseFloydSteinberg($_error_diffusion_args)

Error diffusion algorithm using the filter
```
*   3
3   2         (1//8)
```
Occasionally, you will see this filter erroneously called the Floyd-Steinberg filter.

$(_error_diffusion_details)

# Note
There is no reason to use this algorithm, which is why DitherPunk doesn't export it.

# References
[1] http://www.efg2.com/Lab/Library/ImageProcessing/DHALF.TXT
"""
function FalseFloydSteinberg(args...; kwargs...)
    return ErrorDiffusion(FALSE_FLOYD_STEINBERG, 1, args...; kwargs...)
end
const FALSE_FLOYD_STEINBERG = [0 3; 3 2]//8
