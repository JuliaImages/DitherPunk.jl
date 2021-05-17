using DitherPunk
using DitherPunk: gradient_image, test_on_gradient
using Images

srbg, linear = gradient_image(100, 800);
mosaicview(srbg, linear)

test_on_gradient(ConstantThreshold())

test_on_gradient(WhiteNoiseThreshold())

test_on_gradient(Bayer())

test_on_gradient(Bayer(; level=2))

test_on_gradient(Bayer(; level=3))

test_on_gradient(Bayer(; level=4))

test_on_gradient(ClusteredDots())

test_on_gradient(CentralWhitePoint())

test_on_gradient(BalancedCenteredPoint())

test_on_gradient(Rhombus())

test_on_gradient(SimpleErrorDiffusion())

test_on_gradient(FloydSteinberg())

test_on_gradient(JarvisJudice())

test_on_gradient(Stucki())

test_on_gradient(Burkes())

test_on_gradient(Sierra())

test_on_gradient(TwoRowSierra())

test_on_gradient(SierraLite())

test_on_gradient(Atkinson())

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

