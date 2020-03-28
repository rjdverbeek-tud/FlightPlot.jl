using Shapefile, Plots
gr()

const GridColor = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0)
const CoastColor = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0)
const SeaColor = RGB(205.0/255.0, 235.0/255.0,240.0/255.0)
const LandColor = RGB(1.0, 1.0, 1.0)
# path_land = "data\\GSHHS_c_L1.shp"
# path_lakes = "data\\GSHHS_c_L2.shp"

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1})
    lon = Vector{Float64}()
    lat = Vector{Float64}()
    for shape in shapes
        for point in shape.points
            append!(lon, point.x)
            append!(lat, point.y)
        end
        append!(lon, NaN)
        append!(lat, NaN)
    end
    lon,lat
end

function initialize_plot(;grid_color=GridColor)
    plot(framestyle=:box, xaxis=((-180,180), font(6)), yaxis=((-90,90), font(6)))
end

function info_plot!(;grid_color=GridColor)
    plot!(foreground_color_grid = grid_color,
    foreground_color_guide = RGB(84.0/255.0, 188.0/255.0, 107.0/255.0),
    xticks=-180:10:180, yticks=-90:5:90, aspect_ratio=:equal, legend = false)
end

function add_map!(shp::String; linecolor::RGB{Float64}=CoastColor, fillcolor::RGB{Float64}=
    LandColor, background_color::RGB{Float64}=SeaColor)
    plot!(get_shapefile(shp), linecolor = linecolor, linewidth = 0.1,
    fill = (0, 1.0, fillcolor), background_color = background_color)
end

function get_shapefile(shp::String)
    return Shapefile.shapes(Shapefile.Table(shp))
end

#TODO add network to plot
#TODO add trajectory to plot
#TODO add set of trajectories to plot (same color)
#TODO add set of trajectories to plot (different colors)
#TODO add airports to add_map
#TODO add wind data to map
