import re

from common.response_builder import ErrorResponseBuilder

def user_agent_is_from_mobile(user_agent):
    ua = user_agent.lower()
    if re.search(r'mobile|android|iphone|ipad|iemobile|blackberry|windows phone', ua):
        return True
    return False

def error_response_builder_from_serializer_error(serializer):
    return ErrorResponseBuilder() \
        .set_details([{"field": key, "error": str(value.pop())} for key, value in serializer.errors.items() if key != "non_field_errors"]) 