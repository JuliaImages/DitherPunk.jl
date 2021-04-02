using DitherPunk
using Images
using ImageInTerminal

w = 200
h = 4 * 4 # multiple of 4 for unicode braille print

function gradient_image(height, width)
    row = reshape(range(0; stop=1, length=width), 1, width)
    return img = Gray.(vcat(repeat(row, height)))
end

img = gradient_image(h, w)
println("Test image:")
imshow(img)

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
