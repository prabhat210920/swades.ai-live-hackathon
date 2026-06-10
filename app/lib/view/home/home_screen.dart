import 'package:QuickSlot/controller/venue_controller.dart';
import 'package:QuickSlot/core/router/app_router.dart';
import 'package:QuickSlot/core/theme/app_theme.dart';
import 'package:QuickSlot/view/home/widgets/category_chips.dart';
import 'package:QuickSlot/view/home/widgets/error_state.dart';
import 'package:QuickSlot/view/home/widgets/home_app_bar.dart';
import 'package:QuickSlot/view/home/widgets/serach_bar_widget.dart';
import 'package:QuickSlot/view/home/widgets/shimmer_loading_card.dart';
import 'package:QuickSlot/view/home/widgets/venue_card.dart';
import 'package:QuickSlot/view/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueState = ref.watch(venueListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            const HomeAppBar(),

            // Main Scrollable Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref
                    .read(venueListControllerProvider.notifier)
                    .fetchVenues(),
                child: CustomScrollView(
                  slivers: [
                    // Greeting Section
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ready to play?',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Bar
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: SearchBarWidget(),
                      ),
                    ),

                    // Categories
                    const SliverToBoxAdapter(
                      child: CategoryChips(),
                    ),

                    // Section Header
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Text(
                          'Available Venues',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    // Venue List Implementation based on state
                    if (venueState.isLoading)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, __) => const VenueShimmerCard(),
                            childCount: 4,
                          ),
                        ),
                      )
                    else if (venueState.errorMessage != null)
                      SliverFillRemaining(
                        child: ErrorStateWidget(
                          message: venueState.errorMessage!,
                          onRetry: () => ref
                              .read(venueListControllerProvider.notifier)
                              .fetchVenues(),
                        ),
                      )
                    else if (venueState.venues.isEmpty)
                      const SliverFillRemaining(
                        child: EmptyStateWidget(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => VenueCard(
                              venue: venueState.venues[index],
                              onTap: () => context.push(
                                AppRoutes.venueDetailPath(
                                  venueState.venues[index].id,
                                ),
                              ),
                            ),
                            childCount: venueState.venues.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
