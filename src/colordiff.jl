if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metr) = argmin(colordiff(px, c; metric=metr) for c in cs)
else
    _closest_color_idx(px, cs, metr) = argmin([colordiff(px, c; metric=metr) for c in cs])
end

"""
    FastEuclideanMetric()


DitherPunk's custom `DifferenceMetric` for use with Colors.jl.
This is slightly faster than a generic `EuclideanDifferenceMetric{RGB{N0f8}}`
by skipping the computation of the `sqrt`, which DitherPunk doesn't require
for the computation of the closest neighbor in a colorscheme. 
"""
struct FastEuclideanMetric <: EuclideanDifferenceMetric{RGB{N0f8}} end

function _colordiff(a::RGB{N0f8}, b::RGB{N0f8}, ::FastEuclideanMetric)
    return (a.r.i - b.r.i)^2 + (a.g.i - b.g.i)^2 + (a.b.i - b.b.i)^2
end
function _colordiff(a::Colorant, b::Colorant, m::FastEuclideanMetric)
    a = convert(RGB{N0f8}, a)
    b = convert(RGB{N0f8}, b)
    return _colordiff(a, b, m)
end

# TODO: add fast metric for numberic inputs

# Performance can be gained by converting colors to the colorspace `colordiff`
# operates in for a given metric
colorspace(::DifferenceMetric) = Lab # fallback
colorspace(::EuclideanDifferenceMetric{T}) where {T} = T
colorspace(::FastEuclideanMetric) = RGB{N0f8} # DitherPunk's custom metric
colorspace(::DE_2000) = Lab
colorspace(::DE_94) = Lab
colorspace(::DE_JPC79) = Lab
colorspace(::DE_CMC) = Lab
colorspace(::DE_BFD) = XYZ
