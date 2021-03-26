using DitherPunk
using Test
using SafeTestsets

@time @safetestset "DitherPunk.jl" begin
    @time @safetestset "Gradient image" begin
        include("test_gradient.jl")
    end
    @time @safetestset "Test image" begin
        include("test_img.jl")
    end
end
