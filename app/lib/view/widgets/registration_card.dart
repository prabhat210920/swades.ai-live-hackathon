import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/register_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

class RegisterFormCard extends ConsumerWidget {
  const RegisterFormCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Join QuickSlot to book your first slot',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Phone Number Input
          CustomTextField(
            hintText: 'Phone Number (e.g. +919999999999)',
            icon: Icons.phone_outlined,
            onChanged: controller.updatePhone,
            keyboardType: TextInputType.phone,
            errorText: state.fieldErrors?['phone_number'],
          ),
          const SizedBox(height: 16),

          // Password Input
          CustomTextField(
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: state.obscurePassword,
            onChanged: controller.updatePassword,
            errorText: state.fieldErrors?['password'],
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black54,
              ),
              onPressed: controller.toggleObscurePassword,
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Password Input
          CustomTextField(
            hintText: 'Confirm Password',
            icon: Icons.lock_outline,
            obscureText: state.obscureConfirm,
            onChanged: controller.updatePasswordConfirm,
            errorText: state.fieldErrors?['password_confirm'],
            suffixIcon: IconButton(
              icon: Icon(
                state.obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black54,
              ),
              onPressed: controller.toggleObscureConfirm,
            ),
          ),
          const SizedBox(height: 28),

          // Register Button
          PrimaryButton(
            text: 'Create Account',
            isLoading: state.isLoading,
            onPressed: () async {
              final ok = await controller.register();
              if (!ok && context.mounted) {
                // Field errors are automatically displayed inline
              }
            },
          ),
          const SizedBox(height: 20),

          // Bottom Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: Colors.black54),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: const Text(
                  'Sign In',
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
