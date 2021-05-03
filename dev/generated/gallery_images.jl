using DitherPunk
using Images
using TestImages
using ImageTransformations

function preprocess(img)
    img = Gray.(img)
    return imresize(img; ratio=1 / 2)
end

file_names = [
    "cameraman", "lake_gray", "house", "fabio_gray_512", "mandril_gray", "peppers_gray"
]
imgs = [preprocess(testimage(file)) for file in file_names]
mosaicview(imgs...; ncol=3)

function test_on_images(alg; to_linear=false)
    dithers = [Gray.(alg(img; to_linear)) for img in imgs]
    return mosaicview(dithers...; ncol=3)
end

test_on_images(threshold_dithering)

test_on_images(white_noise_dithering; to_linear=true)

test_on_images(bayer_dithering)

test_on_images(clustered_dots_dithering; to_linear=true)

test_on_images(balanced_centered_point_dithering; to_linear=true)

test_on_images(rhombus_dithering; to_linear=true)

test_on_images(simple_error_diffusion)

test_on_images(floyd_steinberg_diffusion)

test_on_images(jarvis_judice_diffusion)

test_on_images(stucki_diffusion)

test_on_images(burkes_diffusion)

test_on_images(sierra_diffusion)

test_on_images(two_row_sierra_diffusion)

test_on_images(sierra_lite_diffusion)

test_on_images(atkinson_diffusion)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

