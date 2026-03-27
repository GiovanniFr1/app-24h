from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .models import User


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    list_display = ("email", "full_name", "role", "driver_verification_status", "is_active", "is_staff")
    ordering = ("email",)
    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Perfil", {"fields": ("full_name", "phone", "role", "cpf", "cnh", "profile_photo")}),
        (
            "Motorista",
            {
                "fields": (
                    "document_cpf_url",
                    "document_cnh_url",
                    "document_selfie_url",
                    "vehicle_plate",
                    "vehicle_model",
                    "vehicle_year",
                    "driver_verification_status",
                    "driver_verification_notes",
                )
            },
        ),
        ("Permissões", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Datas importantes", {"fields": ("last_login", "date_joined")}),
    )
    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("email", "full_name", "role", "password1", "password2"),
        }),
    )
    search_fields = ("email", "full_name", "cpf", "cnh", "vehicle_plate")
