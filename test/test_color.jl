using DitherPunk
using DitherPunk: DEFAULT_METHOD, AbstractDither
using DitherPunk: ColorNotImplementedError
using DitherPunk: RuntimeColorPicker, LookupColorPicker, FastEuclideanMetric, colorspace
using Test

using ColorSchemes
using IndirectArrays
using ColorTypes: RGB, HSV
using Colors: DE_2000, DE_BFD
using FixedPointNumbers: N0f8
using ReferenceTests
using TestImages

## Define color scheme
colorscheme = ColorSchemes.PuOr_6

# Load test image
img = testimage("fabio_color_256")
img_gray = testimage("fabio_gray_256")

@testset verbose = true "Color dithering defaults" begin
    d = @inferred dither(img, colorscheme)
    @info d typeof(d)
    @test_reference "references/color/default.png" d

    d = @inferred dither(img_gray, colorscheme)
    @info d typeof(d)
    @test_reference "references/color/default_from_gray.png" d
end

# Run & test custom color palette dithering methods
COLOR_ALGS = (FloydSteinberg, ClosestColor, Bayer)
COLOR_METRICS = (FastEuclideanMetric, DE_2000, DE_BFD)
COLOR_PICKERS = (RuntimeColorPicker, LookupColorPicker)

@testset verbose = true "Color dithering methods" begin
    @testset "$(Method)" for Method in COLOR_ALGS
        alg = Method()
        @testset "$(Metric)" for Metric in COLOR_METRICS
            metric = Metric()
            CS = colorspace(metric)
            @testset "$(ColorPicker)" for ColorPicker in COLOR_PICKERS
                colorpicker = ColorPicker(colorscheme, metric)

                # Test custom color dithering on color images
                local img_copy = copy(img)
                local d = @inferred dither(img_copy, alg, cs; colorpicker=colorpicker)
                @test_reference "references/color/$(Method)_$(Metric)_$(CS).png" d

                @test eltype(d) == eltype(img_copy)
                @test img_copy == img # image not modified

                # Test custom color dithering on gray images
                local img_copy_gray = copy(img_gray)
                local d = @inferred dither(img_copy_gray, alg, cs; colorpicker=colorpicker)
                @test_reference "references/color/$(Method)_$(Metric)_$(CS)_from_gray.png" d

                @test eltype(d) == eltype(cs)
                @test img_copy_gray == img_gray # image not modified
            end
        end
    end
end

# Test error diffusion kwarg `clamp_error`:
@testset "clamp_error" begin
    d = @inferred dither(img, FloydSteinberg(), cs; clamp_error=false)
    @test_reference "references/color/FloydSteinberg_clamp_error.txt" d
    @test eltype(d) == eltype(img)
end

## Test API
@testset "ColorNotImplementedError" begin
    # Test for argument errors on algorithms that don't support custom color palettes
    @testset "$(alg)" for alg in (WhiteNoiseThreshold(), ConstantThreshold())
        @test_throws ColorNotImplementedError dither(img, alg, cs)
    end
end

img_copy = copy(img)
d_ref = dither(img_copy, DEFAULT_METHOD, cs)

# Test setting output type
@testset "Custom output type" begin
    d = @inferred dither(HSV, img_copy, DEFAULT_METHOD, cs)
    @test d isa IndirectArray
    @test eltype(d) <: HSV
    @test RGB{N0f8}.(d) ≈ d_ref
    @test img_copy == img # image not modified

    d_default = @inferred dither(HSV, img_copy, cs)
    @test d_default == d
end

# Inplace modify output image
@testset "Inplace modify 3-arg" begin
    out = zeros(RGB{Float16}, size(img_copy)...)
    d = @inferred dither!(out, img_copy, DEFAULT_METHOD, cs)
    @test out === d # image updated in-place
    @test eltype(out) == RGB{Float16}
    @test d ≈ d_ref
    @test img_copy == img # image not modified

    out = zeros(RGB{Float16}, size(img_copy)...)
    d_default = @inferred dither!(out, img_copy, cs)
    @test d_default == d
end

# Inplace modify  image
@testset "Inplace modify 2-arg" begin
    img_copy = deepcopy(img)
    d = @inferred dither!(img_copy, DEFAULT_METHOD, cs)
    @test d == d_ref
    @test img_copy === d # image updated in-place
    @test img_copy != img # image updated in-place
    @test eltype(d) == eltype(img)
    @test eltype(img_copy) == eltype(img)

    img_copy = deepcopy(img)
    d_default = @inferred dither!(img_copy, cs)
    @test img_copy === d_default
    @test d_default == d
end

## Conditional dependencies
# Test conditional dependency on ColorSchemes.jl
@testset "Colorschemes.jl" begin
    d1 = @inferred dither(img, DEFAULT_METHOD, ColorSchemes.jet)
    d2 = @inferred dither(img, DEFAULT_METHOD, ColorSchemes.jet.colors)
    @test d1 == d2
    d3 = @inferred dither(img, ColorSchemes.jet)
    d4 = @inferred dither(img, ColorSchemes.jet.colors)
    @test d3 == d1
    @test d3 == d4
end

# calls Clustering
@testset "Automatic colorscheme" begin
    @test_nowarn @inferred dither(img, DEFAULT_METHOD, 4)
    @test_nowarn @inferred dither(img, 4)
end
