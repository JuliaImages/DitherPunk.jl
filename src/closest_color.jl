"""
Simplest form of image quantization by turning each pixel to the closest one
in the provided color palette `cs`.
Technically this not a dithering algorithm as the quatization error is not "randomized".
"""
struct ClosestColor <: AbstractCustomColorDither end

function binarydither!(::ClosestColor, out::GenericGrayImage, img::GenericGrayImage)
    return out .= img .> 0.5
end

function colordither!(
    ::ClosestColor,
    out::GenericImage,
    img::GenericImage,
    cs::AbstractVector{<:Pixel},
    metric::DifferenceMetric,
)
    return out .= eltype(out).(map((px) -> closest_color(px, cs; metric=metric), img))
end
