abstract type AbstractThresholdDither <: AbstractDither end

function dither(
    img::AbstractMatrix{<:Gray}, alg::AbstractThresholdDither; to_linear=false
)::BitMatrix
    tmap = alg(img)
    to_linear && (img = mappedarray(srgb2linear, img))
    return img .> tmap
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
struct ConstantThreshold <: AbstractThresholdDither
    threshold::Real

    function ConstantThreshold(threshold)
        if threshold < 0 || threshold > 1
            throw(DomainError(threshold, "Threshold needs to be between 0 and 1."))
        end
        return new(threshold)
    end
    function ConstantThreshold()
        return ConstantThreshold(0.5)
    end
end

function (alg::ConstantThreshold)(img)
    tmap = fill(Gray{N0f16}(alg.threshold), size(img)) # constant matrix of value threshold
    return tmap
end
