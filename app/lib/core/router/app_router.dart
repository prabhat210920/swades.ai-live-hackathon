import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../model/booking_model.dart';
import '../../view/booking_success_screen.dart';
import '../../view/home_screen.dart';
import '../../view/login_page.dart';
import '../../view/my_bookings_screen.dart';
import '../../view/profile_screen.dart';
import '../../view/register_screen.dart';
import '../../view/splash_screen.dart';
import '../../view/venue_detail_screen.dart';

// Route paths
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const venueDetail = '/venues/:id';
  static const bookings = '/bookings';
  static const profile = '/profile';
  static const bookingSuccess = '/booking-success';

  static String venueDetailPath(int id) => '/venues/$id';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      // ── 1. Still checking stored token → stay on splash ──────────────
      if (authState.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // ── 2. Splash is done loading → decide where to go ───────────────
      if (location == AppRoutes.splash) {
        return authState.isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      final isOnAuthPage =
          location == AppRoutes.login || location == AppRoutes.register;

      // ── 3. Not logged in on a protected route → go to login ──────────
      if (!authState.isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // ── 4. Logged in but on login/register → go to home ──────────────
      if (authState.isLoggedIn && isOnAuthPage) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.venueDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return VenueDetailScreen(venueId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.bookings,
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingSuccess,
        builder: (context, state) {
          final booking = state.extra as Booking;
          return BookingSuccessScreen(booking: booking);
        },
      ),
    ],
  );
});

/// Listens to [AuthController] and notifies GoRouter's refreshListenable
/// so the redirect guard re-runs whenever auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
