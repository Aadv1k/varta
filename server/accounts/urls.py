from django.urls import path

from .views import user_login, user_verify

urlpatterns = [
    path("me/login", user_login, name="user_login"),
    path("me/verify", user_verify, name="user_verify"),
]
