#TODO Mercator
#TODO Gnomonic
#TODO Equirectangular
#TODO Lambert cylindrical equal-area

# struct EquiRectangular
# end

struct Mercator
    central_meridian_deg::Float64
end

# """
# Equirectangular
# """
# function equirectangular(lat_deg::Float64, lon_deg::Float64)
#     [lon_deg lat_deg]
# end

function mercator(lat_deg::Float64, lon_deg::Float64, projparam::Mercator)
    [(lon_deg-projparam.central_meridian_deg) rad2deg(log(tan(π/4.0 + deg2rad(lat_deg) / 2.0)))]
end

# function mercator(lat_deg::Float64, lon_deg::Float64; projparam::Mercator=Mercator(0.0))
#     # [lon_deg lat_deg]
#     [lon_deg - projparam.central_meridian_deg rad2deg(log(tan(π/4.0 + deg2rad(lat_deg) / 2.0)))]
# end

# """
# Mercator
# """
# function projection(lat_deg::Float64, lon_deg::Float64; radius::Float64,
#     central_meridian::Float64)
#     [lon_deg lat_deg]
# end
#
# """
# Lambert cylindrical equal-area
# """
# function projection(lat_deg::Float64, lon_deg::Float64; central_meridian::Float64)
#     [lon_deg lat_deg]
# end
#
# """
# latlon2gnomonic(centre_point_lat_deg::Float64,
#     centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)
#
# Source: https://mathworld.wolfram.com/GnomonicProjection.html
# """
# function projection(lat_deg::Float64, lon_deg::Float64;
#     center_lat_deg::Float64, center_lon_deg::Float64)
#
#     limited_point = limitdistance(center_lat_deg, center_lon_deg, lat_deg,
#     lon_deg)
#
#     ϕ₀ = deg2rad(center_lat_deg)
#     λ₀ = deg2rad(center_lon_deg)
#     ϕ = deg2rad(limited_point[2])
#     λ = deg2rad(limited_point[1])
#
#     cosc = sin(ϕ₀)sin(ϕ) + cos(ϕ₀)cos(ϕ)cos(λ - λ₀)
#     x = cos(ϕ)sin(λ - λ₀) / cosc
#     y = (cos(ϕ₀)sin(ϕ) - sin(ϕ₀)cos(ϕ)cos(λ - λ₀)) / cosc
#     return [x y]
# end

"""
latlon2gnomonic(centre_point_lat_deg::Float64,
    centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)

Source: https://mathworld.wolfram.com/GnomonicProjection.html
"""
function latlon2gnomonic(centre_point_lat_deg::Float64,
    centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)

    limited_point = limitdistance(centre_point_lat_deg, centre_point_lon_deg,
    lat_deg, lon_deg)

    ϕ₀ = deg2rad(centre_point_lat_deg)
    λ₀ = deg2rad(centre_point_lon_deg)
    ϕ = deg2rad(limited_point[2])
    λ = deg2rad(limited_point[1])

    cosc = sin(ϕ₀)sin(ϕ) + cos(ϕ₀)cos(ϕ)cos(λ - λ₀)
    x = cos(ϕ)sin(λ - λ₀) / cosc
    y = (cos(ϕ₀)sin(ϕ) - sin(ϕ₀)cos(ϕ)cos(λ - λ₀)) / cosc
    return [x y]
end

function limitdistance(centre_point_lat_deg::Float64,
    centre_point_lon_deg::Float64, lat_deg::Float64, lon_deg::Float64)
    center_point = Navigation.Point_deg(centre_point_lat_deg,
    centre_point_lon_deg)
    point = Navigation.Point_deg(lat_deg, lon_deg)
    angular_distance = Navigation.distance(center_point, point, 1.0)
    max_angular_distance = π * 0.4
    if angular_distance > max_angular_distance
        fraction = max_angular_distance / angular_distance
        new_point = Navigation.intermediate_point(center_point, point, fraction)
        return [new_point.λ new_point.ϕ]
    else
        return [lon_deg lat_deg]
    end
end
