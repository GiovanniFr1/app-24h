from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.trips.models import Trip
from apps.users.models import User
from consumers.events import send_driver_location_to_trip

from .serializers import DriverLocationUpdateSerializer, NearbyDriverQuerySerializer
from .services import find_nearby_drivers, update_driver_location


class DriverLocationUpdateView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        if request.user.role != User.Role.DRIVER:
            return Response({"detail": "Somente motorista pode atualizar localização"}, status=status.HTTP_403_FORBIDDEN)

        serializer = DriverLocationUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        location = update_driver_location(
            request.user,
            serializer.validated_data["latitude"],
            serializer.validated_data["longitude"],
        )
        active_trips = Trip.objects.filter(
            driver=request.user,
            status__in=[Trip.Status.ACCEPTED, Trip.Status.IN_PROGRESS],
        )
        for trip in active_trips:
            send_driver_location_to_trip(
                trip.id,
                {
                    "trip_id": trip.id,
                    "driver_id": request.user.id,
                    "latitude": location.point.y,
                    "longitude": location.point.x,
                },
            )

        return Response(
            {
                "driver_id": request.user.id,
                "latitude": location.point.y,
                "longitude": location.point.x,
                "updated_at": location.updated_at,
            },
            status=status.HTTP_200_OK,
        )


class NearbyDriversView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        serializer = NearbyDriverQuerySerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)

        drivers = find_nearby_drivers(
            serializer.validated_data["latitude"],
            serializer.validated_data["longitude"],
            serializer.validated_data["radius_meters"],
        )

        return Response(
            {
                "count": len(drivers),
                "drivers": [
                    {
                        "id": driver.id,
                        "name": driver.full_name,
                    }
                    for driver in drivers
                ],
            },
            status=status.HTTP_200_OK,
        )
