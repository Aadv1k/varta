import random
import redis
from django.conf import settings
from typing import Tuple, Optional

from .kv_store import KVStoreFactory

import json

from datetime import datetime, timedelta
import time


class OTPService:
    def __init__(self) -> None:
        self.kv_store = KVStoreFactory()

    @staticmethod
    def generate_otp(length: int) -> str:
        return "".join(random.choice("0123456789") for _ in range(length))

    def create_and_store_otp(self, contact_data: str) -> str:
        generated_otp = OTPService.generate_otp(settings.OTP_LENGTH)
        self.kv_store.store(contact_data, json.dumps([int(time.time()), generated_otp]))
        return generated_otp

    def verify_otp(self, contact_data: str, otp: str) -> bool:
        stored_otp_data = self.kv_store.retrieve(contact_data)
        if stored_otp_data is None:
            return False

        otp_created_at, stored_otp = json.loads(stored_otp_data)
        
        if datetime.fromtimestamp(otp_created_at) + timedelta(seconds=settings.OTP_EXPIRY_IN_SECONDS) <= datetime.now():
            self.kv_store.delete(contact_data)
            return False
        
        if stored_otp != otp:
            return False

        self.kv_store.delete(contact_data)
        return True