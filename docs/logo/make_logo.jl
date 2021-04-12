using DitherPunk
using Images
using ImageIO
using ImageTransformations
using ImageContrastAdjustment

img_color = load("./docs/logo/DitherPunk.png")
img_color = imresize(img_color; ratio=1 / 4)
img = Gray.(img_color)
img = adjust_histogram(img, LinearStretching())

dither = rhombus_dithering(img);
save("./docs/logo/DitheredPunk.png", show_dither(dither; scale=2))
