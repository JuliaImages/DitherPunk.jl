struct ErrorDiffusion{AT<:AbstractArray} <: AbstractDither
    stencil::AT
end

"""
Error diffusion for general color schemes `cs`.
"""
function dither(
    img::AbstractMatrix{T},
    alg::ErrorDiffusion,
    cs::Vector{<:Colorant};
    to_linear=false,
    metric::DifferenceMetric=DE_2000(),
)::Matrix{T} where {T<:Color}
    # this function does not yet support OffsetArray
    require_one_based_indexing(img)

    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))

    # Change from normalized intensities to Float as error will get added!
    FT = floattype(T)
    if to_linear
        _img = @. FT(srgb2linear(img))
    else
        _img = FT.(img)
    end

    # eagerly promote to the same type to make loop run faster
    stencil = eltype(FT).(alg.stencil)

    h, w = size(_img)
    dither = zeros(FT, h, w) # initialized to zero

    drs = axes(alg.stencil, 1)
    dcs = axes(alg.stencil, 2)

    @inbounds for r in 1:h
        for c in 1:w
            px = _img[r, c]

            # Round to closest color
            col = closest_color(px, cs; metric=metric)

            # Apply pixel to dither
            dither[r, c] = col

            # Diffuse "error" to neighborhood in stencil
            err = px - col
            for dr in drs
                for dc in dcs
                    if (r + dr > 0) && (r + dr <= h) && (c + dc > 0) && (c + dc <= w)
                        _img[r + dr, c + dc] += err * stencil[dr, dc]
                    end
                end
            end
        end
    end

    return dither
end

function dither(
    img::AbstractMatrix{T}, alg::ErrorDiffusion, cs::ColorScheme; kwargs...
)::AbstractMatrix{T} where {T<:Color}
    return dither(img, alg, cs.colors; kwargs...)
end

"""
Binary error diffusion.
"""
function dither(
    img::AbstractMatrix{<:AbstractGray},
    alg::ErrorDiffusion;
    metric=BinaryDitherMetric(),
    kwargs...,
)::Matrix{Gray{Bool}}
    cs = [Gray(false), Gray(true)] # b&w color scheme
    d = dither(img, alg, cs; metric=metric, kwargs...)
    return d
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
