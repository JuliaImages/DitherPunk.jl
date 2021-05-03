using DitherPunk
using Images
using ImageInTerminal
using UnicodePlots

w = 200
h = 4 * 4 # multiple of 4 for unicode braille print

"""
(Ab)use `spy` to interpret image as sparse array and print "sparsity pattern"
in braille through UnicodePlots.
"""
function print_braille(
    img::BitMatrix;
    invert=false,
    title="DitherPunk.jl",
    color=:white,
    labels=false,
    kwargs...,
)
    h, w = size(img)

    # Optionally invert Binary image before printing
    _img = copy(img)
    invert && (_img .= iszero.(_img))

    show(
        spy(
            _img;
            # Braille character ↝ 4x2 grid
            maxheight=ceil(Int, h / 4),
            maxwidth=ceil(Int, w / 2),
            title=title,
            color=color,
            labels=labels,
            kwargs...,
        ),
    )
    return nothing
end

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
    stucki_diffusion,
    burkes_diffusion,
    atkinson_diffusion,
    sierra_diffusion,
    two_row_sierra_diffusion,
    sierra_lite_diffusion,
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
