using DitherPunk
using Images
using TestImages

img = testimage("lighthouse")
img = imresize(img; ratio=1//2)

img_gray = Gray.(img)

dither(img_gray, Bayer())

dither(img_gray, Bayer(); to_linear=true)

dither(img, Bayer())

white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

rubiks_colors = [white, yellow, green, orange, red, blue]

d = dither(img, FloydSteinberg(), rubiks_colors)

d = dither(img, ClosestColor(), rubiks_colors)

using ColorSchemes

dither(img, FloydSteinberg(), ColorSchemes.PuOr_7)

dither(img, FloydSteinberg(), :PuOr_7)

using Clustering

dither(img, FloydSteinberg(), 8)

using UnicodePlots
img = imresize(img; ratio=1//3)

braille(img, FloydSteinberg())

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

