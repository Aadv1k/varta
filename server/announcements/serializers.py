from rest_framework import serializers

from rest_framework.exceptions import ValidationError

from datetime import datetime, timezone

from accounts.models import User
from .models import Announcement, AnnouncementScope

from common.fields.AcademicYearField import AcademicYearField
from common.services.notification_queue import NotificationQueueFactory
from common.services.notification_service import send_notification

from attachments.models import Attachment, AnnouncementAttachment

from django.conf import settings

from accounts.models import Department, Classroom

        
notification_queue = NotificationQueueFactory(send_notification)

def validate_standard(data: str):
    try:
        if not int(data) <= 12 and int(data) > 1:
            raise Exception()
    except Exception :
        raise ValidationError("Standard is expected to be a valid integer between 1 and 12")

def validate_standard_division(data: str):
    is_valid = Classroom.validate_std_div_str(data)
    if not is_valid:
        raise ValidationError("Expected the standard division to be in the format StandardDivision where division is an uppercase between A, E")

def validate_department(data: str):
    try:
        Department.objects.get(department_code=data)
    except Department.DoesNotExist:
        raise ValidationError(f"Couldn't find a department of code \"{data}\".")

class AnnouncementScopeSerializer(serializers.ModelSerializer):
    filter = serializers.ChoiceField(required=True, choices=AnnouncementScope.FilterType.choices)
    filter_data = serializers.CharField(required=False, max_length=255, allow_blank=True)

    def validate(self, data):
        filter_type = data.get('filter')
        filter_data = data.get('filter_data')

        if not filter_type:
            raise serializers.ValidationError({"filter": "This field is required."})

        if filter_type in {
            AnnouncementScope.FilterType.STU_STANDARD, 
            AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD,
            AnnouncementScope.FilterType.STU_STANDARD_DIVISION,
            AnnouncementScope.FilterType.T_CLASS_TEACHER_OF_STANDARD_DIVISION,
            AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION,
            AnnouncementScope.FilterType.T_DEPARTMENT
        }:
            if not filter_data:
                raise serializers.ValidationError({"filter_data": "This field is required for the selected filter type."})

        if filter_type in {AnnouncementScope.FilterType.STU_STANDARD, AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD}:
                validate_standard(filter_data)
        elif filter_type in {AnnouncementScope.FilterType.STU_STANDARD_DIVISION, AnnouncementScope.FilterType.T_CLASS_TEACHER_OF_STANDARD_DIVISION, AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION}:
                validate_standard_division(filter_data)
        elif filter_type == AnnouncementScope.FilterType.T_DEPARTMENT:
                validate_department(filter_data)

        return data

    class Meta:
        model = AnnouncementScope
        fields = ['filter', 'filter_data']


class AnnouncementSerializer(serializers.ModelSerializer):
    title = serializers.CharField(max_length=255)
    body = serializers.CharField()
    scopes = AnnouncementScopeSerializer(many=True)
    attachments = serializers.ListSerializer(
        required=False,
        child=serializers.UUIDField(),
        max_length=settings.MAX_ATTACHMENTS_PER_ANNOUNCEMENT,
        allow_empty=True
    )

    def validate_attachments(self, attachments):
        attachments_set = set()
        
        for attachment_id in attachments:
            if str(attachment_id) in attachments_set:
                raise ValidationError("Duplicate attachment detected. Each attachment must be unique.")
            try:
                Attachment.objects.get(id=attachment_id)
                attachments_set.add(str(attachment_id))
            except Attachment.DoesNotExist:
                raise ValidationError("Duplicate attachment detected. Each attachment must be unique.")

        return attachments

    class Meta:
        model = Announcement 
        fields = ["id", "title", "body", "scopes", "author", "attachments"]

    def validate_scopes(self, scopes_data):
        if len(scopes_data) == 0:
            raise ValidationError("Announcement must have at-least one scope attached to it")
        
        if any([scope["filter"] in {AnnouncementScope.FilterType.ALL_STUDENTS, AnnouncementScope.FilterType.ALL_TEACHERS,  AnnouncementScope.FilterType.EVERYONE} for scope in scopes_data]) and len(scopes_data) > 1:
            raise ValidationError("Can't have a scope with filter that includes all students, teachers or everyone with other scopes")
        
        return scopes_data
    
    def save(self):
        if self.partial:
            # Hmm i think I am doing something VERY wrong here
            self.update(self.instance, self.validated_data)
            return

        data = {**self.validated_data}

        scopes = data.pop("scopes")
        attachments = [] if "attachments" not in data else data.pop("attachments") 

        announcement = Announcement.objects.create(
            **data
        )

        for scope in scopes:
            AnnouncementScope.objects.create(announcement=announcement, **scope)

        for attachment_id in attachments:
            AnnouncementAttachment.objects.create(
                announcement=announcement,
                attachment=Attachment.objects.get(id=attachment_id)
            )

        notification_queue.enqueue(str(announcement.id))

        return announcement
    
    def update(self, instance, validated_data):
        instance.title = validated_data.get("title", instance.title)
        instance.body = validated_data.get("body", instance.body)

        new_scopes = validated_data.get("scopes", []) 

        if len(new_scopes) > 0:
            instance.scopes.all().delete()
            for scope in new_scopes:
                AnnouncementScope.objects.create(announcement=instance, **scope)

        instance.updated_at = datetime.now(timezone.utc)
        instance.save()

        notification_queue.enqueue(instance.id)

        return instance

class SimpleAnnouncementAuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["first_name", "last_name", "public_id"]

class AttachmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attachment
        fields = "__all__"

class AnnouncementAttachmentToAttachmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnnouncementAttachment
        fields = ["announcement"]

    def to_representation(self, instance):
        return AttachmentSerializer(instance.attachment).data

class AnnouncementOutputSerializer(serializers.ModelSerializer):
    author = SimpleAnnouncementAuthorSerializer()
    scopes = AnnouncementScopeSerializer(many=True)
    academic_year = AcademicYearField() 
    attachments = AnnouncementAttachmentToAttachmentSerializer(many=True)

    class Meta:
        model = Announcement
        fields = "__all__"