import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../model/venue_model.dart';

class VenueInfoCard extends StatelessWidget {
  final Venue venue;

  const VenueInfoCard({super.key, required this.venue});

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
                        color: AppColors.textSecondary, fontSize: 13),
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
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
          const SizedBox(height: 16),
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
            children: const [
              _FacilityChip(
                  icon: Icons.local_parking_rounded, label: 'Parking'),
              SizedBox(width: 12),
              _FacilityChip(icon: Icons.wc_rounded, label: 'Washroom'),
              SizedBox(width: 12),
              _FacilityChip(icon: Icons.restaurant_rounded, label: 'Cafeteria'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityChip({required this.icon, required this.label});

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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
