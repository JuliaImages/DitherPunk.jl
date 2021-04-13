using DitherPunk
using Images
using ImageIO
using ImageTransformations
using ImageContrastAdjustment

# Load image & preprocess
scale = 3
img_color = load("./docs/logo/DitherPunk.png")
img_color = imresize(img_color; ratio=scale / 5)
img = imresize(img_color; ratio=1 / scale)
img = Gray.(img)
img = adjust_histogram(img, LinearStretching())

h, w = size(img_color)

# Apply dither
dither = upscale(rhombus_dithering(img), scale)
dither_color = HSV.(RGB.(dither))

# Define Julia Dots colors
RED = HSV{Float32}(2.7814567f0, 0.7475248f0, 0.7921569f0)
GREEN = HSV{Float32}(109.13793f0, 0.76821196f0, 0.5921569f0)
PURPLE = HSV{Float32}(281.1236f0, 0.5056818f0, 0.6901961f0)
GITHUB = HSV{Float32}(215.0f0, 0.26086953f0, 0.18039216f0)

# Manually saturate & darken colors as dither brightens percieved color.
DARK_RED = HSV{Float32}(RED.h, 1, 0.7)
DARK_GREEN = HSV{Float32}(GREEN.h, 1, 0.6)
DARK_PURPLE = HSV{Float32}(PURPLE.h, 1, 0.7)

for r in 1:h
    for c in 1:w
        pix = img_color[r, c]
        color = HSV(pix)

        # Recolor pixel if it is black in the dithered image
        if dither[r, c] == 0
            if color == RED
                dither_color[r, c] = DARK_RED
            elseif color == GREEN
                dither_color[r, c] = DARK_GREEN
            elseif color == PURPLE
                dither_color[r, c] = DARK_PURPLE
            else
                dither_color[r, c] = GITHUB
            end
        end
    end
end

save("./docs/logo/DitheredPunk.png", dither_color)