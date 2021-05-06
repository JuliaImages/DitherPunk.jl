module DitherPunk

using ImageCore
using TiledIteration
using ImageCore.MappedArrays
using Random
using OffsetArrays

include("compat.jl")

# Binary dithering algorithms
include("colorspaces.jl")
include("threshold.jl")
include("ordered.jl")
include("error_diffusion.jl")
include("show.jl")
include("eval.jl")

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

export upscale, show_dither
export gradient_image, test_on_gradient

end # module
