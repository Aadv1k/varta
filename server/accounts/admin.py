from django.contrib import admin
from .models import Classroom, Department, User, StudentDetail, TeacherDetail, UserContact

admin.site.register(User)

admin.site.register(UserContact)
admin.site.register(StudentDetail)
admin.site.register(TeacherDetail)

admin.site.register(Classroom)
admin.site.register(Department)