using PBRTMakie
using Documenter

DocMeta.setdocmeta!(PBRTMakie, :DocTestSetup, :(using PBRTMakie); recursive=true)

makedocs(;
    modules=[PBRTMakie],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="PBRTMakie.jl",
    format=Documenter.HTML(;
        canonical="https://asinghvi17.github.io/PBRTMakie.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/asinghvi17/PBRTMakie.jl",
    devbranch="main",
)
