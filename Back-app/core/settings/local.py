from .base import *

DEBUG = True

# Local mode without external infra (Docker/PostGIS/Redis).
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "local.sqlite3",
    }
}

# Geo/PostGIS app is disabled in local mode to avoid hard dependency on PostGIS/SpatiaLite.
INSTALLED_APPS = [
    app
    for app in INSTALLED_APPS
    if app not in {"apps.locations", "django.contrib.gis"}
]

CHANNEL_LAYERS = {
    "default": {"BACKEND": "channels.layers.InMemoryChannelLayer"},
}

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "ride-local-cache",
    }
}

CELERY_TASK_ALWAYS_EAGER = True
