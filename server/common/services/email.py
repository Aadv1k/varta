from django.template.loader import render_to_string

from django.conf import settings

import requests

url = "https://api.zeptomail.in/v1.1/email"

def send_verification_email(otp: str, to_address: str, user) -> str:
    subject = "Varta OTP Verification"
    email_html_body = render_to_string("emails/email_otp_verification.html", {
        "otp": otp,
    })
    payload = {
        "from": {
            "address": settings.ZEPTOMAIL_FROM_ADDRESS,
            "name": "Aadvik at Varta"
        },
        "to": [
            {
                "email_address": {
                    "address": to_address,
                    "name": str(user)
                }
            }
        ],
        "subject": subject,
        "textbody": f"Here is your varta verification code: {otp}",
        "htmlbody": email_html_body
    }

    headers = {
        'accept': "application/json",
        'content-type': "application/json",
        'authorization': settings.ZEPTOMAIL_TOKEN,
    }


    response = requests.post(url, json=payload, headers=headers)

    if response.status_code // 100 != 2:
        raise Exception(f"Error sending email: {response.status_code} - {response.text}")

    return response.json()["request_id"]
