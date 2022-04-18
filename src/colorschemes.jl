# These functions are only conditionally loaded with ColorSchemes.jl
function _colordither(T, img, alg, cs::ColorSchemes.ColorScheme; kwargs...)
    return _colordither(T, img, alg, cs.colors; kwargs...)
end

function _colordither(T, img, alg, csname::Symbol; kwargs...)
    cs = _get_colorscheme(csname)
    return _colordither(T, img, alg, cs; kwargs...)
end

# help with type inference
function _get_colorscheme(csname::Symbol)::Vector{RGB}
    return ColorSchemes.colorschemes[csname].colors
end
