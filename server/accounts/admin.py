from django.contrib import admin
from .models import Classroom, Department, User, Student, Teacher, UserContact

@admin.register(Classroom)
class ClassroomAdmin(admin.ModelAdmin):
    list_display = ('standard', 'division')
    search_fields = ('standard', 'division')

@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ('department_name',)
    search_fields = ('department_name',)

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'middle_name', 'last_name', 'school')
    search_fields = ('first_name', 'last_name', 'school__name')

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'middle_name', 'last_name', 'school', 'classroom')
    search_fields = ('first_name', 'last_name', 'school__name', 'classroom__standard', 'classroom__division')

@admin.register(Teacher)
class TeacherAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'middle_name', 'last_name', 'school', 'class_teacher_of')
    search_fields = ('first_name', 'last_name', 'school__name', 'class_teacher_of__standard', 'class_teacher_of__division')
    filter_horizontal = ('departments', 'subject_teacher_of')

@admin.register(UserContact)
class UserContactAdmin(admin.ModelAdmin):
    list_display = ('user', 'contact_importance', 'contact_type', 'contact_data')
    search_fields = ('user__first_name', 'user__last_name', 'contact_data')
    list_filter = ('contact_importance', 'contact_type')
