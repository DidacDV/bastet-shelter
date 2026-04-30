import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class DateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool canEdit;
  final Color backgroundColor;
  final VoidCallback? onEdit;

  const DateChip({
    super.key,
    required this.label,
    required this.date,
    required this.backgroundColor,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                MaterialLocalizations.of(context).formatMediumDate(date),
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
