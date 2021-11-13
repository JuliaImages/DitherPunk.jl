abstract type AbstractThresholdDither <: AbstractDither end

"""
    WhiteNoiseThreshold()

Use white noise as a threshold map.
"""
struct WhiteNoiseThreshold <: AbstractThresholdDither end

function binarydither(::WhiteNoiseThreshold, img::GenericGrayImage)
    return img .> rand(eltype(img), size(img))
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

function binarydither(alg::ConstantThreshold, img::GenericGrayImage)
    return img .> fill(eltype(img)(alg.threshold), size(img))
end
