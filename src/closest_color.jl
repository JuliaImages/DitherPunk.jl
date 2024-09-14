"""
Simplest form of image quantization by turning each pixel to the closest one
in the provided color palette `cs`.
Technically this not a dithering algorithm as the quatization error is not "randomized".
"""
struct ClosestColor <: AbstractDither end

function binarydither!(::ClosestColor, out::GrayImage, img::GrayImage)
    threshold = eltype(img)(0.5)
    return out .= img .> threshold
end

function colordither(
    ::ClosestColor,
    img::GenericImage,
    cs::AbstractVector{<:ColorLike},
    metric::DifferenceMetric,
)::Matrix{Int}
    cs_lab = Lab.(cs)
    return map(px -> _closest_color_idx(px, cs_lab, metric), img)
end
