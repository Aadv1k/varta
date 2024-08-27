from rest_framework.test import APITestCase

from django.urls import reverse

from common.services.token import TokenService


class AnnouncementTestCase(APITestCase):
    def setUp(self):
        pass

    def test_authenticated_user_can_view_announcements_of_their_school(self):
        response = self.client.get(reverse("announcement_list"))

        self.assertEqual(response.status_code, 400)