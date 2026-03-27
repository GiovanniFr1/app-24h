from datetime import timedelta

import pytest
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import AccessToken

from apps.users.models import User
from apps.users.tests.factories import UserFactory


@pytest.fixture
def client():
    return APIClient()


@pytest.mark.django_db
def test_register_and_login_flow(client):
    register_payload = {
        "email": "passenger@example.com",
        "password": "myStrongPass123",
        "full_name": "Passenger One",
        "role": "PASSENGER",
    }
    register_resp = client.post(reverse("users-register"), register_payload, format="json")
    assert register_resp.status_code == 201

    login_resp = client.post(
        reverse("users-login"),
        {"email": register_payload["email"], "password": register_payload["password"]},
        format="json",
    )
    assert login_resp.status_code == 200
    assert "access" in login_resp.data
    assert "refresh" in login_resp.data


@pytest.mark.django_db
def test_driver_register_sets_pending_verification(client):
    payload = {
        "email": "driver-register@example.com",
        "password": "myStrongPass123",
        "full_name": "Driver One",
        "phone": "+5568999999999",
        "role": "DRIVER",
        "cpf": "12345678901",
        "cnh": "10987654321",
        "document_cpf_url": "https://example.com/cpf.jpg",
        "document_cnh_url": "https://example.com/cnh.jpg",
        "document_selfie_url": "https://example.com/selfie.jpg",
        "vehicle_plate": "ABC1D23",
        "vehicle_model": "HB20",
        "vehicle_year": 2023,
    }

    response = client.post(reverse("users-register"), payload, format="json")

    assert response.status_code == 201
    created = User.objects.get(email=payload["email"])
    assert created.driver_verification_status == User.DriverVerificationStatus.PENDING


@pytest.mark.django_db
def test_driver_register_requires_documents(client):
    payload = {
        "email": "driver-missing-docs@example.com",
        "password": "myStrongPass123",
        "full_name": "Driver Missing",
        "role": "DRIVER",
        "cpf": "12345678901",
        "cnh": "10987654321",
    }

    response = client.post(reverse("users-register"), payload, format="json")

    assert response.status_code == 400
    assert "detail" in response.data


@pytest.mark.django_db
def test_driver_login_requires_document_approval(client):
    user = User.objects.create_user(
        email="driver-pending@example.com",
        full_name="Driver Pending",
        password="myStrongPass123",
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
    assert user.driver_verification_status == User.DriverVerificationStatus.PENDING

    response = client.post(
        reverse("users-login"),
        {"email": user.email, "password": "myStrongPass123"},
        format="json",
    )

    assert response.status_code == 400
    assert "detail" in response.data


@pytest.mark.django_db
def test_driver_can_login_after_approval(client):
    user = User.objects.create_user(
        email="driver-approved@example.com",
        full_name="Driver Approved",
        password="myStrongPass123",
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

    response = client.post(
        reverse("users-login"),
        {"email": user.email, "password": "myStrongPass123"},
        format="json",
    )

    assert response.status_code == 200
    assert "access" in response.data
    assert "refresh" in response.data


@pytest.mark.django_db
def test_login_with_invalid_password_returns_400(client):
    UserFactory(email="valid@example.com")

    response = client.post(
        reverse("users-login"),
        {"email": "valid@example.com", "password": "wrong-pass"},
        format="json",
    )

    assert response.status_code == 400


@pytest.mark.django_db
def test_profile_requires_auth(client):
    response = client.get(reverse("users-profile"))
    assert response.status_code == 401


@pytest.mark.django_db
def test_profile_returns_authenticated_user_data(client):
    user = UserFactory(email="profile@example.com")
    access = str(AccessToken.for_user(user))

    client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
    response = client.get(reverse("users-profile"))

    assert response.status_code == 200
    assert response.data["email"] == user.email


@pytest.mark.django_db
def test_profile_rejects_manipulated_jwt(client):
    user = UserFactory()
    valid = str(AccessToken.for_user(user))
    manipulated = f"{valid}a"

    client.credentials(HTTP_AUTHORIZATION=f"Bearer {manipulated}")
    response = client.get(reverse("users-profile"))

    assert response.status_code == 401


@pytest.mark.django_db
def test_profile_rejects_expired_jwt(client):
    user = UserFactory()
    token = AccessToken.for_user(user)
    token.set_exp(lifetime=timedelta(seconds=-1))

    client.credentials(HTTP_AUTHORIZATION=f"Bearer {str(token)}")
    response = client.get(reverse("users-profile"))

    assert response.status_code == 401


@pytest.mark.django_db
def test_token_refresh_flow(client):
    user = User.objects.create_user(email="refresh@example.com", full_name="Refresh", password="myStrongPass123")
    login_response = client.post(
        reverse("users-login"),
        {"email": user.email, "password": "myStrongPass123"},
        format="json",
    )

    response = client.post(
        reverse("users-token-refresh"),
        {"refresh": login_response.data["refresh"]},
        format="json",
    )

    assert response.status_code == 200
    assert "access" in response.data


@pytest.mark.django_db
def test_logout_requires_refresh(client):
    user = UserFactory()
    access = str(AccessToken.for_user(user))
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")

    response = client.post(reverse("users-logout"), {}, format="json")

    assert response.status_code == 400


@pytest.mark.django_db
def test_logout_with_invalid_refresh_returns_400(client):
    user = UserFactory()
    access = str(AccessToken.for_user(user))
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")

    response = client.post(reverse("users-logout"), {"refresh": "invalid"}, format="json")

    assert response.status_code == 400
