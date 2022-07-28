using Images
using DitherPunk
using TestImages

img = testimage("cameraman")

img = imresize(img; ratio=(1//14, 1//6))

ascii_ramp = split(" .:-=+*#%@", "")
cs = Gray.(range(0, 1; length=10))

d = dither(img, cs)

mat = ascii_ramp[d.index]

for r in eachrow(mat)
    println(join(r))
end

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

