using DitherPunk
using Images
using TestImages

# # Test image gallery
# This gallery uses images from [*TestImages.jl*](https://testimages.juliaimages.org).
function preprocess(img)
    img = Gray.(img)
    return imresize(img; ratio=1 / 2)
end

file_names = [
    "cameraman", "lake_gray", "house", "fabio_gray_512", "mandril_gray", "peppers_gray"
]
imgs = [preprocess(testimage(file)) for file in file_names]
mosaic(imgs; ncol=3)

# Our test function `test_on_images` just runs a dithering algorithm on all six images
# in linear color space (`to_liner=true`).
function test_on_images(alg; to_linear=false)
    dithers = [dither(img, alg; to_linear) for img in imgs]
    return mosaic(dithers; ncol=3)
end

# ## Threshold dithering
# #### `ConstantThreshold`
test_on_images(ConstantThreshold())

# #### `WhiteNoiseThreshold`
test_on_images(WhiteNoiseThreshold())

# ## Ordered dithering
# #### Bayer matrices
# **Level 1**
test_on_images(Bayer())
# **Level 2**
test_on_images(Bayer(2))
# **Level 3**
test_on_images(Bayer(3))
# **Level 4**
test_on_images(Bayer(4))

# #### `ClusteredDots`
test_on_images(ClusteredDots())

# #### `CentralWhitePoint`
test_on_images(CentralWhitePoint())

# #### `BalancedCenteredPoint`
test_on_images(BalancedCenteredPoint())

# #### `Rhombus`
test_on_images(Rhombus())

# #### ImageMagick methods
test_on_images(IM_checks())
#
test_on_images(IM_h4x4a())
#
test_on_images(IM_h6x6a())
#
test_on_images(IM_h8x8a())
#
test_on_images(IM_h4x4o())
#
test_on_images(IM_h6x6o())
#
test_on_images(IM_h8x8o())
#
test_on_images(IM_c5x5())
#
test_on_images(IM_c6x6())
#
test_on_images(IM_c7x7())

# ## Error diffusion
# #### `SimpleErrorDiffusion`
test_on_images(SimpleErrorDiffusion())

# #### `FloydSteinberg`
test_on_images(FloydSteinberg())

# #### `JarvisJudice`
test_on_images(JarvisJudice())

# #### `Stucki`
test_on_images(Stucki())

# #### `Burkes`
test_on_images(Burkes())

# #### `Sierra`
test_on_images(Sierra())

# #### `TwoRowSierra`
test_on_images(TwoRowSierra())

# #### `SierraLite`
test_on_images(SierraLite())

# #### `Fan93()`
test_on_images(Fan93())

# #### `ShiauFan()`
test_on_images(ShiauFan())

# #### `ShiauFan2()`
test_on_images(ShiauFan2())

# #### `Atkinson()`
test_on_images(Atkinson())
