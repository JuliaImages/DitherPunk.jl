function __init__()
    @require ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4" begin
        function _dither!(out, img, alg, cs::ColorSchemes.ColorScheme, args...; kwargs...)
            return _dither!(out, img, alg, cs.colors, args...; kwargs...)
        end
        function _dither!(out, img, alg, csname::Symbol, args...; kwargs...)
            cs = ColorSchemes.colorschemes[csname]
            return _dither!(out, img, alg, cs.colors, args...; kwargs...)
        end
    end
end
