using DitherPunk
using Test

@testset "DitherPunk.jl" begin
    @testset "Bayer matrices" begin
        include("test_bayer.jl")
    end
    @testset "Gradient image" begin
        include("test_gradient.jl")
    end
    @testset "Color image" begin
        @testset "Custom palette" begin
            include("test_color.jl")
        end
        @testset "Fixed palette" begin
            include("test_fixed_color.jl")
        end
    end
end
