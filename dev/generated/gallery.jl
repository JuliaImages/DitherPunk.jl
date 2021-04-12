using DitherPunk
using Images

img = gradient_image(50, 400)

dither = threshold_dithering(img)
show_dither(dither; scale=2)

dither = random_noise_dithering(img)
show_dither(dither; scale=2)

dither = bayer_dithering(img)
show_dither(dither; scale=2)

imgs = [show_dither(bayer_dithering(img; level=level); scale=2) for level in 0:4]
mosaicview(imgs...)

dither = clustered_dots_dithering(img)
show_dither(dither; scale=2)

dither = balanced_centered_point_dithering(img)
show_dither(dither; scale=2)

dither = rhombus_dithering(img)
show_dither(dither; scale=2)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

