"""
    ErrorDiffusion{CT}(filter::AbstractMatrix; clamp_error=true)

Generalized error diffusion algorithm. When calling `dither` using a color palette `cs`,
this will iterate over pixels and round them to the closest color in `cs`.
The rounding error is then "diffused" over the neighborhood defined by the matrix `filter`.

# Example
```julia-repl
julia> alg = FloydSteinberg() # returns ErrorDiffusion instance
ErrorDiffusion{OffsetArrays.OffsetMatrix{Rational{Int64}, Matrix{Rational{Int64}}}, ColorTypes.XYZ}(Rational{Int64}[0//1 0//1 7//16; 3//16 5//16 1//16], true)

julia> cs = ColorSchemes.PuOr_7.colors; # using ColorSchemes.jl for color palette presets

julia> dither(img, alg, cs);
```

!!! note "Color Image"
    For color image, two color spaces are used when applying the algorithm: 1) the luminance
    channel in the Lab space is used to find the closest color in `cs`, and 2) the `CT`
    diffusion color space is used to propagate the error. `CT` is typically a linear
    colorspace, and the default value is `XYZ`. Another common choice is `RGB`, but strictly
    speaking, RGB is not a linear space.
"""

const _error_diffusion_kwargs = """
# Keyword arguments
- `clamp_error::Bool`: Clamp accumulated error on each pixel within limits of colorant
    type `color_space` before looking up the closest color. Defaults to `true`.
"""

struct ErrorDiffusion{C,F<:AbstractMatrix} <: AbstractDither
    filter::F
    clamp_error::Bool
end
ErrorDiffusion{C}(filter; clamp_error=true) where C = ErrorDiffusion{float32(C), typeof(filter)}(filter, clamp_error)

function binarydither!(alg::ErrorDiffusion, out::GenericGrayImage, img::GenericGrayImage)
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)

    # Change from normalized intensities to Float as error will get added!
    # eagerly promote to the same type to make loop run faster
    FT = floattype(eltype(img))
    img = FT.(img)
    filter = eltype(FT).(alg.filter)

    drs = axes(alg.filter, 1)
    dcs = axes(alg.filter, 2)

    FT0, FT1 = FT(0), FT(1)

    @inbounds for r in axes(img, 1)
        for c in axes(img, 2)
            px = img[r, c]
            alg.clamp_error && (px = clamp01(px))

            px >= 0.5 ? (col = FT1) : (col = FT0) # round to closest color
            out[r, c] = col # apply pixel to dither
            err = px - col  # diffuse "error" to neighborhood in filter

            for dr in drs
                for dc in dcs
                    if (r + dr) in axes(img, 1) && (c + dc) in axes(img, 2)
                        img[r + dr, c + dc] += err * filter[dr, dc]
                    end
                end
            end
        end
    end

    return out
end

function colordither(
    alg::ErrorDiffusion{C},
    img::GenericImage,
    cs::AbstractVector{<:Pixel},
    metric::DifferenceMetric,
) where {C}
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
    filter = FT.(alg.filter)

    drs = axes(alg.filter, 1)
    dcs = axes(alg.filter, 2)

    @inbounds for r in axes(img, 1)
        for c in axes(img, 2)
            px = img[r, c]
            alg.clamp_error && (px = clamp_limits(px))

            colorindex = _closest_color_idx(px, cs_lab, metric)
            index[r, c] = colorindex
            err = px - cs_err[colorindex]  # diffuse "error" to neighborhood in filter

            for dr in drs
                for dc in dcs
                    if (r + dr) in axes(img, 1) && (c + dc) in axes(img, 2)
                        img[r + dr, c + dc] += err * filter[dr, dc]
                    end
                end
            end
        end
    end
    return index
end

"""
    SimpleErrorDiffusion(color_space=XYZ)

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
SimpleErrorDiffusion(CT=XYZ) = ErrorDiffusion{CT}(_simple_filter)
const _simple_filter = OffsetMatrix([0 1; 1 0]//2, 0:1, 0:1)

"""
    FloydSteinberg(color_space=XYZ; kwargs...)

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
FloydSteinberg(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_floydsteinberg_filter; kwargs...)
const _floydsteinberg_filter = OffsetMatrix([0 0 7; 3 5 1]//16,0:1,-1:1)

"""
    JarvisJudice(color_space=XYZ; kwargs...)

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
JarvisJudice(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_jarvisjudice_filter; kwargs...)
const _jarvisjudice_filter = OffsetMatrix([0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48, 0:2, -2:2)

"""
    Stucki(color_space=XYZ; kwargs...)

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
Stucki(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_stucki_filter; kwargs...)
const _stucki_filter = OffsetMatrix([0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42, 0:2, -2:2)

"""
    Burkes(color_space=XYZ; kwargs...)

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
Burkes(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_burkes_filter; kwargs...)
const _burkes_filter = OffsetMatrix([0 0 0 8 4; 2 4 8 4 2]//32, 0:1, -2:2)

"""
    Sierra(color_space=XYZ; kwargs...)

Error diffusion algorithm using the filter
```
        *   5   3
2   4   5   4   2
    2   3   2       (1//32)
```
Also known as Sierra3 or three-row Sierra due to the filter shape.


$(_error_diffusion_kwargs)
"""
Sierra(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_sierra_filter; kwargs...)
const _sierra_filter = OffsetMatrix([0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32, 0:2, -2:2)

"""
    TwoRowSierra(color_space=XYZ; kwargs...)

Error diffusion algorithm using the filter
```
        *   4   3
1   2   3   2   1   (1//16)
```
Also known as Sierra2.

$(_error_diffusion_kwargs)
"""
TwoRowSierra(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_tworowsierra_filter; kwargs...)
const _tworowsierra_filter = OffsetMatrix([0 0 0 4 3; 1 2 3 2 1]//16, 0:1, -2:2)

"""
    SierraLite(color_space=XYZ; kwargs...)

Error diffusion algorithm using the filter
```
    *   2
1   1               (1//4)
```
Also known as Sierra-2-4A filter.

$(_error_diffusion_kwargs)
"""
SierraLite(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_sierralite_filter; kwargs...)
const _sierralite_filter = OffsetMatrix([0 0 2; 1 1 0]//4, 0:1, -1:1)

"""
    Atkinson(color_space=XYZ; kwargs...)

Error diffusion algorithm using the filter
```
    *   1   1
1   1   1
    1               (1//8)
```

$(_error_diffusion_kwargs)
"""
Atkinson(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_atkinson_filter; kwargs...)
const _atkinson_filter = OffsetMatrix([0 0 1 1; 1 1 1 0; 0 1 0 0]//8, 0:2, -1:2)

"""
    Fan93(color_space=XYZ; kwargs...)

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
Fan93(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_fan93_filter; kwargs...)
const _fan93_filter = OffsetMatrix([0 0 0 7; 1 3 5 0]//16, 0:1, -2:1)

"""
    ShiauFan(color_space=XYZ; kwargs...)

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
ShiauFan(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_shiaufan_filter; kwargs...)
const _shiaufan_filter = OffsetMatrix([0 0 0 4; 1 1 2 0]//8, 0:1, -2:1)

"""
    ShiauFan2(color_space=XYZ; kwargs...)

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
ShiauFan2(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_shiaufan2_filter; kwargs...)
const _shiaufan2_filter = OffsetMatrix([0 0 0 0 8; 1 1 2 4 0]//16, 0:1, -3:1)

"""
    FalseFloydSteinberg(color_space=XYZ; kwargs...)

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
FalseFloydSteinberg(CT=XYZ; kwargs...) = ErrorDiffusion{CT}(_falsefloydsteinberg_filter; kwargs...)
const _falsefloydsteinberg_filter = OffsetMatrix([0 3; 3 2]//8, 0:1, 0:1)
