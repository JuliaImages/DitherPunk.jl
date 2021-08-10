abstract type AbstractThresholdDither <: AbstractBinaryDither end

"""
    WhiteNoiseThreshold()

Use white noise as a threshold map.
"""
struct WhiteNoiseThreshold <: AbstractThresholdDither end

function (alg::WhiteNoiseThreshold)(out::GenericGrayImage, img::GenericGrayImage)
    tmap = rand(eltype(img), size(img))
    out .= img .> tmap
    return out
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

function (alg::ConstantThreshold)(out::GenericGrayImage, img::GenericGrayImage)
    tmap = fill(alg.threshold, size(img)) # constant matrix of value threshold
    out .= img .> tmap
    return out
end
