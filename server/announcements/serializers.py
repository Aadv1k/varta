from rest_framework import serializers

from rest_framework.exceptions import ValidationError


from accounts.models import User
from .models import Announcement, AnnouncementScope

from common.fields.AcademicYearField import AcademicYearField

from accounts.models import Department, Classroom

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
        Department.objects.get(department_name=data.lower())
    except Department.DoesNotExist:
        raise ValidationError(f"{data} is not a valid department.")

class AnnouncementScopeSerializer(serializers.ModelSerializer):
    filter_data = serializers.CharField()

    def validate_filter_data(self, filter_data):
        filter_type = self.get_attribute("filter")

        if filter_type in {
            AnnouncementScope.FilterType.STU_STANDARD, 
            AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD
        }:
            validate_standard(filter_data)
        elif filter_type in {
            AnnouncementScope.FilterType.STU_STANDARD_DIVISION,
            AnnouncementScope.FilterType.T_CLASS_TEACHER_OF_STANDARD_DIVISION,
            AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION,
        }:
            validate_standard_division(filter_data)
        elif filter_type == AnnouncementScope.FilterType.T_DEPARTMENT:
            validate_department(filter_type)

        return filter_data


    class Meta:
        model = AnnouncementScope
        fields = ['filter', 'filter_data']

class AnnouncementSerializer(serializers.ModelSerializer):
    title = serializers.CharField(max_length=255)
    body = serializers.CharField()
    scopes = AnnouncementScopeSerializer(many=True)

    class Meta:
        model = Announcement 
        fields = ["title", "body", "scopes", "author"]

    def validate_scopes(self, scopes_data):
        if len(scopes_data) == 0:
            raise ValidationError("Announcement must have at-least one scope attached to it")
        
        if any([scope["filter"] in {AnnouncementScope.FilterType.ALL_STUDENTS, AnnouncementScope.FilterType.ALL_TEACHERS,  AnnouncementScope.FilterType.EVERYONE} for scope in scopes_data]) and len(scopes_data) > 1:
            raise ValidationError("Can't have a scope with filter that includes all students, teachers or everyone with other scopes")
        
        return scopes_data
    
    def create(self, validated_data):
        scopes_data = validated_data.pop('scopes')
        announcement = Announcement.objects.create(**validated_data)
        for scope_data in scopes_data:
            AnnouncementScope.objects.create(announcement=announcement, **scope_data)
        return announcement
    
    def update(self, instance, validated_data):
        instance.title = validated_data.get("title", instance.title)
        instance.body = validated_data.get("body", instance.body)

        instance.scopes.all().delete()

        for scope in validated_data.get("scopes", []):
            AnnouncementScope.objects.create(announcement=instance, **scope)

        instance.save()

        return instance

class SimpleAnnouncementAuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["first_name", "last_name", "public_id"]

class AnnouncementOutputSerializer(serializers.ModelSerializer):
    author = SimpleAnnouncementAuthorSerializer()
    scopes = AnnouncementScopeSerializer(many=True)
    academic_year = AcademicYearField() 

    class Meta:
        model = Announcement
        fields = "__all__"