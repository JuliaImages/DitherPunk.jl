const DEFAULT_UNICODE_METHOD = :braille

"""
    braille(img; kwargs...)
    braille(img, alg; kwargs...)

Binary dither with algorithm `alg`, then print image in braille.

## Keyword arguments
  - `invert`: invert Unicode output, defaults to `false`
  - `to_string`: return a string instead of printing to terminal. Defaults to `false`.
  - `method`: method used to print in unicode. Either `:braille` or `:block`.
    Defaults to `:$DEFAULT_UNICODE_METHOD`.

All keyword arguments for binary dithering methods can be used.
"""
function braille(img::GenericImage, alg::AbstractDither; kwargs...)
    img = convert.(Gray, img)
    return braille(img, alg; kwargs...)
end
function braille(
    img::GrayImage,
    alg::AbstractDither;
    invert::Bool = false,
    to_string::Bool = false,
    method::Symbol = DEFAULT_UNICODE_METHOD,
    kwargs...,
)
    d = dither(Bool, img, alg; kwargs...)
    return _braille(d; invert = invert, to_string = to_string, method = method)
end

# Default method:
function braille(img::GenericImage; kwargs...)
    return braille(img, DEFAULT_METHOD; kwargs...)
end

# Enable direct printing of Binary images:
braille(img::AbstractMatrix{Bool}; kwargs...) = _braille(img; kwargs...)
braille(img::BitMatrix; kwargs...) = _braille(img; kwargs...)
function braille(img::AbstractMatrix{<:AbstractGray{Bool}}; kwargs...)
    return _braille(channelview(img); kwargs...)
end

# Call UnicodeGraphics for printing:
function _braille(
        A::AbstractMatrix;
        invert::Bool = false,
        to_string::Bool = false,
        method::Symbol = DEFAULT_UNICODE_METHOD,
    )
    invert && (A .= .!A)
    to_string && return ustring(A, method)
    return uprint(A, method)
end
