using DitherPunk
using ReferenceTests

using ImageCore
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

    println("")
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

## Run reference tests for deterministic algorithms
algs_deterministic = [
    # threshold methods
    threshold_dithering,
    # ordered dithering
    bayer_dithering,
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

for (alg_name, alg) in algs_deterministic
    dither = alg(img)
    @test_reference "references/grad_$(alg).txt" dither

    dither = alg(img; to_linear=true)
    @test_reference "references/grad_$(alg)_linear.txt" dither

    # Visualize in terminal
    print_braille(dither; title="$(alg)")
end

for level in 2:4
    dither = bayer_dithering(img; level=level)
    @test_reference "references/grad_bayer_dithering_l$(level).txt" Int.(dither)

    dither = bayer_dithering(img; level=level, to_linear=true)
    @test_reference "references/grad_bayer_dithering_l$(level)_linear.txt" dither

    # Visualize in terminal
    print_braille(dither; title="bayer_dithering, level $(level)")
end

## Algorithms with random output are currently only tested visually
algs_random = [
    # threshold methods
    white_noise_dithering,
]

for alg in algs_random
    dither = alg(img; to_linear=true)

    # Visualize in terminal
    print_braille(dither; title="$(alg)")
end
