# These functions are only conditionally loaded with Clustering.jl
# Code adapted from @cormullion's [ColorSchemeTools](https://github.com/JuliaGraphics/ColorSchemeTools.jl).

function _dither!(
    out,
    img,
    alg,
    ncolors::Int;
    maxiter=Clustering._kmeans_default_maxiter,
    tol=Clustering._kmeans_default_tol,
    kwargs...,
)
    T = eltype(img)

    # Cluster in Lab color space
    data = reshape(channelview(Lab.(img)), 3, :)
    R = Clustering.kmeans(data, ncolors; maxiter=maxiter, tol=tol)

    # Make color scheme out of cluster centers
    cs = Lab{Float64}[]
    for i in 1:3:length(R.centers)
        push!(cs, Lab(R.centers[i], R.centers[i + 1], R.centers[i + 2]))
    end

    return _dither!(out, img, alg, T.(cs); kwargs...)
end
