from rest_framework.decorators import api_view

from .serializers import UserLoginSerializer

from .models import UserContact

from django.conf import settings

from common.response_builder import ErrorResponseBuilder, SuccessResponseBuilder

@api_view(["POST"])
def user_login(request):
    serializer = UserLoginSerializer(data=request.data)

    if not serializer.is_valid():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message(serializer.errors.get("non_field_errors") or "Couldn't log you in") \
                .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items() if key != "non_field_errors"]) \
                .build()


    user_contact_query = UserContact.objects.filter(
        user__school=serializer.validated_data.get("school_id"),
        contact_type=serializer.validated_data.get("input_format"),
        contact_data=serializer.validated_data.get("input_data")
    )

    # either the user odesn't exist or the contact doesn't exist
    if not user_contact_query.exists():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("The specified user, or the user contact does not exist") \
                .set_details([{"field": "input_data", "error": "Couldn't find the user in the system"}]) \
                .build()

    user_contact = user_contact_query.first()

    # TODO: send the OTP here

    return SuccessResponseBuilder() \
                .set_message(f"Sent an OTP to {user_contact.input_data}") \
                .set_metadata({"otp_length": settings.otp_length, "otp_expires_in": f"{settings.otp_expiry_in_seconds / 60} mins"}).build()
