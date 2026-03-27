import json
import math
from dataclasses import dataclass
from decimal import Decimal, ROUND_HALF_UP
from urllib.error import URLError
from urllib.parse import urlencode
from urllib.request import urlopen

from django.conf import settings


@dataclass(frozen=True)
class RouteEstimate:
    distance_km: Decimal
    duration_minutes: int
    polyline: str
    provider: str


class MapboxRoutingProvider:
    name = "mapbox"

    def __init__(self, access_token: str, profile: str = "driving") -> None:
        self.access_token = access_token
        self.profile = profile

    def estimate(
        self,
        *,
        pickup_latitude: float,
        pickup_longitude: float,
        dropoff_latitude: float,
        dropoff_longitude: float,
    ) -> RouteEstimate:
        coords = f"{pickup_longitude},{pickup_latitude};{dropoff_longitude},{dropoff_latitude}"
        query = urlencode(
            {
                "access_token": self.access_token,
                "geometries": "polyline",
                "overview": "full",
                "alternatives": "false",
            }
        )
        url = f"https://api.mapbox.com/directions/v5/mapbox/{self.profile}/{coords}?{query}"

        try:
            with urlopen(url, timeout=5) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except (TimeoutError, URLError, OSError, json.JSONDecodeError):
            raise RuntimeError("Routing provider unavailable")

        routes = payload.get("routes") or []
        if not routes:
            raise RuntimeError("No routes returned by provider")

        route = routes[0]
        distance_meters = route.get("distance")
        duration_seconds = route.get("duration")
        geometry = route.get("geometry")

        if distance_meters is None or duration_seconds is None or not geometry:
            raise RuntimeError("Incomplete routing response")

        distance_km = (Decimal(str(distance_meters)) / Decimal("1000")).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        duration_minutes = max(1, math.ceil(float(duration_seconds) / 60))

        return RouteEstimate(
            distance_km=distance_km,
            duration_minutes=duration_minutes,
            polyline=geometry,
            provider=self.name,
        )


def _get_provider():
    provider_name = getattr(settings, "ROUTING_PROVIDER", "none").lower()
    if provider_name == "mapbox":
        # Defensive trim: dotenv parsers may keep stray whitespace and invalidate auth.
        access_token = getattr(settings, "MAPBOX_ACCESS_TOKEN", "").strip()
        profile = getattr(settings, "MAPBOX_PROFILE", "driving").strip()
        if not access_token:
            return None
        return MapboxRoutingProvider(access_token=access_token, profile=profile)
    return None


def estimate_route(
    *,
    pickup_latitude: float,
    pickup_longitude: float,
    dropoff_latitude: float,
    dropoff_longitude: float,
):
    provider = _get_provider()
    if provider is None:
        return None

    try:
        return provider.estimate(
            pickup_latitude=pickup_latitude,
            pickup_longitude=pickup_longitude,
            dropoff_latitude=dropoff_latitude,
            dropoff_longitude=dropoff_longitude,
        )
    except RuntimeError:
        return None
