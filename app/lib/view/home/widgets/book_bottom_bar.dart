import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../model/slot_model.dart';
import '../../../model/venue_model.dart';

class BookBottomBar extends StatelessWidget {
  final Slot? selectedSlot;
  final Venue venue;
  final ValueChanged<Slot> onBookNow;

  const BookBottomBar({
    super.key,
    required this.selectedSlot,
    required this.venue,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
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
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Text(
                  '₹${venue.pricePerHour.toStringAsFixed(0)}',
                  style: const TextStyle(
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
