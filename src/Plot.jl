using Shapefile, Plots
using Navigation
gr()

# function initialize_plot()
#     plot(xaxis=((-0.75,0.75), font(6)), yaxis=((-0.375,0.375), font(6)), legend = false,
#     grid = false, showaxis = true, ticks = false, xticks = -180.0:10.0:180.0,
#     yticks = -90.0:0.5:90.0, framestyle=:box)
# end

# function initialize_plot()
#     plot(xaxis=((-180.0,180.0), font(6)), yaxis=((-90.0,90.0), font(6)), legend = false,
#     grid = false, showaxis = false, ticks = false, xticks = -180.0:10.0:180.0,
#     yticks = -90.0:5.0:90.0, framestyle=:box)
# end

function initialize_plot()
    plot(legend = false, grid = false, showaxis = true, ticks = true,
    framestyle=:box)
end

function shapes2latlon(shapes::Array{Union{Missing, Shapefile.Polygon},1})
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
    lon, lat
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Mercator)
    println(projparam.central_meridian_deg)
    lon, lat = shapes2latlon(shapes)
    # lon = Vector{Float64}()
    # lat = Vector{Float64}()
    # for shape in shapes
    #     for point in shape.points
    #         append!(lon, point.x)
    #         append!(lat, point.y)
    #     end
    #     append!(lon, NaN)
    #     append!(lat, NaN)
    # end
    # centre_point = [50.0,-35.0]
    # points = vcat(limitdistance.(centre_point[1], centre_point[2], lat, lon)...)
    # points = vcat(latlon2gnomonic.(centre_point[1], centre_point[2], lat, lon)...)
    # points = vcat(latlon2latlon.(lat, lon)...)
    # lon, lat
    # x, y
    # projection(lat::Float64, lon::Float64) = mercator(lat, lon,
    # projparam=projparam)
    # points = vcat(projection.(lat, lon)...)
    # points = map((lat, lon) -> mercator(lat, lon), lat, lon)
    # points = vcat(mercator.(lat, lon, projparam=projparam)...)
    projection(lat::Float64, lon::Float64) = mercator(lat, lon, projparam)
    # points = vcat(mercator.(lat, lon, test)...)
    points = vcat(projection.(lat, lon)...)
    points[:,1], points[:,2]
end

# @recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1},
#     projparam::EquiRectangular=EquiRectangular())
#     points = vcat(equirectangular.(lat, lon)...)
#     points[:,1], points[:,2]
# end


function get_shapefile(shp::String)
    return Shapefile.shapes(Shapefile.Table(shp))
end

# """
# latlon2gnomonic(centre_point_lat_deg::Float64,
#     centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)
#
# Source: https://mathworld.wolfram.com/GnomonicProjection.html
# """
# function latlon2gnomonic(centre_point_lat_deg::Float64,
#     centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)
#
#     limited_point = limitdistance(centre_point_lat_deg, centre_point_lon_deg,
#     lat_deg, lon_deg)
#
#     ϕ₀ = deg2rad(centre_point_lat_deg)
#     λ₀ = deg2rad(centre_point_lon_deg)
#     ϕ = deg2rad(limited_point[2])
#     λ = deg2rad(limited_point[1])
#
#     cosc = sin(ϕ₀)sin(ϕ) + cos(ϕ₀)cos(ϕ)cos(λ - λ₀)
#     x = cos(ϕ)sin(λ - λ₀) / cosc
#     y = (cos(ϕ₀)sin(ϕ) - sin(ϕ₀)cos(ϕ)cos(λ - λ₀)) / cosc
#     return [x y]
# end
#
# function limitdistance(centre_point_lat_deg::Float64,
#     centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)
#     center_point = Navigation.Point_deg(centre_point_lat_deg,
#     centre_point_lon_deg)
#     point = Navigation.Point_deg(lat_deg, lon_deg)
#     angular_distance = Navigation.distance(center_point, point, 1.0)
#     max_angular_distance = π * 0.4
#     if angular_distance > max_angular_distance
#         fraction = max_angular_distance / angular_distance
#         new_point = Navigation.intermediate_point(center_point, point, fraction)
#         return [new_point.λ new_point.ϕ]
#     else
#         return [lon_deg lat_deg]
#     end
# end
#
# function latlon2latlon(lat_deg::Float64, lon_deg::Float64)
#     return [lon_deg lat_deg / 2.0]
# end
