import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/booking_controller.dart';
import '../controller/slot_controller.dart';
import '../controller/venue_controller.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../model/booking_model.dart';
import '../model/slot_model.dart';
import '../model/venue_model.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final int venueId;

  @override
  ConsumerState<VenueDetailScreen> createState() =>
      _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  late DateTime _selectedDate;
  final List<DateTime> _dateDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Build 7-day strip starting from today
    for (int i = 0; i < 7; i++) {
      _dateDays.add(DateTime.now().add(Duration(days: i)));
    }

    // Fetch venue + initial slots
    Future.microtask(() {
      ref.read(venueDetailControllerProvider.notifier).fetchVenue(widget.venueId);
      _fetchSlots();
    });
  }

  void _fetchSlots() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    ref.read(slotControllerProvider.notifier).fetchSlots(widget.venueId, dateStr);
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    _fetchSlots();
  }

  Future<void> _onBookNow(BuildContext context, Slot slot, Venue venue) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmBookingSheet(
        slot: slot,
        venue: venue,
        venueId: widget.venueId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueState = ref.watch(venueDetailControllerProvider);
    final slotState = ref.watch(slotControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Hero App Bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient placeholder for venue image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sports_soccer_rounded,
                        size: 72,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                  // Rating chip at bottom right
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '4.8 (120 reviews)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Venue Info ───────────────────────────────────────────────
          if (venueState.isLoading)
            const SliverToBoxAdapter(
              child: _VenueInfoShimmer(),
            )
          else if (venueState.venue != null) ...[
            SliverToBoxAdapter(
              child: _VenueInfoCard(venue: venueState.venue!),
            ),

            // ─── Date Strip ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _DateStrip(
                days: _dateDays,
                selectedDate: _selectedDate,
                onSelected: _onDateSelected,
              ),
            ),

            // ─── Slots Section ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, d MMM').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (slotState.isLoading)
              const SliverToBoxAdapter(child: _SlotsShimmer())
            else if (slotState.slots.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No slots available for this date.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: _SlotGrid(
                  slots: slotState.slots,
                  selectedSlotId: slotState.selectedSlotId,
                  onSelect: (id) =>
                      ref.read(slotControllerProvider.notifier).selectSlot(id),
                ),
              ),

            // Slot Legend
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 100),
                child: Row(
                  children: [
                    _LegendDot(color: Colors.white, label: 'Available'),
                    SizedBox(width: 16),
                    _LegendDot(color: Color(0xFFEEEEEE), label: 'Booked'),
                    SizedBox(width: 16),
                    _LegendDot(color: AppColors.primary, label: 'Selected'),
                  ],
                ),
              ),
            ),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    venueState.errorMessage ?? 'Failed to load venue.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
        ],
      ),

      // ─── Bottom Book Bar ───────────────────────────────────────────────
      bottomNavigationBar: venueState.venue != null
          ? _BookBottomBar(
              selectedSlot: slotState.selectedSlot,
              venue: venueState.venue!,
              onBookNow: (slot) =>
                  _onBookNow(context, slot, venueState.venue!),
            )
          : null,
    );
  }
}

// ─── Venue Info Card ───────────────────────────────────────────────────────────

class _VenueInfoCard extends StatelessWidget {
  const _VenueInfoCard({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            venue.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (venue.address.isNotEmpty || venue.city.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [venue.address, venue.city]
                        .where((s) => s.isNotEmpty)
                        .join(', '),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          if (venue.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              venue.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Facilities chips
          const Text(
            'FACILITIES',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FacilityChip(icon: Icons.local_parking_rounded, label: 'Parking'),
              const SizedBox(width: 12),
              _FacilityChip(icon: Icons.wc_rounded, label: 'Washroom'),
              const SizedBox(width: 12),
              _FacilityChip(icon: Icons.restaurant_rounded, label: 'Cafeteria'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

// ─── Date Strip ────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.days,
    required this.selectedDate,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(selectedDate);

                return GestureDetector(
                  onTap: () => onSelected(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(day).toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormat('d').format(day),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(day),
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot Grid ─────────────────────────────────────────────────────────────────

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selectedSlotId,
    required this.onSelect,
  });

  final List<Slot> slots;
  final int? selectedSlotId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          final isSelected = slot.id == selectedSlotId;
          final isBooked = !slot.isAvailable;

          return GestureDetector(
            onTap: isBooked ? null : () => onSelect(slot.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isBooked
                        ? const Color(0xFFEEEEEE)
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isBooked
                          ? const Color(0xFFDDDDDD)
                          : AppColors.border,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slot.startLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isBooked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.white, size: 14),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Legend Dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Bottom Book Bar ───────────────────────────────────────────────────────────

class _BookBottomBar extends StatelessWidget {
  const _BookBottomBar({
    required this.selectedSlot,
    required this.venue,
    required this.onBookNow,
  });

  final Slot? selectedSlot;
  final Venue venue;
  final ValueChanged<Slot> onBookNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Price per hour',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const Text(
                  '₹400.00',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: selectedSlot != null
                    ? () => onBookNow(selectedSlot!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  selectedSlot != null ? 'Book Now →' : 'Select a Slot',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Booking Sheet ─────────────────────────────────────────────────────

class _ConfirmBookingSheet extends ConsumerWidget {
  const _ConfirmBookingSheet({
    required this.slot,
    required this.venue,
    required this.venueId,
  });

  final Slot slot;
  final Venue venue;
  final int venueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createBookingControllerProvider);
    final createCtrl = ref.read(createBookingControllerProvider.notifier);

    // Listen for slot-taken or generic error
    ref.listen<CreateBookingState>(createBookingControllerProvider,
        (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.isSlotTaken
                ? '⚡ Slot just taken! Pick another time.'
                : next.errorMessage!),
            backgroundColor:
                next.isSlotTaken ? Colors.orange : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      if (next.createdBooking != null &&
          next.createdBooking != prev?.createdBooking) {
        Navigator.of(context).pop();
        context.push(
          AppRoutes.bookingSuccess,
          extra: next.createdBooking,
        );
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Confirm Your Slot',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review your booking details below',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Booking summary card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(slot.date,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.access_time_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(slot.timeRange,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment summary
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'PAYMENT SUMMARY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _PayRow(label: 'Base Price (1h)', value: '₹400.00'),
                const Divider(height: 16, color: AppColors.border),
                _PayRow(
                  label: 'Total Amount',
                  value: '₹400.00',
                  isBold: true,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Info note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Free cancellation up to 24 hours before the start time.',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: createState.isLoading
                  ? null
                  : () async {
                      await createCtrl.createBooking(slotId: slot.id);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: createState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm Booking',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ─── Shimmer Placeholders ──────────────────────────────────────────────────────

class _VenueInfoShimmer extends StatelessWidget {
  const _VenueInfoShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 20, width: 200, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 140, color: Colors.white),
            const SizedBox(height: 12),
            Container(height: 14, width: double.infinity, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 14, width: 260, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SlotsShimmer extends StatelessWidget {
  const _SlotsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
