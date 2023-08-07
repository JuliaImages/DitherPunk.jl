function _colordither(::Type{T}, img, alg, ncolors::Integer; kwargs...) where {T}
    quantizer = KMeansQuantization(ncolors)
    return _colordither(T, img, alg, quantizer; kwargs...)
end

function _colordither(::Type{T}, img, alg, q::AbstractColorQuantizer; kwargs...) where {T}
    cs = quantize(img, q)
    return _colordither(T, img, alg, cs; kwargs...)
end

"""
    dither!([out,] img, alg::AbstractDither, ncolors; maxiter, tol, kwargs...)

Dither image `img` using algorithm `alg`.
A color palette of size `ncolors` is computed by ColorQuantization.jl's `KMeansQuantization`,
which applies K-means clustering.
"""
dither!(img, alg::AbstractDither, ncolors::Integer; kwargs...)

"""
    dither([T::Type,] img, alg::AbstractDither, ncolors; maxiter, tol, kwargs...)

Dither image `img` using algorithm `alg`.
A color palette of size `ncolors` is computed by ColorQuantization.jl's `KMeansQuantization`,
which applies K-means clustering.
"""
dither(::Type, img, alg::AbstractDither, ncolors::Integer; kwargs...)
