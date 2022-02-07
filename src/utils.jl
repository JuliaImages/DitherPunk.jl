"""
    srgb2linear(u)

Convert pixel `u` from sRGB to linear color space.
"""
@inline srgb2linear(u::Number) = Colors.invert_srgb_compand(u)
@inline srgb2linear(u::Gray) = typeof(u)(srgb2linear(gray(u)))
@inline srgb2linear(u::Bool) = u

"""
    upscale(img, scale)

Upscale image by repeating individual pixels `scale` times.
"""
upscale(img, scale) = repeat(img; inner=(scale, scale))

if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metric) = argmin(colordiff(px, c; metric=metric) for c in cs)
else
    function _closest_color_idx(px, cs, metric)
        return argmin([colordiff(px, c; metric=metric) for c in cs])
    end
end

"""
    clamp_limits(color)

Clamp colorant within the limits of each color channel.
"""
clamp_limits(c::Gray) = clamp01(c)
clamp_limits(c::RGB) = clamp01(c)
clamp_limits(c::HSV) = typeof(c)(mod(c.h, 360), clamp01(c.s), clamp01(c.v))
clamp_limits(c::Lab) = c
function clamp_limits(c::XYZ)
    return typeof(c)(clamp(c.x, 0, 0.95047), clamp01(c.y), clamp(c.z, 0, 1.08883))
end
