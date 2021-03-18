using DitherPunk
using Documenter

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
    ],
)

deploydocs(;
    repo="github.com/adrhill/DitherPunk.jl",
)
