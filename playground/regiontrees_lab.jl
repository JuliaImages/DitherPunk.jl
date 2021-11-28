using RegionTrees
using RegionTrees: children, parent, center
import RegionTrees: AbstractRefinery, needs_refinement, refine_data
using LinearAlgebra
using StaticArrays: SVector
using Plots

import DitherPunk: _closest_color_idx
using ImageCore
using ColorSchemes

struct ClosestColorRefinery{T<:Integer} <: AbstractRefinery
    mindepth::T
    maxdepth::T
end

cs = Lab.(distinguishable_colors(20))
# cs = Lab.(ColorSchemes.websafe)

@inline isroot(c::Cell) = isnothing(parent(c))
@inline depth(c::Cell) = first(c.data) # data = (depth, idx)
@inline colorindex(c::Cell) = last(c.data)

@inline allsame(x) = all(y -> y == first(x), x)
@inline siblings(c::Cell) = reshape(children(parent(c)), 1, :)
@inline siblingdata(c::Cell) = colorindex.(siblings(c))
@inline siblingssame(c::Cell) = allsame(siblingdata(c))

@inline function _closest_color_idx(b::HyperRectangle)
    return _closest_color_idx(Lab(center(b)...), cs, DE_2000())
end

function needs_refinement(r::ClosestColorRefinery, cell)
    isroot(cell) && return true
    d = depth(cell)
    (d < r.mindepth) && return true
    (d <= r.maxdepth) && return false
    return !siblingssame(cell)
end

function refine_data(::ClosestColorRefinery, cell, indices)
    return (depth(cell) + 1, _closest_color_idx(child_boundary(cell, indices)))
end

evaluate(col::Lab) = colorindex(RegionTrees.findleaf(root, [col.l, col.a, col.b]))

# L ∈ [0, 100]
# a ∈ [-127, 128]
# b ∈ [-127, 128]
boundary = RegionTrees.HyperRectangle(
    SVector(0.0, -127.0, -127.0), SVector(100.0, 255.0, 255.0)
)
refinery = ClosestColorRefinery(5, 10)
rootval = _closest_color_idx(boundary)
root = Cell(boundary, (0, rootval))

## Evaluate accuracy:
n = 512^2
cols = rand(Lab, n)

println("Naive:")
@time idx_true = [_closest_color_idx(c, cs, DE_2000()) for c in cols];

println("RegionTrees octree:")
@time adaptivesampling!(root, refinery)  # build tree
@time idx_approx = evaluate.(cols);  # evaluate points on it

println("Accuracy: ", sum(idx_true .== idx_approx) / n)
failed_pairs = hcat(
    sort(
        unique([[cs[a]; cs[b]] for (a, b) in zip(idx_true, idx_approx) if a != b]);
        by=t -> t[1].l,
    )...,
)
