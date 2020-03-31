const GridColor = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0)
const CoastColor = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0)
const SeaColor = RGB(205.0/255.0, 235.0/255.0,240.0/255.0)
const LandColor = RGB(1.0, 1.0, 1.0)
# path_land = "data\\GSHHS_c_L1.shp"
# path_lakes = "data\\GSHHS_c_L2.shp"

function add_map!(shp::String, projparam::Mercator; linecolor::RGB{Float64} = CoastColor, fillcolor::RGB{Float64} = LandColor,
    background_color::RGB{Float64} = SeaColor,
    foreground_color_grid::RGB{Float64} = GridColor)

    plot!(get_shapefile(shp), projparam::Mercator, linecolor = linecolor,
    linewidth = 0.1, fill = (0, 1.0, fillcolor),
    background_color = background_color,
    foreground_color_grid = foreground_color_grid)
end
