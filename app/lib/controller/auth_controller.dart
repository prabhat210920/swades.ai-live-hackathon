import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo/auth_repo.dart';

/// Tracks the user's overall authentication status.
/// Used by go_router redirect guard to decide which screen to show.
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? userPhone;
  final int? userId;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = true,
    this.userPhone,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? userPhone,
    int? userId,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      userPhone: userPhone ?? this.userPhone,
      userId: userId ?? this.userId,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check stored tokens on startup
    Future.microtask(() => _checkStoredToken());
    return const AuthState();
  }

  AuthRepo get _repo => ref.read(authRepoProvider);

  Future<void> _checkStoredToken() async {
    final hasToken = await _repo.hasValidToken();
    final phone = await _repo.getStoredPhone();
    final id = await _repo.getStoredUserId();
    state = state.copyWith(
      isLoggedIn: hasToken,
      isLoading: false,
      userPhone: phone,
      userId: id,
    );
  }

  void markLoggedIn({required String phone, required int userId}) {
    state = state.copyWith(
      isLoggedIn: true,
      isLoading: false,
      userPhone: phone,
      userId: userId,
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isLoggedIn: false, isLoading: false);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
