from django.core.management.base import BaseCommand, CommandError
from common.services.kv_store import REDIS_INST
from rq import Worker

worker = Worker(["default"], connection=REDIS_INST)

class Command(BaseCommand):
    help = "Start the RQ worker thread within the django context. Equivalent to running `rq worker`"

    def handle(self, *args, **kwargs):
        worker.work()