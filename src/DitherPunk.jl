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
# Error diffusion
export ErrorDiffusion
export SimpleErrorDiffusion, FloydSteinberg, JarvisJudice, Stucki, Burkes
export Sierra, TwoRowSierra, SierraLite, Atkinson, Fan93, ShiauFan, ShiauFan2
# Closest color
export ClosestColor

export upscale

end # module
