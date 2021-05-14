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

"""
Return color in ColorScheme `cs` that is closest to `color`
[according to `colordiff`](http://juliagraphics.github.io/Colors.jl/dev/colordifferences/#Color-Differences)
"""
function closest_color(color::Colorant, cs::ColorScheme; metric=DE_2000())::Colorant
    imin = argmin(colordiff.(color, cs; metric))
    return cs[imin]
end
