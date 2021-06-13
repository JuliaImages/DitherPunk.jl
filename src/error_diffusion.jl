struct ErrorDiffusion{AT<:AbstractArray} <: AbstractColorDither
    stencil::AT
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
    stencil = eltype(FT).(alg.stencil)

    h, w = size(img)
    fill!(out, zero(eltype(out)))

    drs = axes(alg.stencil, 1)
    dcs = axes(alg.stencil, 2)

    @inbounds for r in 1:h
        for c in 1:w
            px = img[r, c]

            # Round to closest color
            col = closest_color(px, cs; metric=metric)

            # Apply pixel to dither
            out[r, c] = col

            # Diffuse "error" to neighborhood in stencil
            err = px - col
            for dr in drs
                for dc in dcs
                    if (r + dr > 0) && (r + dr <= h) && (c + dc > 0) && (c + dc <= w)
                        img[r + dr, c + dc] += err * stencil[dr, dc]
                    end
                end
            end
        end
    end

    return dither
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
FloydSteinberg() = ErrorDiffusion(OffsetMatrix([0 0 7; 3 5 1]//16, 0:1, -1:1))
function JarvisJudice()
    return ErrorDiffusion(OffsetMatrix([0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48, 0:2, -2:2))
end
Stucki() = ErrorDiffusion(OffsetMatrix([0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42, 0:2, -2:2))
Burkes() = ErrorDiffusion(OffsetMatrix([0 0 0 8 4; 2 4 8 4 2]//32, 0:1, -2:2))
Sierra() = ErrorDiffusion(OffsetMatrix([0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32, 0:2, -2:2))
TwoRowSierra() = ErrorDiffusion(OffsetMatrix([0 0 0 4 3; 1 2 3 2 1]//16, 0:1, -2:2))
SierraLite() = ErrorDiffusion(OffsetMatrix([0 0 2; 1 1 0]//4, 0:1, -1:1))
Atkinson() = ErrorDiffusion(OffsetMatrix([0 0 1 1; 1 1 1 0; 0 1 0 0]//8, 0:2, -1:2))
