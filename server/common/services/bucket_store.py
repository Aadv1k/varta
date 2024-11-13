from abc import ABC, abstractmethod

import tempfile
import os

import boto3
from botocore.exceptions import ClientError

from typing import Optional

from django.conf import settings

class GenericBucketStore(ABC):
    @abstractmethod
    def upload(self, file_content: bytes, object_key: str) -> Optional[str]:
        pass

    @abstractmethod
    def get_url(self, object_key: str) -> Optional[str]:
        pass

    @abstractmethod
    def delete(self, object_key: str):
        pass

class S3BucketStore(GenericBucketStore):
    def upload(self, file_content: bytes, object_key: str) -> Optional[str]:
        raise AssertionError("NOT IMPLEMENTED")

    def get_url(self, object_key):
        raise AssertionError("NOT IMPLEMENTED")

    def delete(self, object_key: str):
        raise AssertionError("NOT IMPLEMENTED")

class LocalBucketStore(GenericBucketStore):
    def __init__(self):
        self.temp_dir = tempfile.TemporaryDirectory()

    def upload(self, file_content: bytes, object_key: str) -> str:
        file_path = os.path.join(self.temp_dir.name, object_key.replace("/", "_"))
        with open(file_path, 'wb') as f:
            f.write(file_content)
        return file_path
    
    def get_url(self, object_key):
        return f"https://example.com/{object_key}"
    
    def delete(self, object_key: str):
        file_path = os.path.join(self.temp_dir.name, object_key)
        try:
            os.remove(file_path)
        except FileNotFoundError:
            pass 

def BucketStoreFactory() -> GenericBucketStore:
    if settings.TESTING or settings.DEBUG:
        return LocalBucketStore()
    return S3BucketStore()
