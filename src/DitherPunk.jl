module DitherPunk

using Base: require_one_based_indexing
using FixedPointNumbers: N0f8, floattype
using ColorTypes: ColorTypes, AbstractGray, Color, Colorant
using ColorTypes: RGB, HSV, Lab, XYZ, Gray, gray
using Colors:
    DifferenceMetric,
    EuclideanDifferenceMetric,
    DE_2000,
    DE_94,
    DE_JPC79,
    DE_CMC,
    DE_BFD,
    colordiff,
    invert_srgb_compand
using ImageCore: channelview, clamp01
using IndirectArrays: IndirectArray
import Colors: _colordiff # extended in colordiff.jl

using ColorSchemes: ColorScheme
using ColorQuantization: quantize, AbstractColorQuantizer, KMeansQuantization
using UnicodeGraphics: uprint, ustring

abstract type AbstractDither end

const ColorLike = Union{Number,Colorant}
const GrayLike = Union{Number,AbstractGray}
const BinaryLike = Union{Bool,AbstractGray{Bool}}

const ColorVector{T<:ColorLike} = AbstractArray{T,1}
const GenericImage{T<:ColorLike} = AbstractArray{T,2}
const GrayImage{T<:GrayLike} = AbstractArray{T,2}
const BinaryImage{T<:BinaryLike} = AbstractArray{T,2}

include("colorschemes.jl")
include("utils.jl")
include("colordiff.jl")
include("color_picker.jl")
include("api/binary.jl")
include("api/color.jl")
include("threshold.jl")
include("ordered.jl")
include("ordered_imagemagick.jl")
include("error_diffusion.jl")
include("closest_color.jl")
include("api/default_method.jl")
include("braille.jl")
include("clustering.jl")

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
# Closest color lookup
export AbstractColorPicker
export RuntimeColorPicker
export LookupColorPicker
export FastEuclideanMetric
# Other utilities
export upscale
export braille

end # module
