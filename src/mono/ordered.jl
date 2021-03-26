"""
Ordered dithering using threshold maps.
https://en.wikipedia.org/wiki/Ordered_dithering#Pre-calculated_threshold_maps
"""
function ordered_dithering(
    img::BitMatrix, map::AbstractMatrix; is_srgb=true, invert_map=true
)
    img = copy(img)
    map = copy(map)

    is_srgb && (img .= srgb2linear.(img))

    # Invert map ∈ [0, 1] if specified
    invert_map && (map .= 1 .- map)

    # Define OffsetArray from map to use with ImageFiltering
    w = first(size(map)) - 1
    offsetmap = OffsetArray(map, 0:w, 0:w)

    # Get per-pixel threshold by filtering image with threshold map
    threshold = imfilter(img, offsetmap)
    return img .> threshold
end

"""
Ordered dithering using the Bayer matrix as a threshold map.
"""
function bayer_dithering(
    img::AbstractMatrix{<:Gray}; level=1, is_srgb=true, invert_map=false
)::BitMatrix
    # Get Bayer matri and normalize it to [0, 1]
    map = bayer(level)
    map ./= maximum(map)

    return ordered_dithering(img, map; is_srgb=is_srgb, invert_map=invert_map)
end

"""
Contruct (un-normalized) Bayer matrices through recursive definition.
"""
function bayer(n::Int)::AbstractMatrix{Int}
    if n == 0
        b = [0 2; 3 1]
    else
        bₙ₋₁ = bayer(n - 1)
        b = 4 * [(bₙ₋₁) (bₙ₋₁.+2); (bₙ₋₁.+3) (bₙ₋₁.+1)]
    end
    return b
end
