const DEFAULT_METRIC = DE_2000()
select_colorpicker(::AbstractDither, colors) = RuntimeColorPicker(colors, DEFAULT_METRIC)

# Binary dithering and color dithering can be distinguished by the extra argument `arg`,
# which is either
#   - a color scheme (array of colors)
#   - a ColorSchemes.jl symbol
#   - the number of colors specified for color quantization
#
# All functions in this file end up calling `colordither!` and return IndirectArrays.

#============#
# Public API #
#============#

# If `out` is specified, it will be changed in place...
function dither!(out::GenericImage, img::GenericImage, alg::AbstractDither, arg; kwargs...)
    return out .= colordither(eltype(out), img, alg, arg; kwargs...)
end

# ...otherwise `img` will be changed in place.
function dither!(img::GenericImage, alg::AbstractDither, arg; kwargs...)
    return img .= colordither(eltype(img), img, alg, arg; kwargs...)
end

# The return type can be chosen...
function dither(::Type{T}, img::GenericImage, alg::AbstractDither, arg; kwargs...) where {T}
    return colordither(T, img, alg, arg; kwargs...)
end

# ...and defaults to the type of the input image.
function dither(
    img::GenericImage{T}, alg::AbstractDither, arg; kwargs...
) where {T <: ColorLike}
    return colordither(T, img, alg, arg; kwargs...)
end

#===========================#
# Low-level algorithm calls #
#===========================#

# Dispatch to dithering with custom color palettes on any image type
# when color palette is provided
function colordither(
    ::Type{T},
    img::GenericImage,
    alg::AbstractDither,
    colorscheme::AbstractVector{<:ColorLike};
    colorpicker::AbstractColorPicker{C} = select_colorpicker(alg, colorscheme),
    to_linear = false,
    kwargs...,
) where {T, C}
    to_linear && (@warn "Skipping transformation `to_linear` when dithering in color.")
    length(colorscheme) > 1 ||
        throw(ArgumentError("Color scheme for dither needs more than one color."))

    # Allocate output: matrix of indices onto the colorscheme
    out = similar(img, Int)
    # Eagerly promote to the optimal color space to make loop run faster
    img = convert.(C, img)
    cs = convert.(C, colorscheme)
    # Call method
    out = colordither!(out, alg, img, cs, colorpicker; kwargs...)
    # Assemble IndirectArray with correct colorant-type
    colorscheme = convert.(T, colorscheme)
    return IndirectArray(out, colorscheme)
end

# TODO: deprecate
# A special case occurs when a grayscale output image is to be dithered in colors.
# Since this is not possible, instead the return image will be of type of the color scheme.
function colordither(
    ::Type{T},
    img::GenericImage,
    alg::AbstractDither,
    colorscheme::AbstractVector{<:Color{<:Any, 3}};
    colorpicker::AbstractColorPicker = select_colorpicker(alg, colorscheme),
    to_linear = false,
    kwargs...,
) where {T <: GrayLike}
    return colordither(
        eltype(colorscheme),
        img,
        alg,
        colorscheme;
        colorpicker = colorpicker,
        to_linear = to_linear,
        kwargs...,
    )
end

#================#
# Error handling #
#================#

struct ColorNotImplementedError <: Exception
    alg::String
    function ColorNotImplementedError(alg)
        return new(string(typeof(alg)))
    end
end
function Base.showerror(io::IO, e::ColorNotImplementedError)
    return print(io, e.alg, " algorithm currently doesn't support custom color palettes.")
end
function colordither!(
    out::Matrix{Int},
    alg::AbstractDither,
    img::GenericImage{C},
    cs::AbstractVector{C},
    colorpicker::AbstractColorPicker{C};
    kwargs...,
) where {C <: ColorLike}
    throw(ColorNotImplementedError(alg))
end
