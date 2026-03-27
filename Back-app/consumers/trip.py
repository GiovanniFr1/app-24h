from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer

from apps.trips.models import Trip
from apps.users.models import User
from consumers.events import driver_dispatch_group, trip_room_group


class PassengerTripConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        user = self.scope.get("user")
        if not user or not user.is_authenticated:
            await self.close(code=4401)
            return

        self.trip_id = int(self.scope["url_route"]["kwargs"]["trip_id"])
        is_allowed = await self._user_can_subscribe_trip(user.id, self.trip_id)
        if not is_allowed:
            await self.close(code=4403)
            return

        self.group_name = trip_room_group(self.trip_id)
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def driver_location(self, event):
        await self.send_json({"event": "driver_location", "payload": event["data"]})

    @database_sync_to_async
    def _user_can_subscribe_trip(self, user_id: int, trip_id: int) -> bool:
        return Trip.objects.filter(id=trip_id, passenger_id=user_id).exists()


class DriverDispatchConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        user = self.scope.get("user")
        if not user or not user.is_authenticated:
            await self.close(code=4401)
            return

        is_driver = await self._user_is_driver(user.id)
        if not is_driver:
            await self.close(code=4403)
            return

        self.group_name = driver_dispatch_group(user.id)
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def trip_request(self, event):
        await self.send_json({"event": "trip_request", "payload": event["data"]})

    @database_sync_to_async
    def _user_is_driver(self, user_id: int) -> bool:
        return User.objects.filter(id=user_id, role=User.Role.DRIVER).exists()
