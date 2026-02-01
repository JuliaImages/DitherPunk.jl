using DitherPunk: srgb2linear

function gradient_image(height, width)
    row = reshape(range(0; stop = 1, length = width), 1, width)
    grad = Gray.(vcat(repeat(row, height))) # Linear gradient
    img = srgb2linear.(grad) # For printing, compensate for SRGB colorspace
    return grad, img
end
