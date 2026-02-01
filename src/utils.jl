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
upscale(img, scale) = repeat(img; inner = (scale, scale))

"""
    clamp_limits(color)

Clamp colorant within the limits of each color channel.
"""
clamp_limits(c::Colorant) = clamp01(c)
clamp_limits(c::HSV) = typeof(c)(mod(c.h, 360), clamp01(c.s), clamp01(c.v))
clamp_limits(c::Lab) = c
clamp_limits(c::XYZ) = c

# Utilities to create LUT
rgb_n0f8_to_ints(c::RGB{N0f8}) = (c.r.i, c.g.i, c.b.i)

int_to_n0f8(x::UInt8) = reinterpret(N0f8, x)
int_to_n0f8(x::Integer) = int_to_n0f8(UInt8(x))

function ints_to_rgb_n0f8(r::Integer, g::Integer, b::Integer)
    vr = int_to_n0f8(r)
    vg = int_to_n0f8(g)
    vb = int_to_n0f8(b)
    return RGB(vr, vg, vb)
end
