from django.urls import path 
from .views import AnnouncementViewSet, create_attachment

urlpatterns = [
    path("announcements/", AnnouncementViewSet.as_view({
        "get": "list",
        "post": "create"
    }), name="announcement_list"),

    path("announcements/<uuid:pk>", AnnouncementViewSet.as_view({
        "delete": "destroy",
        "put": "update"
    }), name="announcement_detail"),

    path("announcements/updated-since", AnnouncementViewSet.as_view({
        "get": "updated_since",
    }), name="announcement_updated_since"),

    path("announcements/search", AnnouncementViewSet.as_view({
        "get": "search",
    }), name="announcement_search"),

    path("announcements/mine", AnnouncementViewSet.as_view({
        "get": "list_mine",
    }), name="my_announcement_list"),

    path("announcements/upload", create_attachment, name="announcement_attachment_upload")
]
