struct ErrorDiffusion{S,RR,CR} <: AbstractDither
    stencil::S
    rowrange::RR
    colrange::CR

    function ErrorDiffusion(stencil, rowrange, colrange)
        stencil = OffsetMatrix(stencil, rowrange, colrange)
        return new{typeof(stencil),typeof(rowrange),typeof(colrange)}(
            stencil, rowrange, colrange
        )
    end
end

function dither(
    img::AbstractMatrix{T},
    alg::ErrorDiffusion,
    cs::ColorScheme;
    to_linear=false,
    metric::DifferenceMetric=DE_2000(),
)::AbstractMatrix{T} where {T<:Color}
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
    stencil = alg.stencil # eagerly promote to the same type to make loop run faster

    h, w = size(_img)
    dither = zeros(FT, h, w) # initialized to zero

    @inbounds for r in 1:h
        for c in 1:w
            px = _img[r, c]

            # Round to closest color
            col = closest_color(px, cs; metric)

            # Apply pixel to dither
            dither[r, c] = col

            # Diffuse "error" to neighborhood in stencil
            err = px - col
            for dr in alg.rowrange
                for dc in alg.colrange
                    if (r + dr > 0) && (r + dr <= h) && (c + dc > 0) && (c + dc <= w)
                        _img[r + dr, c + dc] += err * stencil[dr, dc]
                    end
                end
            end
        end
    end

    return dither
end

"""
Define custom color difference metric with linear distances between grayscale values.
"""
struct BinaryDitherMetric <: DifferenceMetric end

function ImageCore.Colors._colordiff(a::Color, b::Color, m::BinaryDitherMetric)
    return abs(a - b)
end

function dither(
    img::AbstractMatrix{<:AbstractGray},
    alg::ErrorDiffusion;
    steps=2,
    metric=BinaryDitherMetric(),
    kwargs...,
)
    # Construct grayscale ColorScheme of length `steps`
    cs = ColorScheme([Gray(i) for i in range(0.0, 1.0; length=steps)])
    d = dither(img, alg, cs; metric, kwargs...)
    if steps == 2
        # match return type of other binary dithering algorithms
        return BitMatrix(d)
    end
    return d
end

SimpleErrorDiffusion() = ErrorDiffusion([0 1; 1 0]//2, 0:1, 0:1)
FloydSteinberg() = ErrorDiffusion([0 0 7; 3 5 1]//16, 0:1, -1:1)
JarvisJudice() = ErrorDiffusion([0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48, 0:2, -2:2)
Stucki() = ErrorDiffusion([0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42, 0:2, -2:2)
Burkes() = ErrorDiffusion([0 0 0 8 4; 2 4 8 4 2]//32, 0:1, -2:2)
Sierra() = ErrorDiffusion([0 0 0 5 3; 2 4 5 4 2; 0 2 3 2 0]//32, 0:2, -2:2)
TwoRowSierra() = ErrorDiffusion([0 0 0 4 3; 1 2 3 2 1]//16, 0:1, -2:2)
SierraLite() = ErrorDiffusion([0 0 2; 1 1 0]//4, 0:1, -1:1)
Atkinson() = ErrorDiffusion([0 0 1 1; 1 1 1 0; 0 1 0 0]//8, 0:2, -1:2)
