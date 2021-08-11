"""
    SeparateSpace(alg::AbstractDither)

A meta-algorithm that takes any gray-scale dithering algorithm and applies channel-wise
binary dithering.

# Note
The output of this algorithm depends on the color type of input image. RGB is recommended.

# Examples
```julia-repl
julia> dither!(img, SeparateSpace(Bayer()))
```
"""
struct SeparateSpace{A<:AbstractDither} <: AbstractFixedColorDither
    alg::A
end

function (ssd::SeparateSpace)(out::GenericImage, img::GenericImage, args...; kwargs...)
    cvout = channelview(out)
    cvimg = channelview(img)
    for c in axes(cvout, 1)
        # Note: the input `out` will be modified
        # since the dithering algorithms modify the view of the channelview of `out`.
        ssd.alg(view(cvout, c, :, :), view(cvimg, c, :, :), args...; kwargs...)
    end
    return out
end
