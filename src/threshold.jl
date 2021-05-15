abstract type AbstractThresholdDither <: AbstractDither end

function dither(
    img::AbstractMatrix{<:Gray}, alg::AbstractThresholdDither; to_linear=false
)::Matrix{Gray{Bool}}
    tmap = alg(img)
    to_linear && (img = mappedarray(srgb2linear, img))
    return reinterpret(Gray{Bool}, img .> tmap)
end

"""
    WhiteNoiseThreshold()

Use white noise as a threshold map.
"""
struct WhiteNoiseThreshold <: AbstractThresholdDither end
function (alg::WhiteNoiseThreshold)(img)
    tmap = rand(Gray{N0f16}, size(img)) # threshold map is white noise
    return tmap
end

"""
    ConstantThreshold(threshold)

Use a constant threshold map. Defaults to 0.5 if `threshold` isn't specified.
"""
struct ConstantThreshold{T<:Real} <: AbstractThresholdDither
    threshold::T

    function ConstantThreshold(; threshold=0.5)
        if threshold < 0 || threshold > 1
            throw(DomainError(threshold, "Threshold needs to be between 0 and 1."))
        end
        return new{typeof(threshold)}(threshold)
    end
end

function (alg::ConstantThreshold{T})(img) where {T}
    tmap = fill(Gray{T}(alg.threshold), size(img)) # constant matrix of value threshold
    return tmap
end
