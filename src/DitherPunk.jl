module DitherPunk

using ImageCore
using TiledIteration
using ImageCore.MappedArrays
using ImageCore.Colors: DifferenceMetric
using Random
using OffsetArrays
using ColorSchemes

abstract type AbstractDither end

include("compat.jl")
include("colorspaces.jl")
include("threshold.jl")
include("ordered.jl")
include("error_diffusion.jl")
include("show.jl")
include("eval.jl")

export dither
# Threshold dithering
export ConstantThreshold, WhiteNoiseThreshold
# Ordered dithering
export Bayer, ClusteredDots, CentralWhiteDot, BalancedCenteredDot, Rhombus
# Error diffusion
export SimpleErrorDiffusion, FloydSteinberg, JarvisJudice, Stucki, Burkes
export Sierra, TwoRowSierra, SierraLite, Atkinson

export upscale, show_dither

end # module
