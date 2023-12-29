abstract type AbstractColorPicker end
(l::AbstractColorPicker)(c::Colorant) = get_closest_color_index(l, c)

"""
  RuntimeColorPicker(colorscheme)
  RuntimeColorPicker(colorscheme, metric)

Select closest color in `colorscheme` during runtime.
Used by default if `dither` is called without a color picker.
    
"""
struct RuntimeColorPicker{M<:DifferenceMetric,T::Pixel} <: AbstractColorPicker
    metric::M
    colorscheme::Vector{T}

    function RuntimeColorPicker(colorscheme, metric::DifferenceMetric)
        T = colorspace(metric)
        colorscheme = convert.(T, colorscheme)
        return new{typeof{M},T}(metric, colorscheme)
    end
end

RuntimeColorPicker(cs; metric=DEFAULT_METRIC) = RuntimeColorPicker(cs, metric)

function get_closest_color_index(p::RuntimeColorPicker, c::Colorant)
    return _closest_color_idx(c, p.colorscheme, p.metric)
end

#===================#
# LookupColorPicker #
#===================#

const LUT_INDEXTYPE = UInt16

"""
    LookupColorPicker(colorscheme)
    LookupColorPicker(colorscheme, metric)

Compute a look-up table of closest colors on the `RGB{N0f8}` color cube.
"""
struct LookupColorPicker <: AbstractColorPicker
    lut::Array{LUT_INDEXTYPE,3} # look-up table

    function LookupColorPicker(lut::Array{LUT_INDEXTYPE,3})
        size(lut) != (256, 256, 256) &&
            error("Look-up table has to be of size `(256, 256, 256)`, got $(size(lut)).")
        return new(lut)
    end
end

# Construct LUT from colorscheme and color difference metric
function LookupColorPicker(
    colorscheme::ColorVector; metric::DifferenceMetric=DEFAULT_METRIC
)
    lut = Array{LUT_INDEXTYPE}(undef, 256, 256, 256)
    @inbounds @simd for I in CartesianIndices(lut)
        r, g, b = I.I
        px = ints_to_rgb_n0f8(r - 1, g - 1, b - 1)
        lut[I] = _closest_color_idx(px, colorscheme, metric)
    end
    return LookupColorPicker(lut)
end

# Use LUT to look up index of closest color
function get_closest_color_index(p::LookupColorPicker, c::RGB{N0f8})
    ir, ig, ib = rgb_n0f8_to_ints(c) .+ 0x01
    return @inbounds p.lut[ir, ig, ib]
end
function get_closest_color_index(p::LookupColorPicker, c::Colorant)
    return get_closest_color_index(p, convert(RGB{N0f8}, c))
end
