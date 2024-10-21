from announcements.models import Announcement
from accounts.models import User, UserDevice, UserContact

from firebase_admin import messaging

from django.conf import settings

def send_notification(announcement_id: str):
    try:
        announcement = Announcement.objects.get(id=announcement_id)
    except Announcement.DoesNotExist: 
        print(f"send_notification('{announcement_id}') announcement does not exist; This means either the announcement was deleted or this is a test environment.")
        
    user_query = User.objects.filter(school__id=announcement.author.school.id)

    for user in user_query.values():
        if not announcement.for_user(user):
            continue

        for user_device in user.devices:
            if user_device.is_expired:
                user_device.delete()
                continue

            message = messaging.Message(
                    data={
                        "title": announcement.title,
                        "body": announcement.body if len(announcement.body) >= 50 else announcement.body[:50],
                    },
                token=user_device.device_token
            )

            try:
                messaging.send(message)
            except Exception as exc:
                print(f"FAILED to send notification to {user_device} due to {str(exc)}")
                pass
