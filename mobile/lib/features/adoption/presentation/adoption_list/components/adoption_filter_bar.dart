import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/providers/adoption/adoption_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionFilterBar extends ConsumerWidget {
  const AdoptionFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adoptionFilterProvider);
    final notifier = ref.read(adoptionFilterProvider.notifier);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        children: [
          FilterChip(
            label: Text(context.l10n.t('adoption.statusPending')),
            selected: filter.status == AdoptionProcessStatus.pending,
            onSelected: (_) =>
                notifier.setStatus(AdoptionProcessStatus.pending),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(context.l10n.t('adoption.statusCompleted')),
            selected: filter.status == AdoptionProcessStatus.completed,
            onSelected: (_) =>
                notifier.setStatus(AdoptionProcessStatus.completed),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(context.l10n.t('adoption.statusRejected')),
            selected: filter.status == AdoptionProcessStatus.rejected,
            onSelected: (_) =>
                notifier.setStatus(AdoptionProcessStatus.rejected),
          ),
        ],
      ),
    );
  }
}
