if isdefined(OffsetArrays, :OffsetMatrix)
    # This alias is introduced in OffsetArrays v1.1.3
    OffsetMatrix = OffsetArrays.OffsetMatrix
else
    const OffsetMatrix{T} = OffsetArrays.OffsetArray{T,2}
end

if VERSION < v"1.1"
    # newly added in https://github.com/JuliaLang/julia/pull/30630
    require_one_based_indexing(A...) = !Base.has_offset_axes(A...) || throw(ArgumentError("offset arrays are not supported but got an array with index other than 1"))
else
    using Base: require_one_based_indexing
end
