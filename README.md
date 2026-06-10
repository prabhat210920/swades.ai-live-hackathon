# QuickSlot 🏟️
**A Premium Sports Venue Booking Platform**

[![Download APK](https://img.shields.io/badge/Download-APK-green.svg?style=for-the-badge&logo=android)](https://drive.google.com/uc?export=download&id=1uEaSJyZM_vqyM4MEnwzdu_lbJQBb2y_m)

> ⏱️ **Hackathon Timeline & Polish:** 
> The core, fully functional application (both frontend and backend) was successfully built and submitted within the strict **original 3-hour deadline**. When the organizers generously provided an optional 3-hour extension, I utilized that extra time exclusively for **codebase refinement and UI/UX polish**. I refactored large screens into a highly modular atomic widget architecture, optimized Riverpod state management, and smoothed out the micro-interactions—proving my dedication not just to making it work, but making it *beautiful and maintainable*.

## 🎥 App Demo Video

*(Watch QuickSlot in action!)*
https://drive.google.com/file/d/1IUeaBmNZXf9v7SxIiMPj0n19WvlFAXM5/view?usp=sharing

> ⚠️ **Important Note for Judges & Testers:** > The backend API is currently deployed on Render's free tier, which automatically goes to sleep after a period of inactivity. When you first open the app, your initial login or signup attempt might take up to 50 seconds to process (or time out on the very first try) while the server wakes up. Please be patient, wait a few moments, and try again! Once the server is awake, the app will be blazing fast. ⚡

---

QuickSlot is a modern, high-performance platform designed to make booking sports venues effortless. The project consists of a deeply optimized Flutter frontend focused on a minimalist user experience (UX), backed by a highly secure, concurrency-safe Django REST Framework API.

---

## 📱 Part 1: The Application (Frontend)

My primary focus for the mobile application was creating a premium, minimalist user experience backed by a highly modular, production-grade architecture. Instead of writing massive, tangled UI files, I strictly separated the UI into tiny, reusable components and managed the state efficiently using **Riverpod**.

### 1. Seamless Authentication (Login & Register)
* **What I did:** I created a clean, distraction-free authentication flow. Instead of duplicating code, I built a highly reusable `CustomTextField` that handles secure password toggling, input formatting, and inline validation errors.
* **State Management:** The UI listens to Riverpod controllers to show loading spinners inside the buttons and floating Snackbars for authentication failures, ensuring the user is always informed.

<p align="center">
  <img width="350" alt="Login Screen" src="https://github.com/user-attachments/assets/bafb123f-16da-4f45-b0a7-df0bc00f19d3" />
  <img width="350" alt="Register Screen" src="https://github.com/user-attachments/assets/330ea60b-a630-4d67-9edc-d0f721cdbd2c" />
</p>

### 2. Intelligent Discovery (Home Screen)
* **What I did:** The Home Screen acts as the central hub. I implemented a dynamic, sliver-based scrolling experience. To handle network latency gracefully, I built custom Shimmer loading skeletons so the user sees a smooth placeholder before the data arrives.
* **Instant Filtering:** I implemented a lightning-fast local search and category filter. When a user types in the search bar or taps a category (e.g., "Football"), Riverpod instantly filters the pre-fetched venue list locally. This eliminates unnecessary API calls and makes the app feel instantaneous.

<p align="center">
  <img width="350" alt="Home Screen" src="https://github.com/user-attachments/assets/51288978-2228-4f9c-9567-06756cf17e88" />
  <img width="350" alt="Filtered Home Screen" src="https://github.com/user-attachments/assets/2c28b2cd-7682-4389-b69a-19e5f90a58d7" />
</p>

### 3. The Booking Flow (Venue Details & Slot Selection)
* **What I did:** When a user taps a venue, they are taken to a detailed sliver-based layout.
  * **Dynamic Hero Image:** The top image dynamically loads from the network, with a built-in fallback to a local asset if the network fails.
  * **Interactive Date Strip:** I built a custom, scrollable 7-day date selector.
  * **Responsive Slot Grid:** Slots are fetched based on the selected date. The grid intelligently disables booked slots and highlights the user's selection, paired with a clean legend.
  * **Sticky Bottom Bar:** The price per hour and the "Book" button are anchored to the bottom of the screen, ensuring the primary Call-To-Action is always accessible.

<p align="center">
  <img width="350" alt="Venue Details" src="https://github.com/user-attachments/assets/f4669658-3994-4323-84ab-c4ddf2e64942" />
</p>

### 4. Frictionless Checkout (Confirmation Bottom Sheet)
* **What I did:** Instead of navigating to a completely new page and losing context, tapping "Book" slides up a sleek Confirmation Bottom Sheet. It calculates the dynamic pricing, summarizes the booking, and handles the final API call with loading states and error handling (e.g., if a slot is snatched by someone else at the last second).

<p align="center">
  <img width="350" alt="Checkout Sheet" src="https://github.com/user-attachments/assets/479cc0e6-13af-43bf-a4c0-970ac99f030f" />
  <img width="350" alt="Confirmed Booking" src="https://github.com/user-attachments/assets/891ffd28-acbe-4722-b032-3387e1aa3c05" />
</p>

### 5. Frontend Architecture & Code Quality
Beyond a beautiful UI, the true strength of QuickSlot lies in its codebase:
* **Atomic Widget Architecture:** I eliminated "God Classes" (massive files with thousands of lines of code). Every screen is composed of small, isolated widgets (e.g., `CategoryChips`, `VenueCard`, `SlotGridSection`). This means if a slot is selected, *only* the grid rebuilds, not the entire screen.
* **Decoupled State Management:** Using **Riverpod**, the business logic (fetching data, filtering, authenticating) is completely separated from the UI logic. The UI simply watches the state and reacts.
* **Declarative Navigation:** Using **GoRouter**, I implemented type-safe, declarative routing that makes passing data between screens safe and predictable.

---

## ⚙️ Part 2: The API (Backend)

The **Django REST Framework** backend powering QuickSlot is built for speed and reliability, featuring phone-number authentication, concurrency-safe slot reservations, and automated database seeding for easy testing.

### 🚀 Quick Links & Credentials

- **Live API Base URL:** `https://quickslot-api.onrender.com`
- **Interactive API Docs (Swagger):** [`/api/docs/`](https://swades-ai-live-hackathon.onrender.com/api/docs/)
- **Django Admin Panel:** [`/admin/`](https://swades-ai-live-hackathon.onrender.com/admin/)

**🔑 Demo Credentials**
Use these to log into the Admin Panel or test the API via Swagger:
* **Admin / Superuser:** Phone: `+910000000000` | Password: `admin@1234`
* **Standard Test User:** Phone: `+919999999999` | Password: `test@1234`

### 🛠️ Backend Tech Stack
* **Framework:** Django 6.0 & Django REST Framework (DRF)
* **Authentication:** SimpleJWT (Customized to use `phone_number` instead of `username`)
* **Database:** SQLite (Local Dev) / PostgreSQL (Deployment)
* **API Documentation:** `drf-spectacular` (OpenAPI 3)
* **Deployment:** Render (Gunicorn + WhiteNoise for static files)

### ✨ Key Backend Features

1. **Custom Phone Authentication:** Replaced Django's default username system with a custom `PhoneNumberBackend`. Users log in and register using just their phone number and password.
2. **Concurrency-Safe Bookings:** Uses Database Row-Level Locking (`SELECT FOR UPDATE`) and `OneToOneField` constraints to ensure a slot can never be double-booked, even if two users click "Book" at the exact same millisecond.
3. **Automated Seeding:** A custom management command (`python manage.py seed`) instantly populates the database with venues, users, and hundreds of bookable time slots to make judging and testing frictionless.

### 📡 Core API Endpoints

*Authentication is handled via `Authorization: Bearer <token>`.*

* **Auth:** 
  * `POST /auth/register/` - Create account & get tokens.
  * `POST /auth/login/` - Login & get tokens.
* **Venues (Public):**
  * `GET /venues/` - List all venues.
  * `GET /venues/{id}/slots/` - List available time slots for a specific venue (filterable by `?date=YYYY-MM-DD`).
* **Bookings (Protected):**
  * `POST /bookings/` - Book an available slot.
  * `GET /bookings/` - List the logged-in user's bookings.

*Note: Visit the **[Swagger Docs](https://swades-ai-live-hackathon.onrender.com/api/docs/)** for exact request/response payloads and to test the endpoints directly from your browser.*

---

## 💻 Local Development Setup (Backend)

Ensure you have Python 3.10+ installed.

```bash
# 1. Clone the repository and enter the backend directory
cd server

# 2. Create and activate a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set up environment variables
cp .env.example .env

# 5. Run migrations and seed the database with demo data
python manage.py migrate
python manage.py seed

# 6. Start the development server
python manage.py runserver
