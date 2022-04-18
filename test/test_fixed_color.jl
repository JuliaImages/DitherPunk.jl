using DitherPunk
using ImageCore
using ImageInTerminal
using ReferenceTests
using TestImages

# Load test image
img = testimage("fabio_color_256")

# Run & test fixed pallete dithering methods
algs = Dict("FloydSteinberg" => FloydSteinberg(), "Bayer" => Bayer())

for C in [RGB, HSV]
    for (name, alg) in algs
        img1 = C.(img)
        local img2 = copy(img1)
        local d = dither(img2, alg)
        @test_reference "references/per-channel/$(name)_$(C).txt" d
        @test eltype(d) <: C
        @test img2 == img1 # image not modified

        local d = dither!(img2, alg)
        @test eltype(d) <: C
        @test img2 == d # image updated in-place
    end
end
