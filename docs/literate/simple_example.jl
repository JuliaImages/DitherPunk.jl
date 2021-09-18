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
using TestImages

img = testimage("lighthouse")
img = imresize(img; ratio=1//2)

# To apply binary dithering, we also need to convert the image to grayscale.
img_gray = Gray.(img)

#
# !!! note " Preprocessing"
#     Sharpening the image and adjusting the contrast can emphasize the effect of the algorithms. It is highly recommended to play around with algorithms such as those provided by [ImageContrastAdjustment.jl](https://juliaimages.org/ImageContrastAdjustment.jl/stable/)
#
# ## Binary dithering
# Since we already turned the image to grayscale, we are ready to apply Bayer dithering,
# an [ordered dithering](https://en.wikipedia.org/wiki/Ordered_dithering) algorithm that leads to characteristic cross-hatch patterns.
dither(img_gray, Bayer())

# ### Color spaces
# Depending on the method, dithering in sRGB color space can lead to results that are too bright.
# To obtain a dithered image that more closely matches the human perception of brightness, grayscale images can be converted to linear color space using the boolean keyword argument `to_linear`.
dither(img_gray, Bayer(); to_linear=true)

# ## Separate-space dithering
# All dithering algorithms in DitherPunk can also be applied to color images
# and will automatically apply channel-wise binary dithering.
dither(img, Bayer())

#
# !!! note
#     Because the algorithm is applied once per channel, the output of this algorithm depends on the color type of input image. `RGB` is recommended, but feel free to experiment!
#
# ## Dithering with custom colors
# Let's assume we want to recreate an image by stacking a bunch of Rubik's cubes. Dithering algorithms are perfect for this task!
# We start out by defining a custom color scheme:
white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = [white, yellow, green, orange, red, blue]

# Currently, dithering in custom colors is limited to `ErrorDiffusion` algorithms such as `FloydSteinberg`.
d = dither(img, FloydSteinberg(), rubiks_colors)

# this looks much better than simply quantizing to the closest color!
d = dither(img, ClosestColor(), rubiks_colors)

# For an overview of all error diffusion algorithms, check out the [gallery].
#
# ### ColorSchemes.jl
# Predefined color schemes from [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/#Pre-defined-schemes) can also be used.
# Here we use ColorSchemes.jl to dither in the colors of the French flag 🇫🇷:
using ColorSchemes

dither(img, FloydSteinberg(), ColorSchemes.flag_fr)

# You can also directly use the corresponding symbol from the
# [ColorSchemes catalogue](https://juliagraphics.github.io/ColorSchemes.jl/stable/catalogue/):
dither(img, FloydSteinberg(), :flag_fr)

# ### Clustering.jl
# Using [Clustering.jl](https://github.com/JuliaStats/Clustering.jl) allows you to generate
# optimized color schemes. Simply pass the size of the desired color palette:
using Clustering

dither(img, FloydSteinberg(), 8)
