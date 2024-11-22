from announcements.models import Announcement
from accounts.models import User, UserDevice, UserContact

from django.conf import settings

import firebase_admin 
from firebase_admin import messaging, credentials

cred = credentials.Certificate(settings.GOOGLE_APPLICATION_CREDENTIALS)
default_app = firebase_admin.initialize_app(cred)

def send_notification(announcement_id: str):
    try:
        announcement = Announcement.objects.get(id=announcement_id)
    except Announcement.DoesNotExist: 
        assert False, f"send_notification('{announcement_id}') announcement does not exist; This means either the announcement was deleted or this is a test environment."

    user_query = User.objects.filter(school__id=announcement.author.school.id)

    for user in user_query:
        if not announcement.for_user(user):
            continue

        for user_device in UserDevice.objects.filter(user=user):
            try:
                notification = messaging.Notification(
                    title=announcement.title, 
                    body=announcement.body,
                    image="https://res.cloudinary.com/dzx48hsih/image/upload/v1729516515/d8yurokidwexm6oxwk7u.png"
                )
                message = messaging.MulticastMessage(
                    notification=notification,
                    tokens=[user_device.device_token],
                    webpush=messaging.WebpushConfig(
                        data={
                            "url": "https://varta.aadvikpandey.com/"
                        },
                        notification=messaging.WebpushNotification(
                            title=announcement.title, 
                            body=announcement.body,
                            icon="https://res.cloudinary.com/dzx48hsih/image/upload/v1729516515/d8yurokidwexm6oxwk7u.png",
                        ),
                        fcm_options=messaging.WebpushFCMOptions(
                        link="https://varta.aadvikpandey.com/",
                    ))
                )
                response = messaging.send_each_for_multicast(message)
            except firebase_admin.messaging.UnregisteredError:
                print("EXPIRED TOKEN. Deleting")
                user_device.delete()

