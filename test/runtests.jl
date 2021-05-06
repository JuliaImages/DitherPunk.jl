using DitherPunk
using Test

@testset "DitherPunk.jl" begin
    @testset "Bayer matrices" begin
        include("test_bayer.jl")
    end
    @testset "Gradient image" begin
        include("test_gradient.jl")
    end
end