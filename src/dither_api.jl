abstract type AbstractDither end
abstract type AbstractColorDither <: AbstractDither end
abstract type AbstractGrayDither <: AbstractColorDither end

const GenericGrayImage = AbstractArray{<:Union{Number,AbstractGray}}
const GenericImage = Union{GenericGrayImage,AbstractArray{<:Colorant}}

function dither!(
    out::GenericImage,
    img::GenericImage,
    alg::AbstractDither,
    args...;
    to_linear=false,
    kwargs...,
)
    if size(out) != size(img)
        throw(
            ArgumentError(
                "out and img should have the same shape, instead they are $(size(out)) and $(size(img))",
            ),
        )
    end

    if to_linear
        if img isa GenericGrayImage
            img = srgb2linear.(img)
        else
            @warn "Skipping transformation `to_linear` as it can only be applied to grayscale images."
        end
    end
    return alg(out, img, args...; kwargs...)
end

function dither!(img::GenericImage, alg::AbstractDither, args...; kwargs...)
    tmp = copy(img)
    return dither!(img, tmp, alg, args...; kwargs...)
end

function dither(::Type{T}, img, alg::AbstractDither, args...; kwargs...) where {T}
    out = similar(Array{T}, axes(img))
    dither!(out, img, alg, args...; kwargs...)
    return out
end

# Default return type for grayscale algs: `Gray{Bool}`
function dither(img::GenericGrayImage, alg::AbstractDither, args...; kwargs...)
    return dither(Gray{Bool}, img, alg, args...; kwargs...)
end

# Default return type for grayscale algs: type of color scheme `cs`
function dither(
    img::GenericImage, alg::AbstractDither, cs::AbstractVector{T}, args...; kwargs...
) where {T<:Colorant}
    return dither(T, img, alg, cs, args...; kwargs...)
end

"""
    dither!([out,] img, alg::AbstractDither, args...; kwargs...)

Dither `img` using algorithm `alg`.

# Output
If `out` is specified, it will be changed in place. Otherwise `img` will be changed in place.
"""
dither!

"""
    binarize([T::Type,] img, alg::AbstractDither, args...; kwargs...)

Dither `img` using algorithm `alg`.

# Output
If no return type is specified, the default return type for binary dithering algorithms
is `Gray{Bool}`. For color algorithms, the type of the colorscheme is used.
"""
dither
