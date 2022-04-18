using DitherPunk
using DitherPunk: gradient_image
using ReferenceTests

using ImageCore
using ImageCore: GenericGrayImage
using UnicodePlots

w = 200
h = 4 * 4 # multiple of 4 for unicode braille print
img, srgb = gradient_image(h, w)

## Run reference tests for deterministic algorithms
# using Dict for Julia 1.0 compatibility
algs_deterministic = Dict(
    # threshold methods
    "ConstantThreshold" => ConstantThreshold(),
    "ClosestColor" => ClosestColor(),
    # ordered dithering
    "Bayer" => Bayer(),
    "Bayer_l2" => Bayer(; level=2),
    "Bayer_l3" => Bayer(; level=3),
    "Bayer_l4" => Bayer(; level=4),
    "ClusteredDots" => ClusteredDots(),
    "CentralWhitePoint" => CentralWhitePoint(),
    "BalancedCenteredPoint" => BalancedCenteredPoint(),
    "Rhombus" => Rhombus(),
    "IM_checks" => IM_checks(),
    "IM_h4x4a" => IM_h4x4a(),
    "IM_h6x6a" => IM_h6x6a(),
    "IM_h8x8a" => IM_h8x8a(),
    "IM_h4x4o" => IM_h4x4o(),
    "IM_h6x6o" => IM_h6x6o(),
    "IM_h8x8o" => IM_h8x8o(),
    "IM_c5x5" => IM_c5x5(),
    "IM_c6x6" => IM_c6x6(),
    "IM_c7x7" => IM_c7x7(),
    # error error_diffusion
    "SimpleErrorDiffusion" => SimpleErrorDiffusion(),
    "FloydSteinberg" => FloydSteinberg(),
    "JarvisJudice" => JarvisJudice(),
    "Stucki" => Stucki(),
    "Burkes" => Burkes(),
    "Atkinson" => Atkinson(),
    "Sierra" => Sierra(),
    "TwoRowSierra" => TwoRowSierra(),
    "SierraLite" => SierraLite(),
    "Fan" => Fan93(),
    "ShiauFan" => ShiauFan(),
    "ShiauFan2" => ShiauFan2(),
    "FalseFloydSteinberg" => DitherPunk.FalseFloydSteinberg(),
    # Keyword arguments
    "FloydSteinberg_clamp_error" => FloydSteinberg(; clamp_error=false),
    "Bayer_invert_map" => Bayer(; invert_map=true),
)

for (name, alg) in algs_deterministic
    local img2 = copy(img)
    local d = dither(img2, alg)
    @test_reference "references/gradient/$(name).txt" Int.(d)
    @test eltype(d) == eltype(img)
    @test img2 == img # image not modified
end

## Algorithms with random output are currently only tested visually
algs_random = Dict(
    # threshold methods
    "white_noise_dithering" => WhiteNoiseThreshold(),
)

for (name, alg) in algs_random
    local img2 = copy(img)
    local d = dither(Gray{Bool}, img2, alg)
    @test eltype(d) == Gray{Bool}
    @test img2 == img # image not modified
end

## Test to_linear
img2 = copy(img)
alg = Bayer()
d = dither(img2, alg; to_linear=true)
@test_reference "references/gradient/Bayer_linear.txt" Int.(d)

## Test API
d = dither(img2, alg)

# Test setting output type
d2 = dither(Gray{Float16}, img2, alg)
@test eltype(d2) == Gray{Float16}
@test d2 == d
@test img2 == img # image not modified

# Inplace modify output image
out = zeros(Bool, size(img2)...)
d3 = dither!(out, img2, alg)
@test out == d # image updated in-place
@test d3 == d
@test eltype(out) == Bool
@test eltype(d3) == Bool
@test img2 == img # image not modified

# Inplace modify  image
d4 = dither!(img2, alg)
@test d4 == d
@test img2 == d # image updated in-place
@test eltype(d4) == eltype(img)
@test eltype(img2) == eltype(img)

## Test error messages
@test_throws DomainError ConstantThreshold(; threshold=-0.5)

img_zero_based = DitherPunk.OffsetMatrix(rand(Float32, 10, 10), 0:9, 0:9)
@test_throws ArgumentError dither(img_zero_based, FloydSteinberg())
