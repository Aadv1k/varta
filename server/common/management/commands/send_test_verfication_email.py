from django.core.management.base import BaseCommand, CommandError
from common.services.notification_service import send_notification
from accounts.models import UserContact
from accounts.models import User 

from common.services.email import send_verification_email

import uuid

class Command(BaseCommand):
    help = "Send a test verification email to all the registered devices. THIS WILL EAT CREDITS"

    def add_arguments(self, parser):
        parser.add_argument(
            'contact_data',
            type=str,
            help='Contact data of type email which can be found within the system'
        )

    def handle(self, *args, **options):
        contact_data = options['contact_data'].strip()
        
        try:
            user_contact = UserContact.objects.get(contact_data=contact_data)
            assert user_contact.contact_type == UserContact.ContactType.EMAIL
            ret = send_verification_email("000000", user_contact.contact_data, user_contact.user)
            self.stdout.write(self.style.SUCCESS(f"Successfully sent test email to {contact_data}: {ret}"))
        except Exception as e:
            raise CommandError(f'Error sending email: {e}')
