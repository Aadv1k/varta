from abc import ABC
from typing import Optional

from django.conf import settings

import redis 

REDIS_INST = redis.Redis( 
    host=settings.REDIS_HOST,
    port=settings.REDIS_PORT,
    password=settings.REDIS_PASSWORD
)

class GenericKVStore(ABC):
    def store(self, key: str, value: str) -> None:
        pass

    def retrieve(self, key: str) -> Optional[str]:
        pass

    def delete(self, key: str) -> None:
        pass

class RedisKVStore(GenericKVStore):
    def store(self, key, value):
        REDIS_INST.set(key, value)

    def retrieve(self, key: str) -> str | None:
        if not (value := REDIS_INST.get(key)):
            return None

        return value.decode("utf-8")
    
    def delete(self, key: str) -> None:
        REDIS_INST.delete(key)
    

def KVStoreFactory() -> GenericKVStore:
    return RedisKVStore()
