using DitherPunk
using DitherPunk: ColorNotImplementedError
using IndirectArrays
using ImageBase
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

# Run & test custom color palette dithering methods
algs = Dict(
    "FloydSteinberg_XYZ" => @inferred(FloydSteinberg(XYZ)),
    "FloydSteinberg_RGB" => @inferred(FloydSteinberg(RGB)),
    "ClosestColor" => @inferred(ClosestColor()),
    "Bayer" => @inferred(Bayer()),
)

for (name, alg) in algs
    # Test custom color dithering on color images
    local img2 = copy(img)
    local d = @inferred dither(img2, alg, cs)
    @test_reference "references/color/$(name).txt" d
    @test eltype(d) == eltype(img2)
    @test img2 == img # image not modified

    # Test custom color dithering on gray images
    local img2_gray = copy(img_gray)
    local d = @inferred dither(img2_gray, alg, cs)
    @test_reference "references/color/$(name)_from_gray.txt" d
    @test eltype(d) == eltype(cs)
    @test img2_gray == img_gray # image not modified
end

## Test API
# Test for argument errors on algorithms that don't support custom color palettes
for alg in [WhiteNoiseThreshold(), ConstantThreshold()]
    @test_throws ColorNotImplementedError dither(img, alg, cs)
end

img2 = copy(img)
alg = FloydSteinberg()
d = dither(img2, alg, cs)

# Test setting output type
d2 = @inferred dither(HSV, img2, alg, cs)
@test d2 isa IndirectArray
@test eltype(d2) <: HSV
@test RGB{N0f8}.(d2) ≈ d
@test img2 == img # image not modified
d2default = @inferred dither(HSV, img2, cs)
@test d2 == d2default

# Inplace modify output image
out = zeros(RGB{Float16}, size(img2)...)
d3 = @inferred dither!(out, img2, alg, cs)
@test out ≈ d # image updated in-place
@test d3 ≈ d
@test eltype(out) == RGB{Float16}
@test eltype(d3) == RGB{Float16}
@test img2 == img # image not modified
out = zeros(RGB{Float16}, size(img2)...)
d3default = @inferred dither!(out, img2, cs)
@test d2 == d2default

# Inplace modify  image
d4 = @inferred dither!(img2, alg, cs)
@test d4 == d
@test img2 == d # image updated in-place
@test eltype(d4) == eltype(img)
@test eltype(img2) == eltype(img)
img2default = deepcopy(img)
d4default = @inferred dither!(img2default, cs)
@test img2default == d
@test d4 == d4default

## Conditional dependencies
# Test conditional dependency on ColorSchemes.jl
using ColorSchemes
d1 = @inferred dither(img, alg, ColorSchemes.jet)
d2 = @inferred dither(img, alg, ColorSchemes.jet.colors)
@test d1 == d2
d3 = @inferred dither(img, ColorSchemes.jet)
d4 = @inferred dither(img, ColorSchemes.jet.colors)
@test d3 == d1
@test d3 == d4

# calls Clustering
d = @inferred dither(img, alg, 4)
d = @inferred dither(img, 4)
