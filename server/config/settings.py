"""
Django settings for config project.

Split into dev / prod via environment variables.
Use python-decouple to read from .env or OS environment.
"""

from datetime import timedelta
from pathlib import Path

try:
    import dj_database_url
    HAS_DJ_DATABASE_URL = True
except ImportError:
    HAS_DJ_DATABASE_URL = False

try:
    from decouple import Csv, config
    HAS_DECOUPLE = True
except ImportError:
    HAS_DECOUPLE = False
    # Minimal shim so the rest of settings.py works without python-decouple
    import os
    def config(key, default=None, cast=None):
        val = os.environ.get(key, default)
        if cast is not None and val is not None:
            try:
                return cast(val)
            except Exception:
                return default
        return val
    def Csv():
        return lambda v: [s.strip() for s in v.split(",") if s.strip()]


# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent


# ---------------------------------------------------------------------------
# Security — read from environment (never hardcode in production)
# ---------------------------------------------------------------------------

SECRET_KEY = config(
    "SECRET_KEY",
    default="django-insecure-dnxdd1)9t_z+pb316!=kt(eqdp1f#-=&%vsty9*z)90-m-==)+",
)

DEBUG = config("DEBUG", default=False, cast=bool)

# Render sets the service URL automatically; allow it plus localhost for dev
ALLOWED_HOSTS = config(
    "ALLOWED_HOSTS",
    default="localhost,127.0.0.1",
    cast=Csv(),
)


# ---------------------------------------------------------------------------
# Application definition
# ---------------------------------------------------------------------------

try:
    import corsheaders  # noqa: F401
    HAS_CORS = True
except ImportError:
    HAS_CORS = False

try:
    import whitenoise  # noqa: F401
    HAS_WHITENOISE = True
except ImportError:
    HAS_WHITENOISE = False

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Third-party
    "rest_framework",
    "rest_framework_simplejwt",
    "drf_spectacular",
    # Project
    "bookings",
] + (["corsheaders"] if HAS_CORS else [])

MIDDLEWARE = (
    (["corsheaders.middleware.CorsMiddleware"] if HAS_CORS else [])
    + [
        "django.middleware.security.SecurityMiddleware",
    ]
    + (["whitenoise.middleware.WhiteNoiseMiddleware"] if HAS_WHITENOISE else [])
    + [
        "django.contrib.sessions.middleware.SessionMiddleware",
        "django.middleware.common.CommonMiddleware",
        "django.middleware.csrf.CsrfViewMiddleware",
        "django.contrib.auth.middleware.AuthenticationMiddleware",
        "django.contrib.messages.middleware.MessageMiddleware",
        "django.middleware.clickjacking.XFrameOptionsMiddleware",
    ]
)

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"


# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------
# On Render: set DATABASE_URL env var to the Render PostgreSQL connection string.
# Falls back to SQLite for local development.

DATABASES = {
    "default": (
        dj_database_url.config(
            default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}",
            conn_max_age=600,
            conn_health_checks=True,
        )
        if HAS_DJ_DATABASE_URL
        else {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    )
}


# ---------------------------------------------------------------------------
# Custom user model
# ---------------------------------------------------------------------------

AUTH_USER_MODEL = "bookings.CustomUser"

AUTHENTICATION_BACKENDS = [
    "bookings.authentication.PhoneNumberBackend",
]


# ---------------------------------------------------------------------------
# CORS — allow every origin so any frontend domain works
# ---------------------------------------------------------------------------

CORS_ALLOW_ALL_ORIGINS = True          # ← allow ALL domains (no whitelist needed)
CORS_ALLOW_CREDENTIALS = True          # ← allow cookies / auth headers cross-origin

CORS_ALLOW_METHODS = [
    "DELETE",
    "GET",
    "OPTIONS",
    "PATCH",
    "POST",
    "PUT",
]

CORS_ALLOW_HEADERS = [
    "accept",
    "accept-encoding",
    "authorization",
    "content-type",
    "dnt",
    "origin",
    "user-agent",
    "x-csrftoken",
    "x-requested-with",
]


# ---------------------------------------------------------------------------
# Django REST Framework
# ---------------------------------------------------------------------------

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_RENDERER_CLASSES": [
        "rest_framework.renderers.JSONRenderer",
    ],
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
}


# ---------------------------------------------------------------------------
# drf-spectacular — OpenAPI 3 / Swagger settings
# ---------------------------------------------------------------------------

SPECTACULAR_SETTINGS = {
    "TITLE": "QuickSlot API",
    "DESCRIPTION": (
        "Booking platform API. Authenticate with **POST /auth/login/** to receive a JWT Bearer token, "
        "then click the 🔒 Authorize button and enter `Bearer <token>`."
    ),
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "CONTACT": {"name": "QuickSlot Team"},
    "LICENSE": {"name": "MIT"},
    "SECURITY": [{"BearerAuth": []}],
    "APPEND_COMPONENTS": {
        "securitySchemes": {
            "BearerAuth": {
                "type": "http",
                "scheme": "bearer",
                "bearerFormat": "JWT",
            }
        }
    },
    "SWAGGER_UI_SETTINGS": {
        "persistAuthorization": True,
        "displayRequestDuration": True,
        "filter": True,
        "deepLinking": True,
    },
}


# ---------------------------------------------------------------------------
# SimpleJWT configuration
# ---------------------------------------------------------------------------

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(hours=1),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": False,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "AUTH_HEADER_NAME": "HTTP_AUTHORIZATION",
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
}


# ---------------------------------------------------------------------------
# Password validation
# ---------------------------------------------------------------------------

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]


# ---------------------------------------------------------------------------
# Internationalisation
# ---------------------------------------------------------------------------

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True


# ---------------------------------------------------------------------------
# Static files — WhiteNoise serves them in production (no S3/CDN needed)
# ---------------------------------------------------------------------------

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}


# ---------------------------------------------------------------------------
# Default primary key type
# ---------------------------------------------------------------------------

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"


# ---------------------------------------------------------------------------
# Security hardening for production
# ---------------------------------------------------------------------------

if not DEBUG:
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
    SECURE_SSL_REDIRECT = False      # Render handles TLS termination
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
