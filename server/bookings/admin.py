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
    list_display = ["name", "city", "sports_display", "created_at"]
    search_fields = ["name", "city"]

    @admin.display(description="Sports")
    def sports_display(self, obj):
        return ", ".join(obj.sports) if obj.sports else "—"


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
