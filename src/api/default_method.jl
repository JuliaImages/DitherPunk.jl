const DEFAULT_METHOD = FloydSteinberg()

# Binary and per-channel dithering
function dither!(out::GenericImage, img::GenericImage; kwargs...)
    return dither!(out, img, DEFAULT_METHOD; kwargs...)
end
function dither!(img::GenericImage; kwargs...)
    return dither!(img, DEFAULT_METHOD; kwargs...)
end
function dither(::Type{T}, img::GenericImage; kwargs...) where {T}
    return dither(T, img, DEFAULT_METHOD; kwargs...)
end
function dither(img::GenericImage; kwargs...)
    return dither(img, DEFAULT_METHOD; kwargs...)
end

# Dithering with custom colors
for T in (AbstractVector{<:Colorant}, ColorScheme, Integer)
    @eval function dither!(out::GenericImage, img::GenericImage, arg::$T; kwargs...)
        return dither!(out, img, DEFAULT_METHOD, arg; kwargs...)
    end
    @eval function dither!(img::GenericImage, arg::$T; kwargs...)
        return dither!(img, DEFAULT_METHOD, arg; kwargs...)
    end
    @eval function dither(::Type{CT}, img::GenericImage, arg::$T; kwargs...) where {CT}
        return dither(CT, img, DEFAULT_METHOD, arg; kwargs...)
    end
    @eval function dither(img::GenericImage, arg::$T; kwargs...)
        return dither(img, DEFAULT_METHOD, arg; kwargs...)
    end
end

# Dithering to Unicode Braille characters
function braille(img::GenericImage; kwargs...)
    return braille(img, DEFAULT_METHOD; kwargs...)
end
