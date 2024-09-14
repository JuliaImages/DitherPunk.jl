using Images
using DitherPunk
using TestImages

function star_sdf(x, y; r=0.5, rf=2.0)
    k1 = [0.809016994375, -0.587785252292]
    k2 = [-k1[1], k1[2]]
    p = [abs(x), y]
    p -= 2.0 * maximum([k1 ⋅ p, 0.0]) * k1
    p -= 2.0 * maximum([k2 ⋅ p, 0.0]) * k2
    p = [abs(p[1]), p[2] - r]
    ba = rf * [-k1[2], k1[1]] - [0, 1]
    h = clamp((p ⋅ ba) / (ba ⋅ ba), 0.0, r)
    return norm(p - ba * h) * sign(p[2] * ba[1] - p[1] * ba[2])
end;

function sdf2halftone(sdf, n)
    rg = range(-1, 1; length=n)
    A = [sdf(x, y) for y in rg, x in rg]
    p = sortperm(reshape(-A, :))
    B = Matrix{Int}(undef, n, n)
    B[p] .= 1:(n^2)
    return OrderedDither(B)
end

img = testimage("fabio_gray_512")
alg = sdf2halftone(star_sdf, 7)
dither(img, alg)

alg = sdf2halftone(star_sdf, 15)
dither(img, alg)

alg = sdf2halftone(star_sdf, 30)
dither(img, alg)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
