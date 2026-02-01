# These functions are only conditionally loaded with ColorSchemes.jl
function colordither(T, img, alg, cs::ColorScheme; kwargs...)
    return colordither(T, img, alg, cs.colors; kwargs...)
end
