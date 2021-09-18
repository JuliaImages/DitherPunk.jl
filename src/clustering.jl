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
    imdata = convert(Array{Float64}, channelview(img))

    if !any(n -> n == 3, size(imdata))
        error("Image file \"$imfile\" doesn't have three color channels")
    end

    data = reshape(imdata, 3, :)
    R = Clustering.kmeans(
        data,
        ncolors;
        maxiter=maxiter,
        tol=tol,
        # distance=SqColor(RGB),
    )
    cs = RGB{Float64}[]
    for i in 1:3:length(R.centers)
        push!(cs, RGB(R.centers[i], R.centers[i + 1], R.centers[i + 2]))
    end

    return _dither!(out, img, alg, cs; kwargs...)
end
