using Documenter, FlightPlot

makedocs(
    sitename = "FlightPlot.jl",
    modules = [FlightPlot],
    pages = Any[
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/rjdverbeek-tud/FlightPlot.jl.git",
)
