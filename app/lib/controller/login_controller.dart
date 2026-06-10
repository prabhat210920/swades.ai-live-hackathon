import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final String phone;
  final String password;
  final bool obscurePassword;
  final bool isLoading;

  LoginState({
    this.phone = '',
    this.password = '',
    this.obscurePassword = true,
    this.isLoading = false,
  });

  LoginState copyWith({
    String? phone,
    String? password,
    bool? obscurePassword,
    bool? isLoading,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LoginController extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() {
    return LoginState();
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<void> login() async {
    // TODO: Integrate actual authentication logic here
    state = state.copyWith(isLoading: true);

    // Simulating network delay
    await Future.delayed(const Duration(seconds: 2));

    print('Logging in with Phone: ${state.phone}');

    state = state.copyWith(isLoading: false);
  }
}

final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
      () => LoginController(),
    );
