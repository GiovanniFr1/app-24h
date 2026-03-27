from django.urls import path

from .views import DriverLocationUpdateView, NearbyDriversView

urlpatterns = [
    path("me/", DriverLocationUpdateView.as_view(), name="locations-me"),
    path("nearby/", NearbyDriversView.as_view(), name="locations-nearby"),
]
