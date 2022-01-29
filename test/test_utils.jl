using DitherPunk
using DitherPunk: srgb2linear, clamp_limits

@test srgb2linear(true) == true
@test srgb2linear(false) == false

A = [1 2; 3 4]

@test upscale(A, 3) == [
    1 1 1 2 2 2
    1 1 1 2 2 2
    1 1 1 2 2 2
    3 3 3 4 4 4
    3 3 3 4 4 4
    3 3 3 4 4 4
]

c = RGB{Float32}(2, 3, 4)
@test clamp_limits(c) == RGB{Float32}(1, 1, 1)
@test clamp_limits(Gray{Float32}(1000)) == Gray{Float32}(1)
@test clamp_limits(HSV(1000, 1000, 1000)) == HSV(280, 1, 1)
@test clamp_limits(Lab(1000, 1000, 1000)) == Lab(1000, 1000, 1000)
@test clamp_limits(XYZ(100, 100, 100)) == XYZ{Float32}(0.95047f0, 1.0f0, 1.08883f0)
