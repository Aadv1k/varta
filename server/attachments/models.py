from django.db import models
from accounts.models import User

from announcements.models import Announcement

import uuid

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

    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(User, related_name="uploads", on_delete=models.CASCADE)
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    url = models.URLField(max_length=1024)
    name = models.CharField(max_length=512)
    type = models.CharField(max_length=76, choices=AttachmentType.choices)

    def delete(self):
        assert False, "HANDLE ATTACHMENT DELETION HERE"
        # TODO: 
        #  - check if the current hash is shared by anything else
        #     - if it is not, then delete the resource, attachment and the hash
        #  - if the hash is shared then just delete the announcement and the hash, create a new one copying the has from the previous one but referencing to the first announcement which contains that path    
        # NO NEED TO CALL THIS AS IT WILL CASCADE self.attachment_hash.delete() self.delete()
        self.delete()

class AttachmentHash(models.Model):
   attachment = models.ForeignKey(Attachment, related_name="attachment_hash", on_delete=models.CASCADE)
   hash = models.CharField(max_length=64, unique=True)

   class Meta:
       indexes = [
           models.Index(fields=["hash"])
       ]

class AnnouncementAttachment(models.Model):
    announcement = models.ForeignKey(Announcement, related_name="attachments", on_delete=models.CASCADE)
    attachment = models.ForeignKey(Attachment,  on_delete=models.CASCADE)