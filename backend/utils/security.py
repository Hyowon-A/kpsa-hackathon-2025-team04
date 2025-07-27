from functools import wraps
from flask import request, abort
import jwt
from datetime import datetime, timedelta, timezone
import os

jwt_secret = os.getenv('JWT_SECRET_KEY', 'default_secret')

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        # Token can come from cookies or Authorization header (iOS)
        token = request.cookies.get('jwt') or request.headers.get('Authorization')
        if token and token.startswith("Bearer "):
            token = token.split(" ")[1]

        if not token:
            abort(401, description="Authorization token is missing")
        try:
            data = jwt.decode(token, jwt_secret, algorithms=["HS256"])
            current_user = data.get("email")
            user_id = data.get("user_id")

            if not current_user or not user_id:
                abort(403, description="Bad Credentials")
        except jwt.ExpiredSignatureError:
            abort(403, description="Token is outdated")
        except (jwt.InvalidTokenError, KeyError):
            abort(403, description="Bad Credentials")

        return f({"email": current_user, "user_id": user_id}, *args, **kwargs)


    return decorated

def generate_jwt(payload, hours=6):
    """Generate a JWT with expiration time (default 6 hours)."""
    payload_copy = payload.copy()
    payload_copy["exp"] = datetime.now(timezone.utc) + timedelta(hours=hours)
    return jwt.encode(payload_copy, jwt_secret, algorithm="HS256")