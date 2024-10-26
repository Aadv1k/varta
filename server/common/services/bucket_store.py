from abc import ABC
import tempfile
import os

from typing import Optional

from django.conf import settings

class GenericBucketStore(ABC):
    def upload(self, file_name: str, file_content: bytes) -> Optional[str]:
        pass

    def delete(self, id: str):
        pass

class S3BucketStore(GenericBucketStore):
    def upload(self, file_name: str, file_content: bytes):
        pass

class LocalBucketStore(GenericBucketStore):
    def __init__(self):
        self.temp_dir = tempfile.TemporaryDirectory()

    def upload(self, file_name: str, file_content: bytes) -> str:
        file_path = os.path.join(self.temp_dir.name, file_name)
        with open(file_path, 'wb') as f:
            f.write(file_content)
        return file_path

def BucketStoreFactory() -> GenericBucketStore:
    if settings.TESTING:
        return LocalBucketStore()
    return S3BucketStore()