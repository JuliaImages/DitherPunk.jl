function threshold_dithering(
    img::AbstractMatrix{<:Gray}; threshold=0.5, is_srgb=true
)::BitMatrix
    img = copy(img)
    is_srgb && (img .= srgb2linear.(img))
    return img .> threshold
end

function random_noise_dithering(
    img::AbstractMatrix{<:Gray}; threshold=0.5, is_srgb=true
)::BitMatrix
    img = copy(img)
    is_srgb && (img .= srgb2linear.(img))
    img .+= rand(size(img)) .- 0.5
    return img .> threshold
end
