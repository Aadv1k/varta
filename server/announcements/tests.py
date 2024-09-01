from rest_framework.test import APITestCase
from django.urls import reverse
from common.services.token import TokenService, TokenPayload
from typing import Tuple, List
from schools.models import School, AcademicYear
from accounts.models import User, Classroom, StudentDetail, TeacherDetail, Department
from .models import Announcement, AnnouncementScope
import math

class BaseAnnouncementTestCase(APITestCase):
    @staticmethod
    def create_student_and_token(school, std_div) -> Tuple[User, str]:
        user = User.objects.create(
            school=school,
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

    @staticmethod
    def create_teacher_and_token(school, departments: List[str], subject_teacher_of: List[str] = [], class_teacher_of: List[str] = None):
        user = User.objects.create(
            school=school,
            first_name="Li",
            middle_name="G.",
            last_name="Ma",
            user_type=User.UserType.TEACHER
        )
        details = TeacherDetail.objects.create(
            user=user,
            class_teacher_of=class_teacher_of and Classroom.get_by_std_div_or_none(class_teacher_of),
        )

        for std_div in subject_teacher_of:
            details.subject_teacher_of.add(Classroom.get_by_std_div_or_none(std_div))

        for dept in departments:
            details.departments.add(Department.objects.get(department_name=dept))

        token, _ = TokenService.generate_token_pair(TokenPayload(sub=str(user.public_id), iss="varta.test", role=user.user_type))

        return user, token

    def _assertVisibleTo(self, users: List[Tuple[User, str]], ann_id: str, mine:bool=False):
        for (user, token) in users:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list")) if not mine else self.client.get(reverse("my_announcement_list"))
            self.assertIn(str(ann_id), [x["id"] for x in response.data["data"]])

    def _assertNotVisibleTo(self, users: List[Tuple[User, str]], ann_id: str, mine:bool=False):
        for (user, token) in users:
            self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
            response = self.client.get(reverse("announcement_list")) if not mine else self.client.get(reverse("my_announcement_list"))
            self.assertNotIn(str(ann_id), [x["id"] for x in response.data["data"]])

class StudentAnnouncementTestCase(BaseAnnouncementTestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def tearDown(self):
        Announcement.objects.all().delete()

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

        self.student_9A = self.create_student_and_token(self.school, "9A")
        self.student_9B = self.create_student_and_token(self.school, "9B")
        self.student_9C = self.create_student_and_token(self.school, "9C")

        self.student_8A = self.create_student_and_token(self.school, "8A")
        self.student_8B = self.create_student_and_token(self.school, "8B")

    def test_student_can_view_announcements_for_their_standard_and_everyone(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ).with_scope(AnnouncementScope.FilterType.ALL_STUDENTS)

        self._assertVisibleTo([self.student_8A, self.student_9A, self.student_9B], str(cur_ann.id))

    def test_student_of_particular_standard_can_view_announcements(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ).with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="9")

        self._assertVisibleTo([self.student_9A, self.student_9B, self.student_9C], str(cur_ann.id))
        self._assertNotVisibleTo([self.student_8A, self.student_8B], str(cur_ann.id))

    def test_students_of_particular_standard_and_division_can_view_announcements(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ).with_scope(AnnouncementScope.FilterType.STU_STANDARD_DIVISION, filter_data="9B")

        self._assertNotVisibleTo([self.student_8A, self.student_8B, self.student_9A, self.student_9C], str(cur_ann.id))
        self._assertVisibleTo([self.student_9B], str(cur_ann.id))

    def test_announcements_with_multiple_standards_scope(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="9") \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="8")

        self._assertVisibleTo([self.student_8A, self.student_8B, self.student_9A, self.student_9B, self.student_9C], str(cur_ann.id))

    def test_announcements_with_multiple_standards_and_divisions(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD, filter_data="8") \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD_DIVISION, filter_data="9A") \
        .with_scope(AnnouncementScope.FilterType.STU_STANDARD_DIVISION, filter_data="9B")

        self._assertVisibleTo([self.student_8A, self.student_8B, self.student_9A, self.student_9B], str(cur_ann.id))
        self._assertNotVisibleTo([self.student_9C], str(cur_ann.id))

    def test_students_cannot_view_announcements_for_teachers(self):
        cur_ann = Announcement.objects.create(
            author=self.teacher, title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.ALL_TEACHERS, filter_data="9")

        self._assertNotVisibleTo([self.student_8A, self.student_8B, self.student_9A, self.student_9B, self.student_9C], str(cur_ann.id))


class TeacherAnnouncementTestCase(BaseAnnouncementTestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def tearDown(self):
        Announcement.objects.all().delete()

    def setUp(self):
        self.tearDown()

        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.english_class_teacher_12th = self.create_teacher_and_token(self.school, ["english"], subject_teacher_of=["12A", "12B", "12C", "12D"], class_teacher_of="12D")
        self.math_class_teacher_12th = self.create_teacher_and_token(self.school, ["mathematics"], subject_teacher_of=["12B", "12C", "12D"], class_teacher_of="12A")
        self.english_subject_teacher_12th_2nd = self.create_teacher_and_token(self.school, ["english"], subject_teacher_of=["12B", "12C", "12D"])

        self.geography_class_teacher_10th = self.create_teacher_and_token(self.school, ["geography"], subject_teacher_of=["12D", "10A", "10B", "10C", "10D"], class_teacher_of="10C")

        self.mathematics_subject_teacher_10th = self.create_teacher_and_token(self.school, ["mathematics"], subject_teacher_of=["10A", "10B"])
        self.mathematics_subject_teacher_10th_2nd = self.create_teacher_and_token(self.school, ["mathematics"], subject_teacher_of=["10A", "10C"])

        self.primary_english_class_teacher_4th = self.create_teacher_and_token(self.school, ["english"], subject_teacher_of=["4A", "4B", "4C"], class_teacher_of="4A")

        self.admin = self.create_teacher_and_token(self.school, ["administration"])

    def test_announcements_for_all_teachers(self):
        cur_ann = Announcement.objects.create(
            author=self.admin[0], title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.ALL_TEACHERS)

        self._assertVisibleTo([self.english_class_teacher_12th, self.math_class_teacher_12th, self.geography_class_teacher_10th], str(cur_ann.id))

    def test_announcements_for_subject_teachers_of_particular_standard_division(self):
        cur_ann = Announcement.objects.create(
            author=self.admin[0], title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION, "12A") \
        .with_scope(AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD_DIVISION, "12D")

        self._assertVisibleTo([self.english_class_teacher_12th, self.math_class_teacher_12th], str(cur_ann.id))
        self._assertNotVisibleTo([self.primary_english_class_teacher_4th], str(cur_ann.id))

    def test_announcements_for_subject_teachers_of_particular_standard_and_department(self):
        cur_ann = Announcement.objects.create(
            author=self.admin[0], title="Test", body="Test", academic_year=AcademicYear.get_current_academic_year()
        ) \
        .with_scope(AnnouncementScope.FilterType.T_SUBJECT_TEACHER_OF_STANDARD, "9") \
        .with_scope(AnnouncementScope.FilterType.T_DEPARTMENT, "mathematics")

        self._assertVisibleTo([self.mathematics_subject_teacher_10th, self.mathematics_subject_teacher_10th_2nd], str(cur_ann.id))
        self._assertNotVisibleTo([self.english_class_teacher_12th, self.primary_english_class_teacher_4th], str(cur_ann.id))

class MyAnnouncementsTestCase(BaseAnnouncementTestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def tearDown(self):
        Announcement.objects.all().delete()

    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.teacher_mathematics_9th = BaseAnnouncementTestCase.create_teacher_and_token(self.school, ["mathematics"], ["9A", "9B"], class_teacher_of=None)
        self.teacher_class_english_12th = BaseAnnouncementTestCase.create_teacher_and_token(self.school, ["english"], ["12A", "12B", "12C", "12D"], class_teacher_of="12D")
        self.student_12D = BaseAnnouncementTestCase.create_student_and_token(self.school, "12D")

        
    def test_student_cannot_access_my_announcements_endpoint(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.student_12D[1]}")
        response = self.client.get(reverse("my_announcement_list"))

        self.assertEqual(response.status_code, 403)

    def test_teacher_can_view_announcements_by_them(self):
        ann = Announcement.objects.create(author=self.teacher_mathematics_9th[0], title="Test", academic_year=AcademicYear.get_current_academic_year())\
            .with_scope(AnnouncementScope.FilterType.EVERYONE)

        self._assertVisibleTo([self.teacher_mathematics_9th], str(ann.id), mine=True)
        self._assertNotVisibleTo([self.teacher_class_english_12th], str(ann.id), mine=True)
        
    def test_announcements_authored_by_teacher_is_not_present_when_requesting_all_announcements(self):
        ann_by_9th_math_teacher = Announcement.objects.create(author=self.teacher_mathematics_9th[0], title="Test", academic_year=AcademicYear.get_current_academic_year())\
            .with_scope(AnnouncementScope.FilterType.EVERYONE)
        ann_by_12th_english_teacher = Announcement.objects.create(author=self.teacher_class_english_12th[0], title="Test", academic_year=AcademicYear.get_current_academic_year())\
            .with_scope(AnnouncementScope.FilterType.EVERYONE)

        self._assertNotVisibleTo([self.teacher_mathematics_9th], str(ann_by_9th_math_teacher.id))
        self._assertVisibleTo([self.teacher_mathematics_9th], str(ann_by_12th_english_teacher.id))

class PaginatedAnnouncementsTestCase(BaseAnnouncementTestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.teacher_mathematics_9th = BaseAnnouncementTestCase.create_teacher_and_token(self.school, ["mathematics"], ["9A", "9B"], class_teacher_of=None)
        self.teacher_class_english_12th = BaseAnnouncementTestCase.create_teacher_and_token(self.school, ["english"], ["12A", "12B", "12C", "12D"], class_teacher_of="12D")
        self.student_12D = BaseAnnouncementTestCase.create_student_and_token(self.school, "12D")

        self.total_announcement = 50
        self.announcements = [
            Announcement.objects.create(author=self.teacher_mathematics_9th[0], title=f"Announcement {i}", academic_year=AcademicYear.get_current_academic_year())\
                .with_scope(AnnouncementScope.FilterType.EVERYONE)
            for i in range(self.total_announcement)
        ]

    def test_announcements_are_paginated_correctly(self):
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.student_12D[1])
        response = self.client.get(reverse("announcement_list"))

        self.assertEqual(response.data["metadata"].get("page_number"), 1)
        self.assertEqual(response.data["metadata"].get("page_length"), 20)
        self.assertEqual(response.data["metadata"].get("total_pages"), math.ceil(self.total_announcement / 20))
        
        self.assertIn(str(self.announcements[-1].id), [item["id"] for item in response.data["data"]])
        self.assertNotIn(str(self.announcements[20].id), [item["id"] for item in response.data["data"]])

    def test_announcements_pagination_query_params(self):
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + self.student_12D[1])
        response = self.client.get(f"{reverse('announcement_list')}?per_page=10")

        self.assertEqual(response.data["metadata"].get("page_length"), 10)
        self.assertEqual(response.data["metadata"].get("total_pages"), math.ceil(self.total_announcement / 10))