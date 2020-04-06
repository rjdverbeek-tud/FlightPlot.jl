using Navigation
using Printf
# const GridColor = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0)
# const CoastColor = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0)
# const SeaColor = RGB(205.0/255.0, 235.0/255.0,240.0/255.0)
# const LandColor = RGB(1.0, 1.0, 1.0)
# using Printf

struct MapSettings
    map_filename::String
    lake_filename::String
    projection::Union{Equirectangular, Mercator, Lambert, Gnomonic}
    lonticks::StepRangeLen
    latticks::StepRangeLen
    gridcolor::RGB{Float64}
    coastcolor::RGB{Float64}
    seacolor::RGB{Float64}
    landcolor::RGB{Float64}
    gridlinewidth::Float64
    gridalpha::Float64
    function MapSettings(;map_filename::String="data\\GSHHS_c_L1.shp",
        lake_filename::String="data\\GSHHS_c_L2.shp",
        projection::Union{Equirectangular, Mercator, Lambert, Gnomonic}=
        Equirectangular(), lonticks::StepRangeLen=-180.0:10.0:180.0,
        latticks::StepRangeLen=-85.0:2.5:85.0,
        gridcolor::RGB{Float64} = RGB(107.0/255.0, 191.0/255.0, 91.0/255.0),
        coastcolor::RGB{Float64} = RGB(117.0/255.0, 207.0/255.0, 224.0/255.0),
        seacolor::RGB{Float64} = RGB(205.0/255.0, 235.0/255.0,240.0/255.0),
        landcolor::RGB{Float64} = RGB(1.0, 1.0, 1.0),
        gridlinewidth::Float64 = 0.01, gridalpha::Float64 = 0.33)
        new(map_filename, lake_filename, projection, lonticks, latticks, gridcolor,
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
    plot!(mapsettings.lonticks, mapsettings.latticks, mapsettings.projection;
    linewidth=mapsettings.gridlinewidth, linecolor=mapsettings.gridcolor,
    linealpha = mapsettings.gridalpha)
end

function boundaries_map(mapsettings::MapSettings;
    lonlims::Tuple{Float64, Float64} = (-180.0, 180.0),
    latlims::Tuple{Float64, Float64} = (-85.0, 85.0))
    left = projection(lonlims[1], (latlims[1] + latlims[2])/2.0, mapsettings.projection)[1]
    right = projection(lonlims[2], (latlims[1] + latlims[2])/2.0, mapsettings.projection)[1]
    top = projection((lonlims[1] + lonlims[2])/2.0, latlims[2], mapsettings.projection)[2]
    bottom = projection((lonlims[1] + lonlims[2])/2.0, latlims[1], mapsettings.projection)[2]
    left, right, bottom, top
end

function lims_map!(mapsettings::MapSettings;
    lonlims::Tuple{Float64, Float64} = (-180.0, 180.0),
    latlims::Tuple{Float64, Float64} = (-85.0, 85.0))
    left, right, bottom, top = boundaries_map(mapsettings, lonlims=lonlims,
    latlims=latlims)
    plot!(xlims=(left, right), ylims=(bottom, top))
end

function axis_map!(mapsettings::MapSettings;
    lonlims::Tuple{Float64, Float64} = (-180.0, 180.0),
    latlims::Tuple{Float64, Float64} = (-85.0, 85.0))
    left, right, bottom, top = boundaries_map(mapsettings, lonlims=lonlims,
    latlims=latlims)
    x = [left, right, right, left, left]
    y = [bottom, bottom, top, top, bottom]
    plot!(x,y, linewidth=1.0, linecolor=:black)
end

function ticks_map!(mapsettings::MapSettings;
    lonlims::Tuple{Float64, Float64} = (-180.0, 180.0),
    latlims::Tuple{Float64, Float64} = (-85.0, 85.0))

    left, right, bottom, top = boundaries_map(mapsettings, lonlims=lonlims,
    latlims=latlims)

    #xtick Gnomonic
    λ₃, ϕ₃ = projection_inv(left, bottom, mapsettings.projection)
    λ₄, ϕ₄ = projection_inv(right, bottom, mapsettings.projection)
    λ₅, ϕ₅ = projection_inv(left, top, mapsettings.projection)
    pos₃ = Navigation.Point_deg(ϕ₃, λ₃)
    pos₄ = Navigation.Point_deg(ϕ₄, λ₄)
    pos₅ = Navigation.Point_deg(ϕ₅, λ₅)
    bearing₃₄ = Navigation.bearing(pos₃, pos₄)

    x = Vector{Float64}()
    t = Vector{String}()
    for lontick in mapsettings.lonticks
        pos₁ = Navigation.Point_deg(latlims[2], lontick)
        bearing₁₂ = 180.0
        pos_tick = Navigation.intersection_point(pos₁, pos₃, bearing₁₂, bearing₃₄)
        if !isinf(pos_tick.ϕ)
            loc = projection(lontick, pos_tick.ϕ, mapsettings.projection)[1]
            txt = Printf.@sprintf("%4.0f°", lontick)
            append!(x, loc)
            t = vcat(t, txt)
        end
    end
    plot!(showaxis=true, xticks = (x,t), ticks = true)

    # #ytick Gnomonic
    # y = Vector{Float64}()
    # t = Vector{String}()
    #
    # function newton(pos₁::Navigation.Point_deg, pos₂::Navigation.Point_deg,
    #     lat_deg::Float64, left::Float64, mapsettings::MapSettings)
    #     first_pos = pos₁
    #     first_fraction = 0.0
    #     last_pos = pos₂
    #     last_fraction = 1.0
    #     fraction = 0.5
    #     next_pos = Navigation.intermediate_point(first_pos, last_pos, fraction)
    #     while abs(next_pos.ϕ - lat_deg) > 0.01
    #         if next_pos.ϕ - lat_deg > 0.0
    #         else
    #         end
    #     end
    # end
    # #
    # for lattick in mapsettings.latticks
    #     if ϕ₃ ≤ lattick ≤ ϕ₅
    #
    #         # loc = projection(?, lattick, mapsettings.projection)[1]
    #         txt = Printf.@sprintf("%4.0f°", lattick)
    #         append!(y, loc)
    #         t = vcat(t, txt)
    #     end
    #
    # end
    # plot!(yticks = (y,t))
end
