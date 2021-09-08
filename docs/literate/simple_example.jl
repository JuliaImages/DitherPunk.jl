#md # ```@meta
#md # CurrentModule = DitherPunk
#md # ```
#md #
#md # # DitherPunk.jl
#md # A [dithering / digital halftoning](https://en.wikipedia.org/wiki/Dither) package inspired by [Lucas Pope's Obra Dinn](https://obradinn.com) and [Surma's blogpost](https://surma.dev/things/ditherpunk/) of the same name.
#md #
#md # !!! note
#md #     This package is part of a wider [Julia-based image processing ecosystem](https://github.com/JuliaImages). If you are starting out, then you may benefit from reading about some [fundamental conventions](https://juliaimages.org/latest/quickstart/) that the ecosystem utilizes that are markedly different from how images are typically represented in OpenCV, MATLAB, ImageJ or Python.
#md #
# # Getting started
# We start out by loading an image, in this case the lighthouse
# from [*TestImages.jl*](https://testimages.juliaimages.org).
using DitherPunk
using Images
using Images: ImageContrastAdjustment
using TestImages

img = testimage("lighthouse")

# Normalizing the image can emphasize the effect of the algorithms.
# It is highly recommended to play around with algorithms such as those provided by
# [ImageContrastAdjustment.jl](https://juliaimages.org/ImageContrastAdjustment.jl/stable/)
img = Gray.(img) # covert to grayscale
img = adjust_histogram(img, LinearStretching()) # normalize

# ## Dithering
# We can now apply dithering algorithms of our choice, for example `BalancedCenteredPoint`.
# The dithering algorithms return binary matrices of type `Matrix{Gray{Bool}}`.
d = dither(img, BalancedCenteredPoint())

# ## Color spaces
# Dithering in sRGB color space can lead to results that are too bright.
# To obtain a dithered image that more closely matches the human perception of brightness,
# grayscale images can be converted to a linear color space using `srgb2linear`.
# Alternatively, `dither` accepts the boolean keyword argument `to_linear`.
d = dither(img, BalancedCenteredPoint(); to_linear=true)

# ## Working with small images
# The previous `BalancedCenteredPoint` algorithm has a large characteristic
# pattern. Some algorithms work better on smaller images, for example `Bayer`,
# another [ordered dithering algorithm](https://en.wikipedia.org/wiki/Ordered_dithering)
# that leads to characteristic cross-hatch patterns.
img = imresize(img; ratio=1 / 5) # downscale
d = dither(img, Bayer(); to_linear=true)

# The function `upscale` provides integer scaling to print "chunkier" pixels.
upscale(d, 3)
