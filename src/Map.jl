# const GridColor = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0)
# const CoastColor = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0)
# const SeaColor = RGB(205.0/255.0, 235.0/255.0,240.0/255.0)
# const LandColor = RGB(1.0, 1.0, 1.0)

struct MapSettings
    map_filename::String
    lake_filename::String
    projection::Union{Equirectangular, Mercator, Lambert, Gnomonic}
    xticks::StepRangeLen
    yticks::StepRangeLen
    gridcolor::RGB{Float64}
    coastcolor::RGB{Float64}
    seacolor::RGB{Float64}
    landcolor::RGB{Float64}
    gridlinewidth::Float64
    gridalpha::Float64
    function MapSettings(;map_filename::String="data\\GSHHS_c_L1.shp",
        lake_filename::String="data\\GSHHS_c_L2.shp",
        projection::Union{Equirectangular, Mercator, Lambert, Gnomonic}=
        Equirectangular(), xticks::StepRangeLen=-180.0:10.0:180.0,
        yticks::StepRangeLen=-85.0:2.5:85.0,
        gridcolor::RGB{Float64} = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0),
        coastcolor::RGB{Float64} = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0),
        seacolor::RGB{Float64} = RGB(205.0/255.0, 235.0/255.0,240.0/255.0),
        landcolor::RGB{Float64} = RGB(1.0, 1.0, 1.0),
        gridlinewidth::Float64 = 0.01, gridalpha::Float64 = 0.33)
        new(map_filename, lake_filename, projection, xticks, yticks, gridcolor,
        coastcolor, seacolor, landcolor, gridlinewidth, gridalpha)
    end
end

function add_map!(shp::String, projparam=Equirectangular(); kwargs...)
    add_polygon!(shp, projparam; kwargs...)
end

add_map!(mapsettings::MapSettings) = add_map!(mapsettings.map_filename,
mapsettings.projection; linecolor=mapsettings.coastcolor,
fillcolor=mapsettings.landcolor, background_color = mapsettings.seacolor,
fillalpha=1.0, fillrange=0)

add_lakes!(mapsettings::MapSettings) = add_map!(
mapsettings.lake_filename, mapsettings.projection;
linecolor=mapsettings.coastcolor, fillcolor=mapsettings.seacolor,
background_color = mapsettings.seacolor, fillalpha=1.0, fillrange=0)

function add_grid!(mapsettings::MapSettings)
    plot!(mapsettings.xticks, mapsettings.yticks, mapsettings.projection;
    linewidth=mapsettings.gridlinewidth, linecolor=mapsettings.gridcolor,
    linealpha = mapsettings.gridalpha)
end

function lims_map!(mapsettings::MapSettings;
    xlims::Tuple{Float64, Float64} = (-180.0, 180.0),
    ylims::Tuple{Float64, Float64} = (-85.0, 85.0))
    left = projection(xlims[1], (ylims[1] + ylims[2])/2.0, mapsettings.projection)[1]
    right = projection(xlims[2], (ylims[1] + ylims[2])/2.0, mapsettings.projection)[1]
    top = projection((xlims[1] + xlims[2])/2.0, ylims[2], mapsettings.projection)[2]
    bottom = projection((xlims[1] + xlims[2])/2.0, ylims[1], mapsettings.projection)[2]
    plot!(xlims=(left, right), ylims=(bottom, top))
end

function axis_map!(mapsettings::MapSettings;
    xlims::Tuple{Float64, Float64} = (-180.0, 180.0),
    ylims::Tuple{Float64, Float64} = (-85.0, 85.0))
    left = projection(xlims[1], (ylims[1] + ylims[2])/2.0, mapsettings.projection)[1]
    right = projection(xlims[2], (ylims[1] + ylims[2])/2.0, mapsettings.projection)[1]
    top = projection((xlims[1] + xlims[2])/2.0, ylims[2], mapsettings.projection)[2]
    bottom = projection((xlims[1] + xlims[2])/2.0, ylims[1], mapsettings.projection)[2]
    x = [left, right, right, left, left]
    y = [bottom, bottom, top, top, bottom]
    plot!(x,y, linewidth=1.0, linecolor=:black)
end

#TODO Create ticks_map!
# function ticks_map!(mapsettings::MapSettings;
#     xlims::Tuple{Float64, Float64} = (-180.0, 180.0),
#     ylims::Tuple{Float64, Float64} = (-85.0, 85.0))
#     for
#     # left = projection(xlims[1], (ylims[1] + ylims[2])/2.0, mapsettings.projection)[1]
#     # right = projection(xlims[2], (ylims[1] + ylims[2])/2.0, mapsettings.projection)[1]
#     # top = projection((xlims[1] + xlims[2])/2.0, ylims[2], mapsettings.projection)[2]
#     # bottom = projection((xlims[1] + xlims[2])/2.0, ylims[1], mapsettings.projection)[2]
# end
