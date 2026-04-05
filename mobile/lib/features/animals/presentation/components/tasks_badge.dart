import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class TasksBadge extends StatelessWidget {
  final int count;

  const TasksBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 10,
            color: AppColors.surface,
          ),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.surface,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
