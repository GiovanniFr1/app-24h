from decimal import Decimal

from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone


class Trip(models.Model):
    class Status(models.TextChoices):
        SEARCHING = "SEARCHING", "Searching"
        ACCEPTED = "ACCEPTED", "Accepted"
        IN_PROGRESS = "IN_PROGRESS", "In Progress"
        COMPLETED = "COMPLETED", "Completed"
        CANCELLED = "CANCELLED", "Cancelled"

    passenger = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="passenger_trips",
    )
    driver = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="driver_trips",
    )
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.SEARCHING)

    pickup_address = models.CharField(max_length=255)
    dropoff_address = models.CharField(max_length=255)
    pickup_latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    pickup_longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    dropoff_latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    dropoff_longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    estimated_distance_km = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    estimated_duration_minutes = models.PositiveIntegerField(null=True, blank=True)
    route_polyline = models.TextField(blank=True)
    routing_provider = models.CharField(max_length=40, blank=True)

    distance_km = models.DecimalField(max_digits=8, decimal_places=2, default=Decimal("0.00"))
    duration_minutes = models.PositiveIntegerField(default=0)

    base_fare = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal("7.00"))
    per_km_rate = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal("2.50"))
    per_minute_rate = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal("0.35"))
    final_fare = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    requested_at = models.DateTimeField(auto_now_add=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    canceled_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ("-requested_at",)

    def __str__(self) -> str:
        return f"Trip#{self.id} ({self.status})"

    @property
    def is_terminal(self) -> bool:
        return self.status in {self.Status.COMPLETED, self.Status.CANCELLED}

    def accept(self, driver):
        if self.status != self.Status.SEARCHING:
            raise ValidationError("A corrida não está disponível para aceite")
        if self.driver_id is not None:
            raise ValidationError("A corrida já possui motorista")
        if driver.role != "DRIVER":
            raise ValidationError("Somente motoristas podem aceitar corrida")

        self.driver = driver
        self.status = self.Status.ACCEPTED
        self.accepted_at = timezone.now()

    def start(self, driver):
        if self.status != self.Status.ACCEPTED:
            raise ValidationError("A corrida precisa estar aceita para iniciar")
        if self.driver_id != driver.id:
            raise ValidationError("Somente o motorista aceito pode iniciar a corrida")

        self.status = self.Status.IN_PROGRESS
        self.started_at = timezone.now()

    def complete(self, driver, distance_km: Decimal, duration_minutes: int):
        if self.status != self.Status.IN_PROGRESS:
            raise ValidationError("A corrida precisa estar em andamento para finalizar")
        if self.driver_id != driver.id:
            raise ValidationError("Somente o motorista da corrida pode finalizar")
        if distance_km < Decimal("0"):
            raise ValidationError("Distância não pode ser negativa")
        if duration_minutes < 0:
            raise ValidationError("Duração não pode ser negativa")

        self.distance_km = distance_km
        self.duration_minutes = duration_minutes
        self.final_fare = self.calculate_fare(distance_km, duration_minutes)
        self.status = self.Status.COMPLETED
        self.completed_at = timezone.now()

    def cancel(self, actor):
        if self.is_terminal:
            raise ValidationError("Não é possível cancelar corrida finalizada")

        actor_is_passenger = self.passenger_id == actor.id
        actor_is_driver = self.driver_id is not None and self.driver_id == actor.id
        if not actor_is_passenger and not actor_is_driver:
            raise ValidationError("Usuário sem permissão para cancelar esta corrida")

        self.status = self.Status.CANCELLED
        self.canceled_at = timezone.now()

    def calculate_fare(self, distance_km: Decimal, duration_minutes: int) -> Decimal:
        total = self.base_fare + (distance_km * self.per_km_rate) + (Decimal(duration_minutes) * self.per_minute_rate)
        return total.quantize(Decimal("0.01"))
