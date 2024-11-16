from .serializers import AttachmentUploadSerializer, AttachmentOutputSerializer

from .models import Attachment

from announcements.views import IsOwner
from accounts.permissions import IsJWTAuthenticated , IsTeacher
from common.response_builder import SuccessResponseBuilder, ErrorResponseBuilder
from common.services.bucket_store import BucketStoreFactory

from rest_framework.viewsets import ViewSet
from rest_framework.decorators import api_view, parser_classes, permission_classes
from rest_framework.parsers import MultiPartParser

bucket_store = BucketStoreFactory()

class AttachmentViewSet(ViewSet):
    perms = [ IsJWTAuthenticated ] 

    def retrieve(self, request, pk):
        attachment = Attachment.objects.filter(id=pk)

        if not attachment.exists():
            return ErrorResponseBuilder() \
                    .set_code(404) \
                    .set_message("Attachment not found") \
                    .build()

        return SuccessResponseBuilder() \
                .set_code(200) \
                .set_data(AttachmentOutputSerializer(attachment.first()).data) \
                .set_message("Successfully fetched the attachment") \
                .set_metadata({"valid_for_seconds": "30"}) \
                .build()


@api_view(["POST"])
@permission_classes([IsJWTAuthenticated, IsTeacher])
@parser_classes([MultiPartParser])
def upload_attachment(request):
    file = request.FILES.get("file")

    upload_serializer = AttachmentUploadSerializer(data={
        "file": file,
        "filename": file.name
    })

    if not upload_serializer.is_valid():
        return ErrorResponseBuilder() \
                .set_message("Invalid file") \
                .set_details_from_serializer(upload_serializer) \
                .build()

    try:
        attachment = upload_serializer.save(request.user)
        
        return SuccessResponseBuilder() \
                .set_message("Your attachment was uploaded successfully")\
                .set_data(AttachmentOutputSerializer(attachment).data)\
                .set_code(201)\
                .build()
    except Exception as exc :
        return ErrorResponseBuilder() \
                .set_message("Couldn't upload your attachment at the moment")\
                .set_code(500)\
                .set_details([{
                    "field": "file",
                    "error": str(exc),
                }])\
                .build()
