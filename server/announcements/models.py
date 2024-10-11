from typing import Any
from django.db import models
import uuid

from accounts.models import User, Classroom
from schools.models import AcademicYear

from datetime import datetime

import pytz

class AnnouncementManager(models.Manager):
    def belong_to_user_school(self, user):
        return self.filter(author__school__id=user.school.id, deleted_at__isnull=True)

    def get_by_user(self, user):
        return self.filter(author=user, deleted_at__isnull=True)
    
    def deleted_belong_to_user_school(self, user):
        return self.filter(author__school__id=user.school.id, deleted_at__isnull=False)

class Announcement(models.Model):
    objects = AnnouncementManager()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(null=True)
    deleted_at = models.DateTimeField(null=True)

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    academic_year = models.ForeignKey(AcademicYear, on_delete=models.DO_NOTHING, default=AcademicYear.get_current_academic_year)
    author = models.ForeignKey(User, related_name="announcements", on_delete=models.SET_NULL, null=True)
    title = models.CharField(max_length=255)
    body = models.TextField()

    def soft_delete(self):
        self.deleted_at = datetime.now(tz=pytz.utc)
        self.save()

    def with_scope(self, filter_type, filter_data = None):
        AnnouncementScope.objects.create(
            announcement=self,
            filter=filter_type,
            filter_data=filter_data
        )
        return self

    def for_user(self, user: User) -> bool:
        return any([ann_scope.matches_for_user(user) for ann_scope in self.scopes.all()])

class AnnouncementScope(models.Model):
    class FilterType(models.TextChoices):
        # Filter criteria for the teachers
        T_CLASS_TEACHER_OF_STANDARD_DIVISION = "t_class_teacher_of", "Teacher is the class teacher of standard division"
        T_SUBJECT_TEACHER_OF_STANDARD = "t_subject_teacher_of_standard", "Teacher is subject teacher of the standard"
        T_SUBJECT_TEACHER_OF_STANDARD_DIVISION = "t_subject_teacher_of_standard_division", "Teacher is the subject teacher of the standard division"
        T_DEPARTMENT = "t_department", "Teacher is of the department"
        
        # Filter criteria for students
        STU_STANDARD = "stu_standard", "Student is of the standard"
        STU_STANDARD_DIVISION = "stu_standard_division", "Student is of the standard division"

        # General criteria
        ALL_STUDENTS = "stu_all", "All Students",
        ALL_TEACHERS = "t_all", "All Teachers",
        EVERYONE = "everyone", "Everyone in the school"

    
    announcement = models.ForeignKey(Announcement, on_delete=models.CASCADE, related_name="scopes")
    filter = models.CharField(max_length=48, choices=FilterType.choices)

    # NOTE: at the time of writing this I assume this means the field needs to explicitly be set to null
    filter_data = models.CharField(max_length=255, null=True, blank=True) 

    def matches_for_user(self, user: User) -> bool:
        if self.filter == self.FilterType.EVERYONE:
            return True
        elif self.filter == self.FilterType.ALL_STUDENTS and user.user_type == User.UserType.STUDENT:
            return True 
        elif self.filter == self.FilterType.ALL_TEACHERS and user.user_type == User.UserType.TEACHER:
            return True 
        elif self.filter == self.FilterType.STU_STANDARD:
            if user.student_details.classroom.standard == self.filter_data:
                return True
        elif self.filter == self.FilterType.STU_STANDARD_DIVISION:
            if user.student_details.classroom.equals_std_div_str(self.filter_data):
                return True
        elif self.filter == self.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION:
            t_classroom = Classroom.get_by_std_div_or_none(self.filter_data) 
            for classroom in user.teacher_details.subject_teacher_of.all():
                if (t_classroom.division == classroom.division and t_classroom.standard == classroom.standard):
                    return True
        elif self.filter == self.FilterType.T_DEPARTMENT:
            if user.teacher_details.departments.filter(department_code=self.filter_data).exists():
                return True

        return False
