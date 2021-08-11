"""
Simplest form of image quantization by turning each pixel to the closest one
in the provided color palette `cs`.
Technically this not a dithering algorithm as the quatization error is not "randomized".
"""
struct ClosestColor <: AbstractCustomColorDither end

function (alg::ClosestColor)(
    out::GenericImage,
    img::GenericImage,
    cs::AbstractVector{<:Colorant};
    metric::DifferenceMetric=DE_2000(),
)
    return out .= eltype(out).(map((px) -> closest_color(px, cs; metric=metric), img))
end

# default to binary dithering if no color scheme is provided
function (alg::ClosestColor)(
    out::GenericGrayImage, img::GenericGrayImage; metric=BinaryDitherMetric()
)
    cs = [Gray(false), Gray(true)] # b&w color scheme
    alg(out, img, cs; metric=metric)
    return out
end
