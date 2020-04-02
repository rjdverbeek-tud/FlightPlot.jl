const GridColor = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0)
const CoastColor = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0)
const SeaColor = RGB(205.0/255.0, 235.0/255.0,240.0/255.0)
const LandColor = RGB(1.0, 1.0, 1.0)

function add_map!(shp::String, projparam=Equirectangular();
    linecolor::RGB{Float64} = CoastColor, fillcolor::RGB{Float64} = LandColor,
    background_color::RGB{Float64} = SeaColor, kwargs...)

    add_polygon!(shp, projparam, linecolor=linecolor, fill = (0, 1.0, fillcolor),
    background_color = background_color; kwargs...)
end

function add_lakes!(shp::String, projparam=Equirectangular();
    linecolor::RGB{Float64} = CoastColor, fillcolor::RGB{Float64} = SeaColor,
    kwargs...)

    add_polygon!(shp, projparam, linecolor=linecolor, fill = (0, 1.0, fillcolor);
    kwargs...)
end
