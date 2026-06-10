import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/auth_controller.dart';
import '../core/theme/app_theme.dart';

/// Splash screen — shown while [AuthController] checks stored tokens.
/// GoRouter's redirect guard handles navigation once [AuthState.isLoading]
/// becomes false. A 5-second safety timeout forces isLoading=false
/// in case the secure storage read hangs.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    // Safety timeout: if auth check takes > 5 seconds, force-complete it
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final authState = ref.read(authControllerProvider);
        if (authState.isLoading) {
          // Force auth controller to stop loading (treat as not logged in)
          ref.read(authControllerProvider.notifier).forceNotLoading();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // App name
            FadeTransition(
              opacity: _textFadeAnimation,
              child: const Text(
                'QuickSlot',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: const Text(
                'Sports Slot Booking',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 60),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
