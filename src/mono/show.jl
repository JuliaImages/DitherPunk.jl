"""
Apply `Gray` to indicate that image should be interpreted as a grayscale image.
Optionally upscale image by integer value.
"""
function show_dither(img::BitMatrix; scale::Int=1)
    # Using mortar from BlockArrays to repeat individual "pixels" in the BitMatrix.
    return Gray.(upscale(img, scale))
end

"""
Upscale image by repeating individual pixels.
"""
upscale(img::BitMatrix, scale::Int)::BitMatrix = mortar(fill.(img, scale, scale))

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
