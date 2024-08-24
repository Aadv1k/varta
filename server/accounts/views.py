from rest_framework.decorators import api_view, authentication_classes

from .serializers import UserLoginSerializer, UserVerificationSerializer

from .models import UserContact

from django.conf import settings

from common.response_builder import ErrorResponseBuilder, SuccessResponseBuilder

from common.services.otp import OTPService
from common.services.email import send_verification_email
from common.services.token import TokenService, TokenPayload

from .authentication import JWTAuthentication


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

    was_generated, error_message_or_otp = OTPService.create_and_store_otp(user_contact.contact_data)

    if not was_generated:
        ErrorResponseBuilder() \
            .set_code(500)     \
            .set_message("Failed to generate OTP due to internal error") \
            .set_details({ "error_detail": error_message }) \
            .build()

    if user_contact.contact_type == UserContact.ContactType.EMAIL:
        was_sent_successfully, error_message = send_verification_email(user_contact.contact_data, "Your Varta verification code", f"Your one time login code for varta is <h2>{error_message_or_otp}</h2>")
        if not was_sent_successfully:
            return ErrorResponseBuilder() \
                        .set_code(500)     \
                        .set_message("Failed to send verification email at the moment") \
                        .set_details({ "error_detail": error_message }) \
                        .build()

    elif user_contact.contact_type == UserContact.ContactType.PHONE_NUMBER:
        assert False, "Not Implemented"

    return SuccessResponseBuilder() \
                .set_message(f"Sent an OTP to {user_contact.contact_data}") \
                .set_metadata({"otp_length": settings.OTP_LENGTH, "otp_expires_in": f"{settings.OTP_EXPIRY_IN_SECONDS / 60} mins"}).build()



@api_view(["POST"])
def user_verify(request):
    serializer = UserVerificationSerializer(data=request.data)

    if not serializer.is_valid():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message(serializer.errors.get("non_field_errors") or "Unable to verify you") \
                .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items() if key != "non_field_errors"]) \
                .build()

   

    contact_data, provided_otp = serializer.validated_data["input_data"], serializer.validated_data["otp"]
    is_otp_valid, error = OTPService.verify_otp(contact_data, provided_otp)

    if not is_otp_valid:
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message(error)   \
                .build()

    user = UserContact.objects.filter(contact_data=contact_data).first().user

    # TODO: derive the issuer from the user agent string  
    access_token, refresh_token = TokenService.generate_token_pair(TokenPayload(sub=str(user.public_id), role=user.user_type, iss="varta.app"))

    return SuccessResponseBuilder() \
                .set_message(f"Successfully logged in the user") \
                .set_data(dict(access_token=access_token, refresh_token=refresh_token)) \
                .build()

@api_view(["POST"])
def user_token_refresh(request):
    refresh_token = request.data.get("refresh_token")

    if not refresh_token:
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("Refresh token not found") \
                .build()

    try:
        payload = TokenService.try_decode_token(refresh_token):
        access_token, _ = TokenService.generate_token_pair(payload)

        return SuccessResponseBuilder() \
                    .set_message(f"Token refreshed") \
                    .set_data(dict(access_token=access_token)) \
                    .build()

    except Exception as e:
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("Invalid refresh token") \
                .set_details([{"field": "refresh_token", "error": str(e)}]) \
                .build()
