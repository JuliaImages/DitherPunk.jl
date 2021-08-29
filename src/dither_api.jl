abstract type AbstractDither end

# Algorithms for which the user can define a custom output color palette.
# If no palette is specified, algorithms of this type will default to a binary color palette
# and act similarly to algorithms of type AbstractBinaryDither.
abstract type AbstractCustomColorDither <: AbstractDither end

# Algorithms whose output uses predefined sets of color, e.g. separate space dithering:
abstract type AbstractFixedColorDither <: AbstractDither end
# Algorithms which strictly do binary dithering:
abstract type AbstractBinaryDither <: AbstractFixedColorDither end

function dither!(
    out::GenericImage,
    img::GenericImage,
    alg::AbstractDither,
    args...;
    to_linear=false,
    kwargs...,
)
    if size(out) != size(img)
        throw(
            ArgumentError(
                "out and img should have the same shape, instead they are $(size(out)) and $(size(img))",
            ),
        )
    end

    if to_linear
        if img isa GenericGrayImage
            img = srgb2linear.(img)
        else
            @warn "Skipping transformation `to_linear` as it can only be applied to grayscale images."
        end
    end
    return alg(out, img, args...; kwargs...)
end

function dither!(img::GenericImage, alg::AbstractDither, args...; kwargs...)
    tmp = copy(img)
    return dither!(img, tmp, alg, args...; kwargs...)
end

function dither(::Type{T}, img, alg::AbstractDither, args...; kwargs...) where {T}
    out = similar(Array{T}, axes(img))
    dither!(out, img, alg, args...; kwargs...)
    return out
end

# Default return type for fixed color palette algs: type of input image
function dither(
    img::GenericImage{T,N}, alg::AbstractDither, args...; kwargs...
) where {T<:Pixel,N}
    return dither(T, img, alg, args...; kwargs...)
end

# Default return type for custom color palette algs: type of color scheme `cs`
function dither(
    img::GenericImage,
    alg::AbstractCustomColorDither,
    cs::AbstractVector{T},
    args...;
    kwargs...,
) where {T<:Pixel}
    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))
    return dither(T, img, alg, cs, args...; kwargs...)
end

"""
    dither!([out,] img, alg::AbstractDither, args...; kwargs...)

Dither `img` using algorithm `alg`.

# Output
If `out` is specified, it will be changed in place. Otherwise `img` will be changed in place.
"""
dither!

"""
    dither([T::Type,] img, alg::AbstractDither, args...; kwargs...)

Dither `img` using algorithm `alg`.

# Output
If no return type is specified, the default return type for binary dithering algorithms
is `Gray{Bool}`. For color algorithms, the type of the colorscheme is used.
"""
dither
