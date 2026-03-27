from django.contrib.auth import authenticate
from rest_framework import serializers

from .models import User


class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "password",
            "full_name",
            "phone",
            "role",
            "cpf",
            "cnh",
            "document_cpf_url",
            "document_cnh_url",
            "document_selfie_url",
            "vehicle_plate",
            "vehicle_model",
            "vehicle_year",
            "driver_verification_status",
            "profile_photo",
        )
        read_only_fields = ("id", "driver_verification_status")

    def validate(self, attrs):
        role = attrs.get("role", User.Role.PASSENGER)

        if role == User.Role.DRIVER:
            required_fields = (
                "cpf",
                "cnh",
                "document_cpf_url",
                "document_cnh_url",
                "document_selfie_url",
                "vehicle_plate",
                "vehicle_model",
                "vehicle_year",
            )
            missing = [field for field in required_fields if not attrs.get(field)]
            if missing:
                missing_labels = ", ".join(missing)
                raise serializers.ValidationError(
                    {"detail": f"Cadastro de motorista requer os campos: {missing_labels}"}
                )
        return attrs

    def create(self, validated_data):
        password = validated_data.pop("password")
        role = validated_data.get("role", User.Role.PASSENGER)
        if role == User.Role.DRIVER:
            validated_data["driver_verification_status"] = User.DriverVerificationStatus.PENDING
        else:
            validated_data["driver_verification_status"] = User.DriverVerificationStatus.NOT_REQUIRED
        return User.objects.create_user(password=password, **validated_data)


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        user = authenticate(username=attrs["email"], password=attrs["password"])
        if not user:
            raise serializers.ValidationError("Credenciais inválidas")
        if user.role == User.Role.DRIVER and not user.is_driver_approved():
            raise serializers.ValidationError(
                {
                    "detail": (
                        "Conta de motorista aguardando aprovação de documentos. "
                        "Status atual: "
                        f"{user.driver_verification_status}"
                    )
                }
            )
        attrs["user"] = user
        return attrs


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "full_name",
            "phone",
            "role",
            "cpf",
            "cnh",
            "document_cpf_url",
            "document_cnh_url",
            "document_selfie_url",
            "vehicle_plate",
            "vehicle_model",
            "vehicle_year",
            "driver_verification_status",
            "driver_verification_notes",
            "profile_photo",
        )
        read_only_fields = ("id", "email", "role")
