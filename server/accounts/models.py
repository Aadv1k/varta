from django.db import models
from schools.models import School
import uuid
import re

class ClassroomManager(models.Manager):
    def get_by_std_div_or_none(s: str):
        if Classroom.validate_std_div_str(s):
            standard = s[:-1]
            division = s[-1]
            try:
                return Classroom.objects.get(standard=standard, division=division)
            except Classroom.DoesNotExist:
                return None
        return None

# NOTE: this is a reference table data at ./fixtures/initial_classrooms.json
class Classroom(models.Model):
    objects = ClassroomManager()

    STANDARD_CHOICES = [(str(i), str(i)) for i in range(1, 13)]
    DIVISION_CHOICES = [(chr(i), chr(i)) for i in range(ord('A'), ord('J') + 1)]

    standard = models.CharField(max_length=2, choices=STANDARD_CHOICES)
    division = models.CharField(max_length=1, choices=DIVISION_CHOICES)

    @staticmethod
    def validate_std_div_str(s: str) -> bool:
        return bool(re.match(r'^(1[0-2]|[1-9])[A-J]$', s))

    def __str__(self):
        return f"{self.standard}{self.division}"

# NOTE: this is a reference table data at ./fixtures/initial_departments.json
class Department(models.Model):
    department_name = models.CharField(max_length=64)

    def __str__(self):
        return f"{self.department_name[0].upper()}{self.department_name[1:]}"

class User(models.Model):
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name="users")
    public_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    first_name = models.CharField(max_length=255)
    middle_name = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=255)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"

class Student(User):
    classroom = models.OneToOneField(Classroom, on_delete=models.SET_NULL, null=True)

class Teacher(User):
    departments =  models.ManyToManyField(Department)
    subject_teacher_of = models.ManyToManyField(Classroom, related_name="subject_teacher_of")
    class_teacher_of = models.OneToOneField(Classroom, on_delete=models.SET_NULL, null=True, related_name="class_teacher_of")

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
