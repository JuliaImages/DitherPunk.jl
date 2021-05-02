using DitherPunk
using Test
using SafeTestsets

@time @safetestset "DitherPunk.jl" begin
    @time @safetestset "Gradient image" begin
        include("test_bayer.jl")
        include("test_gradient.jl")
    end
end
