from django.conf import settings
from rest_framework.serializers import Serializer, FileField, ValidationError, CharField
from django.core.files import File

from common.services.bucket_store import BucketStoreFactory

from .models import Attachment, AttachmentHash

from pathlib import Path
import hashlib
import re

import magic

SAFE_FILENAME_PATTERN = re.compile(r"^[\w][\w\-. ]{0,252}[\w]$")

bucket_store = BucketStoreFactory()


class AttachmentUploadSerializer(Serializer):
    file = FileField(
        max_length=255, allow_empty_file=False, use_url=True, required=True
    )

    def validate_file(self, file: File):
        self.validate_filename(file.name)
        if file.size <= 2048 and file.size >= settings.MAX_UPLOAD_FILE_SIZE_IN_BYTES:
            raise ValidationError(
                "Invalid file size, it's either too large or too small."
            )

        mimetype = magic.from_buffer(file.read(2048), mime=True)
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
        file_hash = hashlib.md5(file.read(2048)).hexdigest()

        try:
            attachment: Attachment = AttachmentHash.objects.get(
                hash=file_hash
            ).attachment
            new_attachment = Attachment.objects.create(
                user=user,
                url=attachment.url,
                type=attachment.type,
                name=file.name,
            )
        except AttachmentHash.DoesNotExist:
            url = bucket_store.upload( file.name, file.read(),)
            mimetype = magic.from_buffer(file.read(2048), mime=True)
            new_attachment = Attachment.objects.create(
                user=user,
                url=url,
                type=mimetype,
                name=file.name,
            )
            AttachmentHash.objects.create( attachment=new_attachment, hash=file_hash,)

        return new_attachment
