"""
Management command: seed
Usage:
    python manage.py seed              # seed venues + slots for next 7 days + test user
    python manage.py seed --clear      # wipe existing data first, then seed
    python manage.py seed --days 14    # generate slots for next 14 days
"""

import datetime

from django.core.management.base import BaseCommand
from django.utils import timezone

from bookings.models import CustomUser, Slot, Venue


# ---------------------------------------------------------------------------
# Seed data — venues
# ---------------------------------------------------------------------------

VENUES = [
    {
        "name": "Koramangala Sports Arena",
        "address": "80 Feet Road, Koramangala 4th Block",
        "city": "Bengaluru",
        "description": "Premium indoor sports complex with 6 badminton courts and 2 squash courts.",
    },
    {
        "name": "Indiranagar Cricket Ground",
        "address": "100 Feet Road, Indiranagar",
        "city": "Bengaluru",
        "description": "Open-air cricket ground with a turf pitch and practice nets.",
    },
    {
        "name": "HSR Futsal Club",
        "address": "Sector 7, HSR Layout",
        "city": "Bengaluru",
        "description": "5-a-side and 7-a-side football turf, floodlit for night matches.",
    },
    {
        "name": "Powai Aquatic Centre",
        "address": "Hiranandani Gardens, Powai",
        "city": "Mumbai",
        "description": "Olympic-size swimming pool with separate learner's pool and spa.",
    },
    {
        "name": "Bandra Tennis Academy",
        "address": "Hill Road, Bandra West",
        "city": "Mumbai",
        "description": "4 clay courts and 2 hard courts with on-site coaching available.",
    },
]

# ---------------------------------------------------------------------------
# Slot time blocks per day
# Each tuple: (start_time, end_time)
# ---------------------------------------------------------------------------

SLOT_TIMES = [
    (datetime.time(6, 0),  datetime.time(7, 0)),
    (datetime.time(7, 0),  datetime.time(8, 0)),
    (datetime.time(8, 0),  datetime.time(9, 0)),
    (datetime.time(9, 0),  datetime.time(10, 0)),
    (datetime.time(10, 0), datetime.time(11, 0)),
    (datetime.time(11, 0), datetime.time(12, 0)),
    (datetime.time(14, 0), datetime.time(15, 0)),
    (datetime.time(15, 0), datetime.time(16, 0)),
    (datetime.time(16, 0), datetime.time(17, 0)),
    (datetime.time(17, 0), datetime.time(18, 0)),
    (datetime.time(18, 0), datetime.time(19, 0)),
    (datetime.time(19, 0), datetime.time(20, 0)),
    (datetime.time(20, 0), datetime.time(21, 0)),
    (datetime.time(21, 0), datetime.time(22, 0)),
]


class Command(BaseCommand):
    help = "Seed the database with sample venues, slots, and a test user."

    def add_arguments(self, parser):
        parser.add_argument(
            "--clear",
            action="store_true",
            help="Delete all existing venues, slots, and bookings before seeding.",
        )
        parser.add_argument(
            "--days",
            type=int,
            default=7,
            help="Number of days ahead to generate slots for (default: 7).",
        )

    def handle(self, *args, **options):
        clear = options["clear"]
        days_ahead = options["days"]

        if clear:
            self.stdout.write("🗑️  Clearing existing data...")
            Slot.objects.all().delete()
            Venue.objects.all().delete()
            self.stdout.write(self.style.WARNING("   Venues and slots cleared."))

        # ------------------------------------------------------------------
        # 1. Create default superuser (admin)
        # ------------------------------------------------------------------
        admin_phone = "+910000000000"
        admin_password = "admin@1234"

        if not CustomUser.objects.filter(phone_number=admin_phone).exists():
            CustomUser.objects.create_superuser(
                phone_number=admin_phone,
                password=admin_password,
            )
            self.stdout.write(self.style.SUCCESS(
                f"✅ Superuser created  → phone: {admin_phone}  password: {admin_password}"
            ))
        else:
            self.stdout.write(f"ℹ️  Superuser already exists: {admin_phone}")

        # ------------------------------------------------------------------
        # 2. Create test user
        # ------------------------------------------------------------------
        test_phone = "+919999999999"
        test_password = "test@1234"

        user, created = CustomUser.objects.get_or_create(phone_number=test_phone)
        if created:
            user.set_password(test_password)
            user.save()
            self.stdout.write(self.style.SUCCESS(
                f"✅ Test user created  → phone: {test_phone}  password: {test_password}"
            ))
        else:
            self.stdout.write(f"ℹ️  Test user already exists: {test_phone}")

        # ------------------------------------------------------------------
        # 3. Create venues
        # ------------------------------------------------------------------
        venues_created = 0
        venue_objects = []

        for v in VENUES:
            venue, created = Venue.objects.get_or_create(
                name=v["name"],
                defaults={
                    "address": v["address"],
                    "city": v["city"],
                    "description": v["description"],
                },
            )
            venue_objects.append(venue)
            if created:
                venues_created += 1

        self.stdout.write(self.style.SUCCESS(
            f"✅ Venues: {venues_created} created, {len(VENUES) - venues_created} already existed"
        ))

        # ------------------------------------------------------------------
        # 4. Create slots — for each venue, for next N days
        # ------------------------------------------------------------------
        today = timezone.now().date()
        slots_created = 0
        slots_skipped = 0

        for venue in venue_objects:
            for day_offset in range(days_ahead):
                slot_date = today + datetime.timedelta(days=day_offset)

                for start_time, end_time in SLOT_TIMES:
                    slot, created = Slot.objects.get_or_create(
                        venue=venue,
                        date=slot_date,
                        start_time=start_time,
                        defaults={
                            "end_time": end_time,
                            "is_available": True,
                        },
                    )
                    if created:
                        slots_created += 1
                    else:
                        slots_skipped += 1

        self.stdout.write(self.style.SUCCESS(
            f"✅ Slots:  {slots_created} created, {slots_skipped} already existed"
        ))

        # ------------------------------------------------------------------
        # Summary
        # ------------------------------------------------------------------
        self.stdout.write("")
        self.stdout.write("=" * 50)
        self.stdout.write(self.style.SUCCESS("🌱 Seeding complete!"))
        self.stdout.write(f"   Venues : {Venue.objects.count()}")
        self.stdout.write(f"   Slots  : {Slot.objects.count()}")
        self.stdout.write(f"   Users  : {CustomUser.objects.count()}")
        self.stdout.write("")
        self.stdout.write("🔑 Superuser credentials:")
        self.stdout.write(f"   phone_number : {admin_phone}")
        self.stdout.write(f"   password     : {admin_password}")
        self.stdout.write("")
        self.stdout.write("📱 Test user credentials:")
        self.stdout.write(f"   phone_number : {test_phone}")
        self.stdout.write(f"   password     : {test_password}")
        self.stdout.write("=" * 50)
