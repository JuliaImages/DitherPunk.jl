"""
Create linear grayscale gradient image of type `Gray`.
"""
function gradient_image(height, width)
    row = reshape(range(0; stop=1, length=width), 1, width)
    return img = Gray.(vcat(repeat(row, height)))
end

"""
Test dithering algorithm `alg` on linear grayscale gradient from `gradient_image`
and show stacked plot.
"""
function test_on_gradient(alg::Function)
    img = gradient_image(100, 800)
    dither = Gray.(alg(img))
    return mosaicview([img, dither]; ncol=1)
end
