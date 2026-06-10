import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/booking_model.dart';
import '../repo/booking_repo.dart';
import '../core/utils/error_handler.dart';

class BookingListState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? errorMessage;

  const BookingListState({
    this.bookings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BookingListState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<Booking> get upcoming =>
      bookings.where((b) => b.isConfirmed).toList();

  List<Booking> get past =>
      bookings.where((b) => b.isCancelled).toList();
}

class BookingListController extends AutoDisposeNotifier<BookingListState> {
  @override
  BookingListState build() {
    Future.microtask(() => fetchBookings());
    return const BookingListState(isLoading: true);
  }

  BookingRepo get _repo => ref.read(bookingRepoProvider);

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _repo.getMyBookings();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load bookings.',
      );
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      await _repo.cancelBooking(bookingId);
      // Optimistically remove from list
      final updated = state.bookings.where((b) => b.id != bookingId).toList();
      state = state.copyWith(bookings: updated);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to cancel booking.');
      return false;
    }
  }
}

final bookingListControllerProvider =
    AutoDisposeNotifierProvider<BookingListController, BookingListState>(
      BookingListController.new,
    );

// ─── Create Booking ───────────────────────────────────────────────────────────

class CreateBookingState {
  final bool isLoading;
  final Booking? createdBooking;
  final String? errorMessage;
  final bool isSlotTaken;

  const CreateBookingState({
    this.isLoading = false,
    this.createdBooking,
    this.errorMessage,
    this.isSlotTaken = false,
  });

  CreateBookingState copyWith({
    bool? isLoading,
    Booking? createdBooking,
    String? errorMessage,
    bool? isSlotTaken,
    bool clearError = false,
  }) {
    return CreateBookingState(
      isLoading: isLoading ?? this.isLoading,
      createdBooking: createdBooking ?? this.createdBooking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSlotTaken: isSlotTaken ?? this.isSlotTaken,
    );
  }
}

class CreateBookingController
    extends AutoDisposeNotifier<CreateBookingState> {
  @override
  CreateBookingState build() => const CreateBookingState();

  BookingRepo get _repo => ref.read(bookingRepoProvider);

  Future<bool> createBooking({
    required int slotId,
    String notes = '',
  }) async {
    state = const CreateBookingState(isLoading: true);
    try {
      final booking = await _repo.createBooking(slotId: slotId, notes: notes);
      state = CreateBookingState(createdBooking: booking);
      return true;
    } on SlotTakenException catch (e) {
      state = CreateBookingState(
        errorMessage: e.message,
        isSlotTaken: true,
      );
      return false;
    } on AppException catch (e) {
      state = CreateBookingState(errorMessage: e.message);
      return false;
    } catch (_) {
      state = const CreateBookingState(
        errorMessage: 'Booking failed. Please try again.',
      );
      return false;
    }
  }
}

final createBookingControllerProvider =
    AutoDisposeNotifierProvider<CreateBookingController, CreateBookingState>(
      CreateBookingController.new,
    );
