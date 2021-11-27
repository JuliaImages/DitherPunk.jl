# These functions are only conditionally loaded with Clustering.jl
# Code adapted from @cormullion's [ColorSchemeTools](https://github.com/JuliaGraphics/ColorSchemeTools.jl).
function get_colorscheme(
    img,
    ncolors;
    maxiter=Clustering._kmeans_default_maxiter,
    tol=Clustering._kmeans_default_tol,
)
    # Cluster in Lab color space
    data = reshape(channelview(Lab.(img)), 3, :)
    R = Clustering.kmeans(data, ncolors; maxiter=maxiter, tol=tol)

    # Make color scheme out of cluster centers
    cs = Lab{Float64}[]
    for i in 1:3:length(R.centers)
        push!(cs, Lab(R.centers[i], R.centers[i + 1], R.centers[i + 2]))
    end
    return cs
end

function _colordither(
    ::Type{T},
    img,
    alg,
    ncolors::Int;
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
dither!

"""
    dither([T::Type,] img, alg::AbstractDither, ncolors; maxiter, tol, kwargs...)

Dither image `img` using algorithm `alg`.
A color palette with `ncolors` is computed by Clustering.jl's K-means clustering.
The amount of `maxiter` and tolerance `tol` default to those exported by Clustering.jl.
"""
dither
