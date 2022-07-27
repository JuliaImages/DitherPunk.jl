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
        local d = @inferred dither(img2, alg)
        @test_reference "references/per-channel/$(name)_$(C).txt" d
        @test eltype(d) <: C
        @test img2 == img1 # image not modified

        local d = @inferred dither!(img2, alg)
        @test eltype(d) <: C
        @test img2 == d # image updated in-place
    end
end

# Test error diffusion kwarg `clamp_error`:
d = @inferred dither(img, FloydSteinberg(); clamp_error=false)
@test_reference "references/per-channel/FloydSteinberg_clamp_error.txt" d
@test eltype(d) == eltype(img)

# Test default algorithm
d1 = @inferred dither(img, FloydSteinberg())
d2 = @inferred dither(img)
@test d1 == d2
img3 = deepcopy(img)
img4 = deepcopy(img)
d3 = @inferred dither!(img3, FloydSteinberg())
d4 = @inferred dither!(img4)
@test d3 == d4
@test img3 == img4
@test d4 == img4
