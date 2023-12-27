if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metr) = argmin(colordiff(px, c; metric=metr) for c in cs)
else
    _closest_color_idx(px, cs, metr) = argmin([colordiff(px, c; metric=metr) for c in cs])
end

"""
    FastEuclideanMetric()
"""
struct FastEuclideanMetric <: EuclideanDifferenceMetric{RGB} end

function _colordiff(a::RGB{N0f8}, b::RGB{N0f8}, ::FastEuclideanMetric)
    return (a.r.i - b.r.i)^2 + (a.g.i - b.g.i)^2 + (a.b.i - b.b.i)^2
end
function _colordiff(ai::Colorant, bi::Colorant, m::FastEuclideanMetric)
    ai = convert(RGB{N0f8}, ai)
    bi = convert(RGB{N0f8}, bi)
    return _colordiff(ai, bi, m)
end
