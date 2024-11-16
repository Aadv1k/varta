from django.urls import path

from .views import AttachmentViewSet, upload_attachment

urlpatterns = [
    path("attachments", AttachmentViewSet.as_view({
        "post": "create"
    }), name="attachment_list"),

    path("attachments/upload", upload_attachment, name="attachment_upload"),


    path("attachments/<uuid:pk>", AttachmentViewSet.as_view({
        "get": "retrieve"
    }), name="attachment_detail")

]
