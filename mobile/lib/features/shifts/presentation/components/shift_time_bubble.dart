import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class ShiftTimeBubble extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;

  final Color? backgroundColor;
  final Color? textColor;

  const ShiftTimeBubble({
    super.key,
    required this.startTime,
    required this.endTime,
    this.backgroundColor,
    this.textColor,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = backgroundColor ?? AppColors.primaryTint;
    final textCol = textColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textCol.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 14, color: textCol),
          const SizedBox(width: 6),
          Text(
            '${_formatTime(startTime)} - ${_formatTime(endTime)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: textCol,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
