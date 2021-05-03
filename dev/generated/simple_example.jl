using DitherPunk
using Images
using Images: ImageContrastAdjustment
using TestImages

img = testimage("lighthouse")

img = Gray.(img) # covert to grayscale
img = adjust_histogram(img, LinearStretching()) # normalize

dither = balanced_centered_point_dithering(img);

Gray.(dither)

dither = balanced_centered_point_dithering(img; to_linear=true)
Gray.(dither)

img = imresize(img; ratio=1 / 5) # downscale
dither = bayer_dithering(img; to_linear=true);

show_dither(dither; scale=3)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

