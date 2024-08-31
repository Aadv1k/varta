from django.urls import path 
from .views import AnnouncementViewSet

urlpatterns = [
    path("announcements/", AnnouncementViewSet.as_view({
        "get": "list",
    }), name="announcement_list"),

    path("announcements/mine/", AnnouncementViewSet.as_view({
        "get": "list_mine",
    }), name="my_announcement_list")
]