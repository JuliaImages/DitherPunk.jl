using Images
using DitherPunk

w = 200
h = 3 * 4 # multiple of 8 for unicode braille print

function gradient_image(height, width)
    gradient_row = reshape(range(0; stop=1, length=width), 1, width)
    row = DitherPunk.linear2srgb.(gradient_row)
    return img = Gray.(vcat(repeat(gradient_row, height)))
end

test_img = gradient_image(h, w)

algs = [threshold_dithering, random_noise_dithering, bayer_dithering]

for alg in algs
    print_braille(alg(test_img), title="$(alg)")
    println("")
end
