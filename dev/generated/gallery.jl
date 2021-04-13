using DitherPunk
using Images

threshold_dithering |> test_on_gradient

random_noise_dithering |> test_on_gradient

bayer_dithering |> test_on_gradient

img = gradient_image(100, 800)
dithers = [Gray.(bayer_dithering(img; level=level)) for level in 0:4]
mosaicview([img, dithers...])

clustered_dots_dithering |> test_on_gradient

balanced_centered_point_dithering |> test_on_gradient

rhombus_dithering |> test_on_gradient

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

