from django.core.management.base import BaseCommand, CommandError
from common.services.email import send_verification_email

class Command(BaseCommand):
    help = "Send a test verification email to the specified address. WARNING: This will consume email credits."

    def add_arguments(self, parser):
        parser.add_argument("email", type=str, help="The email address to send the test verification email to")

    def handle(self, *args, **options):
        email = options['email']
        subject = "Test Verification Email"
        html_message = "<h1>This is a test verification email</h1><p>If you received this, the email service is working correctly.</p>"

        self.stdout.write(self.style.WARNING(f"Sending test email to {email}..."))

        success, message = send_verification_email(email, subject, html_message)

        if success:
            self.stdout.write(self.style.SUCCESS(f"Successfully sent test email to {email}"))
            self.stdout.write(self.style.SUCCESS(message))
        else:
            self.stdout.write(self.style.ERROR(f"Failed to send test email to {email}"))
            self.stdout.write(self.style.ERROR(f"Error: {message}"))
