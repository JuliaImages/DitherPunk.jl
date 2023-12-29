using DitherPunk
using Test
using Aqua
using ImageBase: Gray

function gradient_image(height, width)
    row = reshape(range(0; stop=1, length=width), 1, width)
    grad = Gray.(vcat(repeat(row, height))) # Linear gradient
    img = srgb2linear.(grad) # For printing, compensate for SRGB colorspace
    return grad, img
end

@testset "DitherPunk.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(DitherPunk; ambiguities=false)
    end
    @testset "Utilities" begin
        @info "Testing utilities..."
        include("test_utils.jl")
    end
    @testset "Bayer matrices" begin
        @info "Testing Bayer matrices..."
        include("test_bayer.jl")
    end
    @testset "Binary dithering" begin
        @info "Testing binary dithering..."
        include("test_gradient.jl")
    end
    @testset "Braille" begin
        @info "Testing printing to braille..."
        include("test_braille.jl")
    end
    @testset "Color image" begin
        @testset "Fixed palette" begin
            @info "Testing per-channel dithering..."
            include("test_fixed_color.jl")
        end
        @testset "Custom palette" begin
            @info "Testing color palette dithering..."
            include("test_color.jl")
        end
    end
end
