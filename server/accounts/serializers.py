from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from schools.models import School
from .models import UserContact, UserDevice, User, StudentDetail, TeacherDetail, Classroom
import re

from django.core.exceptions import ObjectDoesNotExist

email_regex = re.compile(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
phone_number_regex = re.compile(r"^\+\d{10,15}$")

class UserVerificationSerializer(serializers.Serializer):
    input_data = serializers.CharField()
    otp = serializers.CharField(min_length=6, max_length=6)
    school_id = serializers.CharField()

    def validate_school_id(self, data):
        try:
            School.objects.get(id=data)
        except ValueError:
            raise serializers.ValidationError("School ID must be a valid integer.")
        except School.DoesNotExist:
            raise serializers.ValidationError("School with this ID does not exist.")
        return data

class UserLoginSerializer(serializers.Serializer):
    input_format = serializers.ChoiceField(choices=UserContact.ContactType.choices)
    input_data = serializers.CharField()
    
    # RATIONALE: a potential attacker, may try to use are login system to check if a given user exists in the system. Having the specification of school will make it much harder for them to pin point what school the user belongs to, which technically is more secure?
    school_id = serializers.CharField()

    def validate_school_id(self, data):
        try:
            School.objects.get(id=data)
        except ValueError:
            raise serializers.ValidationError("School ID must be a valid integer.")
        except School.DoesNotExist:
            raise serializers.ValidationError("School with this ID does not exist.")
        return data

    def validate(self, data):
        input_format = data.get("input_format")
        input_data = data.get("input_data")

        if input_format == UserContact.ContactType.EMAIL:
            if not email_regex.match(input_data):
                raise ValidationError("Illegal email address.")
        elif input_format == UserContact.ContactType.PHONE_NUMBER:
            if not phone_number_regex.match(input_data):
                raise ValidationError("Illegal phone number.")
        else:
            raise ValidationError("Unrecognized contact parameter; expected email or phone_number")

        return data

class UserDeviceSerializer(serializers.ModelSerializer):
    logged_in_through = serializers.CharField(max_length=255)

    def validate_logged_in_through(self, value):
        try:
            UserContact.objects.get(user=self.initial_data["user"], contact_data=value)
        except UserContact.DoesNotExist:
            raise ValidationError(f"Contact {value} doesn't exist for this user")
        
        return value

    def save(self, **kwargs):
        logged_in_through = self.validated_data.pop("logged_in_through")
        contact_instance = UserContact.objects.get(user=self.validated_data["user"], contact_data=logged_in_through)

        return UserDevice.objects.create(logged_in_through=contact_instance, **self.validated_data)

    class Meta:
        model = UserDevice
        exclude = ["created_at", "id"]


class UserContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserContact
        exclude = ["id", "user"]

class TeacherDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = TeacherDetail
        exclude = ["id", "user"]

class ClassroomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classroom
        exclude = ["id"]
    

class StudentDetailSerializer(serializers.ModelSerializer):
    classroom = ClassroomSerializer()
    class Meta:
        model = StudentDetail
        exclude = ["id", "user"]

class UserSerializer(serializers.ModelSerializer): 
    contacts = UserContactSerializer(many=True)
    class Meta:
        model = User
        exclude = ["id", "school"]

    def to_representation(self, instance):
        repr = super().to_representation(instance)
    
        if not hasattr(instance, "student_details") and not hasattr(instance, "teacher_details"):
            repr["details"]  = {}
            return repr


        if self.instance.user_type == User.UserType.STUDENT:
            serializer = StudentDetailSerializer(instance.student_details)
        elif self.instance.user_type == User.UserType.TEACHER:
            serializer = TeacherDetailSerializer(instance.teacher_details)  
        else:
            assert False, "Unreachable"


        repr["details"] = serializer.data

        return repr
