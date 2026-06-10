import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../model/slot_model.dart';

class SlotGridSection extends StatelessWidget {
  final List<Slot> slots;
  final int? selectedSlotId;
  final ValueChanged<int> onSelect;

  const SlotGridSection({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The Grid
        Padding(
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
                          const Icon(Icons.check,
                              color: Colors.white, size: 14),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // The Legend
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 100),
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
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
