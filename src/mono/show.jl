"""
Apply `Gray` to indicate that image should be interpreted as a grayscale image.
"""
show_dither(img::BitMatrix) = Gray.(img)

"""
(Ab)use `spy` to interpret image as sparse array and print "sparsity pattern"
in braille through UnicodePlots.
"""
function print_braille(
    img::BitMatrix; title="DitherPunk.jl", color=:white, labels=false, kwargs...
)
    h, w = size(img)

    show(spy(
        img;
        # Braille character ↝ 4x2 grid
        maxheight=ceil(Int, h / 4),
        maxwidth=ceil(Int, w / 2),
        title=title,
        color=color,
        labels=labels,
        kwargs...,
    ))
    return nothing
end
