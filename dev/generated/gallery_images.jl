using DitherPunk
using Images
using ImageTransformations
using ImageContrastAdjustment
using TestImages

file_names = [
    "cameraman", "lake_gray", "house", "fabio_gray_512", "mandril_gray", "peppers_gray"
]
imgs = [imresize(Gray.(testimage(file)); ratio=1 / 2) for file in file_names]
mosaicview(imgs...; ncol=3)

function test_on_images(alg)
    dithers = [Gray.(alg(img; to_linear=true)) for img in imgs]
    return mosaicview(dithers...; ncol=3)
end

test_on_images(threshold_dithering)

test_on_images(white_noise_dithering)

test_on_images(bayer_dithering)

test_on_images(clustered_dots_dithering)

test_on_images(balanced_centered_point_dithering)

test_on_images(rhombus_dithering)

test_on_images(simple_error_diffusion)

test_on_images(floyd_steinberg_diffusion)

test_on_images(jarvis_judice_diffusion)

test_on_images(stucki_diffusion)

test_on_images(atkinson_diffusion)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

