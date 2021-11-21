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

"""

if VERSION >= v"1.7"
    _closest_color_idx(px, cs, metric) = argmin(colordiff(px, c; metric=metric) for c in cs)
else
    function _closest_color_idx(px, cs, metric)
        return argmin([colordiff(px, c; metric=metric) for c in cs])
    end
end

"""
    bwcolors(T)

Construct black & white color scheme of type `T`.
"""
bwcolors(::Type{T}) where {T<:NumberLike} = [T(0), T(1)]
const INDEX_BLACK = Int(1)
const INDEX_WHITE = Int(2)

"""
    perchannelbinarycolors(T)

Construct color scheme that corresponds to channel-wise binary dithering.
Indexing corresponds to binary respresentation:

# Example
```julia-repl
julia> perchannelditherpalette(RGB)
8-element Array{RGB{N0f8},1} with eltype RGB{N0f8}:
 RGB{N0f8}(0.0,0.0,0.0)
 RGB{N0f8}(0.0,0.0,1.0)
 RGB{N0f8}(0.0,1.0,0.0)
 RGB{N0f8}(0.0,1.0,1.0)
 RGB{N0f8}(1.0,0.0,0.0)
 RGB{N0f8}(1.0,0.0,1.0)
 RGB{N0f8}(1.0,1.0,0.0)
 RGB{N0f8}(1.0,1.0,1.0)
```
"""
function perchannelbinarycolors(::Type{T}) where {T<:Color{<:Any,3}}
    return [T(a, b, c) for a in 0:1 for b in 0:1 for c in 0:1]
end
