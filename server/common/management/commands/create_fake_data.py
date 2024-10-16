from django.core.management.base import BaseCommand, CommandError

from announcements.models import Announcement, AnnouncementScope
from accounts.models import User
from schools.models import AcademicYear


txt = """ Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec enim lorem, aliquet in finibus at, rutrum in leo. Donec nulla nibh, accumsan ut tincidunt ac, cursus nec felis. Donec lobortis lacus vel massa feugiat consectetur. Aenean accumsan leo convallis, egestas nunc nec, pretium lorem. Pellentesque libero magna, luctus eget consequat a, pretium sit amet quam. In ante lectus, porttitor quis interdum ut, tempus eu nibh. Suspendisse sed mauris sem. Nulla in pulvinar metus. Curabitur ac purus in augue maximus euismod. Duis venenatis arcu eu velit dictum faucibus. Praesent porttitor varius purus, non cursus nunc finibus ut.

Morbi elementum non mauris lacinia mattis. Duis varius porta mattis. Sed gravida tellus tellus, vitae venenatis ipsum aliquam in. Duis sagittis massa est. Ut a ipsum mauris. Nullam suscipit massa magna, id mollis neque pulvinar vel. Mauris in erat ut odio semper sodales in eget mi. Nam a nulla porttitor nibh dignissim suscipit."""



class Command(BaseCommand):
    help = "Create a ton of fake data"

    def add_arguments(self, parser):
        parser.add_argument("user_id", type=str, help="The user under which the data will be created ")

    def handle(self, *args, **options):
        for i in range(100):
            Announcement.objects.create(
                    author=User.objects.get(public_id=options["user_id"]),
                    title=f"{i} Test Announcement: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia sapien vel venenatis vulputate.",
                    body=txt,
                    academic_year=AcademicYear.get_current_academic_year()
            ).with_scope(AnnouncementScope.FilterType.EVERYONE)
            
        self.stdout.write(self.style.SUCCESS(f"DONE."))
