using DitherPunk
using Images
using TestImages

# # Image Gallery
# This gallery uses images from [*TestImages.jl*](https://testimages.juliaimages.org).
function preprocess(img)
    img = Gray.(img)
    return imresize(img; ratio = 1 / 2)
end

file_names = [
    "cameraman", "lake_gray", "house", "fabio_gray_512", "mandril_gray", "peppers_gray",
]
img = mosaic([preprocess(testimage(file)) for file in file_names]; ncol = 3)

# ## Threshold dithering
# #### `ConstantThreshold`
dither(img, ConstantThreshold())

# #### `WhiteNoiseThreshold`
dither(img, WhiteNoiseThreshold())

# ## Ordered dithering
# #### Bayer matrices
# **Level 1**
dither(img, Bayer())
# **Level 2**
dither(img, Bayer(2))
# **Level 3**
dither(img, Bayer(3))
# **Level 4**
dither(img, Bayer(4))

# #### `ClusteredDots`
dither(img, ClusteredDots())

# #### `CentralWhitePoint`
dither(img, CentralWhitePoint())

# #### `BalancedCenteredPoint`
dither(img, BalancedCenteredPoint())

# #### `Rhombus`
dither(img, Rhombus())

# #### ImageMagick methods
dither(img, IM_checks())
#
dither(img, IM_h4x4a())
#
dither(img, IM_h6x6a())
#
dither(img, IM_h8x8a())
#
dither(img, IM_h4x4o())
#
dither(img, IM_h6x6o())
#
dither(img, IM_h8x8o())
#
dither(img, IM_c5x5())
#
dither(img, IM_c6x6())
#
dither(img, IM_c7x7())

# ## Error diffusion
# #### `SimpleErrorDiffusion`
dither(img, SimpleErrorDiffusion())

# #### `FloydSteinberg`
dither(img, FloydSteinberg())

# #### `JarvisJudice`
dither(img, JarvisJudice())

# #### `Stucki`
dither(img, Stucki())

# #### `Burkes`
dither(img, Burkes())

# #### `Sierra`
dither(img, Sierra())

# #### `TwoRowSierra`
dither(img, TwoRowSierra())

# #### `SierraLite`
dither(img, SierraLite())

# #### `Fan93()`
dither(img, Fan93())

# #### `ShiauFan()`
dither(img, ShiauFan())

# #### `ShiauFan2()`
dither(img, ShiauFan2())

# #### `Atkinson()`
dither(img, Atkinson())
