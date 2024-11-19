from pathlib import Path

import os
import sys

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = 'django-insecure-%erff=vl*7gn6gw9n)wgbs6b7m*un!)35687)kr9n&@*nsjd75'


ALLOWED_HOSTS = [ "*" ]


INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    "rest_framework",
    "corsheaders",

    "schools",
    "accounts",
    "announcements",
    "attachments",

    "common"
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    "corsheaders.middleware.CorsMiddleware",
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'


TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.0/howto/static-files/

STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(os.path.dirname(__file__), '../static_data/')

# Default primary key field type
# https://docs.djangoproject.com/en/5.0/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'


# ========================== #
# == Custom Configuration == #
# ========================== #

load_dotenv()

DEBUG = os.getenv("DJANGO_DEBUG", "TRUE") == "TRUE"

# https://stackoverflow.com/questions/6957016/detect-django-testing-mode
TESTING = sys.argv[1:2] == ['test']

CORS_ALLOW_ALL_ORIGINS = True

FCM_DEVICE_TOKEN_EXPIRY_IN_DAYS=30

MAX_UPLOAD_FILE_SIZE_IN_BYTES = 100 * 1024 * 1024 # ~ 105 MB
MAX_UPLOAD_QUOTA_PER_ANNOUNCEMENT_IN_BYTES = 150 * 1024 * 1024 # ~ 157 MB
MAX_ATTACHMENTS_PER_ANNOUNCEMENT = 12 # roughly gives the user 13 mb per attachment, otherwise completely arbitiary 

ZEPTOMAIL_TOKEN = os.getenv("ZEPTOMAIL_TOKEN")
ZEPTOMAIL_FROM_ADDRESS = os.getenv("ZEPTOMAIL_FROM_ADDRESS")

if not ZEPTOMAIL_TOKEN or not ZEPTOMAIL_FROM_ADDRESS:
    raise Exception("BAD CONFIG ZEPTOMAIL_TOKEN and ZEPTOMAIL_FROM_ADDRESS are required to setup the email service")

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = os.getenv("REDIS_PORT", "6379")
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", "")

if not REDIS_HOST or not REDIS_PORT:
    raise Exception("BAD CONFIG: REDIS_HOST and REDIS_PORT are required to setup Redis connection")

if not (GOOGLE_APPLICATION_CREDENTIALS := os.getenv("GOOGLE_APPLICATION_CREDENTIALS")):
    raise Exception("BAD CONFIG: GOOGLE_APPLICATION_CREDENTIALS needs to be provided for notifications to work")

DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "5432") 
DB_USER = os.getenv("DB_USER") 

if not DB_PASSWORD or not DB_USER or not DB_NAME or not DB_HOST:
    raise Exception("BAD CONFIG: DB_USER, DB_PASSWORD, DB_NAME, and DB_HOST are required to setup the database")

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": DB_NAME,
        "USER": DB_USER,
        "PASSWORD": DB_PASSWORD,
        "HOST": DB_HOST,
        "PORT": DB_PORT,
    }
}

# 5 minutes
OTP_EXPIRY_IN_SECONDS = 300
OTP_LENGTH = 6 

ADMIN_MASTER_OTP = os.getenv("ADMIN_MASTER_OTP", "000000")
ADMIN_EMAILS =  [email.strip() for email in os.getenv("ADMIN_EMAILS", "").split(",")]


REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (       
        'accounts.authentication.JWTAuthentication',
    ),

    'DEFAULT_PARSER_CLASSES': (
        'rest_framework.parsers.JSONParser',
    )
}
