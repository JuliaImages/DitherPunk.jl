using DitherPunk
using Images
using ImageTransformations
using ImageContrastAdjustment
using TestImages

img = testimage("lighthouse")

img = Gray.(img) # covert to grayscale
img = adjust_histogram(img, LinearStretching()) # normalize

dither = balanced_centered_point_dithering(img);

Gray.(dither)

img = imresize(img; ratio=1 / 5) # downscale
dither = bayer_dithering(img);

show_dither(dither; scale=3)

print_braille(dither)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

