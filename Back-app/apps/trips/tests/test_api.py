from decimal import Decimal

import pytest
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import AccessToken

from apps.trips.models import Trip
from apps.users.models import User


@pytest.fixture
def client():
    return APIClient()


def auth_client_for(user: User) -> APIClient:
    client = APIClient()
    token = str(AccessToken.for_user(user))
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
    return client


def create_passenger(email: str) -> User:
    return User.objects.create_user(email=email, full_name="Passenger", password="StrongPass123", role=User.Role.PASSENGER)


def create_driver(email: str) -> User:
    return User.objects.create_user(
        email=email,
        full_name="Driver",
        password="StrongPass123",
        role=User.Role.DRIVER,
        cpf="12345678901",
        cnh="12345678901",
        document_cpf_url="https://example.com/cpf.jpg",
        document_cnh_url="https://example.com/cnh.jpg",
        document_selfie_url="https://example.com/selfie.jpg",
        vehicle_plate="ABC1D23",
        vehicle_model="Onix",
        vehicle_year=2024,
        driver_verification_status=User.DriverVerificationStatus.APPROVED,
    )


@pytest.mark.django_db
def test_passenger_can_request_trip():
    passenger = create_passenger("p-request@example.com")
    passenger_client = auth_client_for(passenger)

    response = passenger_client.post(
        reverse("trips-request"),
        {"pickup_address": "Rua A", "dropoff_address": "Rua B"},
        format="json",
    )

    assert response.status_code == 201
    assert response.data["status"] == Trip.Status.SEARCHING


@pytest.mark.django_db
def test_passenger_request_trip_persists_route_estimate(monkeypatch):
    passenger = create_passenger("p-route@example.com")
    passenger_client = auth_client_for(passenger)

    class FakeRoute:
        distance_km = Decimal("8.40")
        duration_minutes = 19
        polyline = "encoded_polyline"
        provider = "mapbox"

    monkeypatch.setattr("apps.trips.views.estimate_route_for_trip", lambda trip: FakeRoute())

    response = passenger_client.post(
        reverse("trips-request"),
        {
            "pickup_address": "Rua A",
            "dropoff_address": "Rua B",
            "pickup_latitude": -9.97472,
            "pickup_longitude": -67.82490,
            "dropoff_latitude": -9.97000,
            "dropoff_longitude": -67.82000,
        },
        format="json",
    )

    assert response.status_code == 201
    assert Decimal(response.data["estimated_distance_km"]) == Decimal("8.40")
    assert response.data["estimated_duration_minutes"] == 19
    assert response.data["route_polyline"] == "encoded_polyline"
    assert response.data["routing_provider"] == "mapbox"


@pytest.mark.django_db
def test_passenger_request_trip_without_provider_keeps_route_fields_empty(monkeypatch):
    passenger = create_passenger("p-no-route@example.com")
    passenger_client = auth_client_for(passenger)

    monkeypatch.setattr("apps.trips.views.estimate_route_for_trip", lambda trip: None)

    response = passenger_client.post(
        reverse("trips-request"),
        {
            "pickup_address": "Rua A",
            "dropoff_address": "Rua B",
            "pickup_latitude": -9.97472,
            "pickup_longitude": -67.82490,
            "dropoff_latitude": -9.97000,
            "dropoff_longitude": -67.82000,
        },
        format="json",
    )

    assert response.status_code == 201
    assert response.data["estimated_distance_km"] is None
    assert response.data["estimated_duration_minutes"] is None
    assert response.data["route_polyline"] == ""
    assert response.data["routing_provider"] == ""


@pytest.mark.django_db
def test_driver_flow_accept_start_complete():
    passenger = create_passenger("p-flow@example.com")
    driver = create_driver("d-flow@example.com")

    passenger_client = auth_client_for(passenger)
    driver_client = auth_client_for(driver)

    request_response = passenger_client.post(
        reverse("trips-request"),
        {"pickup_address": "Rua A", "dropoff_address": "Rua B"},
        format="json",
    )
    trip_id = request_response.data["id"]

    accept_response = driver_client.post(reverse("trips-accept", kwargs={"trip_id": trip_id}), format="json")
    assert accept_response.status_code == 200
    assert accept_response.data["status"] == Trip.Status.ACCEPTED

    start_response = driver_client.post(reverse("trips-start", kwargs={"trip_id": trip_id}), format="json")
    assert start_response.status_code == 200
    assert start_response.data["status"] == Trip.Status.IN_PROGRESS

    complete_response = driver_client.post(
        reverse("trips-complete", kwargs={"trip_id": trip_id}),
        {"distance_km": "12.50", "duration_minutes": 18},
        format="json",
    )
    assert complete_response.status_code == 200
    assert complete_response.data["status"] == Trip.Status.COMPLETED
    assert Decimal(complete_response.data["final_fare"]) == Decimal("44.55")


@pytest.mark.django_db
def test_driver_complete_without_payload_uses_estimated_route(monkeypatch):
    passenger = create_passenger("p-fallback-complete@example.com")
    driver = create_driver("d-fallback-complete@example.com")

    class FakeRoute:
        distance_km = Decimal("8.40")
        duration_minutes = 19
        polyline = "encoded_polyline"
        provider = "mapbox"

    monkeypatch.setattr("apps.trips.views.estimate_route_for_trip", lambda trip: FakeRoute())

    passenger_client = auth_client_for(passenger)
    driver_client = auth_client_for(driver)

    request_response = passenger_client.post(
        reverse("trips-request"),
        {
            "pickup_address": "Rua A",
            "dropoff_address": "Rua B",
            "pickup_latitude": -9.97472,
            "pickup_longitude": -67.82490,
            "dropoff_latitude": -9.97000,
            "dropoff_longitude": -67.82000,
        },
        format="json",
    )
    trip_id = request_response.data["id"]

    driver_client.post(reverse("trips-accept", kwargs={"trip_id": trip_id}), format="json")
    driver_client.post(reverse("trips-start", kwargs={"trip_id": trip_id}), format="json")
    complete_response = driver_client.post(reverse("trips-complete", kwargs={"trip_id": trip_id}), {}, format="json")

    assert complete_response.status_code == 200
    assert complete_response.data["status"] == Trip.Status.COMPLETED
    assert Decimal(complete_response.data["distance_km"]) == Decimal("8.40")
    assert complete_response.data["duration_minutes"] == 19
    assert Decimal(complete_response.data["final_fare"]) == Decimal("34.65")


@pytest.mark.django_db
def test_driver_complete_without_payload_and_without_estimate_returns_400():
    passenger = create_passenger("p-no-estimate-complete@example.com")
    driver = create_driver("d-no-estimate-complete@example.com")
    passenger_client = auth_client_for(passenger)
    driver_client = auth_client_for(driver)

    request_response = passenger_client.post(
        reverse("trips-request"),
        {"pickup_address": "Rua A", "dropoff_address": "Rua B"},
        format="json",
    )
    trip_id = request_response.data["id"]

    driver_client.post(reverse("trips-accept", kwargs={"trip_id": trip_id}), format="json")
    driver_client.post(reverse("trips-start", kwargs={"trip_id": trip_id}), format="json")
    complete_response = driver_client.post(reverse("trips-complete", kwargs={"trip_id": trip_id}), {}, format="json")

    assert complete_response.status_code == 400
    assert "obrigatórios" in complete_response.data["detail"]


@pytest.mark.django_db
def test_race_condition_two_drivers_accept_same_trip():
    passenger = create_passenger("p-race@example.com")
    driver_one = create_driver("d1-race@example.com")
    driver_two = create_driver("d2-race@example.com")

    passenger_client = auth_client_for(passenger)
    driver_one_client = auth_client_for(driver_one)
    driver_two_client = auth_client_for(driver_two)

    request_response = passenger_client.post(
        reverse("trips-request"),
        {"pickup_address": "Rua A", "dropoff_address": "Rua B"},
        format="json",
    )
    trip_id = request_response.data["id"]

    first = driver_one_client.post(reverse("trips-accept", kwargs={"trip_id": trip_id}), format="json")
    second = driver_two_client.post(reverse("trips-accept", kwargs={"trip_id": trip_id}), format="json")

    assert first.status_code == 200
    assert second.status_code == 409


@pytest.mark.django_db
def test_passenger_cannot_accept_trip():
    passenger = create_passenger("p-accept@example.com")
    trip = Trip.objects.create(passenger=passenger, pickup_address="Rua A", dropoff_address="Rua B")

    passenger_client = auth_client_for(passenger)
    response = passenger_client.post(reverse("trips-accept", kwargs={"trip_id": trip.id}), format="json")

    assert response.status_code == 403


@pytest.mark.django_db
def test_only_passenger_or_assigned_driver_can_cancel_trip():
    passenger = create_passenger("p-cancel-api@example.com")
    assigned_driver = create_driver("d-cancel-api@example.com")
    outsider = create_passenger("outsider-cancel-api@example.com")

    trip = Trip.objects.create(passenger=passenger, pickup_address="Rua A", dropoff_address="Rua B")
    trip.accept(assigned_driver)
    trip.save()

    outsider_client = auth_client_for(outsider)
    cancel_response = outsider_client.post(reverse("trips-cancel", kwargs={"trip_id": trip.id}), format="json")
    assert cancel_response.status_code == 403

    passenger_client = auth_client_for(passenger)
    passenger_cancel = passenger_client.post(reverse("trips-cancel", kwargs={"trip_id": trip.id}), format="json")
    assert passenger_cancel.status_code == 200
    assert passenger_cancel.data["status"] == Trip.Status.CANCELLED


@pytest.mark.django_db
def test_trip_history_is_user_scoped():
    passenger = create_passenger("p-history@example.com")
    driver = create_driver("d-history@example.com")
    other_passenger = create_passenger("other-history@example.com")

    own_trip = Trip.objects.create(passenger=passenger, driver=driver, pickup_address="Rua A", dropoff_address="Rua B")
    Trip.objects.create(passenger=other_passenger, pickup_address="Rua X", dropoff_address="Rua Y")

    passenger_client = auth_client_for(passenger)
    response = passenger_client.get(reverse("trips-history"))

    assert response.status_code == 200
    returned_ids = {item["id"] for item in response.data}
    assert own_trip.id in returned_ids
    assert len(returned_ids) == 1
