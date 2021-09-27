using DitherPunk
using DitherPunk: closest_color
using Images
using ImageCore
using ImageInTerminal
using ReferenceTests
using TestImages

## Define color scheme
white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)

cs = [white, yellow, green, orange, red, blue]

# Test helper function
@test closest_color(RGB{Float32}(1, 0.1, 0.1), cs) == red

# Load test image
img = testimage("fabio_color_256")
img_gray = testimage("fabio_gray_256")
imshow(img)

# Run & test custom color pallete dithering methods
algs = Dict("FloydSteinberg" => FloydSteinberg(), "ClosestColor" => ClosestColor())

for (name, alg) in algs
    # Test custom color dithering on color images
    img2 = copy(img)
    d = dither(img2, alg, cs)
    @test_reference "references/color_$(name).txt" d
    @test eltype(d) == eltype(img2)
    @test img2 == img # image not modified
    imshow(d)

    dither!(img2, alg, cs)
    @test eltype(img2) == eltype(img)
    @test img2 == d # image updated in-place

    # Test custom color dithering on gray images
    img2_gray = copy(img_gray)
    d = dither(img2_gray, alg, cs)
    @test_reference "references/color_from_gray_$(name).txt" d
    @test eltype(d) == eltype(cs)
    @test img2_gray == img_gray # image not modified
    imshow(d)

    dither!(img2_gray, alg, cs)
    @test eltype(img2_gray) == eltype(img_gray)
    imshow(img2_gray)
end

# Test for argument errors on AbstractBinaryDither algorithms
for alg in [Bayer(), WhiteNoiseThreshold(), ConstantThreshold()]
    @test_throws ArgumentError dither(img, alg, cs)
end

# Test conditional dependency on ColorSchemes.jl
using ColorSchemes
alg = FloydSteinberg()
@test dither(img, alg, ColorSchemes.jet) == dither(img, alg, :jet)

# Dry-run conditional dependency on Clustering.jl
using Clustering
d = dither(img, alg, 4)
imshow(d)
