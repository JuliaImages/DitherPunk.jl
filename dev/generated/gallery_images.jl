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
img = mosaic([preprocess(testimage(file)) for file in file_names]; ncol=3)

dither(img, ConstantThreshold())

dither(img, WhiteNoiseThreshold())

dither(img, Bayer())

dither(img, Bayer(2))

dither(img, Bayer(3))

dither(img, Bayer(4))

dither(img, ClusteredDots())

dither(img, CentralWhitePoint())

dither(img, BalancedCenteredPoint())

dither(img, Rhombus())

dither(img, IM_checks())

dither(img, IM_h4x4a())

dither(img, IM_h6x6a())

dither(img, IM_h8x8a())

dither(img, IM_h4x4o())

dither(img, IM_h6x6o())

dither(img, IM_h8x8o())

dither(img, IM_c5x5())

dither(img, IM_c6x6())

dither(img, IM_c7x7())

dither(img, SimpleErrorDiffusion())

dither(img, FloydSteinberg())

dither(img, JarvisJudice())

dither(img, Stucki())

dither(img, Burkes())

dither(img, Sierra())

dither(img, TwoRowSierra())

dither(img, SierraLite())

dither(img, Fan93())

dither(img, ShiauFan())

dither(img, ShiauFan2())

dither(img, Atkinson())

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

