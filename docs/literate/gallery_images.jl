using DitherPunk
using Images
using ImageTransformations
using ImageContrastAdjustment
using TestImages

# # Test image gallery
# This gallery uses images from [*TestImages.jl*](https://testimages.juliaimages.org).
file_names = [
    "cameraman", "lake_gray", "house", "fabio_gray_512", "mandril_gray", "peppers_gray"
]
imgs = [imresize(Gray.(testimage(file)); ratio=1 / 2) for file in file_names]
mosaicview(imgs...; ncol=3)

# Our test function `test_on_images` just runs a dithering algorithm on all six images
# in linear color space (`to_liner=true`).
function test_on_images(alg)
    dithers = [Gray.(alg(img; to_linear=true)) for img in imgs]
    return mosaicview(dithers...; ncol=3)
end

# ## Threshold dithering
# #### `threshold_dithering`
test_on_images(threshold_dithering)

# #### `white_noise_dithering`
test_on_images(white_noise_dithering)

# ## Ordered dithering on small images
# #### Bayer matrices

# #### `clustered_dots_dithering`
test_on_images(clustered_dots_dithering)

# #### `balanced_centered_point_dithering`
test_on_images(balanced_centered_point_dithering)

# #### `rhombus_dithering`
test_on_images(rhombus_dithering)

# ## Error diffusion
# #### `simple_error_diffusion`
test_on_images(simple_error_diffusion)

# #### `floyd_steinberg_diffusion`
test_on_images(floyd_steinberg_diffusion)

# #### `jarvis_judice_diffusion`
test_on_images(jarvis_judice_diffusion)

# #### `stucki_diffusion`
test_on_images(stucki_diffusion)

# #### `burkes_diffusion`
test_on_images(burkes_diffusion)

# #### `sierra_diffusion`
test_on_images(sierra_diffusion)

# #### `two_row_sierra_diffusion`
test_on_images(two_row_sierra_diffusion)

# #### `sierra_lite_diffusion`
test_on_images(sierra_lite_diffusion)

# #### `atkinson_diffusion`
test_on_images(atkinson_diffusion)
