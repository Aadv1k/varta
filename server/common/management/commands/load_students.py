from django.core.management.base import BaseCommand, CommandError
from schools.models import School
from accounts.models import User, StudentDetail, Classroom, UserContact
import json

class Command(BaseCommand):
    help = "Load and populate student data from JSON"

    def add_arguments(self, parser):
        parser.add_argument("school_id", type=str, help="The school to which the students belong")
        parser.add_argument("filepath", type=str, help="The file with the JSON data")

    def handle(self, *args, **options):
        filepath = options['filepath']

        User.objects.filter(user_type=User.UserType.STUDENT).delete()

        try:
            school = School.objects.get(id=options["school_id"])
        except School.DoesNotExist:
            raise CommandError(f"School with ID {options['school_id']} does not exist.")

        try:
            with open(filepath, "r") as file:
                students_data = json.load(file)
        except FileNotFoundError:
            raise CommandError(f"The file at {filepath} does not exist.")
        except json.JSONDecodeError:
            raise CommandError("Error decoding JSON data.")

        for data in students_data:
            self.stdout.write(f"Processing {data["first_name"]} {data.get("last_name") or data.get("middle_name")}")

            user = User.objects.create(
                school=school,
                first_name=data.get("first_name", ""),
                middle_name=data.get("middle_name"),
                last_name=data.get("last_name") or "", 
                user_type=User.UserType.STUDENT
            )

            classroom = None
            if data.get("classroom"):
                classroom = Classroom.get_by_std_div_or_none(data["classroom"])
            
            details = StudentDetail.objects.create(
                user=user,
                classroom=classroom
            )

            if contacts := data.get("contacts"):
                for contact in contacts:
                    UserContact.objects.create(
                        user=user,
                        contact_importance=UserContact.ContactImportance.PRIMARY,
                        contact_type=UserContact.ContactType.EMAIL if contact["input_type"] == "email" else UserContact.ContactType.PHONE_NUMBER,
                        contact_data=contact["contact_data"]
                    )

            self.stdout.write(self.style.SUCCESS(f"Done."))
