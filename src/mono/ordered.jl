"""
Ordered dithering using threshold maps.
https://en.wikipedia.org/wiki/Ordered_dithering#Pre-calculated_threshold_maps
"""
function ordered_dithering(
    img::AbstractMatrix{<:Gray}, mat::AbstractMatrix; invert_map=false
)::BitMatrix
    h_img, w_img = size(img)
    h_mat, w_mat = size(mat)

    # Create full threshold map by repeating threshold matrix `mat` in x and y directions
    repeat_rows = ceil(Int, h_img / h_mat)
    repeat_cols = ceil(Int, w_img / w_mat)
    threshold = repeat(mat, repeat_rows, repeat_cols)[1:h_img, 1:w_img]

    # Invert map ∈ [0, 1] if specified
    invert_map && (threshold .= 1 .- threshold)

    return img .> threshold
end

"""
Ordered dithering using the Bayer matrix as a threshold map.
"""
function bayer_dithering(img::AbstractMatrix{<:Gray}; level=1, kwargs...)::BitMatrix
    # Get Bayer matri and normalize it to [0, 1]
    bayer = bayer_matrix(level)
    map = bayer / maximum(bayer)

    return ordered_dithering(img, map; kwargs...)
end

"""
Contruct (un-normalized) Bayer matrices through recursive definition.
"""
function bayer_matrix(n::Int)::AbstractMatrix{Int}
    if n == 0
        b = [0 2; 3 1]
    else
        bₙ₋₁ = bayer_matrix(n - 1)
        b = 4 * [(bₙ₋₁) (bₙ₋₁.+2); (bₙ₋₁.+3) (bₙ₋₁.+1)]
    end
    return b
end
