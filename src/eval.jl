"""
Create linear grayscale gradient image of type `Gray`.
"""
function gradient_image(height, width)
    row = reshape(range(0; stop=1, length=width), 1, width)
    grad = Gray.(vcat(repeat(row, height))) # Linear gradient
    img = srgb2linear.(grad) # For printing, compensate for SRGB colorspace
    return grad, img
end

"""
Test dithering algorithm `alg` on linear grayscale gradient from `gradient_image`
and show stacked plot.
"""
function test_on_gradient(alg::Function)
    srgb, linear = gradient_image(100, 800)
    dither_srgb = Gray.(alg(srgb))
    dither_linear = Gray.(alg(linear))

    return mosaicview([srgb, dither_srgb, linear, dither_linear]; ncol=1)
end
function test_on_gradient(algs)
    srgb, linear = gradient_image(100, 800)
    dithers_srgb = [Gray.(alg(srgb)) for alg in algs]
    dithers_linear = [Gray.(alg(linear)) for alg in algs]

    return mosaicview([srgb, dithers_srgb..., linear, dithers_linear...]; ncol=1)
end
