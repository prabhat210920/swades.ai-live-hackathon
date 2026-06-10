from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import Booking, CustomUser, Slot, Venue


@admin.register(CustomUser)
class CustomUserAdmin(BaseUserAdmin):
    ordering = ["phone_number"]
    list_display = ["phone_number", "is_active", "is_staff", "date_joined"]
    fieldsets = (
        (None, {"fields": ("phone_number", "password")}),
        ("Permissions", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Important dates", {"fields": ("last_login", "date_joined")}),
    )
    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("phone_number", "password1", "password2"),
        }),
    )
    search_fields = ["phone_number"]


@admin.register(Venue)
class VenueAdmin(admin.ModelAdmin):
    list_display = [
        "name",
        "city",
        "price_per_hour",
        "sports_display",
        "image_preview",
        "created_at",
    ]
    list_filter = ["city"]
    search_fields = ["name", "city"]
    readonly_fields = ["image_preview", "created_at", "updated_at"]

    fieldsets = (
        ("Basic Info", {
            "fields": ("name", "address", "city", "description"),
        }),
        ("Media", {
            "fields": ("image_url", "image_preview"),
            "description": "Paste a public image URL (e.g. from Unsplash, Cloudinary, or S3).",
        }),
        ("Sports & Pricing", {
            "fields": ("sports", "price_per_hour"),
            "description": (
                "Enter sports as a JSON list, e.g. [\"Badminton\", \"Squash\"]. "
                "Price is in INR per one-hour slot."
            ),
        }),
        ("Timestamps", {
            "fields": ("created_at", "updated_at"),
            "classes": ("collapse",),
        }),
    )

    # ------------------------------------------------------------------
    # Custom display helpers
    # ------------------------------------------------------------------

    @admin.display(description="Sports")
    def sports_display(self, obj):
        return ", ".join(obj.sports) if obj.sports else "—"

    @admin.display(description="Image Preview")
    def image_preview(self, obj):
        from django.utils.html import format_html
        if obj.image_url:
            return format_html(
                '<img src="{}" style="height:60px; border-radius:4px; object-fit:cover;" />',
                obj.image_url,
            )
        return "—"


@admin.register(Slot)
class SlotAdmin(admin.ModelAdmin):
    list_display = ["venue", "date", "start_time", "end_time", "is_available"]
    list_filter = ["is_available", "date"]
    search_fields = ["venue__name"]


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "slot", "status", "booked_at"]
    list_filter = ["status"]
    search_fields = ["user__phone_number"]
