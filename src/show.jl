"""
Upscale image by repeating individual pixels.
"""
upscale(img, scale) = repeat(img; inner=(scale, scale))
