from django.conf import settings
from rest_framework.serializers import Serializer, FileField, ValidationError, CharField, ModelSerializer
from django.core.files import File

from common.services.bucket_store import BucketStoreFactory

from .models import Attachment

from pathlib import Path
import re

import uuid

import magic

SAFE_FILENAME_PATTERN = re.compile(r"^[\w][\w\-. ]{0,252}[\w]$")

bucket_store = BucketStoreFactory()

class AttachmentOutputSerializer(ModelSerializer):
    class Meta:
        model = Attachment
        exclude = ["user", "announcement"]

class AttachmentUploadSerializer(Serializer):
    file = FileField(
        max_length=255, allow_empty_file=False, use_url=True, required=True
    )

    def validate_file(self, file: File):
        self.validate_filename(file.name)
        if file.size < 2048 or file.size >= settings.MAX_UPLOAD_FILE_SIZE_IN_BYTES:
            raise ValidationError(
                "Invalid file size, it's either too large or too small."
            )

        mimetype = magic.from_buffer(file.read(2048), mime=True)
        file.seek(0)

        if mimetype not in Attachment.attachment_type_set:
            raise ValidationError("Unknown Filetype")

        return file

    def validate_filename(self, filename: str):
        if not all(
            [
                bool(SAFE_FILENAME_PATTERN.match(filename)),
                ".." not in filename,
                not filename.startswith("."),
                len(Path(filename).suffixes) == 1,
                len(Path(filename).suffix) <= 7,
                filename == filename.strip(),
                filename.lower()
                not in {
                    "con",
                    "prn",
                    "aux",
                    "nul",
                    "com1",
                    "com2",
                    "com3",
                    "com4",
                    "lpt1",
                    "lpt2",
                    "lpt3",
                    "lpt4",
                },
            ]
        ):
            raise ValidationError("Illegal Filename")

        return filename

    def save(self, user) -> Attachment:
        file: File = self.validated_data["file"]

        attachment_id = uuid.uuid4()
        object_key = Attachment.get_object_key(user.public_id, attachment_id, file.name)

        url = bucket_store.upload(file.read(), object_key)
        file.seek(0)

        mimetype = magic.from_buffer(file.read(2048), mime=True)
        attachment = Attachment.objects.create(
            id=attachment_id,
            user=user,
            url=url,
            file_size_in_bytes=file.size,
            key=object_key,
            file_type=mimetype,
            file_name=file.name,
        )

        return attachment 
