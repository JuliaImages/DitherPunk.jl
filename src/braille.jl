# These functions are only conditionally loaded with UnicodePlots.jl

"""
    braille(img; kwargs...)
    braille(img, alg; kwargs...)

Binary dither with algorithm `alg`, then print image in braille.

## Keyword arguments
  - `invert`: invert Unicode output, defaults to `false`

All keyword arguments for binary dithering methods can be used.
"""
function braille(img::GenericImage, alg::AbstractDither; invert=false, kwargs...)
    d = dither(Bool, Gray.(img), alg; kwargs...)
    invert && return brailleprint(.!d)
    return brailleprint(d)
end

"""
    brailleprint(img)

Interpret binary image `img` as sparse array and print it in braille through UnicodePlots.
Refer to the UnicodePlots.jl documentation of `spy` for plot arguments.
"""
function brailleprint(
    img::GenericGrayImage; title="", margin=0, padding=0, border=:none, kwargs...
)
    h, w = size(img)
    img = Bool.(img)

    return UnicodePlots.spy(
        img;
        # One braille character corresponds to a 4x2 grid
        maxheight=ceil(Int, h / 4),
        maxwidth=ceil(Int, w / 2),
        title=title,
        margin=margin,
        padding=padding,
        border=border,
        labels=false,
        kwargs...,
    )
end
