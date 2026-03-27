import re
from datetime import date

from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models

from .managers import UserManager


def validate_digits(value: str, field_name: str, expected_length: int):
    if value in (None, ""):
        return
    digits = re.sub(r"\D", "", value)
    if len(digits) != expected_length:
        raise ValidationError(f"{field_name} deve ter {expected_length} dígitos")


class User(AbstractUser):
    class Role(models.TextChoices):
        PASSENGER = "PASSENGER", "Passenger"
        DRIVER = "DRIVER", "Driver"

    class DriverVerificationStatus(models.TextChoices):
        NOT_REQUIRED = "NOT_REQUIRED", "Not required"
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"

    username = None
    first_name = None
    last_name = None

    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255)
    phone = models.CharField(max_length=20, blank=True)
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.PASSENGER)
    cpf = models.CharField(max_length=14, blank=True)
    cnh = models.CharField(max_length=11, blank=True)
    document_cpf_url = models.URLField(blank=True)
    document_cnh_url = models.URLField(blank=True)
    document_selfie_url = models.URLField(blank=True)
    vehicle_plate = models.CharField(max_length=8, blank=True)
    vehicle_model = models.CharField(max_length=120, blank=True)
    vehicle_year = models.PositiveIntegerField(blank=True, null=True)
    driver_verification_status = models.CharField(
        max_length=12,
        choices=DriverVerificationStatus.choices,
        default=DriverVerificationStatus.NOT_REQUIRED,
    )
    driver_verification_notes = models.TextField(blank=True)
    profile_photo = models.ImageField(upload_to="profiles/", blank=True, null=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    objects = UserManager()

    def is_driver_approved(self) -> bool:
        if self.role != self.Role.DRIVER:
            return True
        return self.driver_verification_status == self.DriverVerificationStatus.APPROVED

    def clean(self):
        super().clean()
        validate_digits(self.cpf, "CPF", 11)
        if self.role == self.Role.DRIVER:
            validate_digits(self.cnh, "CNH", 11)
            if not self.cpf:
                raise ValidationError("Motorista precisa informar CPF")
            if not self.cnh:
                raise ValidationError("Motorista precisa informar CNH")
            if not self.document_cpf_url:
                raise ValidationError("Motorista precisa enviar documento de CPF")
            if not self.document_cnh_url:
                raise ValidationError("Motorista precisa enviar documento da CNH")
            if not self.document_selfie_url:
                raise ValidationError("Motorista precisa enviar selfie de verificação")
            if not self.vehicle_plate:
                raise ValidationError("Motorista precisa informar placa do veículo")
            if not self.vehicle_model:
                raise ValidationError("Motorista precisa informar modelo do veículo")
            if not self.vehicle_year:
                raise ValidationError("Motorista precisa informar ano do veículo")
            if self.vehicle_year and not (1980 <= self.vehicle_year <= date.today().year + 1):
                raise ValidationError("Ano do veículo inválido")
            if self.driver_verification_status == self.DriverVerificationStatus.NOT_REQUIRED:
                self.driver_verification_status = self.DriverVerificationStatus.PENDING
        elif self.driver_verification_status != self.DriverVerificationStatus.NOT_REQUIRED:
            raise ValidationError("Status de verificação de motorista é inválido para passageiro")

    def __str__(self) -> str:
        return self.email
