using DitherPunk
using DitherPunk: DEFAULT_METHOD, AbstractDither
using ImageBase: Gray
using OffsetArrays

using Test
using ReferenceTests

include("gradient_image.jl")

img, srgb = gradient_image(16, 200)

isoutputrandom(::AbstractDither) = false
isoutputrandom(::WhiteNoiseThreshold) = true

## Run reference tests for deterministic algorithms
# using Dict for Julia 1.0 compatibility
const ALGS = Dict(
    # threshold methods
    "ConstantThreshold"   => ConstantThreshold(),
    "ClosestColor"        => ClosestColor(),
    "WhiteNoiseThreshold" => WhiteNoiseThreshold(),
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

# Test setting output type
@testset verbose = true "Binary dithering methods" begin
    @testset "$(name)" for (name, alg) in ALGS
        _img = copy(img)
        dref = @inferred dither(_img, alg)
        @test eltype(dref) == eltype(img)
        @test _img == img # image not modified

        if !isoutputrandom(alg)
            @testset "Reference tests" begin
                @test_reference "references/gradient/$(name).txt" braille(
                    dref; to_string=true
                )
            end
        end

        @testset "Output type selection: $T" for T in (Float16, Float32, Bool)
            d2 = @inferred dither(Gray{T}, _img, alg)
            @test eltype(d2) == Gray{T}
            @test d2 ≈ dref
            @test _img == img # image not modified
        end

        # Inplace modify output image
        @testset "In-place updates" begin
            @testset "2-arg" begin
                out = zeros(Bool, size(_img)...)
                d_inplace = @inferred dither!(out, _img, alg)
                @test eltype(out) == Bool
                @test out == dref # image updated in-place
                @test d_inplace === out
                @test _img == img # image not modified
            end

            @testset "3-arg" begin
                # Inplace modify  image
                imgcopy = deepcopy(img)
                d4 = @inferred dither!(imgcopy, alg)
                @test d4 == dref
                @test imgcopy === d4 # image updated in-place
                @test eltype(d4) == eltype(_img)
            end
        end
    end
end

## Test API
@testset "Default algorithm" begin
    _img = copy(img)

    d1 = @inferred dither(_img, DEFAULT_METHOD)
    d1_default = @inferred dither(_img)
    @test d1_default == d1

    d2 = @inferred dither(Gray{Float16}, _img, DEFAULT_METHOD)
    d2_default = @inferred dither(Gray{Float16}, _img)
    @test d2_default == d2

    out = zeros(Bool, size(_img)...)
    d3_default = @inferred dither!(out, _img)
    @test out == d1
    @test d3_default === out

    imgcopy = deepcopy(_img)
    d4_default = @inferred dither!(imgcopy)
    @test d4_default == d1
    @test d4_default === imgcopy
end

# Test error diffusion kwarg `clamp_error`:
@testset "clamp_error" begin
    d = @inferred dither(img, FloydSteinberg(); clamp_error=false)
    @test_reference "references/gradient/FloydSteinberg_clamp_error.txt" braille(
        d; to_string=true
    )
    @test eltype(d) == eltype(img)
end

## Test to_linear
@testset "to_linear" begin
    _img = copy(img)
    d = @inferred dither(_img, Bayer(); to_linear=true)
    @test_reference "references/gradient/Bayer_linear.txt" braille(d; to_string=true)
    dl1 = @inferred dither(_img, DEFAULT_METHOD; to_linear=true)
    dl2 = @inferred dither(_img; to_linear=true)
    @test dl1 == dl2
end

## Test error messages
@testset "Error messages" begin
    @test_throws DomainError ConstantThreshold(; threshold=-0.5)

    img_zero_based = OffsetMatrix(rand(Float32, 10, 10), 0:9, 0:9)
    @test_throws ArgumentError dither(img_zero_based, FloydSteinberg())
    @test_throws ArgumentError dither(img_zero_based)
end
