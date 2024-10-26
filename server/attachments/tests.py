from django.test import TestCase
from announcements.tests import BaseAnnouncementTestCase 
from django.conf import settings
from schools.models import School

import tempfile

class AnnouncementAttachmentTestCase(BaseAnnouncementTestCase):
    fixtures = ["initial_academic_year.json", "initial_classrooms.json", "initial_departments.json"]

    def setUp(self):
        settings.MEDIA_ROOT=tempfile.gettempdir()

        self.school = School.objects.create(
            name="Delhi Public School",
            address="Sector 24, Phase III, Rohini, New Delhi, Delhi 110085, India",
            phone_number="+911123456789",
            email="info@dpsrohini.com",
            website="https://www.dpsrohini.com"
        )

        self.teacher, self.teacher_token = self.create_teacher_and_token(self.school, ["lang/english"], subject_teacher_of=["12A", "12B", "12C", "12D"], class_teacher_of="12D")

    def test_student_cannot_upload_attachment(self):
        self.skipTest("TODO")

    def test_user_cannot_upload_attachment_that_is_too_large(self):
        self.skipTest("TODO")

    def test_user_cannot_upload_attachments_of_invalid_filetype(self):
        self.skipTest("TODO")

    def test_user_can_upload_valid_attachment(self):
        self.skipTest("TODO")

    def test_user_can_delete_their_attachment(self):
        self.skipTest("TODO")

