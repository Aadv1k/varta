from django.urls import path

from .views import SchoolList, TeacherList

urlpatterns = [
    path("schools", SchoolList.as_view(), name="school_list"),
    path("schools/teachers", TeacherList.as_view(), name="teacher_list"),
]
