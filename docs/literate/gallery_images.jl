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
    dithers = [Gray.(dither(img, alg; to_linear)) for img in imgs]
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
test_on_images(Bayer(; level=2))
# **Level 3**
test_on_images(Bayer(; level=3))
# **Level 4**
test_on_images(Bayer(; level=4))

# #### `ClusteredDots`
test_on_images(ClusteredDots())

# #### `CentralWhitePoint`
test_on_images(CentralWhitePoint())

# #### `BalancedCenteredPoint`
test_on_images(BalancedCenteredPoint())

# #### `Rhombus`
test_on_images(Rhombus())

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

# #### `Atkinson()`
test_on_images(Atkinson())
