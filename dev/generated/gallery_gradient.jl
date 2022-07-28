using DitherPunk
using DitherPunk: srgb2linear
using Images

function gradient_image(height, width) #hide
    row = reshape(range(0; stop=1, length=width), 1, width) #hide
    grad_srbg = Gray.(vcat(repeat(row, height))) #hide
    grad_linear = srgb2linear.(grad_srbg) #hide
    return grad_srbg, grad_linear #hide
end; #hide

srbg, linear = gradient_image(100, 800);
mosaicview(srbg, linear)

function test_on_gradient(alg)
    srgb, linear = gradient_image(100, 800)
    dither_srgb = dither(srgb, alg)
    dither_linear = dither(linear, alg)

    return mosaicview([srgb, dither_srgb, linear, dither_linear]; ncol=1)
end;

test_on_gradient(ConstantThreshold())

test_on_gradient(WhiteNoiseThreshold())

test_on_gradient(Bayer())

test_on_gradient(Bayer(2))

test_on_gradient(Bayer(3))

test_on_gradient(Bayer(4))

test_on_gradient(ClusteredDots())

test_on_gradient(CentralWhitePoint())

test_on_gradient(BalancedCenteredPoint())

test_on_gradient(Rhombus())

test_on_gradient(IM_checks())

test_on_gradient(IM_h4x4a())

test_on_gradient(IM_h6x6a())

test_on_gradient(IM_h8x8a())

test_on_gradient(IM_h4x4o())

test_on_gradient(IM_h6x6o())

test_on_gradient(IM_h8x8o())

test_on_gradient(IM_c5x5())

test_on_gradient(IM_c6x6())

test_on_gradient(IM_c7x7())

test_on_gradient(SimpleErrorDiffusion())

test_on_gradient(FloydSteinberg())

test_on_gradient(JarvisJudice())

test_on_gradient(Stucki())

test_on_gradient(Burkes())

test_on_gradient(Sierra())

test_on_gradient(TwoRowSierra())

test_on_gradient(SierraLite())

test_on_gradient(Fan93())

test_on_gradient(ShiauFan())

test_on_gradient(ShiauFan2())

test_on_gradient(Atkinson())

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

