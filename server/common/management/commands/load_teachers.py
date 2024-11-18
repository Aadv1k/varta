from django.core.management.base import BaseCommand, CommandError
from schools.models import School
from accounts.models import User, TeacherDetail, Classroom, Department
import json

class Command(BaseCommand):
    help = "Load and populate teacher data from JSON"

    def add_arguments(self, parser):
        parser.add_argument("school_id", type=str, help="The school to which the teachers belong")
        parser.add_argument("filepath", type=str, help="The file with the JSON data")

    def handle(self, *args, **options):
        filepath = options['filepath']

        User.objects.filter(user_type=User.UserType.TEACHER).delete()

        try:
            school = School.objects.get(id=options["school_id"])
        except School.DoesNotExist:
            raise CommandError(f"School with ID {options['school_id']} does not exist.")

        try:
            with open(filepath, "r") as file:
                teachers_data = json.load(file)
        except FileNotFoundError:
            raise CommandError(f"The file at {filepath} does not exist.")
        except json.JSONDecodeError:
            raise CommandError("Error decoding JSON data.")

        for data in teachers_data:
            self.stdout.write(f"Processing {data["first_name"]} {data.get("last_name") or data.get("middle_name")}")

            user = User.objects.create(
                school=school,
                first_name=data.get("first_name", ""),
                middle_name=data.get("middle_name"),
                last_name=data.get("last_name") or "", 
                user_type=User.UserType.TEACHER
            )

            details = TeacherDetail.objects.create( user=user )

            if (classroom_std_div := data.get("class_teacher_of")):
                details.class_teacher_of = Classroom.get_by_std_div_or_none(classroom_std_div)

            if (classrooms_std_div := data.get("subject_teacher_of")):
                for std_div in classrooms_std_div:
                    classroom = Classroom.get_by_std_div_or_none(std_div)
                    if classroom:
                        details.subject_teacher_of.add(classroom)

            if data.get("departments"):
                for dept in data["departments"]:
                    department = Department.get_by_name_or_none(dept)
                    if department:
                        details.departments.add(department)

            details.save()

            self.stdout.write(self.style.SUCCESS(f"Done."))
