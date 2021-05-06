"""
Convert from sRGB to linear color space.
"""
@inline srgb2linear(u::Number) = Colors.invert_srgb_compand(u)
@inline srgb2linear(u::Gray) = typeof(u)(srgb2linear(gray(u)))

"""
Convert from linear to sRGB color space.
"""
@inline linear2srgb(u::Number) = Colors.srgb_compand(u)
@inline linear2srgb(u::Gray) = typeof(u)(linear2srgb(gray(u)))
