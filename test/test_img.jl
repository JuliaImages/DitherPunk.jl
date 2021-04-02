using DitherPunk
using Images
using TestImages
using FileIO
using ImageTransformations

img = load("./assets/ggb.png")
img = imresize(img; ratio=2 / 3)
img = Gray.(img)

println("Test image:")

algs = [threshold_dithering, random_noise_dithering]

for alg in algs
    println("")
    print_braille(alg(img); title="$(alg)")
end

for level in 1:3
    println("")
    dither = bayer_dithering(img; level=level)
    print_braille(dither; title="bayer_dithering, level $(level)")
end
