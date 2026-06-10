from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


# ---------------------------------------------------------------------------
# Custom User Manager
# ---------------------------------------------------------------------------

class CustomUserManager(BaseUserManager):
    """Manager that uses phone_number as the unique identifier."""

    def create_user(self, phone_number, password=None, **extra_fields):
        if not phone_number:
            raise ValueError("The phone number must be set")
        user = self.model(phone_number=phone_number, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(phone_number, password, **extra_fields)


# ---------------------------------------------------------------------------
# Custom User Model
# ---------------------------------------------------------------------------

class CustomUser(AbstractBaseUser, PermissionsMixin):
    phone_number = models.CharField(max_length=20, unique=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = CustomUserManager()

    USERNAME_FIELD = "phone_number"
    REQUIRED_FIELDS = []

    class Meta:
        db_table = "users"
        verbose_name = "User"
        verbose_name_plural = "Users"

    def __str__(self):
        return self.phone_number


# ---------------------------------------------------------------------------
# Venue
# ---------------------------------------------------------------------------

class Venue(models.Model):
    name = models.CharField(max_length=255)
    address = models.TextField()
    city = models.CharField(max_length=100)
    description = models.TextField(blank=True, default="")
    # URL pointing to a representative photo of the venue (e.g. hosted on Cloudinary, S3, etc.)
    image_url = models.URLField(blank=True, default="", help_text="Public URL of the venue image.")
    # List of sports offered, e.g. ["Badminton", "Squash", "Table Tennis"]
    sports = models.JSONField(
        default=list,
        blank=True,
        help_text="List of sports available at this venue, e.g. ['Badminton', 'Squash'].",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "venues"
        ordering = ["name"]

    def __str__(self):
        return f"{self.name} — {self.city}"


# ---------------------------------------------------------------------------
# Slot
# ---------------------------------------------------------------------------

class Slot(models.Model):
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE, related_name="slots")
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "slots"
        # A venue cannot have two slots at the exact same date/start_time
        unique_together = [("venue", "date", "start_time")]
        ordering = ["date", "start_time"]

    def __str__(self):
        return f"{self.venue.name} | {self.date} {self.start_time}–{self.end_time}"


# ---------------------------------------------------------------------------
# Booking
# ---------------------------------------------------------------------------

class Booking(models.Model):
    class Status(models.TextChoices):
        CONFIRMED = "confirmed", "Confirmed"
        CANCELLED = "cancelled", "Cancelled"

    user = models.ForeignKey(
        CustomUser, on_delete=models.CASCADE, related_name="bookings"
    )
    slot = models.OneToOneField(
        Slot, on_delete=models.CASCADE, related_name="booking"
    )
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.CONFIRMED
    )
    booked_at = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(blank=True, default="")

    class Meta:
        db_table = "bookings"
        ordering = ["-booked_at"]

    def __str__(self):
        return f"Booking #{self.pk} — {self.user.phone_number} @ {self.slot}"
