module DitherPunk

using Images
using Random
using OffsetArrays

# Imports for display functions
using UnicodePlots: spy

# Binary dithering algorithms
include("mono/colorspaces.jl")
include("mono/threshold.jl")
include("mono/ordered.jl")
include("mono/error_diffusion.jl")
include("mono/show.jl")
include("mono/eval.jl")

# Threshold dithering
export threshold_dithering, white_noise_dithering
# Ordered dithering
export ordered_dithering, bayer_dithering
export clustered_dots_dithering, balanced_centered_point_dithering, rhombus_dithering
# Error diffusion
export simple_error_diffusion, floyd_steinberg_diffusion
export stucki_diffusion, burkes_diffusion
export jarvis_judice_diffusion, atkinson_diffusion
export sierra_diffusion, two_row_sierra_diffusion, sierra_lite_diffusion

export upscale, show_dither, print_braille
export gradient_image, test_on_gradient

end # module
