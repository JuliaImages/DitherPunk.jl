using DitherPunk
using Images
using ImageTransformations
using ImageContrastAdjustment
using TestImages

# # Gallery
# A simple gradient works well to show the characteristic patterns of
# different dithering methods.
img = gradient_image(50, 400)

# ## Threshold dithering
# ### `threshold_dithering`
# Threshold at a constant value `threshold`, which defaults to `0.5`.
dither = threshold_dithering(img)
show_dither(dither; scale=2)

# ### `random_noise_dithering`
# Use random noise as a threshold map.
dither = random_noise_dithering(img)
show_dither(dither; scale=2)

# ## Ordered dithering on small images
# ### `bayer_dithering`
# Use Bayer-matrices to construct the threshold map.
dither = bayer_dithering(img)
show_dither(dither; scale=2)

# The order of the Bayer-matrix can be specified through the parameter `level`,
# which defaults to `1`.
imgs = [show_dither(bayer_dithering(img; level=level); scale=2) for level in 0:4]
mosaicview(imgs...)

# ## Ordered dithering on large images
# The following methods have large characteristic patterns and are therefore
# better suited for large images.
#
# ### `clustered_dots_dithering`
dither = clustered_dots_dithering(img)
show_dither(dither; scale=2)

# ### `balanced_centered_point_dithering`
dither = balanced_centered_point_dithering(img)
show_dither(dither; scale=2)

# ### `rhombus_dithering`
dither = rhombus_dithering(img)
show_dither(dither; scale=2)
