# # Color palette swapping
# We can hide an image in another one by switching color palettes.
# Let's try to hide `img_secret` in `img`:
using Images
using DitherPunk
using IndirectArrays
using TestImages

img = testimage("peppers")
img_secret = testimage("airplaneF16");

# First we dither to eight colors:
ncolors = 8
d = dither(img, ncolors)
#
d_secret = dither(img_secret, ncolors)

# Both of these images are IndirectArrays, which means they contain a color scheme
d.values
# and a matrix of indices of type `UInt8` pointing to the color in the color scheme:
d.index

# Since `typemax(UInt8)` is 255 and therefore larger than `ncolor^2`,
# we can fit both images into a single index matrix by modifying the color schemes.
# To recover the secret image, it is then only necessary to swap the new color schemes.
combineindex(a, b) = UInt8((a - 1) * ncolors + b)
function uncombineindex(c)
    b = (c - 1) % ncolors + 1
    a = Int((c - b) / ncolors) + 1
    return a, b
end

function combine_images(ia1::IndirectArray, ia2::IndirectArray)
    index = map(t -> combineindex(t...), zip(ia1.index, ia2.index))
    cs1 = similar(ia1.values, ncolors^2)
    cs2 = similar(ia2.values, ncolors^2)

    for i in 1:(ncolors^2)
        a, b = uncombineindex(i)
        cs1[i] = ia1.values[a]
        cs2[i] = ia2.values[b]
    end
    return index, cs1, cs2
end;

# Let's test this on our dithered images
index, cs, cs_secret = combine_images(d, d_secret);

# When using the color scheme `cs`, we recover the peppers:
IndirectArray(index, cs)
# However, when using the secret color scheme `cs_secret`, the F-16 airplane appears:
IndirectArray(index, cs_secret)

# This certainly isn't a very secure way to hide an image in another one.
# However, it can be useful when trying to fit multiple images on low memory microcontrollers.
# As a matter of fact, this example was inspired by
# [Mark Ferrari's GDC 2016 talk](https://www.youtube.com/watch?t=717&v=aMcJ1Jvtef0)
# where he used a similar technique for this very purpose.
