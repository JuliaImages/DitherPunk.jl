# All functions in this file end up calling `binarydither!` and don't return IndirectArrays.

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

##############
# Public API #
##############

# If `out` is specified, it will be changed in place...
function dither!(out::GenericImage, img::GenericImage, alg::AbstractDither; kwargs...)
    return _binarydither!(out, img, alg; kwargs...)
end

# ...otherwise `img` will be changed in place.
function dither!(img::GenericImage, alg::AbstractDither; kwargs...)
    tmp = copy(img)
    return _binarydither!(img, tmp, alg; kwargs...)
end

# Otherwise the return type can be chosen...
function dither(::Type{T}, img::GenericImage, alg::AbstractDither; kwargs...) where {T}
    out = similar(Array{T}, axes(img))
    return _binarydither!(out, img, alg; kwargs...)
end

# ...and defaults to the type of the input image.
function dither(img::GenericImage{T}, alg::AbstractDither; kwargs...) where {T <: ColorLike}
    return dither(T, img, alg; kwargs...)
end

#############################
# Low-level algorithm calls #
#############################

# Dispatch to binary dithering on grayscale images
# when no color palette is provided
function _binarydither!(
        out::GrayImage, img::GrayImage, alg::AbstractDither; to_linear = false, kwargs...
    )
    to_linear && (img = srgb2linear.(img))
    return binarydither!(alg, out, img; kwargs...)
end

# Dispatch to per-channel dithering on color images when no color palette is provided
function _binarydither!(
        out::GenericImage{T},
        img::GenericImage{T},
        alg::AbstractDither;
        to_linear = false,
        kwargs...,
    ) where {T <: Color{<:Real, 3}}
    to_linear && (@warn "Skipping transformation `to_linear` when dithering color images.")

    cvout = channelview(out)
    cvimg = channelview(img)
    for c in axes(cvout, 1)
        # Note: the input `out` will be modified
        # since binarydither! modifies the view of the channelview of `out`.
        binarydither!(alg, view(cvout, c, :, :), view(cvimg, c, :, :); kwargs...)
    end
    return out
end
