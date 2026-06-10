import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/register_controller.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    // Show error SnackBar when there's a non-field error
    ref.listen<RegisterState>(registerControllerProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage &&
          (next.fieldErrors == null || next.fieldErrors!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Card
                Container(
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

                      // Phone
                      _buildTextField(
                        hintText: 'Phone Number (e.g. +919999999999)',
                        icon: Icons.phone_outlined,
                        onChanged: controller.updatePhone,
                        keyboardType: TextInputType.phone,
                        errorText: state.fieldErrors?['phone_number'],
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
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

                      // Confirm Password
                      _buildTextField(
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

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final ok = await controller.register();
                                  if (!ok && context.mounted) {
                                    // field errors already shown inline
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Already have account
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
                ),

                const SizedBox(height: 40),
                const Text(
                  '© 2024 QuickSlot Sports Booking. All rights reserved.',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Icon(Icons.check, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 8),
        const Text(
          'QuickSlot',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return TextFormField(
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: suffixIcon,
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
