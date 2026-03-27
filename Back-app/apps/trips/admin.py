from django.contrib import admin

from .models import Trip


@admin.register(Trip)
class TripAdmin(admin.ModelAdmin):
    list_display = ("id", "status", "passenger", "driver", "final_fare", "requested_at")
    list_filter = ("status",)
    search_fields = ("passenger__email", "driver__email", "pickup_address", "dropoff_address")
