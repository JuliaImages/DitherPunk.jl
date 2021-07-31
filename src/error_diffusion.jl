struct ErrorDiffusion{AT<:AbstractArray} <: AbstractColorDither
    filter::AT
end

"""
Error diffusion for general color schemes `cs`.
"""
function (alg::ErrorDiffusion)(
    out::GenericImage,
    img::GenericImage,
    cs::AbstractVector{<:Colorant};
    metric::DifferenceMetric=DE_2000(),
)
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)

    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))

    # Change from normalized intensities to Float as error will get added!
    FT = floattype(eltype(out))

    # eagerly promote to the same type to make loop run faster
    img = FT.(img)
    cs = FT.(cs)
    filter = eltype(FT).(alg.filter)

    h, w = size(img)
    fill!(out, zero(eltype(out)))

    drs = axes(alg.filter, 1)
    dcs = axes(alg.filter, 2)

    @inbounds for r in 1:h
        for c in 1:w
            px = img[r, c]

            # Round to closest color
            col = closest_color(px, cs; metric=metric)

            # Apply pixel to dither
            out[r, c] = col

            # Diffuse "error" to neighborhood in filter
            err = px - col
            for dr in drs
                for dc in dcs
                    if (r + dr > 0) && (r + dr <= h) && (c + dc > 0) && (c + dc <= w)
                        img[r + dr, c + dc] += err * filter[dr, dc]
                    end
                end
            end
        end
    end

    return out
end

"""
Binary error diffusion.
"""
function (alg::ErrorDiffusion)(
    out::GenericGrayImage, img::GenericGrayImage; metric=BinaryDitherMetric()
)
    cs = [Gray(false), Gray(true)] # b&w color scheme
    alg(out, img, cs; metric=metric)
    return out
end

SimpleErrorDiffusion() = ErrorDiffusion(OffsetMatrix([0 1; 1 0]//2, 0:1, 0:1))

"""
    FloydSteinberg()

Error diffusion algorithm using the filter
```
    *   7
3   5   1     (1//16)
```

[1]  Floyd, R.W. and L. Steinberg, "An Adaptive Algorithm for Spatial Gray
     Scale."  SID 1975, International Symposium Digest of Technical Papers,
     vol 1975m, pp. 36-37.
"""
FloydSteinberg() = ErrorDiffusion(OffsetMatrix([0 0 7; 3 5 1]//16, 0:1, -1:1))

"""
    JarvisJudice()

Error diffusion algorithm using the filter
```
        *   7   5
3   5   7   5   3
1   3   5   3   1   (1//48)
```
Also known as the Jarvis, Judice, and Ninke filter.

[1]  Jarvis, J.F., C.N. Judice, and W.H. Ninke, "A Survey of Techniques for
     the Display of Continuous Tone Pictures on Bi-Level Displays," Computer
     Graphics and Image Processing, vol. 5, pp. 13-40, 1976.
"""
function JarvisJudice()
    return ErrorDiffusion(OffsetMatrix([0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48, 0:2, -2:2))
end

"""
    Stucki()

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

[1]  Stucki, P., "MECCA - a multiple-error correcting computation algorithm
     for bilevel image hardcopy reproduction."  Research Report RZ1060, IBM
     Research Laboratory, Zurich, Switzerland, 1981.
"""
Stucki() = ErrorDiffusion(OffsetMatrix([0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42, 0:2, -2:2))

"""
    Burkes()

Error diffusion algorithm using the filter
```
        *   8   4
2   4   8   4   2
1   2   4   2   1   (1//42)
```

[1] Burkes, D., "Presentation of the Burkes error filter for use in preparing
    continuous-tone images for presentation on bi-level devices." Unpublished, 1988.
"""
Burkes() = ErrorDiffusion(OffsetMatrix([0 0 0 8 4; 2 4 8 4 2]//32, 0:1, -2:2))

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
Sierra() = ErrorDiffusion(OffsetMatrix([0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32, 0:2, -2:2))

"""
    TwoRowSierra()

Error diffusion algorithm using the filter
```
        *   4   3
1   2   3   2   1   (1//16)
```
Also known as Sierra2.
"""
TwoRowSierra() = ErrorDiffusion(OffsetMatrix([0 0 0 4 3; 1 2 3 2 1]//16, 0:1, -2:2))

"""
    SierraLite()

Error diffusion algorithm using the filter
```
    *   2
1   1               (1//4)
```
Also known as Sierra-2-4A filter.
"""
SierraLite() = ErrorDiffusion(OffsetMatrix([0 0 2; 1 1 0]//4, 0:1, -1:1))

"""
    Atkinson()

Error diffusion algorithm using the filter
```
    *   1   1
1   1   1
    1               (1//8)
```
"""
Atkinson() = ErrorDiffusion(OffsetMatrix([0 0 1 1; 1 1 1 0; 0 1 0 0]//8, 0:2, -1:2))

"""
    Fan()

Error diffusion algorithm using the filter
```
      *  7
1  3  5            (1//16)
```
A modification of the weights used in the Floyd-Steinberg algorithm.

[1] Z. Fan, "A Simple Modification of Error Diffusion Weights",
    IS&T's 46th Annual Conference, May 9-14, 1993, Final Program and Advanced Printing of
    Paper Summaries, pp 113-115 (1993).
"""
Fan() = ErrorDiffusion(OffsetMatrix([0 0 0 7; 1 3 5 0]//16, 0:1, -2:1))

"""
    ShiauFan()

Error diffusion algorithm using the filter
```
        *   4
1   1   2           (1//8)
```

[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
"""
ShiauFan() = ErrorDiffusion(OffsetMatrix([0 0 0 4; 1 1 2 0]//8, 0:1, -2:1))

"""
    ShiauFan2()

Error diffusion algorithm using the filter
```
            *   8
1   1   2   4       (1//16)
```

[1]  J. N. Shiau and Z. Fan. "Method for quantization gray level pixel data with extended
     distribution set", US 5353127A, United States Patent and Trademark Office, Oct. 4, 1993
[2]  J. N. Shiau and Z. Fan. "A set of easily implementable coefficients in error-diffusion
     with reduced worm artifacts" Color Imaging: Device-Independent Color, Color Hard Copy,
     and Graphics Arts, volume 2658, pages 222–225. SPIE, March 1996.
"""
ShiauFan2() = ErrorDiffusion(OffsetMatrix([0 0 0 0 8; 1 1 2 4 0]//16, 0:1, -3:1))

"""
    FalseFloydSteinberg()

Error diffusion algorithm using the filter
```
*   3
3   2         (1//16)
```
Occasionally, you will see this filter erroneously called the Floyd-Steinberg filter.

# Note
There is no reason to use this algorithm, which is why DitherPunk doesn't export it.

[1] http://www.efg2.com/Lab/Library/ImageProcessing/DHALF.TXT
"""
FalseFloydSteinberg() = ErrorDiffusion(OffsetMatrix([0 3; 3 2]//8, 0:1, 0:1))
