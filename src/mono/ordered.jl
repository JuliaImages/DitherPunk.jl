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
    # Get Bayer matrix and normalize it
    bayer = bayer_matrix(level)
    mat = bayer / (2^(2 * level + 2))

    return ordered_dithering(img, mat; kwargs...)
end

"""
Contruct (un-normalized) Bayer matrices through recursive definition.
"""
function bayer_matrix(n::Int)::AbstractMatrix{Int}
    n < 0 && throw(DomainError(n, "Bayer matrix only defined for n ≥ 0."))

    if n == 0
        b = [0 2; 3 1]
    else
        bₙ₋₁ = bayer_matrix(n - 1)
        b = 4 * [(bₙ₋₁) (bₙ₋₁.+2); (bₙ₋₁.+3) (bₙ₋₁.+1)]
    end
    return b
end

"""
Clustered dots ordered dithering.
"""
function clustered_dots_dithering(img::AbstractMatrix{<:Gray}; kwargs...)::BitMatrix
    mat =
        [
            34 29 17 21 30 35
            28 14 9 16 20 31
            13 8 4 5 15 19
            12 3 0 1 10 18
            27 7 2 6 23 24
            33 26 11 22 25 32
        ] / 37

    return ordered_dithering(img, mat; kwargs...)
end

"""
Central white point ordered dithering.
"""
function central_white_point_dithering(img::AbstractMatrix{<:Gray}; kwargs...)::BitMatrix
    mat =
        [
            34 25 21 17 29 33
            30 13 9 5 12 24
            18 6 1 0 8 20
            22 10 2 3 4 16
            26 14 7 11 15 28
            35 31 19 23 27 32
        ] / 37

    return ordered_dithering(img, mat; kwargs...)
end

"""
Balanced centered point ordered dithering.
"""
function balanced_centered_point_dithering(
    img::AbstractMatrix{<:Gray}; kwargs...
)::BitMatrix
    mat =
        [
            30 22 16 21 33 35
            24 11 7 9 26 28
            13 5 0 2 14 19
            15 3 1 4 12 18
            27 8 6 10 25 29
            32 20 17 23 31 34
        ] / 37

    return ordered_dithering(img, mat; kwargs...)
end

"""
Diagonal ordered matrix with balanced centered points, ordered dithering.
"""
function rhombus_dithering(img::AbstractMatrix{<:Gray}; kwargs...)::BitMatrix
    S₁ = [
        13 9 5 12
        6 1 0 8
        10 2 3 4
        14 7 11 15
    ]
    S₂ = [
        18 22 26 19
        25 30 31 23
        21 29 28 27
        17 24 20 16
    ]
    mat = [S₁ S₂; S₂ S₁] / 33

    return ordered_dithering(img, mat; kwargs...)
end
