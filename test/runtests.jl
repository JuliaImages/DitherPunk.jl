using DitherPunk
using Test

@testset "DitherPunk.jl" begin
    @testset "Utilities" begin
        include("test_utils.jl")
    end
    @testset "Bayer matrices" begin
        include("test_bayer.jl")
    end
    @testset "Gradient image" begin
        include("test_gradient.jl")
    end
    @testset "Color image" begin
        @testset "Fixed palette" begin
            include("test_fixed_color.jl")
        end
        @testset "Custom palette" begin
            include("test_color.jl")
        end
    end
end
