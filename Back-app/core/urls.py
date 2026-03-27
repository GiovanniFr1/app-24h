from django.contrib import admin
from django.urls import include, path
from django.apps import apps as django_apps

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/users/", include("apps.users.urls")),
    path("api/v1/trips/", include("apps.trips.urls")),
]

if django_apps.is_installed("apps.locations"):
    urlpatterns.append(path("api/v1/locations/", include("apps.locations.urls")))
