"""
    srgb2linear(u)

Convert pixel `u` from sRGB to linear color space.
"""
@inline srgb2linear(u::Number) = Colors.invert_srgb_compand(u)
@inline srgb2linear(u::Gray) = typeof(u)(srgb2linear(gray(u)))
@inline srgb2linear(u::Bool) = u

"""
    linear2srgb(u)

Convert pixel `u` from linear to sRGB color space.
"""
@inline linear2srgb(u::Number) = Colors.srgb_compand(u)
@inline linear2srgb(u::Gray) = typeof(u)(linear2srgb(gray(u)))
@inline linear2srgb(u::Bool) = u

if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metric) = argmin(colordiff(px, c; metric=metric) for c in cs)
else
    function _closest_color_idx(px, cs, metric)
        return argmin([colordiff(px, c; metric=metric) for c in cs])
    end
end
