module DitherPunk

using TiledIteration
using ImageCore
using ImageCore: NumberLike, Pixel, GenericImage, GenericGrayImage, MappedArrays
using ImageCore.Colors: DifferenceMetric
using Random
using OffsetArrays

include("compat.jl")
include("dither_api.jl")
include("colorspaces.jl")
include("separate_space.jl")
include("threshold.jl")
include("ordered.jl")
include("ordered_imagemagick.jl")
include("error_diffusion.jl")
include("closest_color.jl")
include("show.jl")
include("eval.jl")

export dither, dither!
# Meta algorithms
export SeparateSpace
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

export upscale

end # module
