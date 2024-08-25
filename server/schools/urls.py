from django.urls import path

from .views import SchoolList

urlpatterns = [
    path("schools", SchoolList.as_view(), name="school_list"),
]
