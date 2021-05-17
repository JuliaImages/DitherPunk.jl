using DitherPunk
using Images
using ColorSchemes
using TestImages

white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = ColorScheme([white, yellow, green, orange, red, blue])

img = testimage("fabio_color_256")
img = imresize(img, 60, 60)

d = dither(img, FloydSteinberg(), rubiks_colors)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

