using DitherPunk
using DitherPunk: ColorNotImplementedError
using IndirectArrays
using ImageCore
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

# Load test image
img = testimage("fabio_color_256")
img_gray = testimage("fabio_gray_256")

# Run & test custom color pallete dithering methods
algs = Dict(
    "FloydSteinberg_XYZ" => FloydSteinberg(; color_space=XYZ),
    "FloydSteinberg_RGB" => FloydSteinberg(; color_space=RGB),
    "ClosestColor" => ClosestColor(),
    "Bayer" => Bayer(),
)

for (name, alg) in algs
    # Test custom color dithering on color images
    local img2 = copy(img)
    local d = dither(img2, alg, cs)
    @test_reference "references/color/$(name).txt" d
    @test eltype(d) == eltype(img2)
    @test img2 == img # image not modified

    # Test custom color dithering on gray images
    local img2_gray = copy(img_gray)
    local d = dither(img2_gray, alg, cs)
    @test_reference "references/color/$(name)_from_gray.txt" d
    @test eltype(d) == eltype(cs)
    @test img2_gray == img_gray # image not modified
end

## Test API
# Test for argument errors on algorithms that don't support custom color palletes
for alg in [WhiteNoiseThreshold(), ConstantThreshold()]
    @test_throws ColorNotImplementedError dither(img, alg, cs)
end

img2 = copy(img)
alg = FloydSteinberg()
d = dither(img2, alg, cs)

# Test setting output type
d2 = dither(HSV, img2, alg, cs)
@test d2 isa IndirectArray
@test eltype(d2) <: HSV
@test RGB{N0f8}.(d2) ≈ d
@test img2 == img # image not modified

# Inplace modify output image
out = zeros(RGB{Float16}, size(img2)...)
d3 = dither!(out, img2, alg, cs)
@test out ≈ d # image updated in-place
@test d3 ≈ d
@test eltype(out) == RGB{Float16}
@test eltype(d3) == RGB{Float16}
@test img2 == img # image not modified

# Inplace modify  image
d4 = dither!(img2, alg, cs)
@test d4 == d
@test img2 == d # image updated in-place
@test eltype(d4) == eltype(img)
@test eltype(img2) == eltype(img)

## Conditional dependencies
# Test conditional dependency on ColorSchemes.jl
using ColorSchemes
@test dither(img, alg, ColorSchemes.jet) == dither(img, alg, :jet)

# Dry-run conditional dependency on Clustering.jl
using Clustering
d = dither(img, alg, 4)
