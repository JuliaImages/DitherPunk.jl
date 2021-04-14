module DitherPunk

using Images
using Random

# Imports for display functions
using UnicodePlots: spy

# Binary dithering algorithms
include("mono/colorspaces.jl")
include("mono/threshold.jl")
include("mono/ordered.jl")
include("mono/show.jl")
include("mono/eval.jl")

export threshold_dithering, white_noise_dithering
export ordered_dithering, bayer_dithering
export clustered_dots_dithering, balanced_centered_point_dithering, rhombus_dithering
export upscale, show_dither, print_braille, gradient_image, test_on_gradient

end # module
