using DitherPunk
using Images
using TestImages
using FileIO
using ImageTransformations

img = load("./assets/ggb.png")
img = imresize(img; ratio=2 / 3)
img = Gray.(img)

algs = [threshold_dithering, random_noise_dithering, bayer_dithering]

for alg in algs
    print_braille(alg(img), title="$(alg)")
    println("")
end
