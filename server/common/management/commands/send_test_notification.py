from django.core.management.base import BaseCommand, CommandError
from common.services.notification_service import send_notification
from announcements.models import Announcement, AnnouncementScope
from accounts.models import User 

import uuid

class Command(BaseCommand):
    help = "Send a test announcement notification to all the registered devices"

    def add_arguments(self, parser):
        parser.add_argument(
            'public_user_id',
            type=str,
            help='The public user ID to include in the announcement.'
        )

    def handle(self, *args, **options):
        public_user_id = options['public_user_id'].strip()
        
        try:
            announcement = Announcement.objects.create(
                author=User.objects.get(public_id=uuid.UUID(str(public_user_id), version=4)),
                title="Planned System Maintenance and New Portal Features Rollout",
                body="In order to ensure a smooth and effective learning experience, the IT department has scheduled an upgrade of the school’s online learning management system, portals, and network infrastructure. The key objectives of this upgrade include\n- Enhancing platform speed and stability: Faster access to academic resources like assignments, lesson plans, and teacher communications.\n- Improving security: Ensuring that sensitive student and staff data remains safe with upgraded encryption and login protocols.  \n- Introducing new features: Including real-time assignment tracking, integrated video conferencing capabilities for virtual classrooms, and a centralized communication portal for students and parents.",
            ).with_scope(AnnouncementScope.FilterType.EVERYONE)

            send_notification(announcement.id)
            self.stdout.write(self.style.SUCCESS('Successfully sent test announcement.'))

        except Exception as e:
            raise CommandError(f'Error sending announcement: {e}')
