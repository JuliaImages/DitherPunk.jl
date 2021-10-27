using DitherPunk
using Images
using TestImages

function preprocess(img)
    img = Gray.(img)
    return imresize(img; ratio=1 / 2)
end

file_names = [
    "cameraman", "lake_gray", "house", "fabio_gray_512", "mandril_gray", "peppers_gray"
]
imgs = [preprocess(testimage(file)) for file in file_names]
mosaic(imgs; ncol=3)

function test_on_images(alg; to_linear=false)
    dithers = [dither(img, alg; to_linear) for img in imgs]
    return mosaic(dithers; ncol=3)
end

test_on_images(ConstantThreshold())

test_on_images(WhiteNoiseThreshold())

test_on_images(Bayer())

test_on_images(Bayer(; level=2))

test_on_images(Bayer(; level=3))

test_on_images(Bayer(; level=4))

test_on_images(ClusteredDots())

test_on_images(CentralWhitePoint())

test_on_images(BalancedCenteredPoint())

test_on_images(Rhombus())

test_on_images(IM_checks())

test_on_images(IM_h4x4a())

test_on_images(IM_h6x6a())

test_on_images(IM_h8x8a())

test_on_images(IM_h4x4o())

test_on_images(IM_h6x6o())

test_on_images(IM_h8x8o())

test_on_images(IM_c5x5())

test_on_images(IM_c6x6())

test_on_images(IM_c7x7())

test_on_images(SimpleErrorDiffusion())

test_on_images(FloydSteinberg())

test_on_images(JarvisJudice())

test_on_images(Stucki())

test_on_images(Burkes())

test_on_images(Sierra())

test_on_images(TwoRowSierra())

test_on_images(SierraLite())

test_on_images(Fan93())

test_on_images(ShiauFan())

test_on_images(ShiauFan2())

test_on_images(Atkinson())

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

