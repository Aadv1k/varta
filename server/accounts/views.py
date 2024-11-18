from rest_framework.decorators import api_view, authentication_classes, permission_classes

from .serializers import UserLoginSerializer, UserVerificationSerializer, UserDeviceSerializer, UserSerializer

from .models import UserContact

from django.conf import settings


from common.response_builder import ErrorResponseBuilder, SuccessResponseBuilder

from common.services.otp import OTPService

from common.services.email import send_verification_email
from common.services.sms import send_verification_sms

from common.services.token import TokenService, TokenPayload
from common.utils import user_agent_is_from_mobile

from .permissions import IsJWTAuthenticated

otp_service = OTPService()

@api_view(["POST"])
def user_login(request):
    serializer = UserLoginSerializer(data=request.data)

    if not serializer.is_valid():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("Login failed. Please verify your credentials and try again.") \
                .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items() if key != "non_field_errors"]) \
                .build()

    user_contact_query = UserContact.objects.filter(
        user__school=serializer.validated_data.get("school_id"),
        contact_type=serializer.validated_data.get("input_format"),
        contact_data=serializer.validated_data.get("input_data")
    )

    # either the user doest't exist or the contact doesn't exist
    if not user_contact_query.exists():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("User or contact information could not be found.") \
                .set_details([{"field": "input_data", "error": "Couldn't find the user in the system"}]) \
                .build()

    user_contact = user_contact_query.first()

    try:
        otp = otp_service.create_and_store_otp(user_contact.contact_data)
    except Exception as e:
        ErrorResponseBuilder() \
            .set_code(500)     \
            .set_message("Failed to generate OTP due to internal error") \
            .set_details({ "error_detail": str(e) }) \
            .build()


    print(f"OTP IS THE FOLLOWING: {otp}")
    # if not settings.DEBUG:
        # if user_contact.contact_type == UserContact.ContactType.EMAIL:
            # try:
                # send_verification_email(
                    # otp,
                    # user_contact.contact_data, 
                    # user_contact.user,
                # )
            # except Exception as e:
                # return ErrorResponseBuilder() \
                            # .set_code(500)     \
                            # .set_message("Failed to send verification email at the moment. Please try again later.") \
                            # .set_details({ "error_detail": str(e) }) \
                            # .build()
        # elif user_contact.contact_type == UserContact.ContactType.PHONE_NUMBER:
            # try:
                # send_verification_sms(user_contact.contact_data)
            # except Exception as e:
                # return ErrorResponseBuilder() \
                            # .set_code(500)     \
                            # .set_message("Failed to send verification SMS at the moment. Please try again later.") \
                            # .set_details({ "error_detail": str(e) }) \
                            # .build()

    return SuccessResponseBuilder() \
                .set_message(f"Sent an OTP to {user_contact.contact_data}") \
                .set_metadata({"otp_length": settings.OTP_LENGTH, "otp_expires_in": f"{settings.OTP_EXPIRY_IN_SECONDS / 60} mins"}) \
                .build()


@api_view(["POST"])
def user_verify(request):
    serializer = UserVerificationSerializer(data=request.data)

    if not serializer.is_valid():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("We couldn't verify your details. Please check the details you entered and try again.") \
                .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items() if key != "non_field_errors"]) \
                .build()

    contact_data, provided_otp = serializer.validated_data["input_data"], serializer.validated_data["otp"]
    is_otp_valid = True if settings.DEBUG and provided_otp == settings.MASTER_OTP else otp_service.verify_otp(contact_data, provided_otp)

    if not is_otp_valid:
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("Invalid or expired OTP. Please try again")   \
                .build()

    user_query = UserContact.objects.filter(contact_data=contact_data)

    if not user_query.exists():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("User with the provided details wasn't found")   \
                .build()

    user = user_query.first().user

    token_issuer = "varta.app" if user_agent_is_from_mobile(request.META.get('HTTP_USER_AGENT', "")) else "varta.web"

    access_token, refresh_token = TokenService.generate_token_pair(
        TokenPayload(sub=str(user.public_id), role=user.user_type, iss=token_issuer))

    return SuccessResponseBuilder() \
                .set_message(f"Successfully logged in the user") \
                .set_data(dict(access_token=access_token, refresh_token=refresh_token)) \
                .build()

@api_view(["POST"])
def user_refresh(request):
    refresh_token = request.data.get("refresh_token")

    if not refresh_token:
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("Refresh token not found") \
                .build()

    try:
        payload = TokenService.try_decode_token(refresh_token)
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


@api_view(["POST"])
@permission_classes([IsJWTAuthenticated])
def user_device(request):
    serializer = UserDeviceSerializer(data={
        "user": request.user.id,
        **request.data
    })

    if not serializer.is_valid():
        return ErrorResponseBuilder() \
                .set_code(400)        \
                .set_message("We couldn't register your device. Please check the details you entered and try again.") \
                .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items() if key != "non_field_errors"]) \
                .build()
    
    serializer.save()

    return SuccessResponseBuilder() \
                .set_code(200) \
                .set_message("Your device was successfully registered") \
                .build()


@api_view(["GET"])
@permission_classes([IsJWTAuthenticated])
def user_details(request):
    serializer = UserSerializer(request.user)

    return SuccessResponseBuilder() \
                .set_code(200) \
                .set_data(serializer.data) \
                .set_message("Successfully fetched the user details") \
                .build()
