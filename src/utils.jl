"""
    srgb2linear(u)

Convert pixel `u` from sRGB to linear color space.
"""
@inline srgb2linear(u::Number) = invert_srgb_compand(u)
@inline srgb2linear(u::Gray) = typeof(u)(srgb2linear(gray(u)))
@inline srgb2linear(u::Bool) = u

"""
    upscale(img, scale)

Upscale image by repeating individual pixels `scale` times.
"""
upscale(img, scale) = repeat(img; inner=(scale, scale))

if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metr) = argmin(colordiff(px, c; metric=metr) for c in cs)
else
    _closest_color_idx(px, cs, metr) = argmin([colordiff(px, c; metric=metr) for c in cs])
end

"""
    clamp_limits(color)

Clamp colorant within the limits of each color channel.
"""
clamp_limits(c::Colorant) = clamp01(c)
clamp_limits(c::HSV) = typeof(c)(mod(c.h, 360), clamp01(c.s), clamp01(c.v))
clamp_limits(c::Lab) = c
clamp_limits(c::XYZ) = c
