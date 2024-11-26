from typing import Any
from django.db import models
import uuid

from accounts.models import User, Classroom
from schools.models import AcademicYear

from datetime import datetime, timezone

class Announcement(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(null=True)
    deleted_at = models.DateTimeField(null=True)

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    academic_year = models.ForeignKey(AcademicYear, on_delete=models.DO_NOTHING, default=AcademicYear.get_current_academic_year)
    author = models.ForeignKey(User, related_name="announcements", on_delete=models.SET_NULL, null=True)
    title = models.CharField(max_length=255)
    body = models.TextField()

    # NOTE: this behaviour must be documented as soft-deleting WILL delete all the attachments too
    def soft_delete(self):
        self.deleted_at = datetime.now(timezone.utc)
        for attachment in self.attachments.all():
            attachment.delete()

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
    
    def __str__(self):
        author_name = f"{self.author.first_name} {self.author.last_name}" if self.author else "Unknown Author"
        body_snippet = self.body[:50] + '...' if len(self.body) > 50 else self.body
        return f"Announcement: {self.title} by {author_name}"

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
        if self.filter in { self.FilterType.EVERYONE, self.FilterType.ALL_STUDENTS }:
            return True

        if user.user_type == User.UserType.STUDENT:
            if self.filter == self.FilterType.STU_STANDARD and user.student_details.classroom.standard == self.filter_data:
                return True
            if self.filter == self.FilterType.STU_STANDARD_DIVISION and user.student_details.classroom.equals_std_div_str(self.filter_data):
                return True
            return False

        if user.user_type == User.UserType.TEACHER:
            # this makes sure all the student announcements are visible to the teachers 
            # NOTE: we could also make sure that announcements are only visible within the same STD_DIV, currently this is the simplest approach
            if self.filter in { self.FilterType.STU_STANDARD,  self.FilterType.STU_STANDARD_DIVISION }:
                return True

            if self.filter == self.FilterType.ALL_TEACHERS:
                return True
            if self.filter == self.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION:
                t_classroom = Classroom.get_by_std_div_or_none(self.filter_data)
                return any((t_classroom.division == classroom.division and t_classroom.standard == classroom.standard)
                           for classroom in user.teacher_details.subject_teacher_of.all())
            if self.filter == self.FilterType.T_DEPARTMENT:
                return user.teacher_details.departments.filter(department_code=self.filter_data).exists()
            return False

        return False

    def __str__(self):
        filter_info = f"{self.get_filter_display()}"
        if self.filter_data:
            filter_info += f" ({self.filter_data})"
        return f"Scope for {self.announcement.title}: {filter_info}"
