module DitherPunk

using ImageCore
using TiledIteration
using ImageCore.MappedArrays
using ImageCore.Colors: DifferenceMetric
using Random
using OffsetArrays

include("compat.jl")
include("dither_api.jl")
include("colorspaces.jl")
include("threshold.jl")
include("ordered.jl")
include("error_diffusion.jl")
include("closest_color.jl")
include("show.jl")
include("eval.jl")

export dither, dither!
# Threshold dithering
export ConstantThreshold, WhiteNoiseThreshold
# Ordered dithering
export Bayer, ClusteredDots, CentralWhitePoint, BalancedCenteredPoint, Rhombus
# Error diffusion
export SimpleErrorDiffusion, FloydSteinberg, JarvisJudice, Stucki, Burkes
export Sierra, TwoRowSierra, SierraLite, Atkinson
# Closest color
export ClosestColor

export upscale

end # module
