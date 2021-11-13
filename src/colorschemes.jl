# These functions are only conditionally loaded with ColorSchemes.jl
function _dither(T, img, alg, cs::ColorSchemes.ColorScheme; kwargs...)
    return _dither(T, img, alg, cs.colors)
end

function _dither(T, img, alg, csname::Symbol; kwargs...)
    cs = ColorSchemes.colorschemes[csname]
    return _dither(T, img, alg, cs.colors; kwargs...)
end
