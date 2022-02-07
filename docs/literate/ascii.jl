# # ASCII dithering
# In this example, we are going to approximate a grayscale gradient
# with an ASCII ramp such as ` .:-=+*#%@`.
using Images
using DitherPunk
using TestImages

# When loading an image, we need to compensate for the aspect ratio of ASCII characters.
img = testimage("cameraman")
img = imresize(img, ratio=(1//14, 1//6))

# We then define an ASCII ramp and a corresponding grayscale color scheme of matching length.
ascii_ramp = split(" .:-=+*#%@", "")
cs = Gray.(range(0, 1, length=10))

# Dithering will return an `IndirectArray`:
d = dither(img, FloydSteinberg(), cs)

# Instead of showing `d` as an image, we can use its indices
# to select the corresponding ASCII characters from the ramp.
mat = ascii_ramp[d.index]

# Pretty printing each row of this matrix will output the image:
for r in eachrow(mat)
    println(join(r))
end
