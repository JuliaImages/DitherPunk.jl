module DitherPunk

using Images
using ImageFiltering: mapwindow, imfilter
using OffsetArrays

using Random

using SparseArrays
using UnicodePlots

# Binary dithering algorithms
include("mono/colorspaces.jl")
include("mono/threshold.jl")
include("mono/ordered.jl")
include("mono/show.jl")

export threshold_dithering, random_noise_dithering
export ordered_dithering, bayer_dithering
export show_dither, print_braille

end # module
