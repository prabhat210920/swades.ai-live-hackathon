import 'package:QuickSlot/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller/login_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/login_form_card.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show error SnackBar on login failure
    ref.listen<LoginState>(loginControllerProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
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
                // Header Image
                Image.asset(
                  Assets.homePage,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // The Extracted Form Component
                const LoginFormCard(),

                const SizedBox(height: 40),
                const Text(
                  '© 2026 QuickSlot Sports Booking. All rights reserved.',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
