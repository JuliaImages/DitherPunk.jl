function threshold_dithering(img::AbstractMatrix{<:Gray}; threshold=0.5)::BitMatrix
    return img .> threshold
end

function random_noise_dithering(img::AbstractMatrix{<:Gray})::BitMatrix
    return img .> rand(N0f8, size(img)) # threshold map is random noise
end
