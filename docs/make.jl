using GroupsCore
using Documenter

DocMeta.setdocmeta!(GroupsCore, :DocTestSetup, :(using GroupsCore); recursive=true)

makedocs(;
    modules=[GroupsCore],
    authors="Marek Kaluba <kalmar@amu.edu.pl> and contributors",
    repo="https://github.com/kalmar@amu.edu.pl/GroupsCore.jl/blob/{commit}{path}#{line}",
    sitename="GroupsCore.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kalmar@amu.edu.pl.github.io/GroupsCore.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kalmar@amu.edu.pl/GroupsCore.jl",
)
