from django.conf import settings
from rest_framework.serializers import Serializer, FileField, ValidationError, URLField, ModelSerializer, SerializerMethodField, CharField
from django.core.files import File

from common.services.bucket_store import BucketStoreFactory

from .models import Attachment

from pathlib import Path
import re

import uuid

import magic

SAFE_FILENAME_PATTERN = re.compile(r"^[\w][\w\-. ]{0,252}[\w]$")

bucket_store = BucketStoreFactory()

class AttachmentUploadSerializer(Serializer):
    file = FileField(
        max_length=255, allow_empty_file=False, use_url=True, required=True
    )
    filename = CharField(max_length=255)

    def validate_filename(self, filename: str) -> str:
        filename = Path(filename).name
        
        if not filename or filename in {'.', '..'}:
            raise ValidationError("Invalid filename")
            
        return filename

    def validate_file(self, file: File):
        if file.size < 2048 or file.size >= settings.MAX_UPLOAD_FILE_SIZE_IN_BYTES:
            raise ValidationError(
                "Invalid file size, it's either too large or too small."
            )

        mimetype = magic.from_buffer(file.read(2048), mime=True)
        file.seek(0)

        if mimetype not in Attachment.attachment_type_set:
            raise ValidationError("Unknown Filetype")

        return file

    def save(self, user) -> Attachment:
        file: File = self.validated_data["file"]

        attachment_id = uuid.uuid4()
        object_key = Attachment.get_object_key(user.public_id, attachment_id, file.name)

        mimetype = magic.from_buffer(file.read(2048), mime=True)
        attachment = Attachment.objects.create(
            id=attachment_id,
            user=user,
            file_size_in_bytes=file.size,
            key=object_key,
            file_type=mimetype,
            file_name=file.name,
        )

        return attachment 

class AttachmentOutputSerializer(ModelSerializer):
    url = SerializerMethodField()

    def get_url(self, obj):
        return bucket_store.get_url(obj.key)

    class Meta:
        model = Attachment
        exclude = ["user", "announcement", "key"]
