using DitherPunk
using Test
using Aqua

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
