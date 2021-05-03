if isdefined(OffsetArrays, :OffsetMatrix)
    # This alias is introduced in OffsetArrays v1.1.3
    OffsetMatrix = OffsetArrays.OffsetMatrix
else
    const OffsetMatrix{T} = OffsetArrays.OffsetArray{T, 2}
end
