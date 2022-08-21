# These functions are only conditionally loaded with ColorSchemes.jl
function _colordither(T, img, alg, cs::ColorScheme; kwargs...)
    return _colordither(T, img, alg, cs.colors; kwargs...)
end
