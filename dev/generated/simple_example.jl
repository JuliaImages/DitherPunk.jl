using DitherPunk
using Images
using TestImages

img_color = testimage("lighthouse")
img_color = imresize(img_color; ratio = 1//2)
img_gray = Gray.(img_color) # covert to grayscale

dither(img_gray, Bayer())

dither(img_gray, Bayer(); to_linear=true)

dither(img_color, SeparateSpace(Bayer()))

dither(img_color, SeparateSpace(FloydSteinberg()))

dither(img_color, SeparateSpace(Rhombus()))

white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = [white, yellow, green, orange, red, blue]

img = testimage("fabio_color_256")
img = imresize(img, 150, 150)

d = dither(img, FloydSteinberg(), rubiks_colors)

d = dither(img, ClosestColor(), rubiks_colors)

using ColorSchemes
cs = ColorSchemes.flag_br

dither(img, Atkinson(), cs.colors)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

