from decimal import Decimal

import pytest
from django.core.exceptions import ValidationError

from apps.trips.models import Trip
from apps.users.models import User


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
def test_trip_fsm_happy_path():
    passenger = create_passenger("passenger-fsm@example.com")
    driver = create_driver("driver-fsm@example.com")

    trip = Trip.objects.create(passenger=passenger, pickup_address="A", dropoff_address="B")
    assert trip.status == Trip.Status.SEARCHING

    trip.accept(driver)
    trip.save()
    assert trip.status == Trip.Status.ACCEPTED

    trip.start(driver)
    trip.save()
    assert trip.status == Trip.Status.IN_PROGRESS

    trip.complete(driver, Decimal("10.00"), 20)
    trip.save()
    assert trip.status == Trip.Status.COMPLETED
    assert trip.final_fare == Decimal("39.00")


@pytest.mark.django_db
def test_trip_rejects_second_accept():
    passenger = create_passenger("passenger-accept@example.com")
    driver_one = create_driver("driver-one@example.com")
    driver_two = create_driver("driver-two@example.com")

    trip = Trip.objects.create(passenger=passenger, pickup_address="A", dropoff_address="B")
    trip.accept(driver_one)
    trip.save()

    with pytest.raises(ValidationError):
        trip.accept(driver_two)


@pytest.mark.django_db
def test_trip_cancel_permission():
    passenger = create_passenger("passenger-cancel@example.com")
    driver = create_driver("driver-cancel@example.com")
    outsider = create_passenger("outsider@example.com")

    trip = Trip.objects.create(passenger=passenger, pickup_address="A", dropoff_address="B")
    trip.accept(driver)
    trip.save()

    with pytest.raises(ValidationError):
        trip.cancel(outsider)

    trip.cancel(passenger)
    trip.save()
    assert trip.status == Trip.Status.CANCELLED
