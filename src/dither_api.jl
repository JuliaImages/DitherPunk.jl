abstract type AbstractDither end

# Algorithms for which the user can define a custom output color palette.
# If no palette is specified, algorithms of this type will default to a binary color palette
# and act similarly to algorithms of type AbstractBinaryDither.
abstract type AbstractCustomColorDither <: AbstractDither end

# Algorithms which strictly do binary dithering:
abstract type AbstractBinaryDither <: AbstractDither end
function (alg::AbstractBinaryDither)(out, img, cs, metric)
    return throw(
        ArgumentError("""Algorithms of type $(Base.typename(typeof(alg)))
                      currently don't support dithering in custom color palettes.""")
    )
end
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
function dither!(
    out::GenericImage, img::GenericImage, alg::AbstractDither, args...; kwargs...
)
    if size(out) != size(img)
        throw(
            ArgumentError(
                "out and img should have the same shape, instead they are $(size(out)) and $(size(img))",
            ),
        )
    end
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
    return _dither!(out, img, alg, args...; kwargs...)
end

# ...and defaults to the type of the input image.
function dither(
    img::GenericImage{T,N}, alg::AbstractDither, args...; kwargs...
) where {T<:Pixel,N}
    return dither(T, img, alg, args...; kwargs...)
end

#############################
# Low-level algorithm calls #
#############################

# Dispatch to binary dithering on grayscale images
# when no color palette is provided
function _dither!(
    out::GenericGrayImage, img::GenericGrayImage, alg::AbstractDither; to_linear=false
)
    to_linear && (img = srgb2linear.(img))
    return alg(out, img)
end

# Dispatch to per-channel dithering on color images
# when no color palette is provided
function _dither!(
    out::GenericImage{<:Color{<:Real,3},2},
    img::GenericImage{<:Color{<:Real,3},2},
    alg::AbstractDither;
    to_linear=false,
)
    to_linear && (@warn "Skipping transformation `to_linear` when dithering color images.")

    cvout = channelview(out)
    cvimg = channelview(img)
    for c in axes(cvout, 1)
        # Note: the input `out` will be modified
        # since the dithering algorithms modify the view of the channelview of `out`.
        alg(view(cvout, c, :, :), view(cvimg, c, :, :))
    end
    return out
end

# Dispatch to dithering with custom color palettes on any image type
# when color palette is provided
function _dither!(
    out::GenericImage,
    img::GenericImage,
    alg::AbstractDither,
    cs::AbstractVector{<:Pixel};
    metric::DifferenceMetric=DE_2000(),
    to_linear=false,
)
    to_linear && (@warn "Skipping transformation `to_linear` when dithering in color.")
    length(cs) >= 2 ||
        throw(DomainError(steps, "Color scheme for dither needs >= 2 colors."))
    return alg(out, img, cs, metric)
end

# A special case occurs when a grayscale output image is to be dithered in colors.
# Since this is not possible, instead the return image will be of type of the color scheme.
function _dither!(
    out::GenericGrayImage,
    img::GenericGrayImage,
    alg::AbstractDither,
    cs::AbstractVector{<:Color{<:Any,3}};
    metric::DifferenceMetric=DE_2000(),
    to_linear=false,
)
    T = eltype(cs)
    return _dither!(T.(out), T.(img), alg, cs; metric=metric, to_linear=to_linear)
end
