from announcements.models import Announcement
from accounts.models import User, UserDevice, UserContact

import firebase_admin 
from firebase_admin import messaging, credentials

cred = credentials.Certificate('./firebase-admin.json')
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
            notification = messaging.Notification(
                title=announcement.title, 
                body=announcement.body,
                image="https://res.cloudinary.com/dzx48hsih/image/upload/v1729516515/d8yurokidwexm6oxwk7u.png"
            )
            message = messaging.Message(
                notification=notification,
                token=user_device.device_token
            )
            response = messaging.send(message)
