abstract type AbstractColorPicker end

"""
        LookupColorPicker(colorscheme)
        LookupColorPicker(colorscheme, metric)

Compute a look-up table of closest colors on the `RGB{N0f8}` color cube.
"""
    struct LookupColorPicker{T<:AbstractArray{<:Integer, 3}} <: AbstractColorPicker
    lut::T # look-up table

        function LookupColorPicker(lut)
        require_one_based_indexing(lut)
        size(lut) != (256, 256, 256) && error(
            "Look-up table has to be of size `(256, 256, 256)`, got $(size(lut))."
        )
        return new{typeof(lut)}(lut)
    end
end

    (l::LookupColorPicker)(c::Colorant) = get_closest_color_index(l, c)

# Construct LUT from colorscheme and color difference metric
    function LookupColorPicker(
    colorscheme::AbstractArray{<:Colorant};
    metric::DifferenceMetric=DEFAULT_METRIC,
)
    lut = Array{UInt16}(undef, 256, 256, 256)
    @inbounds @simd for I in CartesianIndices(lut)
        r, g, b = I.I
        px = ints_to_rgb_n0f8(r-1, g-1, b-1)
        lut[I] = _closest_color_idx(px, colorscheme, metric)
    end
        return LookupColorPicker(lut)
end

# Use LUT to look up index of closest color
    function get_closest_color_index(l::LookupColorPicker, c::RGB{N0f8})
    ir, ig, ib = rgb_n0f8_to_ints(c) .+ 0x01
    return @inbounds l.lut[ir, ig, ib]
end
    function get_closest_color_index(l::LookupColorPicker, c::Colorant)
    return get_closest_color_index(l, convert(RGB{N0f8}, c))
end
