from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.core.cache import cache

from .models import DriverLocation

LOCATION_CACHE_TTL_SECONDS = 10


def location_cache_key(driver_id: int) -> str:
    return f"driver:last_location:{driver_id}"


def update_driver_location(driver, latitude: float, longitude: float) -> DriverLocation:
    point = Point(float(longitude), float(latitude), srid=4326)
    location, _ = DriverLocation.objects.update_or_create(
        driver=driver,
        defaults={"point": point},
    )
    cache.set(
        location_cache_key(driver.id),
        {"latitude": float(latitude), "longitude": float(longitude)},
        timeout=LOCATION_CACHE_TTL_SECONDS,
    )
    return location


def find_nearby_drivers(latitude: float, longitude: float, radius_meters: int = 3000) -> list:
    rider_point = Point(float(longitude), float(latitude), srid=4326)
    queryset = DriverLocation.objects.filter(point__distance_lte=(rider_point, D(m=radius_meters))).select_related("driver")
    return [item.driver for item in queryset]
