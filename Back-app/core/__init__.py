from .celery import app as celery_app
from .compat import patch_django_basecontext_copy

patch_django_basecontext_copy()

__all__ = ("celery_app",)
