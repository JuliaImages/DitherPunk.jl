using DitherPunk
using Images
using Images: ImageContrastAdjustment
using TestImages

img = testimage("lighthouse")

img = Gray.(img) # covert to grayscale
img = adjust_histogram(img, LinearStretching()) # normalize

d = dither(img, BalancedCenteredPoint())

d = dither(img, BalancedCenteredPoint(); to_linear=true)

img = imresize(img; ratio=1 / 5) # downscale
d = dither(img, Bayer(); to_linear=true)

upscale(d, 3)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

