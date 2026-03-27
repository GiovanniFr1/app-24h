from django.urls import path

from .views import LoginView, LogoutView, ProfileView, RefreshView, RegisterView

urlpatterns = [
    path("register/", RegisterView.as_view(), name="users-register"),
    path("login/", LoginView.as_view(), name="users-login"),
    path("token/refresh/", RefreshView.as_view(), name="users-token-refresh"),
    path("profile/", ProfileView.as_view(), name="users-profile"),
    path("logout/", LogoutView.as_view(), name="users-logout"),
]
