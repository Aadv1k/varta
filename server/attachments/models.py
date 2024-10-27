from django.db import models
from accounts.models import User

from announcements.models import Announcement

from common.services.bucket_store import BucketStoreFactory

import uuid

bucket_store = BucketStoreFactory()

class Attachment(models.Model):
    class AttachmentType(models.TextChoices):
        DOCX = ("application/vnd.openxmlformats-officedocument.wordprocessingml.document", "MS Word Document")
        DOC = ("application/msword", "Document")
        XLSX = ("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "MS Excel Spreadsheet")
        XLS = ("application/vnd.ms-excel", "MS Excel Spreadsheet (older)")
        PPTX = ("application/vnd.openxmlformats-officedocument.presentationml.presentation", "MS PowerPoint Presentation")
        PPT = ("application/vnd.ms-powerpoint", "MS PowerPoint Presentation (older)")
        PDF = ("application/pdf", "PDF Document")
        JPG = ("image/jpeg", "JPEG Image")
        PNG = ("image/png", "PNG Image")
        MP4 = ("video/mp4", "MP4 Video")
        AVI = ("video/x-msvideo", "AVI Video")
        MOV = ("video/quicktime", "MOV Video")

    attachment_type_set = set(value for value, label in AttachmentType.choices)

    id = models.UUIDField(primary_key=True, default=uuid.uuid4 )
    user = models.ForeignKey(User, related_name="uploads", on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    key = models.CharField(max_length=512, unique=True)
    url = models.URLField(max_length=1024, unique=True)
    file_type = models.CharField(max_length=76, choices=AttachmentType.choices)
    file_name = models.CharField(max_length=255)

    @staticmethod
    def get_object_key(public_id, attachment_id, file_name):
        return f"{public_id}/{attachment_id}/{file_name}"
    
    def delete(self):
        bucket_store.delete(self.key)
        super().delete()

class AnnouncementAttachment(models.Model):
    announcement = models.ForeignKey(Announcement, related_name="attachments", on_delete=models.CASCADE)
    attachment = models.ForeignKey(Attachment, on_delete=models.CASCADE)
