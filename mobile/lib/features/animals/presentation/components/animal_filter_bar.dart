import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/providers/animals/animal_filter_provider.dart';

class AnimalFilterBar extends ConsumerWidget {
  const AnimalFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(animalFilterProvider);
    final notifier = ref.read(animalFilterProvider.notifier);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        children: [
          FilterChip(
            label: Text(
              filter.inAdoption == false
                  ? context.l10n.t('animals.notInAdoption')
                  : context.l10n.t('animals.inAdoption'),
            ),
            selected: filter.inAdoption != null,
            onSelected: (_) =>
                notifier.setInAdoption(switch (filter.inAdoption) {
                  null => true,
                  true => false,
                  false => null,
                }),
          ),

          const SizedBox(width: 8),

          FilterChip(
            label: Text(context.l10n.t('animals.pendingTasks')),
            selected: filter.hasPendingTasks,
            onSelected: (bool isSelected) =>
                notifier.setHasPendingTasks(isSelected),
          ),
        ],
      ),
    );
  }
}
