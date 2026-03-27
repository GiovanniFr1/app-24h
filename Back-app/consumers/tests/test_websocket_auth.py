import pytest
from channels.db import database_sync_to_async
from channels.layers import get_channel_layer
from channels.testing import WebsocketCommunicator
from rest_framework_simplejwt.tokens import AccessToken

from apps.trips.models import Trip
from apps.users.models import User
from core.asgi import application
from consumers.events import driver_dispatch_group


@database_sync_to_async
def create_passenger(email: str) -> User:
    return User.objects.create_user(
        email=email,
        full_name="Passenger",
        password="StrongPass123",
        role=User.Role.PASSENGER,
    )


@database_sync_to_async
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


@database_sync_to_async
def token_for(user: User) -> str:
    return str(AccessToken.for_user(user))


@database_sync_to_async
def create_trip_for_passenger(passenger: User) -> Trip:
    return Trip.objects.create(passenger=passenger, pickup_address="A", dropoff_address="B")


@pytest.mark.asyncio
@pytest.mark.django_db(transaction=True)
async def test_passenger_ws_requires_valid_jwt():
    passenger = await create_passenger("ws-passenger-auth@example.com")
    trip = await create_trip_for_passenger(passenger)

    communicator = WebsocketCommunicator(application, f"/ws/passenger/trips/{trip.id}/")
    connected, _ = await communicator.connect()

    assert not connected
    await communicator.disconnect()


@pytest.mark.asyncio
@pytest.mark.django_db(transaction=True)
async def test_passenger_ws_allows_trip_owner_only():
    passenger = await create_passenger("ws-passenger-owner@example.com")
    outsider = await create_passenger("ws-passenger-outsider@example.com")
    trip = await create_trip_for_passenger(passenger)

    owner_token = await token_for(passenger)
    owner_communicator = WebsocketCommunicator(
        application,
        f"/ws/passenger/trips/{trip.id}/?token={owner_token}",
    )
    owner_connected, _ = await owner_communicator.connect()
    assert owner_connected
    await owner_communicator.disconnect()

    outsider_token = await token_for(outsider)
    outsider_communicator = WebsocketCommunicator(
        application,
        f"/ws/passenger/trips/{trip.id}/?token={outsider_token}",
    )
    outsider_connected, _ = await outsider_communicator.connect()
    assert not outsider_connected
    await outsider_communicator.disconnect()


@pytest.mark.asyncio
@pytest.mark.django_db(transaction=True)
async def test_driver_dispatch_ws_receives_trip_request_event():
    driver = await create_driver("ws-driver@example.com")
    driver_token = await token_for(driver)

    communicator = WebsocketCommunicator(application, f"/ws/driver/dispatch/?token={driver_token}")
    connected, _ = await communicator.connect()
    assert connected

    channel_layer = get_channel_layer()
    await channel_layer.group_send(
        driver_dispatch_group(driver.id),
        {
            "type": "trip.request",
            "data": {
                "trip_id": 99,
                "pickup_address": "Rua A",
                "dropoff_address": "Rua B",
            },
        },
    )

    message = await communicator.receive_json_from()
    assert message["event"] == "trip_request"
    assert message["payload"]["trip_id"] == 99

    await communicator.disconnect()
