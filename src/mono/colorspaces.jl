"""
Convert from sRGB to linear color space.
"""
srgb2linear(u) = u ≤ 0.04045 ? 25 * u / 323 : ((200 * u + 11) / 211)^(12 / 5)

"""
Convert from linear to sRGB color space.
"""
linear2srgb(u) = u ≤ 0.0031308 ? 323 * u / 25 : (211 * u^(5 / 12) - 11) / 200
