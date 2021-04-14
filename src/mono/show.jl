"""
Apply `Gray` to indicate that image should be interpreted as a grayscale image.
Optionally upscale image by integer value.
"""
show_dither(img::BitMatrix; scale::Int=1) = Gray.(upscale(img, scale))

"""
Upscale image by repeating individual pixels.
"""
upscale(img, scale) = repeat(img; inner=(scale, scale))

"""
(Ab)use `spy` to interpret image as sparse array and print "sparsity pattern"
in braille through UnicodePlots.
"""
function print_braille(
    img::BitMatrix;
    invert=false,
    title="DitherPunk.jl",
    color=:white,
    labels=false,
    kwargs...,
)
    h, w = size(img)

    # Optionally invert Binary image before printing
    _img = copy(img)
    invert && (_img .= iszero.(_img))

    show(
        spy(
            _img;
            # Braille character ↝ 4x2 grid
            maxheight=ceil(Int, h / 4),
            maxwidth=ceil(Int, w / 2),
            title=title,
            color=color,
            labels=labels,
            kwargs...,
        ),
    )
    return nothing
end
