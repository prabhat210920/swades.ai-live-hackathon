import 'package:QuickSlot/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/register_controller.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/registration_card.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show error SnackBar when there is a non-field error
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
                // Header Image
                Image.asset(
                  Assets.homePage,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // The Extracted Form Component
                const RegisterFormCard(),

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
}
