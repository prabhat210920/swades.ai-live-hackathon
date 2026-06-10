from django.db import IntegrityError, transaction
from drf_spectacular.utils import (
    OpenApiExample,
    OpenApiParameter,
    OpenApiResponse,
    extend_schema,
    extend_schema_view,
)
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Booking, Slot, Venue
from .serializers import (
    BookingSerializer,
    PhoneTokenObtainSerializer,
    RegisterSerializer,
    SlotSerializer,
    VenueSerializer,
)


# ---------------------------------------------------------------------------
# Inline response serializers for Swagger (no extra model needed)
# ---------------------------------------------------------------------------

from rest_framework import serializers as drf_serializers


class LoginResponseSerializer(drf_serializers.Serializer):
    access = drf_serializers.CharField(help_text="Short-lived JWT access token (1 h).")
    refresh = drf_serializers.CharField(help_text="Long-lived JWT refresh token (7 d).")

    class UserInline(drf_serializers.Serializer):
        id = drf_serializers.IntegerField()
        phone_number = drf_serializers.CharField()

    user = UserInline()


class ErrorDetailSerializer(drf_serializers.Serializer):
    detail = drf_serializers.CharField()


# ---------------------------------------------------------------------------
# Auth view — POST /auth/login/
# ---------------------------------------------------------------------------

@extend_schema(tags=["Auth"])
class LoginView(APIView):
    """
    Obtain JWT access and refresh tokens by authenticating with a
    phone number and password.
    """
    permission_classes = [AllowAny]

    @extend_schema(
        summary="Login with phone number & password",
        description=(
            "Authenticate a user using their registered **phone number** and **password**. "
            "Returns a short-lived `access` token (1 h) and a long-lived `refresh` token (7 d). "
            "Use the access token as `Authorization: Bearer <token>` on protected endpoints."
        ),
        request=PhoneTokenObtainSerializer,
        responses={
            200: OpenApiResponse(
                response=LoginResponseSerializer,
                description="Authentication successful — returns JWT tokens.",
            ),
            400: OpenApiResponse(
                response=ErrorDetailSerializer,
                description="Invalid credentials or missing fields.",
                examples=[
                    OpenApiExample(
                        "Bad credentials",
                        value={"detail": "Unable to log in with the provided credentials."},
                    )
                ],
            ),
        },
        examples=[
            OpenApiExample(
                "Login request",
                value={"phone_number": "+919876543210", "password": "secret123"},
                request_only=True,
            ),
            OpenApiExample(
                "Successful response",
                value={
                    "access": "<JWT_ACCESS_TOKEN>",
                    "refresh": "<JWT_REFRESH_TOKEN>",
                    "user": {"id": 1, "phone_number": "+919876543210"},
                },
                response_only=True,
                status_codes=["200"],
            ),
        ],
        auth=[],   # No auth required for this endpoint
    )
    def post(self, request, *args, **kwargs):
        serializer = PhoneTokenObtainSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data["user"]
        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": {
                    "id": user.pk,
                    "phone_number": user.phone_number,
                },
            },
            status=status.HTTP_200_OK,
        )


# ---------------------------------------------------------------------------
# Register view — POST /auth/register/
# ---------------------------------------------------------------------------

@extend_schema(tags=["Auth"])
class RegisterView(APIView):
    """
    Create a new user account using a phone number and password.
    Returns JWT tokens immediately — no separate login step needed.
    """
    permission_classes = [AllowAny]

    @extend_schema(
        summary="Register a new user",
        description=(
            "Creates a new user account with a **phone number** and **password**. "
            "On success, returns JWT `access` and `refresh` tokens so the user "
            "is instantly authenticated — no separate login call required.\n\n"
            "**Validation rules:**\n"
            "- `phone_number` must be unique.\n"
            "- `password` must be at least 8 characters.\n"
            "- `password` and `password_confirm` must match."
        ),
        request=RegisterSerializer,
        responses={
            201: OpenApiResponse(
                response=LoginResponseSerializer,
                description="Account created — returns JWT tokens.",
            ),
            400: OpenApiResponse(
                response=ErrorDetailSerializer,
                description="Validation error (duplicate phone, password mismatch, etc.).",
                examples=[
                    OpenApiExample(
                        "Phone already exists",
                        value={"phone_number": ["A user with this phone number already exists."]},
                    ),
                    OpenApiExample(
                        "Password mismatch",
                        value={"password_confirm": ["Passwords do not match."]},
                    ),
                ],
            ),
        },
        examples=[
            OpenApiExample(
                "Register request",
                value={
                    "phone_number": "+919876543210",
                    "password": "strongpass1",
                    "password_confirm": "strongpass1",
                },
                request_only=True,
            ),
            OpenApiExample(
                "Successful response",
                value={
                    "access": "<JWT_ACCESS_TOKEN>",
                    "refresh": "<JWT_REFRESH_TOKEN>",
                    "user": {"id": 1, "phone_number": "+919876543210"},
                },
                response_only=True,
                status_codes=["201"],
            ),
        ],
        auth=[],
    )
    def post(self, request, *args, **kwargs):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        refresh = RefreshToken.for_user(user)
        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": {
                    "id": user.pk,
                    "phone_number": user.phone_number,
                },
            },
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# Venue ViewSet — GET /venues/  and  GET /venues/{id}/slots/?date=YYYY-MM-DD
# ---------------------------------------------------------------------------

@extend_schema_view(
    list=extend_schema(
        tags=["Venues"],
        summary="List all venues",
        description=(
            "Returns a list of all venues. **No authentication required.**\n\n"
            "Each venue includes:\n"
            "- `image_url` — public photo URL\n"
            "- `sports` — list of sports offered (e.g. `[\"Badminton\", \"Squash\"]`)\n"
            "- `price_per_hour` — cost in INR per one-hour slot"
        ),
        responses={200: VenueSerializer(many=True)},
        examples=[
            OpenApiExample(
                "Venue list item",
                value={
                    "id": 1,
                    "name": "Koramangala Sports Arena",
                    "address": "80 Feet Road, Koramangala 4th Block",
                    "city": "Bengaluru",
                    "description": "Premium indoor sports complex with 6 badminton courts.",
                    "image_url": "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800",
                    "sports": ["Badminton", "Squash", "Table Tennis"],
                    "price_per_hour": "800.00",
                    "created_at": "2026-06-10T12:00:00Z",
                    "updated_at": "2026-06-10T12:00:00Z",
                },
                response_only=True,
                status_codes=["200"],
            ),
        ],
        auth=[],
    ),
    retrieve=extend_schema(
        tags=["Venues"],
        summary="Get a single venue",
        description="Returns full details for a single venue by ID, including image, sports, and pricing.",
        responses={
            200: VenueSerializer,
            404: OpenApiResponse(description="Venue not found."),
        },
        examples=[
            OpenApiExample(
                "Venue detail",
                value={
                    "id": 1,
                    "name": "Koramangala Sports Arena",
                    "address": "80 Feet Road, Koramangala 4th Block",
                    "city": "Bengaluru",
                    "description": "Premium indoor sports complex.",
                    "image_url": "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800",
                    "sports": ["Badminton", "Squash", "Table Tennis"],
                    "price_per_hour": "800.00",
                    "created_at": "2026-06-10T12:00:00Z",
                    "updated_at": "2026-06-10T12:00:00Z",
                },
                response_only=True,
                status_codes=["200"],
            ),
        ],
        auth=[],
    ),
    create=extend_schema(
        tags=["Venues"],
        summary="Create a venue",
        description=(
            "Creates a new venue. **Requires JWT authentication.**\n\n"
            "**Fields:**\n"
            "- `name` *(required)* — venue name\n"
            "- `address` *(required)* — full street address\n"
            "- `city` *(required)* — city name\n"
            "- `description` *(optional)* — longer description\n"
            "- `image_url` *(optional)* — public URL to a venue photo\n"
            "- `sports` *(optional)* — JSON list of sports, e.g. `[\"Badminton\", \"Squash\"]`\n"
            "- `price_per_hour` *(optional)* — price in INR per hour slot (default `0.00`)"
        ),
        responses={
            201: VenueSerializer,
            400: OpenApiResponse(description="Validation error."),
            401: OpenApiResponse(description="Authentication credentials were not provided."),
        },
        examples=[
            OpenApiExample(
                "Create venue request",
                value={
                    "name": "Koramangala Sports Arena",
                    "address": "80 Feet Road, Koramangala 4th Block",
                    "city": "Bengaluru",
                    "description": "Premium indoor sports complex.",
                    "image_url": "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800",
                    "sports": ["Badminton", "Squash", "Table Tennis"],
                    "price_per_hour": "800.00",
                },
                request_only=True,
            ),
            OpenApiExample(
                "Created venue response",
                value={
                    "id": 1,
                    "name": "Koramangala Sports Arena",
                    "address": "80 Feet Road, Koramangala 4th Block",
                    "city": "Bengaluru",
                    "description": "Premium indoor sports complex.",
                    "image_url": "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800",
                    "sports": ["Badminton", "Squash", "Table Tennis"],
                    "price_per_hour": "800.00",
                    "created_at": "2026-06-10T12:00:00Z",
                    "updated_at": "2026-06-10T12:00:00Z",
                },
                response_only=True,
                status_codes=["201"],
            ),
        ],
    ),
    update=extend_schema(
        tags=["Venues"],
        summary="Update a venue (full)",
        description=(
            "Fully replaces an existing venue. All fields must be supplied. **Requires JWT authentication.**\n\n"
            "Updatable fields: `name`, `address`, `city`, `description`, `image_url`, `sports`, `price_per_hour`."
        ),
        examples=[
            OpenApiExample(
                "Full update request",
                value={
                    "name": "Koramangala Sports Arena",
                    "address": "80 Feet Road, Koramangala 4th Block",
                    "city": "Bengaluru",
                    "description": "Updated description.",
                    "image_url": "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800",
                    "sports": ["Badminton", "Squash"],
                    "price_per_hour": "900.00",
                },
                request_only=True,
            ),
        ],
    ),
    partial_update=extend_schema(
        tags=["Venues"],
        summary="Update a venue (partial)",
        description=(
            "Partially updates an existing venue — send only the fields you want to change. "
            "**Requires JWT authentication.**\n\n"
            "Examples: change only `price_per_hour`, or add a sport to `sports`."
        ),
        examples=[
            OpenApiExample(
                "Update price only",
                value={"price_per_hour": "950.00"},
                request_only=True,
            ),
            OpenApiExample(
                "Update image URL",
                value={"image_url": "https://example.com/new-photo.jpg"},
                request_only=True,
            ),
            OpenApiExample(
                "Update sports list",
                value={"sports": ["Badminton", "Squash", "Table Tennis"]},
                request_only=True,
            ),
        ],
    ),
    destroy=extend_schema(
        tags=["Venues"],
        summary="Delete a venue",
        description="Deletes a venue by ID. **Requires JWT authentication.** Cascades to all slots and bookings.",
        responses={
            204: OpenApiResponse(description="Venue deleted successfully."),
            404: OpenApiResponse(description="Venue not found."),
        },
    ),
)
class VenueViewSet(viewsets.ModelViewSet):
    queryset = Venue.objects.all()
    serializer_class = VenueSerializer

    def get_permissions(self):
        # Listing and retrieving venues is public; mutations require auth
        if self.action in ("list", "retrieve", "slots"):
            return [AllowAny()]
        return [IsAuthenticated()]

    @extend_schema(
        tags=["Venues"],
        summary="List slots for a venue",
        description=(
            "Returns all time slots for the specified venue. "
            "Filter by date using the `?date=YYYY-MM-DD` query parameter."
        ),
        parameters=[
            OpenApiParameter(
                name="date",
                location=OpenApiParameter.QUERY,
                description="Filter slots by date (format: `YYYY-MM-DD`). "
                            "If omitted, all future and past slots are returned.",
                required=False,
                type=str,
                examples=[
                    OpenApiExample("Example date", value="2026-06-15"),
                ],
            ),
        ],
        responses={
            200: SlotSerializer(many=True),
            404: OpenApiResponse(description="Venue not found."),
        },
        auth=[],
    )
    @action(detail=True, methods=["get"], url_path="slots")
    def slots(self, request, pk=None):
        """
        GET /venues/{id}/slots/?date=YYYY-MM-DD
        Returns all slots for a given venue, optionally filtered by date.
        """
        venue = self.get_object()
        queryset = venue.slots.all()

        date_param = request.query_params.get("date")
        if date_param:
            queryset = queryset.filter(date=date_param)

        serializer = SlotSerializer(queryset, many=True)
        return Response(serializer.data)


# ---------------------------------------------------------------------------
# Booking ViewSet — POST /bookings/  |  GET /users/{id}/bookings/  |  DELETE /bookings/{id}/
# ---------------------------------------------------------------------------

@extend_schema_view(
    list=extend_schema(
        tags=["Bookings"],
        summary="List my bookings",
        description="Returns all bookings belonging to the currently authenticated user.",
        responses={200: BookingSerializer(many=True)},
    ),
    retrieve=extend_schema(
        tags=["Bookings"],
        summary="Get a single booking",
        responses={
            200: BookingSerializer,
            404: OpenApiResponse(description="Booking not found."),
        },
    ),
    destroy=extend_schema(
        tags=["Bookings"],
        summary="Cancel / delete a booking",
        description="Deletes the specified booking. Only the booking owner can delete it.",
        responses={
            204: OpenApiResponse(description="Booking deleted successfully."),
            403: OpenApiResponse(description="Not authorised to delete this booking."),
            404: OpenApiResponse(description="Booking not found."),
        },
    ),
    # Hide the auto-generated update/partial_update actions (not in spec)
    update=extend_schema(exclude=True),
    partial_update=extend_schema(exclude=True),
)
class BookingViewSet(viewsets.ModelViewSet):
    """
    Concurrency-safe booking creation using transaction.atomic() +
    select_for_update() to prevent double-booking the same slot.
    """
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]
    # Needed so drf-spectacular can detect the pk type (int) for path params.
    # The real queryset is always returned by get_queryset() at runtime.
    queryset = Booking.objects.none()

    def get_queryset(self):
        # Each authenticated user can only see their own bookings
        return Booking.objects.filter(user=self.request.user).select_related(
            "slot__venue", "user"
        )

    # ------------------------------------------------------------------
    # POST /bookings/  — concurrency-safe creation
    # ------------------------------------------------------------------

    @extend_schema(
        tags=["Bookings"],
        summary="Create a booking",
        description=(
            "Books an available slot for the authenticated user. "
            "This endpoint is **concurrency-safe**: it uses a database-level row lock "
            "(`SELECT FOR UPDATE`) inside an atomic transaction to prevent two users "
            "from booking the same slot simultaneously.\n\n"
            "**Validation rules:**\n"
            "- The slot date must not be in the past.\n"
            "- The slot must still be available (`is_available: true`)."
        ),
        request=BookingSerializer,
        responses={
            201: BookingSerializer,
            400: OpenApiResponse(description="Validation error (e.g. past date, missing field)."),
            409: OpenApiResponse(
                response=ErrorDetailSerializer,
                description="Slot already taken — conflict detected.",
                examples=[
                    OpenApiExample(
                        "Slot taken",
                        value={"detail": "This slot has just been booked by someone else."},
                    )
                ],
            ),
        },
        examples=[
            OpenApiExample(
                "Booking request",
                value={"slot": 5, "notes": "Court 1 preferred"},
                request_only=True,
            ),
        ],
    )
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        slot_id = serializer.validated_data["slot"].pk

        try:
            with transaction.atomic():
                # Lock the row so concurrent requests queue up here
                slot = (
                    Slot.objects.select_for_update()
                    .get(pk=slot_id)
                )

                # Re-check availability inside the lock
                if not slot.is_available:
                    return Response(
                        {"detail": "This slot has just been booked by someone else."},
                        status=status.HTTP_409_CONFLICT,
                    )

                # Mark the slot as taken
                slot.is_available = False
                slot.save(update_fields=["is_available"])

                # Persist the booking, injecting the authenticated user
                booking = Booking.objects.create(
                    user=request.user,
                    slot=slot,
                    notes=serializer.validated_data.get("notes", ""),
                )

        except IntegrityError:
            # OneToOneField constraint fires if two requests slip through
            return Response(
                {"detail": "This slot is already booked. Please choose another slot."},
                status=status.HTTP_409_CONFLICT,
            )

        output = BookingSerializer(booking, context={"request": request})
        return Response(output.data, status=status.HTTP_201_CREATED)

    # ------------------------------------------------------------------
    # GET /users/{user_id}/bookings/  — list by user id (admin or self)
    # ------------------------------------------------------------------

    @extend_schema(
        tags=["Users"],
        summary="List bookings for a specific user",
        description=(
            "Returns all bookings for the given user ID. "
            "Authenticated users can only retrieve **their own** bookings — "
            "requesting another user's bookings returns `403 Forbidden`."
        ),
        parameters=[
            OpenApiParameter(
                name="user_pk",
                location=OpenApiParameter.PATH,
                description="ID of the user whose bookings to retrieve.",
                required=True,
                type=int,
            ),
        ],
        responses={
            200: BookingSerializer(many=True),
            403: OpenApiResponse(
                response=ErrorDetailSerializer,
                description="Access denied — can only view your own bookings.",
            ),
        },
    )
    def list_by_user(self, request, user_pk=None, *args, **kwargs):
        """
        Extra action registered in urls.py for GET /users/{id}/bookings/.
        Only the authenticated user can access their own bookings.
        """
        if str(request.user.pk) != str(user_pk):
            return Response(
                {"detail": "You do not have permission to view these bookings."},
                status=status.HTTP_403_FORBIDDEN,
            )

        bookings = Booking.objects.filter(user_id=user_pk).select_related(
            "slot__venue", "user"
        )
        serializer = self.get_serializer(bookings, many=True)
        return Response(serializer.data)
