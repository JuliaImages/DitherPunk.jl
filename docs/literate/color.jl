using DitherPunk
using Images
using TestImages

# # Color dithering
# ## Defining a color scheme
# Let's assume we want to recreate an image by stacking ``20 \times 20`` Rubik's cubes.
# Dithering algorithms are perfect for this task!
# We start out by defining a custom color scheme:
white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = [white, yellow, green, orange, red, blue]

# ## Dithering the image
# Now we only have to pick an image
img = testimage("fabio_color_256")
img = imresize(img, 60, 60)

# and run an `ErrorDiffusion` algorithm of our choice, e.g. `FloydSteinberg`
d = dither(img, FloydSteinberg(), rubiks_colors)

# or simply quantize to the closest color:
d = dither(img, ClosestColor(), rubiks_colors)

# For an overview of all error diffusion algorithms, check out the gallery.

# ## Using ColorSchemes.jl
# Predefined color schemes from
# [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/#Pre-defined-schemes)
# can also be used by accessing the color scheme's `colors`.
# Let's use the colors of the Brazilian flag 🇧🇷:
using ColorSchemes
cs = ColorSchemes.flag_br
colors = cs.colors

img = testimage("fabio_color_256")
d = dither(img, Atkinson(), colors)
