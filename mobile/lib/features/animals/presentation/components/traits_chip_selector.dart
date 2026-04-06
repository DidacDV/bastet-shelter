import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/providers/traits/trait_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TraitsChipSelector extends ConsumerWidget {
  final Set<int> selectedTraitIds;
  final Function(int traitId, bool isSelected) onToggle;

  const TraitsChipSelector({
    super.key,
    required this.selectedTraitIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traitsAsync = ref.watch(traitsProvider);

    return traitsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(
        'Could not load traits.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
      data: (traits) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: traits.map((trait) {
          final isSelected = selectedTraitIds.contains(trait.id);
          return FilterChip(
            label: Text(trait.name),
            selected: isSelected,
            onSelected: (val) => onToggle(trait.id, val),
          );
        }).toList(),
      ),
    );
  }
}
