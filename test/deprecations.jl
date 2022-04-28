@testset "test deprecated usage" begin
    alg = FloydSteinberg()
    @test alg == ErrorDiffusion(DitherPunk._floydsteinberg_filter; color_space=XYZ)
end
