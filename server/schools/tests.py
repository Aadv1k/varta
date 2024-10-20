from django.test import TestCase
from rest_framework.test import APITestCase

from django.urls import reverse
from django.core.exceptions import ValidationError

from .models import School

class SchoolModelTests(TestCase):
    def test_invalid_phone_number_field(self):
        with self.assertRaises(ValidationError):
            School(phone_number="1234").full_clean()

        with self.assertRaises(ValidationError):
            School(phone_number="+1234").full_clean()

    def test_valid_entry(self):
        valid_number = "+918555059793"
        try:
            School(
                phone_number=valid_number,
                address = "42 Baker Street, London",
                name = "John Wilkes Public School",
                email = "foo@bar.com"
            ).full_clean()
        except:
            self.fail("Failed")

class SchoolListTest(APITestCase):
    def setUp(self):
        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

    def test_user_can_fetch_the_list_of_schools(self):
        response = self.client.get(reverse("school_list"))
        
        self.assertEqual(response.data["metadata"]["total_schools"], 1)


