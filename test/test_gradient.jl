using DitherPunk
using Images
using ImageInTerminal

w = 200
h = 4 * 4 # multiple of 4 for unicode braille print

img, srgb = gradient_image(h, w)
println("Test image:")
imshow(srgb)

algs = [
    threshold_dithering,
    white_noise_dithering,
    clustered_dots_dithering,
    balanced_centered_point_dithering,
    rhombus_dithering,
]

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
