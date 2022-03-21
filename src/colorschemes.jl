# These functions are only conditionally loaded with ColorSchemes.jl
function _colordither(T, img, alg, cs::ColorSchemes.ColorScheme; kwargs...)
    return _colordither(T, img, alg, cs.colors; kwargs...)
end

function _colordither(T, img, alg, csname::Symbol; kwargs...)
    cs::ColorSchemes.ColorScheme = ColorSchemes.colorschemes[csname]
    return _colordither(T, img, alg, cs; kwargs...)
end
