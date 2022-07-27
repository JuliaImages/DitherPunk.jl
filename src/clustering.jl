# These functions are lazily loaded from Clustering.jl using LazyModules.jl
# Code adapted from @cormullion's [ColorSchemeTools](https://github.com/JuliaGraphics/ColorSchemeTools.jl).
function get_colorscheme(
    img,
    ncolors;
    maxiter=Clustering._kmeans_default_maxiter,
    tol=Clustering._kmeans_default_tol,
)::Vector{Lab}
    # Cluster in Lab color space

    # Clustering on the downsampled image already generates good enough colormap estimation
    # This significantly reduces the algorithmic complexity.
    img = _restrict_to(img, ncolors * 100)
    data = reshape(channelview(Lab.(img)), 3, :)
    R = Clustering.kmeans(data, ncolors; maxiter=maxiter, tol=tol)

    # Make color scheme out of cluster centers
    return [Lab(c...) for c in eachcol(R.centers)]
end

function _restrict_to(img, n)
    length(img) <= n && return img
    out = restrict(img)
    while length(out) > n
        out = restrict(out)
    end
    return out
end

function _colordither(
    ::Type{T},
    img,
    alg,
    ncolors::Integer;
    maxiter=Clustering._kmeans_default_maxiter,
    tol=Clustering._kmeans_default_tol,
    kwargs...,
) where {T}
    cs = get_colorscheme(img, ncolors; maxiter=maxiter, tol=tol)
    return _colordither(T, img, alg, cs; kwargs...)
end

"""
    dither!([out,] img, alg::AbstractDither, ncolors; maxiter, tol, kwargs...)

Dither image `img` using algorithm `alg`.
A color palette with `ncolors` is computed by Clustering.jl's K-means clustering.
The amount of `maxiter` and tolerance `tol` default to those exported by Clustering.jl.
"""
dither!(img, alg::AbstractDither, ncolors::Integer; kwargs...)

"""
    dither([T::Type,] img, alg::AbstractDither, ncolors; maxiter, tol, kwargs...)

Dither image `img` using algorithm `alg`.
A color palette with `ncolors` is computed by Clustering.jl's K-means clustering.
The amount of `maxiter` and tolerance `tol` default to those exported by Clustering.jl.
"""
dither(::Type, img, alg::AbstractDither, ncolors::Integer; kwargs...)
