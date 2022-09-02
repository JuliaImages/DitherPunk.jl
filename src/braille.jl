"""
    braille(img; kwargs...)
    braille(img, alg; kwargs...)

Binary dither with algorithm `alg`, then print image in braille.

## Keyword arguments
  - `invert`: invert Unicode output, defaults to `false`
  - `to_string`: return a string instead of printing to terminal. Defaults to `false`.

All keyword arguments for binary dithering methods can be used.
"""
function braille(img::GenericImage, alg::AbstractDither; kwargs...)
    img = convert.(Gray, img)
    return braille(img, alg; kwargs...)
end
function braille(
    img::GenericGrayImage,
    alg::AbstractDither;
    invert::Bool=false,
    to_string::Bool=false,
    kwargs...,
)
    d = dither(Bool, img, alg; kwargs...)
    return _braille(d; invert=invert, to_string=to_string)
end

# Default method:
function braille(img::GenericImage; kwargs...)
    return braille(img, DEFAULT_METHOD; kwargs...)
end

# Enable direct printing of Binary images:
braille(img::AbstractMatrix{Bool}; kwargs...) = _braille(img; kwargs...)
braille(img::BitMatrix; kwargs...) = _braille(img; kwargs...)
function braille(img::AbstractMatrix{<:BinaryGray}; kwargs...)
    return _braille(channelview(img); kwargs...)
end

function _braille(A::AbstractMatrix; invert::Bool=false, to_string::Bool=false)
    invert && (A .= .!A)
    to_string && return braille_string(A)
    print_braille(A)
    return nothing
end

function braille_string(A)
    buff = IOBuffer()
    print_braille(buff, A)
    return String(take!(buff))
end

hasrem(x, n) = !iszero(mod(x, n))
roundup(x, n) = n * cld(x, n)

print_braille(A) = print_braille(stdout, A)
function print_braille(io::IO, A)
    h, w = size(A)
    if hasrem(h, 4) || hasrem(w, 2)
        A = PaddedView(0, A, (roundup(h, 4), roundup(w, 2)))
    end
    return _print_braille(io, A)
end
function _print_braille(io::IO, A)
    rs, cs = axes(A)
    for r in first(rs):4:last(rs)
        for c in first(cs):2:last(cs)
            @inbounds print(io, braille_symbol(view(A, r:(r + 3), c:(c + 1))))
        end
        println(io)
    end
    return io
end

function braille_symbol(A)
    return @inbounds Char(
        10240 +
        A[1] +
        2 * A[2] +
        4 * A[3] +
        64 * A[4] +
        8 * A[5] +
        16 * A[6] +
        32 * A[7] +
        128 * A[8],
    )
end
