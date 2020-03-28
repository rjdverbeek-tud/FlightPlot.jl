using Shapefile, Plots
gr()

function initialize_plot()
    plot(xaxis=((-80,80), font(6)), yaxis=((-40,40), font(6)), legend = false,
    grid = true, showaxis = true, ticks = true, xticks = -180.0:10.0:180.0,
    yticks = -90.0:5.0:90.0, framestyle=:box)
end

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
    # x, y = latlon2latlon.(lat, lon)
    lon, lat
end

function get_shapefile(shp::String)
    return Shapefile.shapes(Shapefile.Table(shp))
end

"""
latlon2gnomonic(centre_point_lat_deg::Float64,
    centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)

Source: https://mathworld.wolfram.com/GnomonicProjection.html
"""
function latlon2gnomonic(centre_point_lat_deg::Float64,
    centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)
    ϕ₀ = deg2rad(centre_point_lat_deg)
    λ₀ = deg2rad(centre_point_lon_deg)
    ϕ = deg2rad(lat_deg)
    λ = deg2rad(lon_deg)
    cosc = sin(ϕ₀)sin(ϕ) + cos(ϕ₀)cos(ϕ)cos(λ - λ₀)
    x = cos(ϕ)sin(λ - λ₀) / cosc
    y = (cos(ϕ₀)sin(ϕ) - sin(ϕ₀)cos(ϕ)cos(λ - λ₀)) / cosc
    return x, y
end

function latlon2latlon(lat_deg::Float64, lon_deg::Float64)
    return lon_deg, lat_deg / 2.0
end
