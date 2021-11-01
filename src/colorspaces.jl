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

"""
    closest_color(color, cs; metric=DE_2000())

Return color in ColorScheme `cs` that is closest to `color`
[according to `colordiff`](http://juliagraphics.github.io/Colors.jl/dev/colordifferences/#Color-Differences)
"""
function closest_color(color::Color, cs::AbstractVector{<:Color}; metric=DE_2000())
    imin = argmin(colordiff.(color, cs; metric=metric))
    return cs[imin]
end
