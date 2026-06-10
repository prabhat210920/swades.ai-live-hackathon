from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

urlpatterns = [
    # Django admin
    path("admin/", admin.site.urls),

    # -------------------------------------------------------------------------
    # OpenAPI 3 schema + Swagger / ReDoc UI
    # -------------------------------------------------------------------------
    # Raw schema download (JSON/YAML):   GET /api/schema/
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    # Swagger UI:                         GET /api/docs/
    path(
        "api/docs/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="swagger-ui",
    ),
    # ReDoc (alternative UI):             GET /api/redoc/
    path(
        "api/redoc/",
        SpectacularRedocView.as_view(url_name="schema"),
        name="redoc",
    ),

    # -------------------------------------------------------------------------
    # Application routes
    # -------------------------------------------------------------------------
    path("", include("bookings.urls")),
]
