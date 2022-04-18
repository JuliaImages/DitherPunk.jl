using Images
using DitherPunk
using Clustering
using IndirectArrays

img = load("../../assets/waterfall.png")

cs = DitherPunk.get_colorscheme(img, 16)
cs = sort(cs; by=c -> -c.l)

d1 = dither(img, Bayer(;color_error_multiplier=1.0), cs)

d2 = IndirectArray(d1.index, cs[[3, 1, 2, 4:end...]])
d3 = IndirectArray(d1.index, cs[[2, 3, 1, 4:end...]]);

ds = cat(d1, d2, d3; dims=3)
save("waterfall.gif", ds; fps=5)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

