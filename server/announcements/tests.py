from rest_framework.test import APITestCase

from django.urls import reverse


import json
from common.services.token import TokenService, TokenPayload
from typing import Tuple, List


from schools.models import School, AcademicYear
from accounts.models import User, Classroom, StudentDetail, TeacherDetail
from .models import Announcement, AnnouncementScope

class StudentAnnouncementTestCase(APITestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def tearDown(self):
        Announcement.objects.all().delete()

    def create_student_and_token(self, std_div):
        user = User.objects.create(
            school=self.school,
            first_name="Foo",
            middle_name="Bar",
            last_name="Baz",
        )
        StudentDetail.objects.create(
            user=user,
            classroom=Classroom.get_by_std_div_or_none(std_div),
        )
        token, _ = TokenService.generate_token_pair(TokenPayload(sub=str(user.public_id), iss="varta.test", role=user.user_type))
        
        return user, token

    def setUp(self):
        self.tearDown()

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

        self.student_9A = self.create_student_and_token("9A")
        self.student_9B = self.create_student_and_token("9B")
        self.student_9C = self.create_student_and_token("9C")

        self.student_8A = self.create_student_and_token("8A")
        self.student_8B = self.create_student_and_token("8B")


    def test_student_can_view_announcements_for_their_standard_and_everyone(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ).with_scope(AnnouncementScope.FilterType.ALL_STUDENTS)


        for (student, token) in [self.student_8A, self.student_9A, self.student_9B]:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list"))

            self.assertTrue(str(cur_ann.id) in [ann["id"] for ann in response.data["data"]])
        
      
    def test_student_of_particular_standard_can_view_announcements(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ).with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="9")

        for (student, token) in [self.student_9A, self.student_9B, self.student_9C]:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list"))

            self.assertTrue(str(cur_ann.id) in [ann["id"] for ann in response.data["data"]])

        for (student, token) in [self.student_8A, self.student_8B]:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list"))
            self.assertEqual(len(response.data["data"]), 0)

    def test_students_of_particular_standard_and_division_can_view_announcements(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ).with_scope(AnnouncementScope.FilterType.STU_STANDARD_DIVISION, filter_data="9B")

        for (student, token) in [self.student_8A, self.student_8B, self.student_9A, self.student_9C]:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list"))
            self.assertEqual(len(response.data["data"]), 0)

        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.student_9B[1])
        response = self.client.get(reverse("announcement_list"))

        self.assertTrue(str(cur_ann.id) in [ann["id"] for ann in response.data["data"]])

    def test_announcements_with_multiple_standard_scope(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="9") \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="8")

        for (student, token) in [self.student_8A, self.student_8B, self.student_9A, self.student_9C, self.student_9B]:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list"))

            self.assertTrue(str(cur_ann.id) in [ann["id"] for ann in response.data["data"]])
    
    def test_students_cannot_view_announcements_for_teachers(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.ALL_TEACHERS, filter_data="9")

        for (student, token) in [self.student_8A, self.student_8B, self.student_9A, self.student_9C, self.student_9B]:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list"))

            self.assertEqual(len(response.data["data"]), 0)