import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class ShiftsBody extends StatelessWidget {
  final int activeRefugeId;
  final String activeRefugeName;

  const ShiftsBody({
    super.key,
    required this.activeRefugeId,
    required this.activeRefugeName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Text(
          'Shifts content for $activeRefugeName (ID: $activeRefugeId) goes here!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
