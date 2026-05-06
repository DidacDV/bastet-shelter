import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/pick_refuge_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftsHeader extends ConsumerWidget {
  final String activeRefugeName;
  final int activeRefugeId;
  final bool hasMultipleRefuges;
  final List<dynamic> refuges;

  const ShiftsHeader({
    super.key,
    required this.activeRefugeName,
    required this.activeRefugeId,
    required this.hasMultipleRefuges,
    required this.refuges,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activeRefugeName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (hasMultipleRefuges)
            TextButton(
              onPressed: () => showPickRefugeBottomSheet(
                context: context,
                refuges: refuges,
                currentId: activeRefugeId,
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Change'),
            ),
        ],
      ),
    );
  }
}
