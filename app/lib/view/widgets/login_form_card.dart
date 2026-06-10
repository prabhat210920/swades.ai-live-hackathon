import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/login_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

class LoginFormCard extends ConsumerWidget {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ready for your next game?',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // Phone Number Input
          CustomTextField(
            hintText: 'Phone Number',
            icon: Icons.phone_outlined,
            onChanged: controller.updatePhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Password Input
          CustomTextField(
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onChanged: controller.updatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black54,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 32),

          // Login Button
          PrimaryButton(
            text: 'Login',
            isLoading: state.isLoading,
            onPressed: () => controller.login(),
          ),
          const SizedBox(height: 24),

          // Forgot Password Link
          TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.black54),
              ),
              GestureDetector(
                onTap: () =>
                    context.go(AppRoutes.register), // Imperative navigation
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
