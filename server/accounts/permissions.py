from rest_framework import exceptions
from rest_framework import permissions
from rest_framework.authentication import get_authorization_header

from accounts.models import User

from common.services.token import TokenService

import jwt

from django.conf import settings

def extract_auth_token_or_fail(request):
    auth = get_authorization_header(request).split()

    if not auth or auth[0].lower() != b'bearer':
        raise exceptions.AuthenticationFailed('Invalid token header')

    if len(auth) == 1 or len(auth) > 2:
        raise exceptions.AuthenticationFailed('Invalid token header')

    return auth[1]

class IsJWTAuthenticated(permissions.BasePermission):
    def has_permission(self, request, view):
        try:
            auth_token = extract_auth_token_or_fail(request)
        except exceptions.AuthenticationFailed:
            return False

        try:
            TokenService.try_decode_token(auth_token)
        except jwt.ExpiredSignatureError | jwt.InvalidTokenError:
            return False;

        return True

class IsTeacher(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.user_type == User.UserType.TEACHER