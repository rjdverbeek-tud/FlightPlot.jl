using DDR2import

function get_arefile(arefile::String)
    are = DDR2import.Are.read(arefile)
    sectors = Vector{Vector{Array{Float64, 2}}}()
    for sector in are
        append!(sectors, [[sector[2].points]])
    end
    return sectors
end

function add_sectors!(sectors::String, projparam=Equirectangular();
    linecolor=:grey, linewidth=0.01, linealpha=0.33, kwargs...)
    sectors_array = get_arefile(sectors)
    add_polygon!(sectors_array, projparam; linecolor=linecolor,
    linewidth=linewidth, linealpha=linealpha, kwargs...)
end

add_sectors!(sectors::String, mapsettings::MapSettings; kwargs...) =
add_sectors!(sectors, mapsettings.projection; kwargs...)

function add_freeflightairspaces!(sectors::String, projparam=Equirectangular();
    linecolor=:orange, linewidth=0.01, linealpha=0.2, fillcolor=:orange,
    fillalpha=0.1, fillrange=0, kwargs...)
    sectors_array = get_arefile(sectors)
    add_polygon!(sectors_array, projparam; linecolor=linecolor,
    linewidth=linewidth, linealpha=linealpha, fillcolor=fillcolor,
    fillalpha=fillalpha, fillrange=fillrange, kwargs...)
end

add_freeflightairspaces!(sectors::String, mapsettings::MapSettings; kwargs...) =
add_freeflightairspaces!(sectors, mapsettings.projection; kwargs...)

# add_map!(mapsettings::MapSettings) = add_map!(mapsettings.map_filename,
# mapsettings.projection; linecolor=mapsettings.coastcolor,
# fillcolor=mapsettings.landcolor, background_color = mapsettings.seacolor,
# fillalpha=1.0, fillrange=0)

# mapsettings.map_filename,
# mapsettings.projection; linecolor=mapsettings.coastcolor,
# fillcolor=mapsettings.landcolor, background_color = mapsettings.seacolor,
# fillalpha=1.0, fillrange=0
