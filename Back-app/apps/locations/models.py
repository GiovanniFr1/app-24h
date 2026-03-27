from django.conf import settings
from django.contrib.gis.db import models


class DriverLocation(models.Model):
    driver = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="location",
    )
    point = models.PointField(geography=True, srid=4326)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-updated_at",)

    def __str__(self) -> str:
        return f"DriverLocation(driver={self.driver_id})"
