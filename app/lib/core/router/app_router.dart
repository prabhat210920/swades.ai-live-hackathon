import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';

// Route names
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const venueDetail = '/venues/:id';
  static const bookings = '/bookings';
  static const profile = '/profile';

  static String venueDetailPath(int id) => '/venues/$id';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state to trigger router refresh
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);

      // While checking token, stay on splash
      if (authState.isLoading) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      // Not logged in → send to login
      if (!authState.isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // Logged in → don't show splash/login/register
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
    ],
  );
});

/// A [ChangeNotifier] that listens to [AuthController] changes
/// so go_router's [refreshListenable] can rebuild routes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
