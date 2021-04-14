using DitherPunk
using Images

# # Gallery
# A simple linear gradient works well to reveal the characteristic patterns of
# different dithering algorithms.
img = gradient_image(100, 800)

# The function `test_on_gradient` takes a dithering algorithm and runs it on this
# image, showing the input and the output.

# ## Threshold dithering
# ### `threshold_dithering`
test_on_gradient(threshold_dithering)

# ### `white_noise_dithering`
test_on_gradient(white_noise_dithering)

# ## Ordered dithering on small images
# ### `bayer_dithering`
test_on_gradient(bayer_dithering)

# The order of the Bayer-matrix can be specified through the parameter `level`,
# which defaults to `1`.
dithers = [Gray.(bayer_dithering(img; level=level)) for level in 0:4]
mosaicview([img, dithers...])

# ## Ordered dithering on large images
# The following methods have large characteristic patterns and are therefore
# better suited for large images.
#
# ### `clustered_dots_dithering`
test_on_gradient(clustered_dots_dithering)

# ### `balanced_centered_point_dithering`
test_on_gradient(balanced_centered_point_dithering)

# ### `rhombus_dithering`
test_on_gradient(rhombus_dithering)
