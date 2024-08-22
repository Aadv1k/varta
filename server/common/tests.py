from django.test import TestCase

from .services.otp import OTPService, redis_inst

class TestServices(TestCase):
    def setUp(self):
        self.number = "+912084422881"

    def test_otp_service_can_store_otp(self):
        created, otp = OTPService.create_and_store_otp(self.number)
        self.assertTrue(created);
        self.assertEqual(redis_inst.get(self.number).decode("utf8"), otp);


    def test_otp_service_can_verify_otp(self):
        _, otp = OTPService.create_and_store_otp(self.number)
        found, error = OTPService.verify_otp(self.number, "1234")

        self.assertFalse(found)
