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

# Automate method docstrings
const _error_diffusion_kwargs = "; clamp_error=true"
const _error_diffusion_details = """
# Keyword arguments
- `clamp_error::Bool`: Clamp accumulated error on each pixel within limits of the image's
    colorant type before looking up the closest color. Defaults to `true`.
"""

struct ErrorDiffusion{I,V,R} <: AbstractDither
    inds::I # indices of filter
    vals::V # values of filter
    ranges::Tuple{R,R} # range of filter: (column_range, row_range)
    clamp_error::Bool
end
function ErrorDiffusion(inds, vals, ranges, clamp_error)
    length(inds) != length(vals) &&
        throw(ArgumentError("Lengths of filter indices and values don't match."))
    return ErrorDiffusion{typeof(inds),typeof(vals),typeof(first(ranges))}(
        inds, vals, ranges, clamp_error
    )
end
function ErrorDiffusion(filter::AbstractMatrix, offset::Integer; clamp_error=true)
    require_one_based_indexing(filter)
    filter = transpose(filter)
    CI = CartesianIndices(filter) .- CartesianIndex(offset, 1)
    mask = .!iszero.(filter) # only keep non-zero values
    return ErrorDiffusion(CI[mask], filter[mask], CI.indices, clamp_error)
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
    Inner = inner_range(img, alg) # domain in which boundschecks can be skipped

    @inbounds for I in CartesianIndices(img)
        px = img[I]
        alg.clamp_error && (px = clamp01(px))
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

function colordither(
    alg::ErrorDiffusion,
    img::GenericImage,
    cs::AbstractVector{<:Pixel},
    metric::DifferenceMetric,
)
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)
    index = Matrix{Int}(undef, size(img)...) # allocate matrix of color indices
    Inner = inner_range(img, alg) # domain in which boundschecks can be skipped

    # Change from normalized intensities to Float as error will get added!
    # Eagerly promote to the same type to make loop run faster.
    img = convert.(floattype(eltype(img)), img)
    FT = floattype(eltype(eltype(img))) # type of Float
    cs_err = convert.(eltype(img), cs)
    cs_lab = Lab.(cs)
    vals = convert.(FT, alg.vals)

    @inbounds for I in CartesianIndices(img)
        px = img[I]
        alg.clamp_error && (px = clamp_limits(px))
        index[I] = _closest_color_idx(px, cs_lab, metric)

        # Diffuse "error" to neighborhood in filter
        err = px - cs_err[index[I]]  # diffuse "error" to neighborhood in filter
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
    return index
end

"""
    SimpleErrorDiffusion($_error_diffusion_kwargs)

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
function SimpleErrorDiffusion(; kwargs...)
    return ErrorDiffusion(SIMPLE_ERROR_DIFFUSION, 1; kwargs...)
end
const SIMPLE_ERROR_DIFFUSION = [0 1; 1 0]//2

"""
    FloydSteinberg($_error_diffusion_kwargs)

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
FloydSteinberg(; kwargs...) = ErrorDiffusion(FLOYD_STEINBERG, 2; kwargs...)
const FLOYD_STEINBERG = [0 0 7; 3 5 1]//16

"""
    JarvisJudice($_error_diffusion_kwargs)

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
JarvisJudice(; kwargs...) = ErrorDiffusion(JARVIS_JUDICE, 3; kwargs...)
const JARVIS_JUDICE = [0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48

"""
    Stucki($_error_diffusion_kwargs)

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
Stucki(; kwargs...) = ErrorDiffusion(STUCKI, 3; kwargs...)
const STUCKI = [0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42

"""
    Burkes($_error_diffusion_kwargs)

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
Burkes(; kwargs...) = ErrorDiffusion(BURKES, 3; kwargs...)
const BURKES = [0 0 0 8 4; 2 4 8 4 2]//32

"""
    Sierra($_error_diffusion_kwargs)

Error diffusion algorithm using the filter
```
        *   5   3
2   4   5   4   2
    2   3   2       (1//32)
```
Also known as Sierra3 or three-row Sierra due to the filter shape.


$(_error_diffusion_details)
"""
Sierra(; kwargs...) = ErrorDiffusion(SIERRA, 3; kwargs...)
const SIERRA = [0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32

"""
    TwoRowSierra($_error_diffusion_kwargs)

Error diffusion algorithm using the filter
```
        *   4   3
1   2   3   2   1   (1//16)
```
Also known as Sierra2.

$(_error_diffusion_details)
"""
TwoRowSierra(; kwargs...) = ErrorDiffusion(TWO_ROW_SIERRA, 3; kwargs...)
const TWO_ROW_SIERRA = [0 0 0 4 3; 1 2 3 2 1]//16

"""
    SierraLite($_error_diffusion_kwargs)

Error diffusion algorithm using the filter
```
    *   2
1   1               (1//4)
```
Also known as Sierra-2-4A filter.

$(_error_diffusion_details)
"""
SierraLite(; kwargs...) = ErrorDiffusion(SIERRA_LITE, 2; kwargs...)
const SIERRA_LITE = [0 0 2; 1 1 0]//4

"""
    Atkinson($_error_diffusion_kwargs)

Error diffusion algorithm using the filter
```
    *   1   1
1   1   1
    1               (1//8)
```

$(_error_diffusion_details)
"""
Atkinson(; kwargs...) = ErrorDiffusion(ATKINSON, 2; kwargs...)
const ATKINSON = [0 0 1 1; 1 1 1 0; 0 1 0 0]//8

"""
    Fan93($_error_diffusion_kwargs)

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
Fan93(; kwargs...) = ErrorDiffusion(FAN_93, 3; kwargs...)
const FAN_93 = [0 0 0 7; 1 3 5 0]//16

"""
    ShiauFan($_error_diffusion_kwargs)

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
ShiauFan(; kwargs...) = ErrorDiffusion(SHIAU_FAN, 3; kwargs...)
const SHIAU_FAN = [0 0 0 4; 1 1 2 0]//8

"""
    ShiauFan2($_error_diffusion_kwargs)

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
ShiauFan2(; kwargs...) = ErrorDiffusion(SHIAU_FAN_2, 4; kwargs...)
const SHIAU_FAN_2 = [0 0 0 0 8; 1 1 2 4 0]//16

"""
    FalseFloydSteinberg($_error_diffusion_kwargs)

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
function FalseFloydSteinberg(; kwargs...)
    return ErrorDiffusion(FALSE_FLOYD_STEINBERG, 1; kwargs...)
end
const FALSE_FLOYD_STEINBERG = [0 3; 3 2]//8
