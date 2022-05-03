module DitherPunk

using ImageBase
using ImageBase.ImageCore: NumberLike, Pixel, GenericImage, GenericGrayImage, MappedArrays
using ImageBase.ImageCore.Colors: DifferenceMetric
using Random
using IndirectArrays
using Requires

abstract type AbstractDither end

include("compat.jl")
include("utils.jl")
include("api/binary.jl")
include("api/color.jl")
include("threshold.jl")
include("ordered.jl")
include("ordered_imagemagick.jl")
include("error_diffusion.jl")
include("closest_color.jl")
include("eval.jl")
include("deprecations.jl")

export dither, dither!
# Threshold dithering
export ConstantThreshold, WhiteNoiseThreshold
# Ordered dithering
export OrderedDither
export Bayer, ClusteredDots, CentralWhitePoint, BalancedCenteredPoint, Rhombus
export IM_checks, IM_h4x4a, IM_h6x6a, IM_h8x8a, IM_h4x4o, IM_h6x6o, IM_h8x8o
export IM_c5x5, IM_c6x6, IM_c7x7
# Error diffusion
export ErrorDiffusion
export SimpleErrorDiffusion, FloydSteinberg, JarvisJudice, Stucki, Burkes
export Sierra, TwoRowSierra, SierraLite, Atkinson, Fan93, ShiauFan, ShiauFan2
# Closest color
export ClosestColor
# Other utilities
export upscale

# Conditional dependencies using Requires.jl
function __init__()
    @require ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4" begin
        include("colorschemes.jl")
    end
    @require Clustering = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5" begin
        include("clustering.jl")
    end
    @require UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228" begin
        include("braille.jl")
        export braille, brailleprint
    end
end

end # module
