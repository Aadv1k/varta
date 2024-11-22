from django.core.management.base import BaseCommand, CommandError
from common.services.notification_service import send_notification
from announcements.models import Announcement, AnnouncementScope
from accounts.models import User 

import uuid

import firebase_admin 

from firebase_admin import messaging, credentials

from django.conf import settings 

cred = credentials.Certificate(settings.GOOGLE_APPLICATION_CREDENTIALS)

class Command(BaseCommand):
    help = "Send a test announcement notification to a particular device token"

    def add_arguments(self, parser):
        parser.add_argument(
            'device_token',
            type=str,
            help='The device token of a user.'
        )

    def handle(self, *args, **options):
        device_token = options['device_token'].strip()
        
        try:
            notification = messaging.Notification(
                title="This is a maintainence systems test. Please ignore", 
                body="You can ignore this notification. It is part of a routine maintainence test of Varta.",
                image="https://res.cloudinary.com/dzx48hsih/image/upload/v1729516515/d8yurokidwexm6oxwk7u.png"
            )
            message = messaging.Message(
                notification=notification,
                token=device_token
            )
            response = messaging.send(message)
            self.stdout.write(self.style.SUCCESS('Successfully sent sample notification.'))
        except Exception as e:
            raise CommandError(f'Error sending announcement: {e}')
