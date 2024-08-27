from rest_framework.test import APITestCase
from django.urls import reverse
from unittest import skip

from django.conf import settings

from common.services.otp import OTPService, redis_inst
from common.services.token import TokenService, TokenPayload

from .models import User, StudentDetail, TeacherDetail, UserContact, Classroom
from schools.models import School

class UserActionTest(APITestCase):
    def setUp(self):
        settings.DEBUG = True

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


        self.assertIsNotNone(redis_inst.get(self.primary_contact_email.contact_data).decode("utf8"))

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

        generated_otp = redis_inst.get(self.primary_contact_email.contact_data).decode("utf8")

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
