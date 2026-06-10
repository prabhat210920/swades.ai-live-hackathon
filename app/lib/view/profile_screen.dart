import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/auth_controller.dart';
import '../core/theme/app_theme.dart';
import 'widgets/app_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final phone = authState.userPhone ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _initials(phone),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'QuickSlot Member',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(label: 'Bookings', value: '—'),
                      _StatDivider(),
                      _StatCard(label: 'Venues', value: '—'),
                      _StatDivider(),
                      _StatCard(label: 'Hours', value: '—'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── Menu Items ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () {},
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  _Divider(),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About QuickSlot',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── Logout ───────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                labelColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                showChevron: false,
                onTap: () => _confirmLogout(context, ref),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2024 QuickSlot Sports Booking',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      // GoRouter redirect will handle navigation to login
    }
  }

  String _initials(String phone) {
    // Last 2 digits of phone as "initials"
    if (phone.length >= 2) return phone.substring(phone.length - 2);
    return phone;
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border,
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 60),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
