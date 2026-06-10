from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from .views import BookingViewSet, LoginView, RegisterView, VenueViewSet

# ---------------------------------------------------------------------------
# Router
# ---------------------------------------------------------------------------

router = DefaultRouter()
router.register(r"venues", VenueViewSet, basename="venue")
router.register(r"bookings", BookingViewSet, basename="booking")

# ---------------------------------------------------------------------------
# URL patterns
# ---------------------------------------------------------------------------

urlpatterns = [
    # --- Authentication ---
    # POST  /auth/register/       → create account → JWT tokens
    # POST  /auth/login/          → phone_number + password → JWT tokens
    # POST  /auth/token/refresh/  → refresh token → new access token
    path("auth/register/", RegisterView.as_view(), name="auth-register"),
    path("auth/login/", LoginView.as_view(), name="auth-login"),
    path("auth/token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),

    # --- Venues & Slots (via router) ---
    # GET   /venues/
    # GET   /venues/{id}/
    # GET   /venues/{id}/slots/?date=YYYY-MM-DD
    # POST  /venues/              (auth required)
    # PUT   /venues/{id}/         (auth required)
    # DELETE /venues/{id}/        (auth required)

    # --- Bookings (via router) ---
    # POST   /bookings/
    # DELETE /bookings/{id}/
    # GET    /bookings/           (own bookings only)
    path("", include(router.urls)),

    # --- User-scoped booking list ---
    # GET  /users/{user_id}/bookings/
    path(
        "users/<int:user_pk>/bookings/",
        BookingViewSet.as_view({"get": "list_by_user"}),
        name="user-bookings",
    ),
]
