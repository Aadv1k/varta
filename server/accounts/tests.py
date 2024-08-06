from rest_framework.test import APITestCase
from django.urls import reverse

class UserActionTest(APITestCase):
    def setUp(self):
        pass

    def test_user_can_login_with_email(self):
        response = self.client.post(reverse("user_login"), {
            "input_format": "email",
            "input_data": "aadv1k@outlook.com",
        }, format="json")

        self.assertEqual(response.status_code, 200)
        self.assertIsNotNone(response.data.get("data"))


    def test_user_cant_login_with_invalid_email(self):
        response = self.client.post(reverse("user_login"), {
            "input_format": "email",
            "input_data": "aadv1k.foo",
        }, format="json")

        self.assertEqual(response.status_code, 400)

        response = self.client.post(reverse("user_login"), {
            "input_format": "email",
            "input_data": "foo@bar.com",
        }, format="json")

        self.assertEqual(response.status_code, 400)

    def user_can_login_with_phone(self):
        pass

    def user_can_verify_self_with_otp_(self):
        pass

    def user_can_renew_access_token(self):
        pass

    def user_can_request_their_details(self):
        pass
