from typing import Tuple, Dict
import jwt
from datetime import datetime, timedelta

from django.conf import settings 

from typing import NamedTuple 

class TokenPayload(NamedTuple):
    iss: str
    sub: str
    role: str

class TokenService:
    SECRET_KEY = settings.SECRET_KEY
    ALGORITHM = "HS256"

    @staticmethod
    def generate_token_pair(payload: TokenPayload) -> Tuple[str, str]:
        now = datetime.utcnow()
        
        access_token = jwt.encode(
            dict(iat=now, exp=now+timedelta(weeks=1), **payload._asdict()),
            TokenService.SECRET_KEY, algorithm=TokenService.ALGORITHM
        )

        refresh_token = jwt.encode(
            dict(iat=now, exp=now+timedelta(weeks=4), is_refresh=True, **payload._asdict()),
            TokenService.SECRET_KEY, algorithm=TokenService.ALGORITHM
        )

        return access_token, refresh_token
        
    @staticmethod
    def try_decode_token(token: str) -> TokenPayload:
        payload = jwt.decode(token, TokenService.SECRET_KEY, algorithms=[TokenService.ALGORITHM])
        return TokenPayload(
            iss=payload["iss"],
            sub=payload["sub"],
            role=payload["role"],
        )
