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
    cs = ccolor(Lab, eltype(cs)).(cs) # convert to Lab
    return map(px -> argmin(colordiff(px, c; metric=metric) for c in cs), img)
end
