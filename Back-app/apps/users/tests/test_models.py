import pytest
from django.core.exceptions import ValidationError

from apps.users.models import User


@pytest.mark.django_db
def test_validate_digits_accepts_empty_values():
    user = User(email="p1@example.com", full_name="Passenger")
    user.set_password("myStrongPass123")
    user.full_clean()


@pytest.mark.django_db
@pytest.mark.parametrize("cpf", ["123", "111.222.333-4"])
def test_user_rejects_invalid_cpf(cpf):
    user = User(email="p2@example.com", full_name="Passenger", cpf=cpf)

    with pytest.raises(ValidationError):
        user.full_clean()


@pytest.mark.django_db
def test_driver_requires_cpf_and_cnh():
    user = User(email="driver@example.com", full_name="Driver", role=User.Role.DRIVER)

    with pytest.raises(ValidationError):
        user.full_clean()


@pytest.mark.django_db
def test_driver_rejects_invalid_cnh():
    user = User(
        email="driver2@example.com",
        full_name="Driver Two",
        role=User.Role.DRIVER,
        cpf="12345678901",
        cnh="123",
    )

    with pytest.raises(ValidationError):
        user.full_clean()


@pytest.mark.django_db
def test_driver_requires_documents_and_vehicle_data():
    user = User(
        email="driver3@example.com",
        full_name="Driver Three",
        role=User.Role.DRIVER,
        cpf="12345678901",
        cnh="12345678901",
    )

    with pytest.raises(ValidationError):
        user.full_clean()


@pytest.mark.django_db
def test_driver_defaults_to_pending_verification():
    user = User(
        email="driver4@example.com",
        full_name="Driver Four",
        role=User.Role.DRIVER,
        cpf="12345678901",
        cnh="12345678901",
        document_cpf_url="https://example.com/cpf.jpg",
        document_cnh_url="https://example.com/cnh.jpg",
        document_selfie_url="https://example.com/selfie.jpg",
        vehicle_plate="ABC1D23",
        vehicle_model="Onix",
        vehicle_year=2024,
    )

    user.set_password("myStrongPass123")
    user.full_clean()
    assert user.driver_verification_status == User.DriverVerificationStatus.PENDING
