import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo/auth_repo.dart';
import '../core/utils/error_handler.dart';
import 'auth_controller.dart';

class LoginState {
  final String phone;
  final String password;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;

  const LoginState({
    this.phone = '',
    this.password = '',
    this.obscurePassword = true,
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    String? phone,
    String? password,
    bool? obscurePassword,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LoginController extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  AuthRepo get _repo => ref.read(authRepoProvider);

  void updatePhone(String value) =>
      state = state.copyWith(phone: value, clearError: true);

  void updatePassword(String value) =>
      state = state.copyWith(password: value, clearError: true);

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Returns true on success so the UI can navigate.
  Future<bool> login() async {
    if (state.phone.trim().isEmpty || state.password.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter your phone number and password.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await _repo.login(
        phoneNumber: state.phone.trim(),
        password: state.password,
      );
      ref.read(authControllerProvider.notifier).markLoggedIn(
        phone: auth.user.phoneNumber,
        userId: auth.user.id,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Please try again.',
      );
      return false;
    }
  }
}

final loginControllerProvider =
    AutoDisposeNotifierProvider<LoginController, LoginState>(
      LoginController.new,
    );
