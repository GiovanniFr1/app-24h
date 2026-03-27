from django.test import override_settings

from apps.trips.routing import MapboxRoutingProvider, _get_provider


@override_settings(ROUTING_PROVIDER="mapbox", MAPBOX_ACCESS_TOKEN=" token-with-space ", MAPBOX_PROFILE=" driving ")
def test_get_provider_trims_mapbox_settings():
    provider = _get_provider()

    assert isinstance(provider, MapboxRoutingProvider)
    assert provider.access_token == "token-with-space"
    assert provider.profile == "driving"


@override_settings(ROUTING_PROVIDER="none", MAPBOX_ACCESS_TOKEN="token")
def test_get_provider_returns_none_when_disabled():
    assert _get_provider() is None
