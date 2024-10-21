from pathlib import Path

import os
import sys

from dotenv import load_dotenv
load_dotenv() 

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = 'django-insecure-%erff=vl*7gn6gw9n)wgbs6b7m*un!)35687)kr9n&@*nsjd75'

DEBUG = True

ALLOWED_HOSTS = [
    "10.0.2.2",
    "192.168.1.4",
    "localhost"
]


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

# Database
# https://docs.djangoproject.com/en/5.0/ref/settings/#databases


# Password validation
# https://docs.djangoproject.com/en/5.0/ref/settings/#auth-password-validators

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

# Default primary key field type
# https://docs.djangoproject.com/en/5.0/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'


# ========================== #
# == Custom Configuration == #
# ========================== #


CORS_ALLOW_ALL_ORIGINS = True

FCM_DEVICE_TOKEN_EXPIRY_IN_DAYS=30

MAX_UPLOAD_SIZE_IN_BYTES = 10 * 1024 * 1024 # 10MB
MAX_ATTACHMENTS_PER_ANNOUNCEMENT = 4

# https://stackoverflow.com/questions/6957016/detect-django-testing-mode
TESTING = sys.argv[1:2] == ['test']


AWS_RDS_VARTA_DB_CONNECTION_URL = os.getenv("AWS_RDS_VARTA_DB_CONNECTION_URL")
AWS_RDS_VARTA_DB_PASSWORD = os.getenv("AWS_RDS_VARTA_DB_PASSWORD")

if not AWS_RDS_VARTA_DB_PASSWORD or not AWS_RDS_VARTA_DB_CONNECTION_URL:
    raise Exception("BAD CONFIG AWS_RDS_VARTA_DB_CONNECTION_URL and AWS_RDS_VARTA_DB_PASSWORD are required to setup the database")

if TESTING:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": "vartadb",
            "USER": "aadv1k",
            "PASSWORD": AWS_RDS_VARTA_DB_PASSWORD,
            "HOST": AWS_RDS_VARTA_DB_CONNECTION_URL,
            "PORT": "5432",
        }
    }


# 5 minutes
OTP_EXPIRY_IN_SECONDS = 300
OTP_LENGTH = 6 
MASTER_OTP = "000000"

# Redis configuration
REDIS_HOST = "localhost"
REDIS_PORT = 6379
REDIS_PASSWORD = ""

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (       
        'accounts.authentication.JWTAuthentication',
    ),

    'DEFAULT_PARSER_CLASSES': (
        'rest_framework.parsers.JSONParser',
    )
}
