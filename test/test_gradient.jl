using DitherPunk
using ReferenceTests
using OffsetArrays

img, srgb = gradient_image(16, 200)

## Run reference tests for deterministic algorithms
# using Dict for Julia 1.0 compatibility
algs_deterministic = Dict(
    # threshold methods
    "ConstantThreshold" => ConstantThreshold(),
    "ClosestColor"      => ClosestColor(),
    # ordered dithering
    "Bayer"                 => Bayer(),
    "Bayer_l2"              => Bayer(2),
    "Bayer_l3"              => Bayer(3),
    "Bayer_l4"              => Bayer(4),
    "ClusteredDots"         => ClusteredDots(),
    "CentralWhitePoint"     => CentralWhitePoint(),
    "BalancedCenteredPoint" => BalancedCenteredPoint(),
    "Rhombus"               => Rhombus(),
    "IM_checks"             => IM_checks(),
    "IM_h4x4a"              => IM_h4x4a(),
    "IM_h6x6a"              => IM_h6x6a(),
    "IM_h8x8a"              => IM_h8x8a(),
    "IM_h4x4o"              => IM_h4x4o(),
    "IM_h6x6o"              => IM_h6x6o(),
    "IM_h8x8o"              => IM_h8x8o(),
    "IM_c5x5"               => IM_c5x5(),
    "IM_c6x6"               => IM_c6x6(),
    "IM_c7x7"               => IM_c7x7(),
    # error error_diffusion
    "SimpleErrorDiffusion" => @inferred(SimpleErrorDiffusion()),
    "FloydSteinberg"       => @inferred(FloydSteinberg()),
    "JarvisJudice"         => @inferred(JarvisJudice()),
    "Stucki"               => @inferred(Stucki()),
    "Burkes"               => @inferred(Burkes()),
    "Atkinson"             => @inferred(Atkinson()),
    "Sierra"               => @inferred(Sierra()),
    "TwoRowSierra"         => @inferred(TwoRowSierra()),
    "SierraLite"           => @inferred(SierraLite()),
    "Fan"                  => @inferred(Fan93()),
    "ShiauFan"             => @inferred(ShiauFan()),
    "ShiauFan2"            => @inferred(ShiauFan2()),
    "FalseFloydSteinberg"  => @inferred(DitherPunk.FalseFloydSteinberg()),
    # Keyword arguments
    "Bayer_invert_map" => Bayer(; invert_map=true),
)

for (name, alg) in algs_deterministic
    local img2 = copy(img)
    local d = @inferred dither(img2, alg)
    @test_reference "references/gradient/$(name).txt" braille(d; to_string=true)
    @test eltype(d) == eltype(img)
    @test img2 == img # image not modified
end

# Test error diffusion kwarg `clamp_error`:
d = @inferred dither(img, FloydSteinberg(); clamp_error=false)
@test_reference "references/gradient/FloydSteinberg_clamp_error.txt" braille(
    d; to_string=true
)
@test eltype(d) == eltype(img)

## Algorithms with random output are currently only tested visually
algs_random = Dict(
    # threshold methods
    "white_noise_dithering" => WhiteNoiseThreshold(),
)

for (name, alg) in algs_random
    local img2 = copy(img)
    local d = @inferred dither(Gray{Bool}, img2, alg)
    @test eltype(d) == Gray{Bool}
    @test img2 == img # image not modified
end

## Test to_linear
img2 = copy(img)
d = @inferred dither(img2, Bayer(); to_linear=true)
@test_reference "references/gradient/Bayer_linear.txt" braille(d; to_string=true)
alg = FloydSteinberg()
dl1 = @inferred dither(img2, alg; to_linear=true)
dl2 = @inferred dither(img2; to_linear=true)
@test dl1 == dl2

## Test API
d = @inferred dither(img2, alg)
ddef = @inferred dither(img2)
@test d == ddef

# Test setting output type
d2 = @inferred dither(Gray{Float16}, img2, alg)
@test eltype(d2) == Gray{Float16}
@test d2 == d
@test img2 == img # image not modified
d2def = @inferred dither(Gray{Float16}, img2)
@test d2 == d2def

# Inplace modify output image
out = zeros(Bool, size(img2)...)
d3 = @inferred dither!(out, img2, alg)
@test out == d # image updated in-place
@test d3 == d
@test eltype(out) == Bool
@test eltype(d3) == Bool
@test img2 == img # image not modified
outdef = zeros(Bool, size(img2)...)
d3def = @inferred dither!(outdef, img2)
@test out == outdef
@test d3 == d3def

# Inplace modify  image
img2def = deepcopy(img2)
d4 = @inferred dither!(img2, alg)
@test d4 == d
@test img2 == d # image updated in-place
@test eltype(d4) == eltype(img)
@test eltype(img2) == eltype(img)
d4def = @inferred dither!(img2def)
@test d4 == d4def
@test img2 == img2def

## Test error messages
@test_throws DomainError ConstantThreshold(; threshold=-0.5)

img_zero_based = OffsetMatrix(rand(Float32, 10, 10), 0:9, 0:9)
@test_throws ArgumentError dither(img_zero_based, FloydSteinberg())
@test_throws ArgumentError dither(img_zero_based)
