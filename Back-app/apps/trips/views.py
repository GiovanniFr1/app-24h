from django.core.exceptions import ValidationError
from django.db import transaction
from django.db.models import Q
from django.shortcuts import get_object_or_404
from django.apps import apps as django_apps
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.users.models import User
from consumers.events import send_trip_request_to_driver

from .models import Trip
from .routing import estimate_route
from .serializers import TripCompleteSerializer, TripRequestSerializer, TripSerializer


def user_is_passenger(user: User) -> bool:
    return user.role == User.Role.PASSENGER


def user_is_driver(user: User) -> bool:
    return user.role == User.Role.DRIVER


def estimate_route_for_trip(trip: Trip):
    if (
        trip.pickup_latitude is None
        or trip.pickup_longitude is None
        or trip.dropoff_latitude is None
        or trip.dropoff_longitude is None
    ):
        return None
    return estimate_route(
        pickup_latitude=float(trip.pickup_latitude),
        pickup_longitude=float(trip.pickup_longitude),
        dropoff_latitude=float(trip.dropoff_latitude),
        dropoff_longitude=float(trip.dropoff_longitude),
    )


class TripRequestView(generics.CreateAPIView):
    serializer_class = TripRequestSerializer

    def create(self, request, *args, **kwargs):
        if not user_is_passenger(request.user):
            return Response({"detail": "Somente passageiro pode solicitar corrida"}, status=status.HTTP_403_FORBIDDEN)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        trip = serializer.save(passenger=request.user)
        route = estimate_route_for_trip(trip)
        if route is not None:
            trip.estimated_distance_km = route.distance_km
            trip.estimated_duration_minutes = route.duration_minutes
            trip.route_polyline = route.polyline
            trip.routing_provider = route.provider
            trip.save(
                update_fields=[
                    "estimated_distance_km",
                    "estimated_duration_minutes",
                    "route_polyline",
                    "routing_provider",
                ]
            )

        if (
            django_apps.is_installed("apps.locations")
            and trip.pickup_latitude is not None
            and trip.pickup_longitude is not None
        ):
            from apps.locations.services import find_nearby_drivers

            nearby_drivers = find_nearby_drivers(float(trip.pickup_latitude), float(trip.pickup_longitude))
            for driver in nearby_drivers:
                send_trip_request_to_driver(
                    driver.id,
                    {
                        "trip_id": trip.id,
                        "pickup_address": trip.pickup_address,
                        "dropoff_address": trip.dropoff_address,
                    },
                )
        return Response(TripSerializer(trip).data, status=status.HTTP_201_CREATED)


class TripHistoryView(generics.ListAPIView):
    serializer_class = TripSerializer

    def get_queryset(self):
        user = self.request.user
        return Trip.objects.filter(Q(passenger=user) | Q(driver=user))


class TripAcceptView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, trip_id: int):
        if not user_is_driver(request.user):
            return Response({"detail": "Somente motorista pode aceitar corrida"}, status=status.HTTP_403_FORBIDDEN)

        with transaction.atomic():
            trip = get_object_or_404(Trip.objects.select_for_update(), id=trip_id)
            try:
                trip.accept(request.user)
            except ValidationError as exc:
                return Response({"detail": exc.message}, status=status.HTTP_409_CONFLICT)
            trip.save(update_fields=["driver", "status", "accepted_at"])

        return Response(TripSerializer(trip).data, status=status.HTTP_200_OK)


class TripStartView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, trip_id: int):
        trip = get_object_or_404(Trip, id=trip_id)
        if not user_is_driver(request.user):
            return Response({"detail": "Somente motorista pode iniciar corrida"}, status=status.HTTP_403_FORBIDDEN)

        try:
            trip.start(request.user)
        except ValidationError as exc:
            return Response({"detail": exc.message}, status=status.HTTP_409_CONFLICT)
        trip.save(update_fields=["status", "started_at"])
        return Response(TripSerializer(trip).data, status=status.HTTP_200_OK)


class TripCompleteView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, trip_id: int):
        trip = get_object_or_404(Trip, id=trip_id)
        if not user_is_driver(request.user):
            return Response({"detail": "Somente motorista pode finalizar corrida"}, status=status.HTTP_403_FORBIDDEN)

        serializer = TripCompleteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        distance_km = serializer.validated_data.get("distance_km")
        duration_minutes = serializer.validated_data.get("duration_minutes")

        # Fallback to route estimation when driver app does not send final metrics.
        if distance_km is None:
            distance_km = trip.estimated_distance_km
        if duration_minutes is None:
            duration_minutes = trip.estimated_duration_minutes
        if distance_km is None or duration_minutes is None:
            return Response(
                {
                    "detail": (
                        "distance_km e duration_minutes são obrigatórios quando a corrida não possui "
                        "estimativa de rota"
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            trip.complete(
                request.user,
                distance_km,
                duration_minutes,
            )
        except ValidationError as exc:
            return Response({"detail": exc.message}, status=status.HTTP_409_CONFLICT)

        trip.save(update_fields=["status", "distance_km", "duration_minutes", "final_fare", "completed_at"])
        return Response(TripSerializer(trip).data, status=status.HTTP_200_OK)


class TripCancelView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, trip_id: int):
        trip = get_object_or_404(Trip, id=trip_id)
        try:
            trip.cancel(request.user)
        except ValidationError as exc:
            message = str(exc.message)
            status_code = status.HTTP_403_FORBIDDEN if "permissão" in message else status.HTTP_409_CONFLICT
            return Response({"detail": message}, status=status_code)

        trip.save(update_fields=["status", "canceled_at"])
        return Response(TripSerializer(trip).data, status=status.HTTP_200_OK)
