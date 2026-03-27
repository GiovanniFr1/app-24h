from decimal import Decimal

from rest_framework import serializers

from .models import Trip


class TripRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Trip
        fields = (
            "id",
            "pickup_address",
            "dropoff_address",
            "pickup_latitude",
            "pickup_longitude",
            "dropoff_latitude",
            "dropoff_longitude",
            "status",
            "requested_at",
        )
        read_only_fields = ("id", "status", "requested_at")


class TripCompleteSerializer(serializers.Serializer):
    distance_km = serializers.DecimalField(
        max_digits=8,
        decimal_places=2,
        min_value=Decimal("0"),
        required=False,
        allow_null=True,
    )
    duration_minutes = serializers.IntegerField(min_value=0, required=False, allow_null=True)


class TripSerializer(serializers.ModelSerializer):
    passenger_id = serializers.IntegerField(read_only=True)
    driver_id = serializers.IntegerField(read_only=True)

    class Meta:
        model = Trip
        fields = (
            "id",
            "status",
            "passenger_id",
            "driver_id",
            "pickup_address",
            "dropoff_address",
            "pickup_latitude",
            "pickup_longitude",
            "dropoff_latitude",
            "dropoff_longitude",
            "estimated_distance_km",
            "estimated_duration_minutes",
            "route_polyline",
            "routing_provider",
            "distance_km",
            "duration_minutes",
            "base_fare",
            "per_km_rate",
            "per_minute_rate",
            "final_fare",
            "requested_at",
            "accepted_at",
            "started_at",
            "completed_at",
            "canceled_at",
        )
        read_only_fields = fields
