"""
Apply `Gray` to indicate that image should be interpreted as a grayscale image.
Optionally upscale image by integer value.
"""
show_dither(img::BitMatrix; scale::Int=1) = Gray.(upscale(img, scale))

"""
Upscale image by repeating individual pixels.
"""
upscale(img, scale) = repeat(img; inner=(scale, scale))
