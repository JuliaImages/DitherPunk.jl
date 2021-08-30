"""
Simplest form of image quantization by turning each pixel to the closest one
in the provided color palette `cs`.
Technically this not a dithering algorithm as the quatization error is not "randomized".
"""
struct ClosestColor <: AbstractCustomColorDither end

function (alg::ClosestColor)(
    out::GenericImage,
    img::GenericImage,
    cs::AbstractVector{<:Pixel},
    metric::DifferenceMetric,
)
    return out .= eltype(out).(map((px) -> closest_color(px, cs; metric=metric), img))
end

# default to binary dithering if no color scheme is provided
function (alg::ClosestColor)(out::GenericGrayImage, img::GenericGrayImage)
    cs = eltype(out).([false, true]) # b&w color scheme
    alg(out, img, cs, BinaryDitherMetric())
    return out
end
