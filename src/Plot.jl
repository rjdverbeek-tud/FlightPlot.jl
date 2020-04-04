using Shapefile, Plots
using Navigation
# using DDR2import
gr()

# function initialize_plot()
#     plot(xaxis=((-0.75,0.75), font(6)), yaxis=((-0.375,0.375), font(6)), legend = false,
#     grid = false, showaxis = true, ticks = false, xticks = -180.0:10.0:180.0,
#     yticks = -90.0:0.5:90.0, framestyle=:box)
# end

# function initialize_plot()
    # plot(xaxis=((-180.0,180.0), font(6)), yaxis=((-90.0,90.0), font(6)), legend = false,
    # grid = false, showaxis = false, ticks = false, xticks = -180.0:10.0:180.0,
    # yticks = -90.0:5.0:90.0, framestyle=:box)
# end

function initialize_plot()
    plot(legend = false, grid = false, showaxis = false, ticks = false,
    framestyle=:box)
    # plot(legend = false, grid = false, showaxis = false, ticks = false,
    # framestyle=:box, xticks = -180.0:10.0:180.0, yticks = -85.0:2.5:85.0)
    # plot!(showaxis = true, ticks = true, xticks = -180.0:10.0:180.0,
    # yticks = -85.0:2.5:85.0, xlim=(-40.0,40.0), ylim=(-20.0, 20.0))
end

function shapes2lonlat(shapes::Array{Union{Missing, Shapefile.Polygon},1})
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

function grid2lonlat(grid_lon_deg::StepRangeLen, grid_lat_deg::StepRangeLen)
    lon = Vector{Float64}()
    lat = Vector{Float64}()
    lon_prev = NaN
    lat_prev = NaN
    fractions = 2
    function grid_loop(grid_lon::Float64, grid_lat::Float64,
        lon_prev::Float64, lat_prev::Float64, lon::Vector{Float64},
        lat::Vector{Float64}, fractions::Int64)
        if !isnan(lon_prev)
            for part in 1:(fractions - 1)
                fraction = 1.0 / fractions * part
                append!(lon, lon_prev + (grid_lon - lon_prev) * fraction)
                append!(lat, lat_prev + (grid_lat - lat_prev) * fraction)
            end
        end
        append!(lon, grid_lon)
        append!(lat, grid_lat)
        lon_prev = grid_lon
        lat_prev = grid_lat
        lon, lat, lon_prev, lat_prev
    end

    for grid_lat in grid_lat_deg
        for grid_lon in grid_lon_deg
            lon, lat, lon_prev, lat_prev = grid_loop(grid_lon, grid_lat,
            lon_prev, lat_prev, lon, lat, fractions)
        end
        append!(lon, NaN)
        append!(lat, NaN)
        lon_prev = NaN
        lat_prev = NaN
    end
    for grid_lon in grid_lon_deg
        for grid_lat in grid_lat_deg
            lon, lat, lon_prev, lat_prev = grid_loop(grid_lon, grid_lat,
            lon_prev, lat_prev, lon, lat, fractions)
        end
        append!(lon, NaN)
        append!(lat, NaN)
        lon_prev = NaN
        lat_prev = NaN
    end
    lon, lat
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Equirectangular)
    lon, lat = shapes2lonlat(shapes)
    points = vcat(equirectangular.(lon, lat)...)
    points[:,1], points[:,2]
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Mercator)
    lon, lat = shapes2lonlat(shapes)
    projection(lon::Float64, lat::Float64) = mercator(lon, lat, projparam)
    points = vcat(projection.(lon, lat)...)
    points[:,1], points[:,2]
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Lambert)
    lon, lat = shapes2lonlat(shapes)
    projection(lon::Float64, lat::Float64) = lambert(lon, lat, projparam)
    points = vcat(projection.(lon, lat)...)
    points[:,1], points[:,2]
end

@recipe function f(shapes::Array{Union{Missing, Shapefile.Polygon},1}, projparam::Gnomonic)
    lon, lat = shapes2lonlat(shapes)
    projection(lon::Float64, lat::Float64) = gnomonic(lon, lat, projparam)
    points = vcat(projection.(lon, lat)...)
    points[:,1], points[:,2]
end

@recipe function f(grid_lon_deg::StepRangeLen, grid_lat_deg::StepRangeLen,
    projparam::Mercator)
    lon, lat = grid2lonlat(grid_lon_deg, grid_lat_deg)
    projection(lon::Float64, lat::Float64) = mercator(lon, lat, projparam)
    points = vcat(projection.(lon, lat)...)
    points[:,1], points[:,2]
end

@recipe function f(grid_lon_deg::StepRangeLen, grid_lat_deg::StepRangeLen,
    projparam::Equirectangular)
    lon, lat = grid2lonlat(grid_lon_deg, grid_lat_deg)
    points = vcat(equirectangular.(lon, lat)...)
    points[:,1], points[:,2]
end

@recipe function f(grid_lon_deg::StepRangeLen, grid_lat_deg::StepRangeLen,
    projparam::Gnomonic)
    lon, lat = grid2lonlat(grid_lon_deg, grid_lat_deg)
    projection(lon::Float64, lat::Float64) = gnomonic(lon, lat, projparam)
    points = vcat(projection.(lon, lat)...)
    points[:,1], points[:,2]
end

function get_shapefile(shp::String)
    return Shapefile.shapes(Shapefile.Table(shp))
end

function add_polygon!(shp::String, projparam=Equirectangular(); kwargs...)
    plot!(get_shapefile(shp), projparam; kwargs...)
end
