from django.test import TestCase

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
