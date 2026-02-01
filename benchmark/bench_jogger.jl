using BenchmarkTools
using DitherPunk
using TestImages
using ColorTypes: RGB

on_CI = haskey(ENV, "GITHUB_ACTIONS")

img_gray = testimage("fabio_gray_256")
img_color = testimage("fabio_color_256")

## Define color scheme
white = RGB{Float32}(1, 1, 1)
yellow = RGB{Float32}(1, 1, 0)
green = RGB{Float32}(0, 0.5, 0)
orange = RGB{Float32}(1, 0.5, 0)
red = RGB{Float32}(1, 0, 0)
blue = RGB{Float32}(0, 0, 1)
cs = [white, yellow, green, orange, red, blue]

# Use one representative algorithm of each type
algs = Dict(
    "error diffusion" => FloydSteinberg(),
    "ordered dithering" => Bayer(3),
    "closest color" => ClosestColor(),
    "threshold dithering" => WhiteNoiseThreshold(),
)

# Tag what is tested on each algorithm type
suite = BenchmarkGroup()
suite["error diffusion"] = BenchmarkGroup(["binary", "color"])
suite["ordered dithering"] = BenchmarkGroup(["binary", "color"])
suite["threshold dithering"] = BenchmarkGroup(["binary"])
suite["closest color"] = BenchmarkGroup(["binary", "color"])

println(suite)

for (algname, alg) in algs
    suite[algname]["binary new"] = @benchmarkable dither($(img_gray), $(alg))
    suite[algname]["binary inplace"] = @benchmarkable dither!($(copy(img_gray)), $(alg))

    suite[algname]["per-channel new"] = @benchmarkable dither($(img_color), $(alg))
    suite[algname]["per-channel inplace"] = @benchmarkable dither!(
        $(copy(img_color)), $(alg)
    )

    if "color" in suite[algname].tags
        suite[algname]["color new"] = @benchmarkable dither($(img_color), $(alg), $(cs))
        suite[algname]["color inplace"] = @benchmarkable dither!(
            $(copy(img_color)), $(alg), $(cs)
        )
    end
end
