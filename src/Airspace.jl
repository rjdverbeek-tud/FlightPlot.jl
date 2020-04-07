using DDR2import

function get_arefile(arefile::String)
    are = DDR2import.Are.read(arefile)
    sectors = Vector{Vector{Array{Float64, 2}}}()
    for sector in are
        append!(sectors, [[sector[2].points]])
    end
    return sectors
end

function add_sectors!(sectors::String, projparam=Equirectangular(); kwargs...)
    sectors_array = get_arefile(sectors)
    add_polygon!(sectors_array, projparam; linecolor=:grey, linewidth=0.1,
    linealpha=0.5, kwargs...)
end

# add_map!(mapsettings::MapSettings) = add_map!(mapsettings.map_filename,
# mapsettings.projection; linecolor=mapsettings.coastcolor,
# fillcolor=mapsettings.landcolor, background_color = mapsettings.seacolor,
# fillalpha=1.0, fillrange=0)
