from django.urls import path

from .trip import DriverDispatchConsumer, PassengerTripConsumer

websocket_urlpatterns = [
    path("ws/passenger/trips/<int:trip_id>/", PassengerTripConsumer.as_asgi()),
    path("ws/driver/dispatch/", DriverDispatchConsumer.as_asgi()),
]
