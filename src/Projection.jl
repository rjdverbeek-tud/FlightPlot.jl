struct Equirectangular
end

struct Mercator
    central_meridian_deg::Float64
end

struct Lambert
    central_meridian_deg::Float64
end

struct Gnomonic
    center_lat_deg::Float64
    center_lon_deg::Float64
end


"""
Equirectangular projection
"""
function equirectangular(lat_deg::Float64, lon_deg::Float64)
    [lon_deg lat_deg]
end


"""
Mercator projection
"""
function mercator(lat_deg::Float64, lon_deg::Float64, projparam::Mercator)
    [(lon_deg-projparam.central_meridian_deg) rad2deg(log(tan(π/4.0 + deg2rad(lat_deg) / 2.0)))]
end

"""
Lambert cylindrical equal-area
"""
function lambert(lat_deg::Float64, lon_deg::Float64, projparam::Lambert)
    [(lon_deg-projparam.central_meridian_deg) sin(deg2rad(lat_deg))]
end

"""
gnomonic(lat_deg::Float64, lon_deg::Float64, projparam::Gnomonic)

Source: https://mathworld.wolfram.com/GnomonicProjection.html
"""
function gnomonic(lat_deg::Float64, lon_deg::Float64, projparam::Gnomonic)

    limited_point = limitdistance(projparam.center_lat_deg,
    projparam.center_lon_deg, lat_deg, lon_deg)

    ϕ₀ = deg2rad(projparam.center_lat_deg)
    λ₀ = deg2rad(projparam.center_lon_deg)
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
