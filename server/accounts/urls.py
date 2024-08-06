from django.urls import path

from .views import user_login

urlpatterns = [
    path("me/login", user_login, name="user_login")
]
