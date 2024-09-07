from django.urls import path 
from .views import AnnouncementViewSet

urlpatterns = [
    path("announcements/", AnnouncementViewSet.as_view({
        "get": "list",
        "post": "create"
    }), name="announcement_list"),

    path("announcements/search", AnnouncementViewSet.as_view({
        "get": "search",
    }), name="announcement_search"),

    path("announcements/mine/", AnnouncementViewSet.as_view({
        "get": "list_mine",
    }), name="my_announcement_list")
]