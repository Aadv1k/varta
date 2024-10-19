from django.db import models
from schools.models import School
from schools.serializers import SchoolSerializer
import uuid
import re

from django.conf import settings
from datetime import timezone, timedelta

class Classroom(models.Model):
    STANDARD_CHOICES = [(str(i), str(i)) for i in range(1, 13)]
    DIVISION_CHOICES = [(chr(i), chr(i)) for i in range(ord('A'), ord('J') + 1)]

    standard = models.CharField(max_length=2, choices=STANDARD_CHOICES)
    division = models.CharField(max_length=1, choices=DIVISION_CHOICES)

    @staticmethod
    def validate_std_div_str(s: str) -> bool:
        return bool(re.match(r'^(1[0-2]|[1-9])[A-J]$', s))
    
    def equals_std_div_str(self, s: str):
        classroom = Classroom.get_by_std_div_or_none(s)
        return self.standard == classroom.standard and self.division == classroom.division

    @staticmethod
    def get_by_std_div_or_none(s: str):
        if Classroom.validate_std_div_str(s):
            standard = s[:-1]
            division = s[-1]
            try:
                return Classroom.objects.get(standard=standard, division=division)
            except Classroom.DoesNotExist:
                return None
        return None

    def __str__(self):
        return f"{self.standard}{self.division}"

    class Meta:
        unique_together = ('standard', 'division')
        ordering = ['standard', 'division']

        indexes = [
            models.Index(fields=["standard"]),
            models.Index(fields=["standard", "division"]),
        ]


# NOTE: this is a reference table data at ./fixtures/initial_departments.json
class Department(models.Model):
    department_code = models.CharField(max_length=32, unique=True)
    department_name = models.CharField(max_length=64)

    def __str__(self):
        return f"{self.department_name[0].upper()}{self.department_name[1:]}"
    
    class Meta:
        ordering = ['department_name']

    @staticmethod
    def get_by_name_or_none(dept_name):
        try:
            return Department.objects.get(department_name=dept_name)
        except Department.DoesNotExist:
            return None

    indexes = [
        models.Index(fields=["department_code"]),
    ]

class User(models.Model):
    class UserType(models.TextChoices):
        TEACHER = "teacher", "Teacher"
        STUDENT = "student", "Student"

    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name="users")
    public_id = models.UUIDField(default=uuid.uuid4, editable=False)

    first_name = models.CharField(max_length=255)
    middle_name = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=255, blank=True)

    user_type = models.CharField(choices=UserType.choices, max_length=8, default=UserType.STUDENT)

    @classmethod
    def from_public_id(cls, public_id: str):
        return cls.objects.get(public_id=public_id)

    def is_authenticated():
        return True
    
    def __str__(self):
        return f"{self.first_name} {"" if not self.middle_name else self.middle_name + "."} {self.last_name or ""}"
    
    class Meta:
        ordering = ['first_name', 'last_name']

    indexes = [
        models.Index(fields=["user_type"]),
        models.Index(fields=["user_type", "school"]),
    ]


class StudentDetail(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="student_details")
    classroom = models.OneToOneField(Classroom, on_delete=models.SET_NULL, null=True)

    class Meta:
        verbose_name = "Student Detail"
        verbose_name_plural = "Student Details"

    def __str__(self):
        return f"{self.user}'s Details"

class TeacherDetail(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="teacher_details")
    departments =  models.ManyToManyField(Department, related_name="departments")
    subject_teacher_of = models.ManyToManyField(Classroom, related_name="subject_teacher_of")
    class_teacher_of = models.OneToOneField(Classroom, on_delete=models.SET_NULL, null=True, related_name="class_teacher_of", blank=True)

    class Meta:
        verbose_name = "Teacher Detail"
        verbose_name_plural = "Teacher Details"

    def __str__(self):
        return f"{self.user}'s Teacher Details"

class UserContact(models.Model):
    class ContactImportance(models.TextChoices):
        PRIMARY = "primary", "Primary"
        SECONDARY = "secondary", "Secondary"

    class ContactType(models.TextChoices):
        EMAIL = "email", "Email"
        PHONE_NUMBER = "phone_number", "Phone Number"

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="contacts")
    contact_importance = models.CharField(max_length=10, choices=ContactImportance.choices)
    contact_type = models.CharField(max_length=14, choices=ContactType.choices)
    contact_data = models.CharField(max_length=255)

    class Meta:
        verbose_name = "User Contact"
        verbose_name_plural = "User Contacts"
        unique_together = ('user', 'contact_type', 'contact_data')

        indexes = [
            models.Index(fields=["contact_importance", "contact_type", "contact_data"])
        ]


    def __str__(self):
        return f"{self.user.first_name} {self.user.last_name}'s - {self.contact_importance} {self.contact_type}"


class UserDevice(models.Model):
    class DeviceType(models.TextChoices):
        ANDROID = "android", "Android"
        IOS = "ios", "iOS"
        WEB = "web", "Web"

    user = models.ForeignKey(User, related_name="devices", on_delete=models.CASCADE)
    logged_in_through = models.ForeignKey(UserContact, related_name="registered_on", on_delete=models.CASCADE)
    device_token = models.CharField(max_length=255, blank=False, null=False, unique=True)
    device_type = models.CharField(max_length=10, choices=DeviceType.choices, blank=False, null=False)
    created_at = models.DateTimeField(auto_now_add=True)
    last_used_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'device_token') 
        verbose_name = "User Device"
        verbose_name_plural = "User Devices"
        ordering = ['-last_used_at']


    @property
    def is_expired(self):
        expiry_days = getattr(settings, 'FCM_DEVICE_TOKEN_EXPIRY_IN_DAYS', 30)
        return self.last_used_at <= timezone.now() - timedelta(days=expiry_days)

    def update_last_used(self):
        self.last_used_at = timezone.now()
        self.save(update_fields=['last_used_at'])

    def __str__(self):
        return f"{self.user}'s {self.device_type} device"
