import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/booking_controller.dart';
import '../core/theme/app_theme.dart';
import '../model/booking_model.dart';
import 'widgets/app_bottom_nav.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onCancel(BuildContext context, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Booking',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await ref
          .read(bookingListControllerProvider.notifier)
          .cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'Booking cancelled.' : 'Failed to cancel. Try again.',
            ),
            backgroundColor: ok ? AppColors.primary : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: state.isLoading
          ? _buildShimmer()
          : state.errorMessage != null
              ? _buildError(state.errorMessage!, ref)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref
                      .read(bookingListControllerProvider.notifier)
                      .fetchBookings(),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming
                      state.upcoming.isEmpty
                          ? _EmptyBookingsState(
                              message: 'No upcoming bookings',
                              sub: 'Find a venue and book your next session!',
                              icon: Icons.calendar_today_rounded,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: state.upcoming.length,
                              itemBuilder: (context, index) => _BookingCard(
                                booking: state.upcoming[index],
                                onCancel: () => _onCancel(
                                    context, state.upcoming[index].id),
                              ),
                            ),

                      // Past / Cancelled
                      state.past.isEmpty
                          ? _EmptyBookingsState(
                              message: 'No past bookings',
                              sub: 'Your booking history will appear here.',
                              icon: Icons.history_rounded,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: state.past.length,
                              itemBuilder: (context, index) => _BookingCard(
                                booking: state.past[index],
                                onCancel: null,
                              ),
                            ),
                    ],
                  ),
                ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref
                .read(bookingListControllerProvider.notifier)
                .fetchBookings(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, this.onCancel});

  final Booking booking;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final slot = booking.slotDetail;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 44,
                color: Colors.white24,
              ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        slot?.venueName.isNotEmpty == true
                            ? slot!.venueName
                            : 'Sports Venue #${booking.slot}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: booking.status),
                  ],
                ),
                const SizedBox(height: 6),

                // Date & time
                if (slot != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${slot.date} • ${slot.timeRange}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                // Price + cancel action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '₹400.00',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onCancel != null && booking.isConfirmed)
                      GestureDetector(
                        onTap: onCancel,
                        child: const Text(
                          'Cancel Booking',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = AppColors.confirmedBg;
        fg = AppColors.confirmedText;
        label = 'Confirmed';
        break;
      case 'cancelled':
        bg = AppColors.cancelledBg;
        fg = AppColors.cancelledText;
        label = 'Cancelled';
        break;
      default:
        bg = AppColors.pendingBg;
        fg = AppColors.pendingText;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyBookingsState extends StatelessWidget {
  const _EmptyBookingsState({
    required this.message,
    required this.sub,
    required this.icon,
  });

  final String message;
  final String sub;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
