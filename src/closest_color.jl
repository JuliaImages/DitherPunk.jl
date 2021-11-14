"""
Simplest form of image quantization by turning each pixel to the closest one
in the provided color palette `cs`.
Technically this not a dithering algorithm as the quatization error is not "randomized".
"""
struct ClosestColor <: AbstractDither end

function binarydither(::ClosestColor, img::GenericGrayImage)
    return map(px -> px > 0.5 ? INDEX_WHITE : INDEX_BLACK, img)
end

function colordither(
    ::ClosestColor, img::GenericImage, cs::AbstractVector{<:Pixel}, metric::DifferenceMetric
)
    cs = Lab{floattype(eltype(eltype(img)))}.(cs)
    # return matrix of indices of closest color
    return map(px -> argmin(colordiff.(px, cs; metric=metric)), img)
end
