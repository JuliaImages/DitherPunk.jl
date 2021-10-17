# These functions are only conditionally loaded with ColorSchemes.jl
function _dither!(out, img, alg, cs::ColorSchemes.ColorScheme; kwargs...)
    return _dither!(out, img, alg, cs.colors)
end

function _dither!(out, img, alg, csname::Symbol; kwargs...)
    cs = ColorSchemes.colorschemes[csname]
    return _dither!(out, img, alg, cs.colors; kwargs...)
end
