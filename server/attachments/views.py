from .serializers import AttachmentUploadSerializer

from announcements.views import IsOwner
from accounts.permissions import IsJWTAuthenticated , IsTeacher
from common.response_builder import SuccessResponseBuilder, ErrorResponseBuilder
from common.services.bucket_store import BucketStoreFactory

from rest_framework.viewsets import ViewSet
from rest_framework.decorators import api_view, parser_classes, permission_classes
from rest_framework.parsers import MultiPartParser

from rest_framework.request import Request

bucket_store = BucketStoreFactory()

class AttachmentViewSet(ViewSet):
    def get_permissions(self):
        perms = [ IsJWTAuthenticated ] 

        if self.action == "create":
            perms += [IsTeacher]
        elif self.action == "destroy":
            perms += [IsTeacher, IsOwner]
        
        return [perm() for perm in perms]

    def create(self, reqeust):
        pass

    def destroy(self, request, pk=None):
        pass


@api_view(["POST"])
@permission_classes([IsJWTAuthenticated, IsTeacher])
@parser_classes([MultiPartParser])
def upload_attachment(request):
    file = request.FILES.get("file")

    upload_serializer = AttachmentUploadSerializer(data={
        "file": file,
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
                .set_data({
                    "id": str(attachment.id),
                    "url": attachment.url,
                })\
                .set_code(201)\
                .build()
    except Exception as exc :
        return ErrorResponseBuilder() \
                .set_message("Couldn't upload your attachment at the moment")\
                .set_code(500)\
                .set_details({
                    "file": str(exc)
                })\
                .build()