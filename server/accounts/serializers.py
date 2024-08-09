from rest_framework import serializers
from rest_framework.exceptions import ValidationError


from schools.models import School
from .models import UserContact
import re

email_regex = re.compile(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
phone_number_regex = re.compile(r"^\+\d{10,15}$")

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
