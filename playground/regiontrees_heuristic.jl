using RegionTrees
using RegionTrees: center, faces, vertices
using RegionTrees: children, parent
import RegionTrees: AbstractRefinery, needs_refinement, refine_data
using LinearAlgebra
using StaticArrays: SVector
using Plots

function closest_color(x, y)
    return round(Int8, 3 * sinc(norm([x + 1, y]) / π))
end

##
struct ClosestColorRefinery <: AbstractRefinery
    tolerance::Float64
end

isroot(c::Cell) = isnothing(parent(c))

allsame(x) = all(y -> y == x[1], x)
siblings(c::Cell) = reshape(children(parent(c)), 1, :)
siblingdata(c::Cell) = getproperty.(siblings(c), :data)
siblingssame(c::Cell) = allsame(siblingdata(c))

closest_color(b::HyperRectangle) = closest_color(center(b)...)

function needs_refinement(r::ClosestColorRefinery, cell)
    isroot(cell) && return true
    (prod(cell.boundary.widths) < r.tolerance) && return false
    return !siblingssame(cell)
end

function refine_data(::ClosestColorRefinery, cell, indices)
    return closest_color(child_boundary(cell, indices))
end

##
boundary = RegionTrees.HyperRectangle(SVector(-6.0, -6.0), SVector(12.0, 12.0))
refinery = ClosestColorRefinery(1e-1)
rootval = closest_color(boundary)
root = Cell(boundary, rootval)
adaptivesampling!(root, refinery)

##
plt = plot(; xlim=(-6, 6), ylim=(-6, 6), legend=nothing, grid=false)

x = range(-6, 6; length=1000)
y = range(-6, 6; length=1000)
contour!(plt, x, y, closest_color; fill=true)
for cell in RegionTrees.allleaves(root)
    v = hcat(collect(RegionTrees.vertices(cell.boundary))...)
    plot!(v[1, [1, 2, 4, 3, 1]], v[2, [1, 2, 4, 3, 1]]; color=:white)
end
plt
savefig("asdf.png")
