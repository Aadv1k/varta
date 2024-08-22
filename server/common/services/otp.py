import random
import redis
from django.conf import settings
from typing import Tuple, Optional

redis_inst = redis.Redis()

class OTPService:
    @staticmethod
    def generate_otp(length: int) -> str:
        return "".join(random.choice("0123456789") for _ in range(length))

    @staticmethod
    def create_and_store_otp(contact_data: str) -> Tuple[bool, Optional[str]]:
        generated_otp = OTPService.generate_otp(settings.OTP_LENGTH)

        try:
            redis_inst.setex(contact_data, settings.OTP_EXPIRY_IN_SECONDS, generated_otp)
            return True, generated_otp
        except Exception as e:
            return False, str(e)

    @staticmethod
    def verify_otp(contact_data: str, otp: str) -> Tuple[bool, Optional[str]]:
        try:
            stored_otp = redis_inst.get(contact_data)
            if stored_otp is None:
                return False, "OTP does not exist or has expired."
            if stored_otp.decode() == otp:
                redis_inst.delete(contact_data)
                return True, None
            else:
                return False, "Invalid OTP."
        except Exception as e:
            return False, str(e)
