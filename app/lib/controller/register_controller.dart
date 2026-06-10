import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo/auth_repo.dart';
import '../core/utils/error_handler.dart';
import 'auth_controller.dart';

class RegisterState {
  final String phone;
  final String password;
  final String passwordConfirm;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String>? fieldErrors;

  const RegisterState({
    this.phone = '',
    this.password = '',
    this.passwordConfirm = '',
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors,
  });

  RegisterState copyWith({
    String? phone,
    String? password,
    String? passwordConfirm,
    bool? obscurePassword,
    bool? obscureConfirm,
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) {
    return RegisterState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: clearError ? null : (fieldErrors ?? this.fieldErrors),
    );
  }
}

class RegisterController extends AutoDisposeNotifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  AuthRepo get _repo => ref.read(authRepoProvider);

  void updatePhone(String v) =>
      state = state.copyWith(phone: v, clearError: true);
  void updatePassword(String v) =>
      state = state.copyWith(password: v, clearError: true);
  void updatePasswordConfirm(String v) =>
      state = state.copyWith(passwordConfirm: v, clearError: true);
  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  Future<bool> register() async {
    // Client-side validation
    if (state.phone.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Phone number is required.');
      return false;
    }
    if (state.password.length < 6) {
      state = state.copyWith(
        errorMessage: 'Password must be at least 6 characters.',
      );
      return false;
    }
    if (state.password != state.passwordConfirm) {
      state = state.copyWith(errorMessage: 'Passwords do not match.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await _repo.register(
        phoneNumber: state.phone.trim(),
        password: state.password,
        passwordConfirm: state.passwordConfirm,
      );
      ref.read(authControllerProvider.notifier).markLoggedIn(
        phone: auth.user.phoneNumber,
        userId: auth.user.id,
      );
      return true;
    } on AppException catch (e) {
      // Build field-level error map for inline display
      Map<String, String>? fieldErrors;
      if (e.fieldErrors != null) {
        fieldErrors = e.fieldErrors!.map(
          (k, v) => MapEntry(k, v.isNotEmpty ? v.first : ''),
        );
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        fieldErrors: fieldErrors,
      );
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

final registerControllerProvider =
    AutoDisposeNotifierProvider<RegisterController, RegisterState>(
      RegisterController.new,
    );
