using DitherPunk
using Documenter
using Literate

EXAMPLE_DIR = joinpath(@__DIR__, "literate")
OUT_DIR = joinpath(@__DIR__, "src/generated")

# Use Literate.jl to generate docs and notebooks of examples
for example in readdir(EXAMPLE_DIR)
    EXAMPLE = joinpath(EXAMPLE_DIR, example)

    Literate.markdown(EXAMPLE, OUT_DIR; documenter=true) # markdown for Documenter.jl
    Literate.notebook(EXAMPLE, OUT_DIR) # .ipynb notebook
    Literate.script(EXAMPLE, OUT_DIR) # .jl script
end

DocMeta.setdocmeta!(DitherPunk, :DocTestSetup, :(using DitherPunk); recursive=true)

makedocs(;
    modules=[DitherPunk],
    authors="Adrian Hill",
    sitename="DitherPunk.jl",
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", "false") == "true", assets=String[]),
    pages=[
        "Getting started" => "index.md",
        "Gallery" => Any[
            "Images" => "generated/gallery_images.md",
            "Gradient" => "generated/gallery_gradient.md",
        ],
        "Fun applications" => Any[
            "ASCII dithering" => "generated/ascii.md",
            "SDF halftoning" => "generated/sdf_halftoning.md",
            "Color cycling" => "generated/color_cycling.md",
            "Palette swapping" => "generated/palette_swapping.md",
        ],
        "API Reference" => "api.md",
    ],
    linkcheck=true,
    checkdocs=:exports,
    warnonly=[:missing_docs],
)

deploydocs(; repo="github.com/JuliaImages/DitherPunk.jl")
