abstract type AbstractThresholdDither <: AbstractDither end

"""
    WhiteNoiseThreshold()

Use white noise as a threshold map.
"""
struct WhiteNoiseThreshold <: AbstractThresholdDither end

function binarydither(::WhiteNoiseThreshold, img::GenericGrayImage)
    T = eltype(img)
    return map(px -> px > rand(T) ? INDEX_WHITE : INDEX_BLACK, img)
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
    threshold = eltype(img)(alg.threshold)
    return map(px -> px > threshold ? INDEX_WHITE : INDEX_BLACK, img)
end
