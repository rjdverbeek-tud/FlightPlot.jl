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

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Equirectangular)
    lon, lat = shapes2latlon(shapes)
    points = vcat(equirectangular.(lat, lon)...)
    points[:,1], points[:,2]
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Mercator)
    lon, lat = shapes2latlon(shapes)
    projection(lat::Float64, lon::Float64) = mercator(lat, lon, projparam)
    points = vcat(projection.(lat, lon)...)
    points[:,1], points[:,2]
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Lambert)
    lon, lat = shapes2latlon(shapes)
    projection(lat::Float64, lon::Float64) = lambert(lat, lon, projparam)
    points = vcat(projection.(lat, lon)...)
    points[:,1], points[:,2]
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Gnomonic)
    lon, lat = shapes2latlon(shapes)
    projection(lat::Float64, lon::Float64) = gnomonic(lat, lon, projparam)
    points = vcat(projection.(lat, lon)...)
    points[:,1], points[:,2]
end

function get_shapefile(shp::String)
    return Shapefile.shapes(Shapefile.Table(shp))
end

function add_polygon!(shp::String, projparam=Equirectangular(); kwargs...)
    plot!(get_shapefile(shp), projparam; kwargs...)
end
