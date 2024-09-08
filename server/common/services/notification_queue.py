from abc import ABC, abstractmethod

from .kv_store import REDIS_INST

from rq import Queue

RQ_INST = Queue(connection=REDIS_INST)

from typing import Callable, NamedTuple, Any
    
class GenericNotificationQueue(ABC):
    def __init__(self, queue_processor: Callable[[Any], None]) -> None:
        """
        Initializes the notification queue with a processor function.
        
        :param queue_processor: A callable that processes the enqueued payload.
        """
        self.queue_processor = queue_processor

    @abstractmethod
    def enqueue(self, payload: Any) -> None:
        """
        Enqueues the given payload into the notification queue.
        
        :param payload: The data to be processed by the queue processor.
        """
        pass

class RqNotificationQueue(GenericNotificationQueue):
    def enqueue(self, payload: Any) -> None:
        """
        Enqueues the given payload into the Redis queue using rq.
        
        :param payload: The data to be processed by the queue processor.
        """
        RQ_INST.enqueue(self.queue_processor, payload)

def NotificationQueueFactory(callback: Callable[[Any], None]) -> GenericNotificationQueue:
    """
    Factory function to create a notification queue with the given callback.
    
    :param callback: A callable function that will process the enqueued payload.
    :return: An instance of GenericNotificationQueue (specifically RqNotificationStore).
    """
    return RqNotificationQueue(callback)