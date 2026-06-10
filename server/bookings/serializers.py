from django.contrib.auth import authenticate
from rest_framework import serializers

from .models import Booking, CustomUser, Slot, Venue


# ---------------------------------------------------------------------------
# Auth serializer — phone_number + password → JWT tokens
# ---------------------------------------------------------------------------

class PhoneTokenObtainSerializer(serializers.Serializer):
    """
    Custom login serializer: accepts phone_number + password,
    delegates to Django's authenticate() (which uses CustomUser.USERNAME_FIELD),
    and returns SimpleJWT access + refresh tokens.
    """

    phone_number = serializers.CharField(write_only=True)
    password = serializers.CharField(write_only=True, style={"input_type": "password"})

    def validate(self, attrs):
        phone_number = attrs.get("phone_number")
        password = attrs.get("password")

        user = authenticate(
            request=self.context.get("request"),
            username=phone_number,   # Django's authenticate() maps 'username' to USERNAME_FIELD
            password=password,
        )

        if not user:
            raise serializers.ValidationError(
                "Unable to log in with the provided credentials.", code="authorization"
            )

        if not user.is_active:
            raise serializers.ValidationError("User account is disabled.", code="authorization")

        # Attach the user so the view can generate tokens
        attrs["user"] = user
        return attrs


# ---------------------------------------------------------------------------
# Registration serializer
# ---------------------------------------------------------------------------

class RegisterSerializer(serializers.Serializer):
    """
    Registers a new user with a phone number and password.
    Returns JWT tokens immediately so the user is logged in after signup.
    """
    phone_number = serializers.CharField(
        max_length=20,
        help_text="Unique phone number used as the login identifier (e.g. +919876543210).",
    )
    password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={"input_type": "password"},
        help_text="Password (minimum 8 characters).",
    )
    password_confirm = serializers.CharField(
        write_only=True,
        style={"input_type": "password"},
        help_text="Repeat the password to confirm.",
    )

    def validate_phone_number(self, value):
        if CustomUser.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError(
                "A user with this phone number already exists."
            )
        return value

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError(
                {"password_confirm": "Passwords do not match."}
            )
        return attrs

    def create(self, validated_data):
        validated_data.pop("password_confirm")
        return CustomUser.objects.create_user(
            phone_number=validated_data["phone_number"],
            password=validated_data["password"],
        )



# ---------------------------------------------------------------------------
# Venue serializer
# ---------------------------------------------------------------------------

class VenueSerializer(serializers.ModelSerializer):
    class Meta:
        model = Venue
        fields = ["id", "name", "address", "city", "description", "created_at", "updated_at"]
        read_only_fields = ["id", "created_at", "updated_at"]


# ---------------------------------------------------------------------------
# Slot serializer
# ---------------------------------------------------------------------------

class SlotSerializer(serializers.ModelSerializer):
    venue_name = serializers.CharField(source="venue.name", read_only=True)

    class Meta:
        model = Slot
        fields = [
            "id",
            "venue",
            "venue_name",
            "date",
            "start_time",
            "end_time",
            "is_available",
            "created_at",
        ]
        read_only_fields = ["id", "created_at"]


# ---------------------------------------------------------------------------
# Booking serializer
# ---------------------------------------------------------------------------

class BookingSerializer(serializers.ModelSerializer):
    slot_detail = SlotSerializer(source="slot", read_only=True)
    user_phone = serializers.CharField(source="user.phone_number", read_only=True)

    class Meta:
        model = Booking
        fields = [
            "id",
            "user",
            "user_phone",
            "slot",
            "slot_detail",
            "status",
            "booked_at",
            "notes",
        ]
        read_only_fields = ["id", "user", "user_phone", "booked_at", "slot_detail"]

    # ------------------------------------------------------------------
    # Field-level validation: slot date must not be in the past
    # ------------------------------------------------------------------

    def validate_slot(self, slot):
        from django.utils import timezone
        import datetime

        today = timezone.now().date()
        if slot.date < today:
            raise serializers.ValidationError(
                "You cannot book a slot that is in the past."
            )
        return slot

    # ------------------------------------------------------------------
    # Object-level validation: slot must still be available
    # ------------------------------------------------------------------

    def validate(self, attrs):
        slot = attrs.get("slot")
        if slot and not slot.is_available:
            raise serializers.ValidationError(
                {"slot": "This slot is already booked or unavailable."}
            )
        return attrs
