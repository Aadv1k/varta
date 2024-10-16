from django.contrib import admin
from .models import Classroom, Department, User, StudentDetail, TeacherDetail, UserContact, UserDevice


class UserAdmin(admin.ModelAdmin):
    list_display = ('public_id', 'first_name', 'middle_name', 'last_name', 'user_type', 'school')
    search_fields = ('first_name', 'last_name', 'school__name') 
    list_filter = ('user_type', 'school') 
    ordering = ('last_name', 'first_name')

admin.site.register(User, UserAdmin)

# Customizing the UserContact admin
class UserContactAdmin(admin.ModelAdmin):
    list_display = ('user', 'contact_importance', 'contact_type', 'contact_data')
    search_fields = ('user__first_name', 'user__last_name', 'contact_data')  
    list_filter = ('contact_type', 'contact_importance')  

admin.site.register(UserContact, UserContactAdmin)

class StudentDetailAdmin(admin.ModelAdmin):
    list_display = ('user', 'classroom')
    search_fields = ('user__first_name', 'user__last_name', 'classroom__standard', 'classroom__division')
    list_filter = ('classroom__standard', 'classroom__division')

admin.site.register(StudentDetail, StudentDetailAdmin)


class TeacherDetailAdmin(admin.ModelAdmin):
    list_display = ('user', 'class_teacher_of')
    search_fields = ('user__first_name', 'user__last_name', 'class_teacher_of__standard', 'class_teacher_of__division')
    list_filter = ('departments__department_name', 'class_teacher_of')

admin.site.register(TeacherDetail, TeacherDetailAdmin)


class ClassroomAdmin(admin.ModelAdmin):
    list_display = ('standard', 'division')
    search_fields = ('standard', 'division')
    list_filter = ('standard', 'division')

admin.site.register(Classroom, ClassroomAdmin)


class DepartmentAdmin(admin.ModelAdmin):
    list_display = ('department_code', 'department_name')
    search_fields = ('department_code', 'department_name')
    ordering = ('department_name',)  

admin.site.register(Department, DepartmentAdmin)


class UserDeviceAdmin(admin.ModelAdmin):
    list_display = ('user', 'device_type', 'device_token', 'last_used_at')
    search_fields = ('user__first_name', 'user__last_name', 'device_token')
    list_filter = ('device_type',)
    ordering = ('-last_used_at',)  

admin.site.register(UserDevice, UserDeviceAdmin)


# from django.contrib.auth.models import User
# from django.contrib.auth.models import Group

# admin.site.unregister(User)
# admin.site.unregister(Group)
