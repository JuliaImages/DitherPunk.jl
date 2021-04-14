using DitherPunk
using Images

srbg, linear = gradient_image(100, 800);
mosaicview(srbg, linear)

test_on_gradient(threshold_dithering)

test_on_gradient(white_noise_dithering)

test_on_gradient(bayer_dithering)

bayer_dithering_algs = [(img) -> (bayer_dithering(img; level=level)) for level in 4:-1:0]
test_on_gradient(bayer_dithering_algs)

test_on_gradient(clustered_dots_dithering)

test_on_gradient(balanced_centered_point_dithering)

test_on_gradient(rhombus_dithering)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

