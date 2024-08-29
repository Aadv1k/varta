from django.db import models
import uuid

from accounts.models import User
from schools.models import AcademicYear

class Announcement(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    academic_year = models.ForeignKey(AcademicYear, on_delete=models.DO_NOTHING)
    author = models.ForeignKey(User, related_name="announcements", on_delete=models.SET_NULL, null=True)
    title = models.CharField(max_length=255)
    body = models.TextField()

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
    filter_data = models.CharField(max_length=255, null=True, blank=False) 

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

        return False
