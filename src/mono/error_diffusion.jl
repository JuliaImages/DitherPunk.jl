function error_diffusion(
    img::AbstractMatrix{<:Gray}, stencil::OffsetMatrix; to_linear=false
)::BitMatrix
    # Optionally cast to linear colorspace
    _img = copy(img)
    to_linear && srgb2linear!(_img)

    h, w = size(_img)
    dither = BitArray(undef, h, w) # initialized to zero

    # Get OffsetMatrix indices
    drs, dcs = indices(stencil)

    for r in 1:h
        for c in 1:w
            px = _img[r, c]
            rnd = round(px)
            err = px - rnd

            # Apply pixel to dither
            if rnd == 1
                dither[r, c] = 1
            else
                dither[r, c] = 0
            end

            # Diffuse "error" to neighborhood in stencil
            for dr in drs
                for dc in dcs
                    if (r + dr > 0) && (r + dr <= h) && (c + dc > 0) && (c + dc <= w)
                        _img[r + dr, c + dc] += err * stencil[dr, dc]
                    end
                end
            end
        end
    end

    return dither
end

"""
Get indices from OffsetMatrix
"""
function indices(om::OffsetMatrix)
    rows, cols = size(om)
    row_range = (1:rows) .+ om.offsets[1]
    col_range = (1:cols) .+ om.offsets[2]
    return row_range, col_range
end

simple_error_diffusion(img; kwargs...) = error_diffusion(img, SIMPLE_STENCIL; kwargs...)
SIMPLE_STENCIL = OffsetArray([0 0.5; 0.5 0], 1:2, 1:2)

floyd_steinberg_diffusion(img; kwargs...) = error_diffusion(img, FS_STENCIL; kwargs...)
FS_STENCIL = OffsetArray([0 0 7; 3 5 1]//16, 1:2, -1:1)

jarvis_judice_diffusion(img; kwargs...) = error_diffusion(img, JJ_STENCIL; kwargs...)
JJ_STENCIL = OffsetArray([0 0 0 7 5; 3 5 7 5 3; 1 3 5 3 1]//48, 1:3, -2:2)

stucki_diffusion(img; kwargs...) = error_diffusion(img, STUCKI_STENCIL; kwargs...)
STUCKI_STENCIL = OffsetArray([0 0 0 8 4; 2 4 8 4 2; 1 2 4 2 1]//42, 1:3, -2:2)

atkinson_diffusion(img; kwargs...) = error_diffusion(img, ATKINSON_STENCIL; kwargs...)
ATKINSON_STENCIL = OffsetArray([0 0 1 1; 1 1 1 0; 0 1 0 0]//8, 1:3, -1:2)
