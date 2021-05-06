if isdefined(OffsetArrays, :OffsetMatrix)
    # This alias is introduced in OffsetArrays v1.1.3
    OffsetMatrix = OffsetArrays.OffsetMatrix
else
    const OffsetMatrix{T} = OffsetArrays.OffsetArray{T,2}
end

if VERSION >= v"1.1"
    # I:J syntax for CartesianIndex is newly introduced in
    # https://github.com/JuliaLang/julia/pull/29440
    _colon(a::CartesianIndex, b::CartesianIndex) = a:b
else
    _colon(a::CartesianIndex, b::CartesianIndex) = CartesianIndices(map(UnitRange, a.I, b.I))
end
