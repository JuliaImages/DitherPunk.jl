abstract type AbstractDither end

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

# If `out` is specified, it will be changed in place...
function dither!(img::GenericImage, alg::AbstractDither, args...; kwargs...)
    return img .= _dither(eltype(img), img, alg, args...; kwargs...)
end

# Otherwise the return type can be chosen...
function dither(
    ::Type{T}, img::GenericImage, alg::AbstractDither, args...; kwargs...
) where {T}
    return _dither(T, img, alg, args...; kwargs...)
end

# ...and defaults to the type of the input image.
function dither(
    img::GenericImage{T,N}, alg::AbstractDither, args...; kwargs...
) where {T<:Pixel,N}
    return _dither(T, img, alg, args...; kwargs...)
end

#############################
# Low-level algorithm calls #
#############################

# Dispatch to binary dithering on grayscale images
# when no color palette is provided
function _dither(
    ::Type{T}, img::GenericGrayImage, alg::AbstractDither; to_linear=false, kwargs...
) where {T}
    to_linear && (img = srgb2linear.(img))
    index = binarydither(alg, img; kwargs...)
    return IndirectArray(index, bwcolors(T))
end

# Dispatch to per-channel dithering on color images when no color palette is provided
function _dither(
    ::Type{T},
    img::GenericImage{<:Color{<:Real,3},2},
    alg::AbstractDither;
    to_linear=false,
    kwargs...,
) where {T}
    to_linear && (@warn "Skipping transformation `to_linear` when dithering color images.")

    cs = perchannelbinarycolors(T) # color scheme with binary respresentation
    index = ones(Int, size(img)...) # allocate indices

    for c in 1:3
        channelindex = binarydither(alg, view(channelview(img), c, :, :), kwargs...)
        index += 2^(3 - c) * (channelindex .- 1) # reconstruct "decimal" indices
    end

    return IndirectArray(index, cs)
end

# Dispatch to dithering with custom color palettes on any image type
# when color palette is provided
function _dither(
    ::Type{T},
    img::GenericImage,
    alg::AbstractDither,
    cs::AbstractVector{<:Pixel};
    metric::DifferenceMetric=DE_2000(),
    to_linear=false,
) where {T}
    to_linear && (@warn "Skipping transformation `to_linear` when dithering in color.")
    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))

    index = colordither(alg, img, cs, metric)
    return IndirectArray(index, T.(cs))
end

# A special case occurs when a grayscale output image is to be dithered in colors.
# Since this is not possible, instead the return image will be of type of the color scheme.
function _dither(
    ::Type{T},
    img::GenericImage,
    alg::AbstractDither,
    cs::AbstractVector{<:Color{<:Any,3}};
    metric::DifferenceMetric=DE_2000(),
    to_linear=false,
) where {T<:NumberLike}
    return _dither(eltype(cs), img, alg, cs; metric=metric, to_linear=to_linear)
end
