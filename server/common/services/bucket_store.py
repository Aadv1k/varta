from abc import ABC, abstractmethod

import tempfile
import os

from typing import Optional

from django.conf import settings

class GenericBucketStore(ABC):
    @abstractmethod
    def upload(self, file_content: bytes, object_key: str) -> Optional[str]:
        pass

    @abstractmethod
    def delete(self, object_key: str):
        pass

class S3BucketStore(GenericBucketStore):
    def upload(self, file_content: bytes, object_key: str) -> Optional[str]:
        pass 

    def delete(self, object_key: str):
        pass

class LocalBucketStore(GenericBucketStore):
    def __init__(self):
        self.temp_dir = tempfile.TemporaryDirectory()

    def upload(self, file_content: bytes, object_key: str) -> str:
        file_path = os.path.join(self.temp_dir.name, object_key)
        with open(file_path, 'wb') as f:
            f.write(file_content)
        return file_path

    def delete(self, object_key: str):
        file_path = os.path.join(self.temp_dir.name, object_key)
        try:
            os.remove(file_path)
        except FileNotFoundError:
            pass 

def BucketStoreFactory() -> GenericBucketStore:
    if settings.TESTING:
        return LocalBucketStore()
    return S3BucketStore()
