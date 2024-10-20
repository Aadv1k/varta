from django.urls import path

from .views import user_login, user_verify, user_refresh, user_device, user_details

urlpatterns = [
    path("me/login", user_login, name="user_login"),
    path("me/verify", user_verify, name="user_verify"),
    path("me/refresh", user_refresh, name="user_refresh"),
    path("me", user_details, name="user_details"),
    path("me/device", user_device, name="user_device"),
]