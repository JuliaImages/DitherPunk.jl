abstract type AbstractDither end

# Algorithms for which the user can define a custom output color palette.
# If no palette is specified, algorithms of this type will default to a binary color palette
# and act similarly to algorithms of type AbstractBinaryDither.
abstract type AbstractCustomColorDither <: AbstractDither end

# Algorithms whose output uses predefined sets of color, e.g. separate space dithering:
abstract type AbstractFixedColorDither <: AbstractDither end
# Algorithms which strictly do binary dithering:
abstract type AbstractBinaryDither <: AbstractFixedColorDither end

####################
# Low-level checks #
####################

# Lowest-level call that dispatches to the algorithms
function __dither!(
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

# Before `__dither!` is called, additional checks and defaults are run for AbstractCustomColorDither...
function _dither!(
    out::GenericImage,
    img::GenericImage,
    alg::AbstractCustomColorDither,
    cs::AbstractVector{<:Pixel},
    args...;
    metric::DifferenceMetric=DE_2000(),
    kwargs...,
)
    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))
    return __dither!(out, img, alg, cs, metric, args...; kwargs...)
end
# ...that get skipped for AbstractBinaryDither & AbstractFixedColorDither.
_dither!(args...; kwargs...) = __dither!(args...; kwargs...)

##############
# Public API #
##############

# If `out` is specified, it will be changed in place...
function dither!(
    out::GenericImage, img::GenericImage, alg::AbstractDither, args...; kwargs...
)
    return _dither!(out, img, alg, args...; kwargs...)
end

# ...otherwise `img` will be changed in place.
function dither!(img::GenericImage, alg::AbstractDither, args...; kwargs...)
    tmp = copy(img)
    return _dither!(img, tmp, alg, args...; kwargs...)
end


# The return type can be chosen...
function dither(
    ::Type{T}, img::GenericImage, alg::AbstractDither, args...; kwargs...
) where {T}
    out = similar(Array{T}, axes(img))
    _dither!(out, img, alg, args...; kwargs...)
    return out
end

# ...and defaults to the type of the input image.
function dither(
    img::GenericImage{T,N}, alg::AbstractDither, args...; kwargs...
) where {T<:Pixel,N}
    return dither(T, img, alg, args...; kwargs...)
end

"""
    dither!([out,] img, alg::AbstractDither, args...; kwargs...)

Dither image `img` using algorithm `alg`.

# Output
If `out` is specified, it will be changed in place. Otherwise `img` will be changed in place.
"""
dither!

"""
    dither([T::Type,] img, alg::AbstractDither, args...; kwargs...)

Dither image `img` using algorithm `alg`.

# Output
If no return type is specified, `dither` will default to the type of the input image.
"""
dither
