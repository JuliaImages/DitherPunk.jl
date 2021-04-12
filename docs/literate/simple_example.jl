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

# Normalizing the image can emphasize the effect of the algorithms.
img = Gray.(img) # covert to grayscale
img = adjust_histogram(img, LinearStretching()) # normalize

# ## Dithering
# We can now apply dithering algorithms of our choice,
# for example `balanced_centered_point_dithering`.
dither = balanced_centered_point_dithering(img);

# ## Visualizing the result
# The dithering algorithms return binary matrices of type `BitMatrix`.
# These can be shown by casting them to grayscale using `Gray.()`.
Gray.(dither)

# ## Working with small images
# The previous `balanced_centered_point_dithering` algorithm has a large characteristic
# pattern. Some algorithms work better on smaller images, for example `bayer_dithering`,
# another [ordered dithering algorithm](https://en.wikipedia.org/wiki/Ordered_dithering)
# that leads to characteristic cross-hatch patterns.
img = imresize(img; ratio=1 / 5) # downscale
dither = bayer_dithering(img);

# The function `show_dither` casts to `Gray` and provides an additional integer scaling
# parameter to print "chunkier" pixels.
show_dither(dither; scale=3)

# Alternatively, the images can also be printed to console though `UnicodePlots`
# by using `print_braille`
print_braille(dither)
