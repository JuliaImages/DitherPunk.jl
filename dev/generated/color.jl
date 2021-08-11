using DitherPunk
using Images
using TestImages

white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = [white, yellow, green, orange, red, blue]

img = testimage("fabio_color_256")
img = imresize(img, 60, 60)

d = dither(img, FloydSteinberg(), rubiks_colors)

d = dither(img, ClosestColor(), rubiks_colors)

using ColorSchemes
cs = ColorSchemes.flag_br
colors = cs.colors

img = testimage("fabio_color_256")
d = dither(img, Atkinson(), colors)

dither(img, SeparateSpace(Atkinson()))

dither(img, SeparateSpace(Bayer()))

dither(img, SeparateSpace(ClusteredDots()))

dither(HSV.(img), SeparateSpace(ClusteredDots()))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

