from rest_framework.decorators import api_view

from .serializers import UserLoginSerializer

from .models import UserContact

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


    UserContact.objects.get(
        user__school=serializer.validated_data.get("school_id"),
        contact_type=serializer.validated_data.get("input_format"),
        contact_data=serializer.validated_data.get("input_data")
    )

    
    return SuccessResponseBuilder().set_data({
        "access_token": "",
        "refresh_token": "",
    }).build()
