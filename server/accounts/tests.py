from rest_framework.test import APITestCase
from django.urls import reverse
from unittest import skip
import json

from django.conf import settings

from common.services.otp import OTPService
from common.services.kv_store import KVStoreFactory
from common.services.token import TokenService, TokenPayload

from .models import User, StudentDetail, TeacherDetail, UserContact, Classroom
from schools.models import School

from announcements.tests import BaseAnnouncementTestCase

class UserActionTest(APITestCase):
    def setUp(self):
        self.kv_store = KVStoreFactory()
        self.otp_service = OTPService()

        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.student = User.objects.create(
            school=self.school,
            first_name="Aarav",
            middle_name="Raj",
            last_name="Sharma",
        )

        StudentDetail.objects.create(
            user=self.student,
            classroom=Classroom.get_by_std_div_or_none("9A"),
        )

        self.primary_contact_email = UserContact.objects.create(
            user=self.student,
            contact_importance=UserContact.ContactImportance.PRIMARY,
            contact_type=UserContact.ContactType.EMAIL,
            contact_data="aarav.sharma@example.com"
        )

        UserContact.objects.create(
            user=self.student,
            contact_importance=UserContact.ContactImportance.SECONDARY,
            contact_type=UserContact.ContactType.PHONE_NUMBER,
            contact_data="+919876543210"
        )

        UserContact.objects.create(
            user=self.student,
            contact_importance=UserContact.ContactImportance.PRIMARY,
            contact_type=UserContact.ContactType.PHONE_NUMBER,
            contact_data="+919123456789"
        )

    def test_user_cannot_login_with_invalid_school_id(self):
        response = self.client.post(reverse("user_login"), {
            "school_id": 12,
            "input_format": "email",
            "input_data": "aadv1k.foo",
        }, format="json")

        self.assertTrue(any(error['field'] == 'school_id' for error in response.data.get("errors")))

    def test_user_cant_login_with_non_existent_email(self):
        response = self.client.post(reverse("user_login"), {
            "school_id": self.school.id,
            "input_format": "email",
            "input_data": "foo@bar.com",
        }, format="json")

        self.assertTrue(any(error['field'] == 'input_data' for error in response.data.get("errors")))

    def test_user_can_login_with_email(self):
        response = self.client.post(reverse("user_login"), {
            "school_id": self.school.id,
            "input_format": "email",
            "input_data": self.primary_contact_email.contact_data,
        }, format="json")


        self.assertIsNotNone(self.kv_store.retrieve(self.primary_contact_email.contact_data))

        self.assertEqual(response.status_code, 200)
        self.assertIsNotNone(response.data.get("data"))

    def test_user_cannot_verify_self_with_bad_otp(self):
        self.client.post(reverse("user_login"), {
            "school_id": self.school.id,
            "input_format": "email",
            "input_data": self.primary_contact_email.contact_data,
        }, format="json")

        response = self.client.post(reverse("user_verify"), {
            "school_id": self.school.id,
            "input_data": self.primary_contact_email.contact_data,
            "otp": "123456"
        }, format="json")


        self.assertEqual(response.status_code, 400)

    def test_user_can_verify_self_with_otp(self):
        self.client.post(reverse("user_login"), {
            "school_id": self.school.id,
            "input_format": "email",
            "input_data": self.primary_contact_email.contact_data,
        }, format="json")

        stored_data = self.kv_store.retrieve(self.primary_contact_email.contact_data)
        created_at, generated_otp = json.loads(stored_data)

        response = self.client.post(reverse("user_verify"), {
            "school_id": self.school.id,
            "input_data": self.primary_contact_email.contact_data,
            "otp": generated_otp
        }, format="json")

        self.assertEqual(response.status_code, 200)

        data = response.json()

        self.assertIn("access_token", data["data"])
        self.assertIn("refresh_token", data["data"])

    def test_user_cannot_refresh_with_bad_token(self):
        response = self.client.post(reverse("user_refresh"), {
            # Malacious token whose payload has been modified
            "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3MjQ1NjkyNjAsImV4cCI6MTcyNTE3NDA2MCwiaXNzIjoidmFydGEuYXBwIiwic3ViIjoiZWE0Yzc4Y2ItYWU0MS00ZmIzLTgwNjgtNjhhMTlhNmRiMDA0Iiwicm9sZSI6InRlYWNoZXIifQ.E0zM1vC_F7WPmmauhFD1J1s1pD-Ves4tMH-SKa8c0gY"
        }, format="json")

        self.assertEqual(response.status_code, 400)

    def test_user_can_refresh_with_good_token(self):
        at, rt = TokenService.generate_token_pair(TokenPayload(sub=str(self.student.public_id), role=self.student.user_type, iss="varta.app"))

        response = self.client.post(reverse("user_refresh"), {
            "refresh_token": rt
        }, format="json")

        self.assertEqual(response.status_code, 200)
        self.assertIn("access_token", response.data["data"])

    def test_user_can_register_device(self):
        at, _ = TokenService.generate_token_pair(TokenPayload(sub=str(self.student.public_id), role=self.student.user_type, iss="varta.app"))
            

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {at}")
        response = self.client.post(reverse("user_device"), {
            "logged_in_through": self.student.contacts.filter(contact_type="phone_number").first().contact_data,
            "device_token": "some-random-token-that-cannot-be-validated",
            "device_type": "web",
        }, format="json")

        self.assertEqual(response.status_code, 204)
        

    def test_user_cannot_register_device_with_invalid_login_details(self):
        at, _ = TokenService.generate_token_pair(TokenPayload(sub=str(self.student.public_id), role=self.student.user_type, iss="varta.app"))
        response = self.client.post(reverse("user_device"), { }, format="json")

        self.assertEqual(response.status_code, 403)

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {at}")
        response = self.client.post(reverse("user_device"), {
            "logged_in_through": "invalid-non-existent-contact",
            "device_token": "some-random-token-that-cannot-be-validated",
            "device_type": "web",
        }, format="json")

        self.assertEqual(response.status_code, 400)
        self.assertIn("logged_in_through", map(lambda x: x["field"], response.data["errors"]))

class UserSelfActionTestCase(BaseAnnouncementTestCase):
    fixtures = ["initial_classrooms.json", "initial_departments.json"]
    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.student = self.create_student_and_token(
            school=self.school,
            std_div="12D"
        )

    def test_student_can_fetch_their_own_details_correctly(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.student[1]}") 

        response = self.client.get(reverse("user_details"))

        self.assertEqual(response.status_code, 200)

        self.assertIn("first_name", response.data["data"])
        self.assertIn("last_name", response.data["data"])
        self.assertIn("details", response.data["data"])
        self.assertIn("contacts", response.data["data"])


    def test_teacher_can_fetch_their_own_details_correctly(self):
        pass