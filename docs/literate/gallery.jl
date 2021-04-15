using DitherPunk
using Images

# # Gallery
# ## On sRGB and linear colorspaces
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
# which converts the input image to a linear colorspace before applying the dithering.
# Select what looks best!
#
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
bayer_dithering_algs = [(img) -> (bayer_dithering(img; level=level)) for level in 4:-1:0]
test_on_gradient(bayer_dithering_algs)

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

# ## Error diffusion
# ### `simple_error_diffusion`
test_on_gradient(simple_error_diffusion)

# ### `floyd_steinberg_diffusion`
test_on_gradient(floyd_steinberg_diffusion)

# ### `jarvis_judice_diffusion`
test_on_gradient(jarvis_judice_diffusion)

# ### `stucki_diffusion`
test_on_gradient(stucki_diffusion)

# ### `atkinson_diffusion`
test_on_gradient(atkinson_diffusion)
