from announcements.models import Announcement
from accounts.models import User, UserDevice, UserContact

def send_notification(announcement_id: str):
    try:
        announcement = Announcement.objects.get(id=announcement_id)
    except Announcement.DoesNotExist: 
        assert False, f"send_notification('{announcement_id}') announcement does not exist; This means either the announcement was deleted or this is a test environment."
        
    user_query = User.objects.filter(school__id=announcement.author.school.id)

    for user in user_query.values():
        if not announcement.for_user(user):
            continue

        for user_device in user.devices:
            if user_device.device_type in { UserDevice.DeviceType.ANDROID, UserDevice.DeviceType.IOS }:
                user_device.device_token
                assert False, "Native notifications aren't implemented"
            else:
                assert False, "Web notifications aren't implemented"