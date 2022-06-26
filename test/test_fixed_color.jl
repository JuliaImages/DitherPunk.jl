using DitherPunk
using ImageBase
using ReferenceTests
using TestImages

# Load test image
img = testimage("fabio_color_256")

# Run & test fixed palette dithering methods
algs = Dict("FloydSteinberg" => FloydSteinberg(), "Bayer" => Bayer())

for C in [RGB, HSV]
    for (name, alg) in algs
        img1 = C.(img)
        local img2 = copy(img1)
        if alg isa ErrorDiffusion
            local d = @inferred dither(transpose(img2), alg)
            @test_reference "references/per-channel/$(name)_$(C).txt" transpose(d)
        else
            local d = @inferred dither(img2, alg)
            @test_reference "references/per-channel/$(name)_$(C).txt" d
        end
        @test eltype(d) <: C
        @test img2 == img1 # image not modified

        # TODO: comment back in when tests pass
        # local d = @inferred dither!(img2, alg)
        # @test eltype(d) <: C
        # @test img2 == d # image updated in-place
    end
end
