using DitherPunk
using DitherPunk: gradient_image, test_on_gradient
using Images

# # Gallery
# ## On color spaces
# A simple linear gradient works well to reveal the characteristic patterns of
# different dithering algorithms.
srbg, linear = gradient_image(100, 800);
mosaicview(srbg, linear)
# The pixel intensities in the image `srgb` increase linearly from 0 to 1.
# The second image `linear` has been converted from sRGB to a linear representation,
# which more closely matches our human perception of brightness.
#
# The helper function `test_on_gradient` takes a dithering algorithm and runs it on
# both the `srgb` and the `linear` image.
# It then shows a comparison of both inputs and outputs.
#
# Most dithering algorithms in DitherPunk.jl provide an optional parameter `to_linear`,
# which converts the input image to a linear color space before applying the dithering.
# Select what looks best!
#
# ## Threshold dithering
# #### `ConstantThreshold`
test_on_gradient(ConstantThreshold())

# #### `WhiteNoiseThreshold`
test_on_gradient(WhiteNoiseThreshold())

# ## Ordered dithering
# ### Bayer matrices
# #### `bayer_dithering`
test_on_gradient(Bayer())

# The order of the Bayer-matrix can be specified through the parameter `level`,
# which defaults to `1`.
# **Level 2**
test_on_gradient(Bayer(2))
# **Level 3**
test_on_gradient(Bayer(3))
# **Level 4**
test_on_gradient(Bayer(4))

# ### Clustered / halftone dithering
# The following methods have large characteristic patterns and are therefore
# better suited for large images.
#
# #### `ClusteredDots`
test_on_gradient(ClusteredDots())

# #### `CentralWhitePoint`
test_on_gradient(CentralWhitePoint())

# #### `BalancedCenteredPoint`
test_on_gradient(BalancedCenteredPoint())

# #### `Rhombus`
test_on_gradient(Rhombus())

# #### ImageMagick methods
test_on_gradient(IM_checks())
#
test_on_gradient(IM_h4x4a())
#
test_on_gradient(IM_h6x6a())
#
test_on_gradient(IM_h8x8a())
#
test_on_gradient(IM_h4x4o())
#
test_on_gradient(IM_h6x6o())
#
test_on_gradient(IM_h8x8o())
#
test_on_gradient(IM_c5x5())
#
test_on_gradient(IM_c6x6())
#
test_on_gradient(IM_c7x7())

# ## Error diffusion
# #### `SimpleErrorDiffusion`
test_on_gradient(SimpleErrorDiffusion())

# #### `FloydSteinberg`
test_on_gradient(FloydSteinberg())

# #### `JarvisJudice`
test_on_gradient(JarvisJudice())

# #### `Stucki`
test_on_gradient(Stucki())

# #### `Burkes`
test_on_gradient(Burkes())

# #### `Sierra`
test_on_gradient(Sierra())

# #### `TwoRowSierra`
test_on_gradient(TwoRowSierra())

# #### `SierraLite`
test_on_gradient(SierraLite())

# #### `Fan93()`
test_on_gradient(Fan93())

# #### `ShiauFan()`
test_on_gradient(ShiauFan())

# #### `ShiauFan2()`
test_on_gradient(ShiauFan2())

# #### `Atkinson()`
test_on_gradient(Atkinson())
