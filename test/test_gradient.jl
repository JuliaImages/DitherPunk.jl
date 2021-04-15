using DitherPunk
using Images
using ImageInTerminal

w = 200
h = 4 * 4 # multiple of 4 for unicode braille print

img, srgb = gradient_image(h, w)
println("Test image:")
imshow(srgb)

algs = [
    # threshold methods
    threshold_dithering,
    white_noise_dithering,
    # ordered dithering
    clustered_dots_dithering,
    balanced_centered_point_dithering,
    rhombus_dithering,
    # error error_diffusion
    simple_error_diffusion,
    floyd_steinberg_diffusion,
    jarvis_judice_diffusion,
    atkinson_diffusion,
    stucki_diffusion,
]

# Run tests using conversion to linear color space
for alg in algs
    println("")
    print_braille(alg(img; to_linear=true); title="$(alg)")
end

for level in 1:3
    println("")
    print_braille(
        bayer_dithering(img; to_linear=true, level=level);
        title="bayer_dithering, level $(level)",
    )
end
