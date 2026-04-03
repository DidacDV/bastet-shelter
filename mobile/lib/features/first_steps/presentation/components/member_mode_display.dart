import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class MemberModeDisplay extends StatelessWidget {
  final bool isVolunteer;
  const MemberModeDisplay({super.key, required this.isVolunteer});

  @override
  Widget build(BuildContext context) {
    final color = isVolunteer ? AppColors.primary : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isVolunteer ? 'VOLUNTEER' : 'MANAGER',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
