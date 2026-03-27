import copy

from django.template.context import BaseContext


def patch_django_basecontext_copy() -> None:
    """
    Work around a runtime incompatibility hit in Python 3.14 where
    BaseContext.__copy__ can raise AttributeError in admin templates.
    """
    try:
        copy.copy(BaseContext())
        return
    except AttributeError as exc:
        if "dicts" not in str(exc):
            return

    def _fixed_copy(self):
        duplicate = object.__new__(self.__class__)
        duplicate.__dict__ = self.__dict__.copy()
        duplicate.dicts = self.dicts[:]
        return duplicate

    BaseContext.__copy__ = _fixed_copy
