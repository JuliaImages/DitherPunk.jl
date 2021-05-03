"""
Convert from sRGB to linear color space.
"""
srgb2linear(u::Gray)::Gray = u ≤ 0.04045 ? 25 * u / 323 : ((200 * u + 11) / 211)^(12 / 5)
srgb2linear(img::AbstractMatrix{<:Gray}) = srgb2linear.(img)
function srgb2linear!(img::AbstractMatrix{<:Gray})
    img .= srgb2linear.(img)
    return nothing
end

"""
Convert from linear to sRGB color space.
"""
linear2srgb(u::Gray)::Gray = u ≤ 0.0031308 ? 323 * u / 25 : (211 * u^(5 / 12) - 11) / 200
linear2srgb(img::AbstractMatrix{<:Gray}) = linear2srgb.(img)
function linear2srgb!(img::AbstractMatrix{<:Gray})
    img .= linear2srgb.(img)
    return nothing
end
