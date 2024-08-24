from common.service.token import TokenService

from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

from .models import User  

import jwt

class JWTAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION', '').split(' ')
        if len(auth_header) != 2 or auth_header[0] != 'Bearer':
            return None

        token = auth_header.pop()


        try:
            payload = TokenService.try_decode_token(token)
            user = User.from_public_id(payload.sub)
            return user, None
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed('Token has expired')
        except (jwt.DecodeError, User.DoesNotExist) as e:
            raise AuthenticationFailed('Invalid token')
