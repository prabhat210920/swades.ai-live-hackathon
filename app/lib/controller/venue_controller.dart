import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/venue_model.dart';
import '../repo/venue_repo.dart';
import '../core/utils/error_handler.dart';

// ─── Venue List ───────────────────────────────────────────────────────────────

class VenueListState {
  final List<Venue> venues;
  final bool isLoading;
  final String? errorMessage;

  const VenueListState({
    this.venues = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  VenueListState copyWith({
    List<Venue>? venues,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VenueListState(
      venues: venues ?? this.venues,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class VenueListController extends AutoDisposeNotifier<VenueListState> {
  @override
  VenueListState build() {
    Future.microtask(() => fetchVenues());
    return const VenueListState(isLoading: true);
  }

  VenueRepo get _repo => ref.read(venueRepoProvider);

  Future<void> fetchVenues() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final venues = await _repo.getVenues();
      state = state.copyWith(venues: venues, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load venues. Pull to refresh.',
      );
    }
  }
}

final venueListControllerProvider =
    AutoDisposeNotifierProvider<VenueListController, VenueListState>(
      VenueListController.new,
    );

// ─── Venue Detail ─────────────────────────────────────────────────────────────

class VenueDetailState {
  final Venue? venue;
  final bool isLoading;
  final String? errorMessage;

  const VenueDetailState({
    this.venue,
    this.isLoading = false,
    this.errorMessage,
  });

  VenueDetailState copyWith({
    Venue? venue,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VenueDetailState(
      venue: venue ?? this.venue,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class VenueDetailController extends AutoDisposeNotifier<VenueDetailState> {
  @override
  VenueDetailState build() => const VenueDetailState();

  VenueRepo get _repo => ref.read(venueRepoProvider);

  Future<void> fetchVenue(int id) async {
    state = const VenueDetailState(isLoading: true);
    try {
      final venue = await _repo.getVenueDetail(id);
      state = VenueDetailState(venue: venue);
    } on AppException catch (e) {
      state = VenueDetailState(errorMessage: e.message);
    } catch (_) {
      state = const VenueDetailState(errorMessage: 'Failed to load venue.');
    }
  }
}

final venueDetailControllerProvider =
    AutoDisposeNotifierProvider<VenueDetailController, VenueDetailState>(
      VenueDetailController.new,
    );
