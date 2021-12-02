using Images
using DitherPunk
using Clustering
using IndirectArrays
# # Color cycling
# We will try to fake a subtle animation of the water in this public domain image:
img = load("../../assets/waterfall.jpg")

# When Clustering.jl is loaded, we can import DitherPunk's internal function `get_colorscheme`
# to obtain a color scheme of size 16.
cs = DitherPunk.get_colorscheme(img, 16)
cs = sort(cs; by=c -> c.b)

# The first four colors are white-ish and correspond to the water.
# We will modify the colors in this range by adding some noise.
# Depending on the result of the clustering, this might require some tweaking.
modrange = 1:4;

# Let's look at the dithered result:
d = dither(img, FloydSteinberg(), cs)

# We define a function to modify the color palette
function modify_dither(d, modrange)
    cs = Lab.(d.values)
    v = view(cs, modrange)
    map!(c -> Lab(clamp(c.l + randn(), 0, 120), c.a, c.b), v, v) # modify lightness
    return IndirectArray(d.index, cs)
end;

# And finally create a gif out of the modified images:
ds = cat([modify_dither(d, 1:3) for i in 1:10]...; dims=3)
save("waterfall.gif", ds; fps=5)

# The result should look like this:
# ![](https://i.imgur.com/DnS5TWj.gif)
# Wow! We really nailed that Web 1.0 look!
#
# To see how good color cycling can look when done correctly,
# take a look at [Mark Ferrari's amazing work](http://www.effectgames.com/demos/canvascycle/?sound=1).
