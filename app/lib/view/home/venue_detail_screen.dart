import 'package:QuickSlot/controller/slot_controller.dart';
import 'package:QuickSlot/controller/venue_controller.dart';
import 'package:QuickSlot/core/theme/app_theme.dart';
import 'package:QuickSlot/model/slot_model.dart';
import 'package:QuickSlot/model/venue_model.dart';
import 'package:QuickSlot/view/home/widgets/book_bottom_bar.dart';
import 'package:QuickSlot/view/home/widgets/confirm_booking_sheet.dart';
import 'package:QuickSlot/view/home/widgets/date_strip.dart';
import 'package:QuickSlot/view/home/widgets/slot_grid_selection.dart';
import 'package:QuickSlot/view/home/widgets/venue_hero_appbar.dart';
import 'package:QuickSlot/view/home/widgets/venue_info_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'widgets/venue_info_card.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final int venueId;

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
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
      ref
          .read(venueDetailControllerProvider.notifier)
          .fetchVenue(widget.venueId);
      _fetchSlots();
    });
  }

  void _fetchSlots() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    ref
        .read(slotControllerProvider.notifier)
        .fetchSlots(widget.venueId, dateStr);
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
      builder: (_) => ConfirmBookingSheet(
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
          // 1. Hero App Bar with Network Image
          VenueHeroAppBar(venue: venueState.venue),

          // 2. Venue Data Implementation
          if (venueState.isLoading)
            const SliverToBoxAdapter(child: VenueInfoShimmer())
          else if (venueState.venue != null) ...[
            SliverToBoxAdapter(
              child: VenueInfoCard(venue: venueState.venue!),
            ),
            SliverToBoxAdapter(
              child: DateStrip(
                days: _dateDays,
                selectedDate: _selectedDate,
                onSelected: _onDateSelected,
              ),
            ),
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
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      DateFormat('EEE, d MMM').format(_selectedDate),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            if (slotState.isLoading)
              const SliverToBoxAdapter(child: SlotsShimmer())
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
                child: SlotGridSection(
                  slots: slotState.slots,
                  selectedSlotId: slotState.selectedSlotId,
                  onSelect: (id) =>
                      ref.read(slotControllerProvider.notifier).selectSlot(id),
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

      // 3. Bottom Book Bar
      bottomNavigationBar: venueState.venue != null
          ? BookBottomBar(
              selectedSlot: slotState.selectedSlot,
              venue: venueState.venue!,
              onBookNow: (slot) => _onBookNow(context, slot, venueState.venue!),
            )
          : null,
    );
  }
}
