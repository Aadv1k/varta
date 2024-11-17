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
    def __init__(self):
        self.client = boto3.client("s3")
        self.s3_bucket = "varta-bucket"

    def upload(self, file_content: bytes, object_key: str) -> Optional[str]:
        try:
            self.client.put_object(
                    Bucket=self.s3_bucket,
                    Key=object_key,
                    Body=file_content
            )
            object_url = f"https://{self.s3_bucket}.s3.amazonaws.com/{object_key}"
            return object_url
        except Exception as e: 
            print(f"Something went wrong while uploading file to S3: {e}")
            return None


    def get_url(self, object_key) -> str:
        return self.client.generate_presigned_url(
            'get_object',
            Params={'Bucket': self.s3_bucket, 'Key': object_key},
            ExpiresIn=3600
        )
        
    def delete(self, object_key: str):
        self.client.delete_object(Bucket=self.s3_bucket, Key=object_key)

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
