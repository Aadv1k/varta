from rest_framework.test import APITestCase

from django.urls import reverse

from common.services.token import TokenService, TokenPayload


from schools.models import School, AcademicYear
from accounts.models import Teacher, Classroom, Student
from .models import Announcement, AnnouncementScope

class AnnouncementTestCase(APITestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.teacher = Teacher.objects.create(
            school=self.school,
            first_name="John",
            last_name="Doe",
            class_teacher_of=Classroom.get_by_std_div_or_none("10A")
        )

        self.student = Student.objects.create(
            school=self.school,
            first_name="Aarav",
            middle_name="Raj",
            last_name="Sharma",
            classroom=Classroom.get_by_std_div_or_none("10A"),
        )

        self.stud_access_token, self.student_rt = TokenService.generate_token_pair(TokenPayload(sub=str(self.student.public_id), iss="varta.test", role=self.student.user_type))

        self.announcement_1 = Announcement.objects.create(
            author=self.teacher,
            academic_year=AcademicYear.get_current_academic_year(),
            title = "School holiday delcared due to heavy rainfall as per order by DM",
            body = "Dear Students\nYou'll be pleased to informed NO SCHOOL!"
        )

        AnnouncementScope.objects.create(
            announcement=self.announcement_1,
            filter=AnnouncementScope.FilterType.ALL_STUDENTS
        )


    def test_authenticated_user_can_view_announcements_of_their_school(self):
        response = self.client.get(reverse("announcement_list"))
        self.assertEqual(response.status_code, 403) 

        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.stud_access_token)
        self.client.get(reverse("announcement_list"))

        self.assertEqual(response.status_code, 200) 