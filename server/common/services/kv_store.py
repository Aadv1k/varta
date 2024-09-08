from abc import ABC
from typing import Optional

import redis 

REDIS_INST = redis.Redis()

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
        return (REDIS_INST.get(key) or "").decode("utf8")
    
    def delete(self, key: str) -> None:
        REDIS_INST.delete(key)
    

def KVStoreFactory() -> GenericKVStore:
    return RedisKVStore()