using DitherPunk
using DitherPunk: srgb2linear, clamp_limits
using ImageCore

@test srgb2linear(true) == true
@test srgb2linear(false) == false

A = [1 2; 3 4]

U = @inferred upscale(A, 3)
@test U == [
    1 1 1 2 2 2
    1 1 1 2 2 2
    1 1 1 2 2 2
    3 3 3 4 4 4
    3 3 3 4 4 4
    3 3 3 4 4 4
]

c = RGB{Float32}(2, 3, 4)
cl = @inferred clamp_limits(c)
@test cl == RGB{Float32}(1, 1, 1)
cl = @inferred clamp_limits(Gray{Float32}(1000))
@test cl == Gray{Float32}(1)
cl = @inferred clamp_limits(HSV(1000, 1000, 1000))
@test cl == HSV(280, 1, 1)
cl = @inferred clamp_limits(Lab(1000, 1000, 1000))
@test cl == Lab(1000, 1000, 1000)
cl = @inferred clamp_limits(XYZ(100, 100, 100))
@test cl == XYZ{Float32}(0.95047f0, 1.0f0, 1.08883f0)
