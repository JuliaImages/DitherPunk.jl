const BRAILLE_SYMBOLS = Char.(10240:10495)
const BRAILLE_CODE = [1, 2, 4, 64, 8, 16, 32, 128]
const H_BRAILLE = 4
const W_BRAILLE = 2

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
    return braille(img, alg; kwargs)
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

# Enable direct prining of Binary images:
braille(img::AbstractMatrix{Bool}; kwargs...) = _braille(img; kwargs...)
braille(img::BitMatrix; kwargs...) = _braille(img; kwargs...)
function braille(img::AbstractMatrix{<:BinaryGray}; kwargs...)
    return _braille(channelview(img); kwargs...)
end

function _braille(A::AbstractMatrix; invert::Bool=false, to_string::Bool=false)
    invert && (A .= .!A)
    B = _braille_matrix(A)
    str = _mat2string(B)
    to_string && return str
    print(str)
    return nothing
end

# Construct Matrix{Char} of Unicode Braille characters
function _braille_matrix(A::AbstractMatrix)
    hi, wi = size(A)
    ho, wo = cld(hi, H_BRAILLE), cld(wi, W_BRAILLE)
    out = Matrix{Char}(undef, ho, wo)

    AP = PaddedView(0, A, (ho * H_BRAILLE, wo * W_BRAILLE))
    for (i, tileaxs) in enumerate(TileIterator(axes(AP), (H_BRAILLE, W_BRAILLE)))
        v = view(AP, tileaxs...)
        out[i] = BRAILLE_SYMBOLS[_braille_index(v)]
    end
    return out
end

Base.@propagate_inbounds function _braille_index(A)
    idx = 1
    for i in 1:8
        idx += A[i] * BRAILLE_CODE[i]
    end
    return idx
end

function _mat2string(A::AbstractMatrix)
    io = IOBuffer()
    nmax = size(A, 1)
    for (i, line) in enumerate(eachrow(A))
        foreach(c -> print(io, c), line)
        i < nmax && println(io)
    end
    return String(take!(io))
end
