# Binary dithering and color dithering can be distinguished by the extra argument `arg`,
# which is either
#   - a color scheme (array of colors)
#   - a ColorSchemes.jl symbol
#   - the number of colors specified for color quantization
#
# All functions in this file end up calling `colordither` and return IndirectArrays.

struct ColorNotImplementedError <: Exception
    algname::String
    ColorNotImplementedError(alg::AbstractDither) = new("$alg")
end
function Base.showerror(io::IO, e::ColorNotImplementedError)
    return print(
        io, e.algname, " algorithm currently doesn't support custom color palettes."
    )
end
colordither(alg, img, cs, metric) = throw(ColorNotImplementedError(alg))

##############
# Public API #
##############

# If `out` is specified, it will be changed in place...
function dither!(out::GenericImage, img::GenericImage, alg::AbstractDither, arg; kwargs...)
    return out .= _colordither(eltype(out), img, alg, arg; kwargs...)
end

# ...otherwise `img` will be changed in place.
function dither!(img::GenericImage, alg::AbstractDither, arg; kwargs...)
    return img .= _colordither(eltype(img), img, alg, arg; kwargs...)
end

# The return type can be chosen...
function dither(::Type{T}, img::GenericImage, alg::AbstractDither, arg; kwargs...) where {T}
    return _colordither(T, img, alg, arg; kwargs...)
end

# ...and defaults to the type of the input image.
function dither(
    img::GenericImage{T,N}, alg::AbstractDither, arg; kwargs...
) where {T<:Pixel,N}
    return _colordither(T, img, alg, arg; kwargs...)
end

#############################
# Low-level algorithm calls #
#############################

# Dispatch to dithering with custom color palettes on any image type
# when color palette is provided
function _colordither(
    ::Type{T},
    img::GenericImage,
    alg::AbstractDither,
    cs::AbstractVector{<:Pixel};
    metric::DifferenceMetric=DE_2000(),
    to_linear=false,
    kwargs...,
) where {T}
    to_linear && (@warn "Skipping transformation `to_linear` when dithering in color.")
    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))

    index = colordither(alg, img, cs, metric; kwargs...)
    _cs::Vector{T} = T.(cs)
    return IndirectArray(index, _cs)
end

# A special case occurs when a grayscale output image is to be dithered in colors.
# Since this is not possible, instead the return image will be of type of the color scheme.
function _colordither(
    ::Type{T},
    img::GenericImage,
    alg::AbstractDither,
    cs::AbstractVector{<:Color{<:Any,3}};
    metric::DifferenceMetric=DE_2000(),
    to_linear=false,
    kwargs...,
) where {T<:NumberLike}
    return _colordither(
        eltype(cs), img, alg, cs; metric=metric, to_linear=to_linear, kwargs...
    )
end
