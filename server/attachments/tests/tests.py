from django.urls import reverse
from attachments.models import Attachment
from announcements.tests import BaseAnnouncementTestCase 
from announcements.models import AnnouncementScope
from django.conf import settings
from schools.models import School
from django.core.files.uploadedfile import SimpleUploadedFile


import tempfile

class AttachmentTestCase(BaseAnnouncementTestCase):
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

        self.student, self.student_token = self.create_student_and_token(self.school, std_div="12D")

    def test_student_cannot_upload_attachment(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.student_token}")
        file = SimpleUploadedFile(
            "test.pdf", 
            b"0" * 1024 * 5,
            content_type="application/pdf"
        )
        response = self.client.post(reverse("attachment_upload"), data={
            "file": file
        })
        self.assertEqual(response.status_code, 403)

    def test_teacher_cannot_upload_blank_attachments(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")
        blank_file = SimpleUploadedFile(
            "test.pdf", 
            b"",
            content_type="application/pdf"
        )
        response = self.client.post(reverse("attachment_upload"), data={
            "file": blank_file
        })

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "file")


    def test_user_cannot_upload_attachment_that_is_too_large(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")
        large_file = SimpleUploadedFile(
            "test.pdf", 
            b"0" * 1024 * 1024 * 15, # ~ 15 MB
            content_type="application/pdf"
        )
        response = self.client.post(reverse("attachment_upload"), data={
            "file": large_file
        })
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "file")

    def test_user_cannot_upload_attachments_of_invalid_filetype(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")
        invalid_file = SimpleUploadedFile(
            "test.exe", 
            b"MZ" + b"\x90\x00\x03" + b"0" * 1024, 
            content_type="application/pdf"
        )
        response = self.client.post(reverse("attachment_upload"), data={
            "file": invalid_file
        })
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "file")

    def test_user_cannot_upload_attachments_of_illegal_filename(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")

        with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
            file_with_illegal_name = SimpleUploadedFile(
                "test....file.jpg",
                test_file.read(),
                content_type="image/jpeg"
            )

        response = self.client.post(reverse("attachment_upload"), data={
            "file": file_with_illegal_name
        })
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "file")
        self.assertEqual(response.data["errors"][0]["error"], "Illegal Filename")

    def test_user_can_upload_valid_attachment(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")
        with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
            valid_file = SimpleUploadedFile(
                "test-file.jpg",
                test_file.read(),
                content_type="image/jpeg"
            )

        response = self.client.post(reverse("attachment_upload"), data={
            "file": valid_file
        })

        self.assertEqual(response.status_code, 201)

        self.assertIn("id", response.data["data"])
        self.assertIn("url", response.data["data"])

    
    # def test_duplicate_announcements_arent_reuploaded(self):
    #     self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")
    #     with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
    #         valid_file = SimpleUploadedFile( "test-file.jpg", test_file.read(), content_type="image/jpeg")
    #         test_file.seek(0)
    #         valid_file_2 = SimpleUploadedFile( "test-file.jpg", test_file.read(), content_type="image/jpeg")

    #     response = self.client.post(reverse("attachment_upload"), data={ "file": valid_file })
    #     response_2 = self.client.post(reverse("attachment_upload"), data={ "file": valid_file_2 })

    #     self.assertEqual(response.status_code, 201)
    #     self.assertEqual(response_2.status_code, 201)

    #     self.assertEqual(response.data["data"]["url"], response_2.data["data"]["url"])

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

        self.student, self.student_token = self.create_student_and_token(self.school, std_div="12D")

    def test_user_cannot_reference_unknown_attachments_in_announcement(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")

        response = self.client.post(reverse("announcement_list"), data={
            "title": "Test Announcement",
            "body": "This is a test announcement",
            "scopes": [
                {"filter": AnnouncementScope.FilterType.EVERYONE},
            ],
            "attachments": ["30f0dbcd-5363-4fea-a910-ff7ae9eb757a"]
        }, format="json")

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "attachments")


    def test_user_cannot_have_duplicate_attachments_in_announcement(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")

        with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
            response = self.client.post(reverse("attachment_upload"), data={ "file": SimpleUploadedFile("testing.jpg", content=test_file.read(), content_type="application/pdf") }) 

            attachment_id = response.data["data"]["id"]

        response = self.client.post(reverse("announcement_list"), data={
            "title": "Test Announcement",
            "body": "This is a test announcement",
            "scopes": [
                {"filter": AnnouncementScope.FilterType.EVERYONE},
            ],
            "attachments": [attachment_id, attachment_id]
        }, format="json")

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "attachments")


    def test_user_cannot_create_announcement_with_too_many_attachments(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")
        attachment_ids = []

        with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
            for _ in range(5):
                response = self.client.post(reverse("attachment_upload"), data={ "file": SimpleUploadedFile("testing.jpg", content=test_file.read(), content_type="application/pdf") }) 
                attachment_ids.append(response.data["data"]["id"])
                test_file.seek(0)

        self.assertEqual(Attachment.objects.all().count(), 5)

        response = self.client.post(reverse("announcement_list"), data={
            "title": "Test Announcement",
            "body": "This is a test announcement",
            "scopes": [
                {"filter": AnnouncementScope.FilterType.EVERYONE},
            ],
            "attachments": attachment_ids
        }, format="json")

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data["errors"][0]["field"], "attachments")

    def test_user_can_create_announcement_with_valid_attachments(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")

        with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
            response = self.client.post(reverse("attachment_upload"), data={ "file": SimpleUploadedFile("testing.jpg", content=test_file.read(), content_type="application/pdf") }) 
            attachment_id = response.data["data"]["id"]

        response = self.client.post(reverse("announcement_list"), data={
            "title": "Test Announcement",
            "body": "This is a test announcement",
            "scopes": [
                {"filter": AnnouncementScope.FilterType.EVERYONE},
            ],
            "attachments": [attachment_id]
        }, format="json")

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["attachments"][0]["type"], "image/jpeg")

    def test_user_deleting_announcement_will_also_delete_attachments(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.teacher_token}")

        with open("./attachments/tests/test-image-v3.jpg", "rb") as test_file:
            response = self.client.post(reverse("attachment_upload"), data={ "file": SimpleUploadedFile("testing.jpg", content=test_file.read(), content_type="application/pdf") }) 
            attachment_id = response.data["data"]["id"]

        response = self.client.post(reverse("announcement_list"), data={
            "title": "Test Announcement",
            "body": "This is a test announcement",
            "scopes": [
                {"filter": AnnouncementScope.FilterType.EVERYONE},
            ],
            "attachments": [attachment_id]
        }, format="json")

        self.client.delete(reverse("announcement_detail", kwargs={ "pk": response.data["data"]["id"] }))

        self.assertFalse(Attachment.objects.filter(id=attachment_id).exists())

    def test_user_can_delete_individual_attachments_by_id(self):
        pass

    def test_user_deleting_announcement_will_delete_attachments_unless_it_is_references_elsewhere(self):
        pass