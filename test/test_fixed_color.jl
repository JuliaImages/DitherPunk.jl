using DitherPunk
using ImageCore
using TestImages

# Load test image
img = testimage("fabio_color_256")
imshow(img)

# Run & test fixed pallete dithering methods
algs = Dict(
    "SeparateSpaceFloydSteinberg" => SeparateSpace(FloydSteinberg()),
    "SeparateSpaceBayer" => SeparateSpace(Bayer()),
)

for C in [RGB, HSV]
    for (name, alg) in algs
        img1 = C.(img)
        img2 = copy(img1)
        d = dither(img2, alg)
        @test_reference "references/fixed_color_$(C)_$(name).txt" d
        @test eltype(d) <: C
        @test img2 == img1 # image not modified

        imshow(d)

        d = dither!(img2, alg)
        @test eltype(d) <: C
        @test img2 == d # image updated in-place
    end
end
