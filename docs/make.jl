using GroupsCore
using Documenter

DocMeta.setdocmeta!(
    GroupsCore,
    :DocTestSetup,
    :(using GroupsCore);
    recursive=true
   )

makedocs(
    sitename  = "GroupsCore.jl",
    repo      = "https://github.com/kalmar@amu.edu.pl/GroupsCore.jl/blob/{commit}{path}#{line}",
    authors   = "Marek Kaluba <kalmar@amu.edu.pl> and contributors",
    format    = Documenter.HTML(
        prettyurls  = get(ENV, "CI", "false") == "true",
        canonical   = "https://kalmar@amu.edu.pl.github.io/GroupsCore.jl",
        assets      = String[]
       ),
    modules   = [GroupsCore],
    checkdocs = :none,
    pages     = [
        "index.md",
        "Basic interface" => ["groups.md",
                              "group_elements.md"],
        "extensions.md"
    ],
)

deploydocs(;
    repo="github.com/kalmarek/GroupsCore.jl",
)
