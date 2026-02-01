"""
    AbstractColorPicker{C}

Abstract supertype of all color pickers.
The parametric type `C` indicates the color space in which the closest color is computed. 
"""
abstract type AbstractColorPicker{C <: ColorLike} end
colorspace(::AbstractColorPicker{C}) where {C} = C

# By design, to ensure performance, color pickers only work on inputs of the same color space.
function (picker::AbstractColorPicker{C})(color::C) where {C <: ColorLike}
    return closest_color_index(picker, color)
end

"""
  RuntimeColorPicker(colorscheme)
  RuntimeColorPicker(colorscheme, metric)

Select closest color in `colorscheme` during runtime.
Used by default if `dither` is called without a color picker.
"""
struct RuntimeColorPicker{C <: ColorLike, M <: DifferenceMetric} <: AbstractColorPicker{C}
    metric::M
    colorscheme::Vector{C}

    function RuntimeColorPicker(
            colorscheme::ColorVector, metric::M
        ) where {M <: DifferenceMetric}
        C = colorspace(metric)
        colorscheme = convert.(C, colorscheme)
        return new{C, M}(metric, colorscheme)
    end
end

function RuntimeColorPicker(colorscheme; metric = DEFAULT_METRIC)
    return RuntimeColorPicker(colorscheme, metric)
end
function RuntimeColorPicker(colorscheme::ColorScheme, metric)
    return RuntimeColorPicker(colorscheme.colors, metric)
end

# Performance can be gained by converting colors to the colorspace the picker operates in:

function closest_color_index(p::RuntimeColorPicker{C}, c::C) where {C <: ColorLike}
    return closest_color_index_runtime(c, p.colorscheme, p.metric)
end

function closest_color_index_runtime(
        px::C, colorscheme::AbstractArray{C}, metric
    ) where {C <: ColorLike}
    mycolordiff(c) = colordiff(px, c; metric = metric)
    c, index = findmin(mycolordiff, colorscheme)
    return index
end

#===================#
# LookupColorPicker #
#===================#

const LUT_COLORSPACE = RGB{N0f8}
const LUT_INDEXTYPE = UInt16

"""
    LookupColorPicker(colorscheme)
    LookupColorPicker(colorscheme, metric)

Compute a look-up table of closest colors on the `$LUT_COLORSPACE` color cube.
"""
struct LookupColorPicker <: AbstractColorPicker{LUT_COLORSPACE}
    lut::Array{LUT_INDEXTYPE, 3} # look-up table

    function LookupColorPicker(lut::Array{LUT_INDEXTYPE, 3})
        size(lut) != (256, 256, 256) &&
            error("Look-up table has to be of size `(256, 256, 256)`, got $(size(lut)).")
        return new(lut)
    end
end

function LookupColorPicker(colorscheme; metric = DEFAULT_METRIC)
    return LookupColorPicker(colorscheme, metric)
end
function LookupColorPicker(colorscheme::ColorScheme, metric)
    return LookupColorPicker(colorscheme.colors, metric)
end

# Construct LUT from colorscheme and color difference metric
function LookupColorPicker(colorscheme::ColorVector, metric::DifferenceMetric)
    C = colorspace(metric)
    colorscheme = convert.(C, colorscheme)

    lut = Array{LUT_INDEXTYPE}(undef, 256, 256, 256)
    @inbounds @simd for I in CartesianIndices(lut)
        r, g, b = I.I
        px_rgb = ints_to_rgb_n0f8(r - 1, g - 1, b - 1)
        px = convert(C, px_rgb)
        lut[I] = closest_color_index_runtime(px, colorscheme, metric)
    end
    return LookupColorPicker(lut)
end

# Use LUT to look up index of closest color
function closest_color_index(picker::LookupColorPicker, c::LUT_COLORSPACE)
    ir, ig, ib = rgb_n0f8_to_ints(c) .+ 0x01
    return @inbounds picker.lut[ir, ig, ib]
end
