function threshold_dithering(
    img::AbstractMatrix{<:Gray}, threshold_map::AbstractMatrix{<:Gray}; to_linear=false
)::BitMatrix
    size(img) ≢ size(threshold_map) && throw(
        DimensionMismatch("Arguments img and threshold_map need to have same dimensions"),
    )

    to_linear && (img = mappedarray(srgb2linear, img))
    return img .> threshold_map
end

function threshold_dithering(
    img::AbstractMatrix{<:Gray}; threshold::Real=0.5, kwargs...
)::BitMatrix
    if threshold < 0 || threshold > 1
        throw(
            DomainError(
                threshold, "Keyword argument threshold needs to be between 0 and 1."
            ),
        )
    end

    tmap = fill(Gray{N0f16}(threshold), size(img)) # constant matrix of value threshold
    return threshold_dithering(img, tmap; kwargs...)
end

function white_noise_dithering(img::AbstractMatrix{<:Gray}; kwargs...)::BitMatrix
    tmap = rand(Gray{N0f16}, size(img)) # threshold map is white noise
    return threshold_dithering(img, tmap; kwargs...)
end
