w = 200
h = 4 * 4 # multiple of 4 for unicode braille print
img, srgb = gradient_image(h, w)

@test_reference "references/braille/FS.txt" braille(img; to_string=true)
@test_reference "references/braille/FS.txt" braille(convert.(RGB, img); to_string=true)
@test_reference "references/braille/FS.txt" braille(img, FloydSteinberg(); to_string=true)
@test_reference "references/braille/FS_invert.txt" braille(img; invert=true, to_string=true)
@test_reference "references/braille/Bayer.txt" braille(img, Bayer(); to_string=true)
@test_reference "references/braille/Bayer_invert.txt" braille(
    img, Bayer(); invert=true, to_string=true
)

d = dither(Bool, img, FloydSteinberg())
@test_reference "references/braille/FS.txt" braille(d; to_string=true)
@test_reference "references/braille/FS.txt" braille(BitMatrix(d); to_string=true)
@test_reference "references/braille/FS.txt" braille(convert.(Gray{Bool}, d); to_string=true)
