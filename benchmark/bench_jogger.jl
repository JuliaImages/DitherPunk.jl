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
    "ordered dithering" => Bayer(; level=3),
    "closest color" => ClosestColor(),
    "threshold dithering" => WhiteNoiseThreshold(),
)

# Tag what is tested on each algorithm type
SUITE = BenchmarkGroup()
SUITE["error diffusion"] = BenchmarkGroup(["binary", "color"])
SUITE["ordered dithering"] = BenchmarkGroup(["binary", "color"])
SUITE["threshold dithering"] = BenchmarkGroup(["binary"])
SUITE["closest color"] = BenchmarkGroup(["binary", "color"])

println(SUITE)

for (algname, alg) in algs
    SUITE[algname]["binary new"] = @benchmarkable dither($(img_gray), $(alg))
    SUITE[algname]["binary inplace"] = @benchmarkable dither!($(copy(img_gray)), $(alg))

    SUITE[algname]["per-channel new"] = @benchmarkable dither($(img_color), $(alg))
    SUITE[algname]["per-channel inplace"] = @benchmarkable dither!(
        $(copy(img_color)), $(alg)
    )

    if "color" in SUITE[algname].tags
        SUITE[algname]["color new"] = @benchmarkable dither($(img_color), $(alg), $(cs))
        SUITE[algname]["color inplace"] = @benchmarkable dither!(
            $(copy(img_color)), $(alg), $(cs)
        )
    end
end
