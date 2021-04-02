using Images
using DitherPunk

w = 200
h = 3 * 4 # multiple of 8 for unicode braille print

function gradient_image(height, width)
    gradient_row = reshape(range(0; stop=1, length=width), 1, width)
    row = DitherPunk.linear2srgb.(gradient_row)
    return img = Gray.(vcat(repeat(gradient_row, height)))
end

img = gradient_image(h, w)

algs = [threshold_dithering, random_noise_dithering]

for alg in algs
    println("")
    print_braille(alg(img); title="$(alg)")
end

for level in 1:3
    println("")
    print_braille(
        bayer_dithering(img; level=level); title="bayer_dithering, level $(level)"
    )
end
