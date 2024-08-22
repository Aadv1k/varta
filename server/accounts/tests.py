from rest_framework.test import APITestCase
from django.urls import reverse
from unittest import skip


from .models import Student, UserContact, Classroom
from schools.models import School

class UserActionTest(APITestCase):
    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.student = Student.objects.create(
            school=self.school,
            first_name="Aarav",
            middle_name="Raj",
            last_name="Sharma",
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

        self.assertEqual(response.status_code, 200)
        self.assertIsNotNone(response.data.get("data"))


    def test_user_can_login_with_phone(self):
        response = self.client.post(reverse("user_login"), {
            "school_id": self.school.id,
            "input_format": "phone_number",
            "input_data": "+919876543210",
        }, format="json")

        self.assertEqual(response.status_code, 200)
        self.assertIsNotNone(response.data.get("data"))


    def user_can_verify_self_with_otp_(self):
        self.skipTest("not implemented")

    def user_can_renew_access_token(self):
        self.skipTest("not implemented")

    def user_can_request_their_details(self):
        self.skipTest("not implemented")
