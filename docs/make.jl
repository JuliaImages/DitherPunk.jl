using DitherPunk
using Documenter, Literate

EXAMPLE_DIR = joinpath(@__DIR__, "literate")
OUT_DIR = joinpath(@__DIR__, "src/generated")

## Use Literate.jl to generate docs and notebooks of examples
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
    repo="https://github.com/adrhill/DitherPunk.jl/blob/{commit}{path}#{line}",
    sitename="DitherPunk.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://adrhill.github.io/DitherPunk.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => "generated/simple_example.jl",
        "Gallery" => "generated/gallery.md",
    ],
)

deploydocs(; repo="github.com/adrhill/DitherPunk.jl", devbranch="master", branch="gh-pages")
