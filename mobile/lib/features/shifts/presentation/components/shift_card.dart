import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key, required this.shift, this.onTap});

  final Shift shift;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final timeFormat = DateFormat('HH:mm');

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Row(
                children: [
                  Text(
                    timeFormat.format(shift.startTime),
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("-"),
                  const SizedBox(width: 12),
                  Text(
                    timeFormat.format(shift.endTime),
                    style: tt.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              const VerticalDivider(width: 1, color: AppColors.outline),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      shift.maxParticipants != null
                          ? '${shift.currentParticipants} / ${shift.maxParticipants}'
                          : 'No limit',
                      style: tt.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
