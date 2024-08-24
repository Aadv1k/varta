from django.contrib import admin
from .models import Classroom, Department, User, Student, Teacher, UserContact, Admin

admin.site.register(UserContact)

admin.site.register(Student)

admin.site.register(Teacher)
admin.site.register(Classroom)
admin.site.register(Department)

admin.site.register(Admin)

