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

function colordither!(
    out::Matrix{Int},
    ::ClosestColor,
    img::GenericImage{C},
    cs::AbstractVector{C},
    colorpicker::AbstractColorPicker{C},
) where {C<:ColorLike}
    return map!(colorpicker, out, img)
end
