struct Equirectangular
end

struct Mercator
    central_meridian_deg::Float64
end

struct Lambert
    central_meridian_deg::Float64
end

struct Gnomonic
    center_lon_deg::Float64
    center_lat_deg::Float64
end

"""
projection(lon_deg::Float64, lat_deg::Float64,
    projparam::Equirectangular=Equirectangular())
Equirectangular projection
"""
function projection(lon_deg::Float64, lat_deg::Float64,
    projparam::Equirectangular=Equirectangular())
    [lon_deg lat_deg]
end

"""
projection_inv(x::Float64, y::Float64,
    projparam::Equirectangular=Equirectangular())
Equirectangular projection (inverse)
"""
function projection_inv(x::Float64, y::Float64,
    projparam::Equirectangular=Equirectangular())
    [x y]
end

"""
projection(lon_deg::Float64, lat_deg::Float64, projparam::Mercator)
Mercator projection

Source: https://mathworld.wolfram.com/MercatorProjection.html
"""
function projection(lon_deg::Float64, lat_deg::Float64, projparam::Mercator)
    [(lon_deg-projparam.central_meridian_deg) rad2deg(log(tan(π/4.0 + deg2rad(lat_deg) / 2.0)))]
end

"""
projection_inv(x::Float64, y::Float64, projparam::Mercator)
Mercator projection (inverse)

Source: https://mathworld.wolfram.com/MercatorProjection.html
"""
function projection_inv(x::Float64, y::Float64, projparam::Mercator)
    [(x + projparam.central_meridian_deg) rad2deg(atan(sinh(deg2rad(y))))]
end

"""
projection(lon_deg::Float64, lat_deg::Float64, projparam::Lambert)
Lambert cylindrical equal-area

Source: https://mathworld.wolfram.com/CylindricalEqual-AreaProjection.html
"""
function projection(lon_deg::Float64, lat_deg::Float64, projparam::Lambert)
    [(lon_deg-projparam.central_meridian_deg) rad2deg(sin(deg2rad(lat_deg)))]
end

"""
projection_inv(x::Float64, y::Float64, projparam::Lambert)
Lambert cylindrical equal-area (inverse)

Source: https://mathworld.wolfram.com/CylindricalEqual-AreaProjection.html
"""
function projection_inv(x::Float64, y::Float64, projparam::Lambert)
    [(x + projparam.central_meridian_deg) rad2deg(asin(deg2rad(y)))]
end

"""
projection(lat_deg::Float64, lon_deg::Float64, projparam::Gnomonic)

Source: https://mathworld.wolfram.com/GnomonicProjection.html
"""
function projection(lon_deg::Float64, lat_deg::Float64, projparam::Gnomonic)

    limited_point = limitdistance(projparam.center_lon_deg,
    projparam.center_lat_deg, lon_deg, lat_deg)

    ϕ₀ = deg2rad(projparam.center_lat_deg)
    λ₀ = deg2rad(projparam.center_lon_deg)
    ϕ = deg2rad(limited_point[2])
    λ = deg2rad(limited_point[1])

    cosc = sin(ϕ₀)sin(ϕ) + cos(ϕ₀)cos(ϕ)cos(λ - λ₀)
    x = cos(ϕ)sin(λ - λ₀) / cosc
    y = (cos(ϕ₀)sin(ϕ) - sin(ϕ₀)cos(ϕ)cos(λ - λ₀)) / cosc
    return [rad2deg(x) rad2deg(y)]
end

"""
projection_inv(x::Float64, y::Float64, projparam::Gnomonic) inverse

Source: https://mathworld.wolfram.com/GnomonicProjection.html
"""
function projection_inv(x::Float64, y::Float64, projparam::Gnomonic)

    # limited_point = limitdistance(projparam.center_lon_deg,
    # projparam.center_lat_deg, lon_deg, lat_deg)

    ϕ₀ = deg2rad(projparam.center_lat_deg)
    λ₀ = deg2rad(projparam.center_lon_deg)

    xr = deg2rad(x)
    yr = deg2rad(y)

    ρ = √(xr^2 + yr^2)
    if ρ != 0.0
        c = atan(ρ)
        ϕ = asin(cos(c)sin(ϕ₀) + yr*sin(c)cos(ϕ₀)/ρ)
        λ = λ₀ + atan(xr*sin(c),ρ*cos(ϕ₀)cos(c)-yr*sin(ϕ₀)sin(c))
    else  # ρ == 0.0
        ϕ = ϕ₀
        λ = λ₀
    end
    return [rad2deg(λ) rad2deg(ϕ)]
end

function limitdistance(centre_point_lon_deg::Float64,
    centre_point_lat_deg::Float64, lon_deg::Float64, lat_deg::Float64)
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
