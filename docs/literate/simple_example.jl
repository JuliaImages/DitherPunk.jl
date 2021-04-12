using DitherPunk
using Images
using ImageTransformations
using ImageContrastAdjustment
using TestImages

# # Example
# ## Preprocessing
# We start out by loading an image, in this case the lighthouse
# from [*TestImages.jl*](https://testimages.juliaimages.org).
img = testimage("lighthouse")

# Downscaling and normalizing the image can emphasize the effect of the algorithms.
img = Gray.(img)                                # covert to grayscale
img = imresize(img; ratio=1 / 4)                # downscale
img = adjust_histogram(img, LinearStretching()) # normalize

# ## Dithering
# We can now apply dithering algorithms of our choice, for example `bayer_dithering`,
# an [ordered dithering algorithm](https://en.wikipedia.org/wiki/Ordered_dithering)
# that leads to characteristic cross-hatch patterns.
dither = bayer_dithering(img)

# ## Visualizing the result
# The dithering algorithms return binary matrices of type `BitMatrix`.
# These can be shown by casting them to grayscale using `Gray.()`.
# The function `show_dither` provides an additional integer scaling parameter to print
# "chunkier" pixels.
show_dither(dither; scale=2)

# Alternatively, the images can also be printed to console though `UnicodePlots`
# by using `print_braille`
print_braille(dither)

# which can also be inverted if so desired.
print_braille(dither; invert=true)
