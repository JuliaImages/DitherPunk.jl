using DitherPunk
using DitherPunk: gradient_image
using ReferenceTests

using ImageCore
using ImageCore: GenericGrayImage
using ImageInTerminal
using UnicodePlots

w = 200
h = 4 * 4 # multiple of 4 for unicode braille print
img, srgb = gradient_image(h, w)
println("Test image:")
imshow(srgb)

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
)

for (name, alg) in algs_deterministic
    img2 = copy(img)
    d = dither(img2, alg)
    @test_reference "references/grad_$(name).txt" Int.(d)
    @test eltype(d) == eltype(img)
    @test img2 == img # image not modified

    show(brailleprint(d; title=name)) # Visualize in terminal

    d = dither!(img2, alg; to_linear=true)
    @test_reference "references/grad_$(name)_linear.txt" Int.(d)
    @test eltype(d) == eltype(img)
    @test img2 == d # image updated in-place
end

## Algorithms with random output are currently only tested visually
algs_random = Dict(
    # threshold methods
    "white_noise_dithering" => WhiteNoiseThreshold(),
)

for (name, alg) in algs_random
    img2 = copy(img)
    d = dither(Gray{Bool}, img2, alg)
    show(brailleprint(d; title=name)) # Visualize in terminal
    @test eltype(d) == Gray{Bool}
    @test img2 == img # image not modified

    d = dither!(img2, alg; to_linear=true)
    show(brailleprint(d; title="$(name) linear")) # Visualize in terminal
    @test eltype(d) == eltype(img)
    @test img2 == d # image updated in-place
end
