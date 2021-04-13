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
function upscale(img::T, scale::Int)::T where {T <: AbstractMatrix}
    return mortar(fill.(img, scale, scale))
end
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

"""
Create linear grayscale gradient image of specified dimensions.
"""
function gradient_image(height, width)
    row = reshape(range(0; stop=1, length=width), 1, width)
    return img = Gray.(vcat(repeat(row, height)))
end

"""
Test dithering algorithm on linear grayscale gradient and show stacked plot.
"""
function test_on_gradient(alg::Function)
    img = gradient_image(100, 800)
    dither = Gray.(alg(img))
    return mosaicview([img, dither], ncol=1)
end
