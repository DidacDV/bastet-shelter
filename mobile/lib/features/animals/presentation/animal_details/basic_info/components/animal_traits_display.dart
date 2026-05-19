import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/providers/traits/trait_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalTraitsDisplay extends ConsumerWidget {
  final List<int> animalTraitIds;
  final bool canEdit;
  final VoidCallback? onEdit;

  const AnimalTraitsDisplay({
    super.key,
    required this.animalTraitIds,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    final allTraitsAsync = ref.watch(traitsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.t('traits.title').toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            if (canEdit)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.primary,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        allTraitsAsync.when(
          loading: () => const CircularProgressIndicator(strokeWidth: 2),
          error: (_, _) => Text(
            context.l10n.t('traits.failedToLoad'),
            style: const TextStyle(color: AppColors.error),
          ),
          data: (allTraits) {
            final myTraits = allTraits
                .where((t) => animalTraitIds.contains(t.id))
                .toList();

            if (myTraits.isEmpty) {
              return Text(
                context.l10n.t('traits.noneAssigned'),
                style: tt.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: myTraits.map((trait) {
                return Chip(
                  label: Text(
                    trait.name,
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
