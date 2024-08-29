from rest_framework.test import APITestCase

from django.urls import reverse

from common.services.token import TokenService, TokenPayload


from schools.models import School, AcademicYear
from accounts.models import User, Classroom, StudentDetail, TeacherDetail
from .models import Announcement, AnnouncementScope

class StudentAnnouncementTestCase(APITestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def _only_has_these_filters(self, expected_scope_filters: set, announcements):
        for announcement in announcements:
            if not all(map(lambda ann: ann["filter"] in expected_scope_filters, announcement.scopes)):
                return False

        return True


    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.teacher = User.objects.create(
            school=self.school,
            first_name="John",
            last_name="Doe",
        )

        self.announcements_for_all_students = 5
        self.announcements_for_student_standard = 5
        self.announcements_for_student_standard_division = 5

        self.announcements = [
            *[Announcement.objects.create(
                author=self.teacher,
                academic_year=AcademicYear.get_current_academic_year(),
                title=f"Announcement #{i} for all students",
                body="Dear Students\nYou'll be pleased to informed NO SCHOOL!"
            ).with_scope(AnnouncementScope.FilterType.ALL_STUDENTS)
            for i in range(self.announcements_for_all_students)],


            *[Announcement.objects.create(
                author=self.teacher,
                academic_year=AcademicYear.get_current_academic_year(),
                title=f"Announcement #{i} for students of standard 9th",
                body="Dear Students\nYou'll be pleased to informed NO SCHOOL!"
            ).with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="9")
            for i in range(self.announcements_for_student_standard)],

            *[Announcement.objects.create(
                author=self.teacher,
                academic_year=AcademicYear.get_current_academic_year(),
                title=f"Announcement #{i} for students of standard 9th",
                body="Dear Students\nYou'll be pleased to informed NO SCHOOL!"
            ).with_scope(AnnouncementScope.FilterType.STU_STANDARD_DIVISION, filter_data="9A")
            for i in range(self.announcements_for_student_standard_division)]
        ]

        self.student_10A = User.objects.create(
            school=self.school,
            first_name="Aarav",
            middle_name="Raj",
            last_name="Sharma",
        )
        StudentDetail.objects.create(
            user=self.student_10A,
            classroom=Classroom.get_by_std_div_or_none("10A"),
        )
        self.stud_10A_at, _ = TokenService.generate_token_pair(TokenPayload(sub=str(self.student_10A.public_id), iss="varta.test", role=self.student_10A.user_type))

        self.student_9B = User.objects.create(
            school=self.school,
            first_name="Aarav",
            middle_name="Raj",
            last_name="Sharma",
        )
        StudentDetail.objects.create(
            user=self.student_9B,
            classroom=Classroom.get_by_std_div_or_none("9B"),
        )
        self.stud_9B_at, _ = TokenService.generate_token_pair(TokenPayload(sub=str(self.student_9B.public_id), iss="varta.test", role=self.student_9B.user_type))

        self.student_9C = User.objects.create(
            school=self.school,
            first_name="Aarav",
            middle_name="Raj",
            last_name="Sharma",
        )
        StudentDetail.objects.create(
            user=self.student_9C,
            classroom=Classroom.get_by_std_div_or_none("9C"),
        )
        self.stud_9C_at, _ = TokenService.generate_token_pair(TokenPayload(sub=str(self.student_9C.public_id), iss="varta.test", role=self.student_9C.user_type))


    def test_student_can_view_announcements_for_all_students(self):
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.stud_10A_at)
        response = self.client.get(reverse("announcement_list"))

        self.assertEqual(response.status_code, 200) 
        self.assertTrue(self._only_has_these_filters({ AnnouncementScope.FilterType.ALL_STUDENTS, }, response.data["data"]))

    def test_student_can_view_announcements_for_their_standard_and_everyone(self):
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.stud_9B_at)
        response = self.client.get(reverse("announcement_list"))

        self.assertEqual(response.status_code, 200) 
        self.assertTrue(self._only_has_these_filters({ AnnouncementScope.FilterType.ALL_STUDENTS, AnnouncementScope.FilterType.STU_STANDARD }, response.data["data"]))

    def test_student_can_view_announcements_for_their_standard_division_and_standard_and_everyone(self):
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.stud_9C_at)
        response = self.client.get(reverse("announcement_list"))

        self.assertEqual(response.status_code, 200) 
        self.assertTrue(self._only_has_these_filters({ AnnouncementScope.FilterType.ALL_STUDENTS, AnnouncementScope.FilterType.STU_STANDARD, AnnouncementScope.FilterType.STU_STANDARD_DIVISION }, response.data["data"]))