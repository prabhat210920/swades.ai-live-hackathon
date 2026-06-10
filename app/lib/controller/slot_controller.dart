import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/slot_model.dart';
import '../repo/venue_repo.dart';
import '../core/utils/error_handler.dart';

class SlotState {
  final List<Slot> slots;
  final bool isLoading;
  final String? errorMessage;
  final int? selectedSlotId;

  const SlotState({
    this.slots = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSlotId,
  });

  SlotState copyWith({
    List<Slot>? slots,
    bool? isLoading,
    String? errorMessage,
    int? selectedSlotId,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return SlotState(
      slots: slots ?? this.slots,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedSlotId:
          clearSelected ? null : (selectedSlotId ?? this.selectedSlotId),
    );
  }

  Slot? get selectedSlot {
    if (selectedSlotId == null) return null;
    try {
      return slots.firstWhere((s) => s.id == selectedSlotId);
    } catch (_) {
      return null;
    }
  }
}

class SlotController extends AutoDisposeNotifier<SlotState> {
  @override
  SlotState build() => const SlotState();

  VenueRepo get _repo => ref.read(venueRepoProvider);

  Future<void> fetchSlots(int venueId, String date) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelected: true,
    );
    try {
      final slots = await _repo.getSlots(venueId, date);
      state = state.copyWith(slots: slots, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load slots.',
      );
    }
  }

  void selectSlot(int slotId) {
    // Toggle: deselect if already selected
    if (state.selectedSlotId == slotId) {
      state = state.copyWith(clearSelected: true);
    } else {
      state = state.copyWith(selectedSlotId: slotId);
    }
  }

  void clearSelection() => state = state.copyWith(clearSelected: true);
}

final slotControllerProvider =
    AutoDisposeNotifierProvider<SlotController, SlotState>(
      SlotController.new,
    );
