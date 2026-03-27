from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer


def driver_dispatch_group(driver_id: int) -> str:
    return f"driver_dispatch_{driver_id}"


def trip_room_group(trip_id: int) -> str:
    return f"trip_room_{trip_id}"


def send_trip_request_to_driver(driver_id: int, payload: dict) -> None:
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        driver_dispatch_group(driver_id),
        {
            "type": "trip.request",
            "data": payload,
        },
    )


def send_driver_location_to_trip(trip_id: int, payload: dict) -> None:
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        trip_room_group(trip_id),
        {
            "type": "driver.location",
            "data": payload,
        },
    )
