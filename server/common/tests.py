from django.test import TestCase

from .services.otp import OTPService
from .services.kv_store import KVStoreFactory

class TestOTPService(TestCase):
    def setUp(self):
        self.number = "+912084422881"
        self.otp_service = OTPService() 
        self.kv_store = KVStoreFactory()

    def test_otp_service_can_store_otp(self):
        self.otp_service.create_and_store_otp(self.number)
        self.assertIsNotNone(self.kv_store.retrieve(self.number));


    def test_otp_service_can_verify_otp(self):
        self.otp_service.create_and_store_otp(self.number)
        found = self.otp_service.verify_otp(self.number, "1234")

        self.assertFalse(found)
