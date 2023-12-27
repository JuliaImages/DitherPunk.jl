abstract type AbstractClosestColorComputer end

"""
    ClosestColorLookup(colorscheme)
    ClosestColorLookup(colorscheme, metric)

Compute a look-up table of closest colors on the `RGB{N0f8}` color cube.
"""
struct ClosestColorLookup{T<:AbstractArray{<:Integer, 3}} <: AbstractClosestColorComputer
    lut::T # look-up table

    function ClosestColorLookup(lut)
        require_one_based_indexing(lut)
        size(lut) != (256, 256, 256) && error(
            "Look-up table has to be of size `(256, 256, 256)`, got $(size(lut))."
        )
        return new{typeof(lut)}(lut)
    end
end

(l::ClosestColorLookup)(c::Colorant) = get_closest_color_index(l, c)

# Construct LUT from colorscheme and color difference metric
function ClosestColorLookup(
    colorscheme::AbstractArray{<:Colorant};
    metric::DifferenceMetric=DEFAULT_METRIC,
)
    lut = Array{UInt16}(undef, 256, 256, 256)
    @inbounds @simd for I in CartesianIndices(lut)
        r, g, b = I.I
        px = ints_to_rgb_n0f8(r-1, g-1, b-1)
        lut[I] = _closest_color_idx(px, colorscheme, metric)
    end
    return ClosestColorLookup(lut)
end

# Use LUT to look up index of closest color
function get_closest_color_index(l::ClosestColorLookup, c::RGB{N0f8})
    ir, ig, ib = rgb_n0f8_to_ints(c) .+ 0x01
    return @inbounds l.lut[ir, ig, ib]
end
function get_closest_color_index(l::ClosestColorLookup, c::Colorant)
    return get_closest_color_index(l, convert(RGB{N0f8}, c))
end
