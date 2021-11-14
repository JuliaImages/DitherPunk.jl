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
