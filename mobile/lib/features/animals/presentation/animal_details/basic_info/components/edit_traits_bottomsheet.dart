import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/presentation/components/traits_chip_selector.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/providers/traits/trait_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTraitsBottomSheet extends ConsumerStatefulWidget {
  final List<int> initialTraitIds;
  final Future<void> Function(List<int> traitIds) onSave;

  const EditTraitsBottomSheet({
    super.key,
    required this.initialTraitIds,
    required this.onSave,
  });

  @override
  ConsumerState<EditTraitsBottomSheet> createState() =>
      _EditTraitsBottomSheetState();
}

class _EditTraitsBottomSheetState extends ConsumerState<EditTraitsBottomSheet> {
  late final Set<int> _selectedTraitIds;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedTraitIds = widget.initialTraitIds.toSet();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await widget.onSave(_selectedTraitIds.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final allTraitsAsync = ref.watch(traitsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.t('traits.editTraits'),
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          allTraitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text(
              context.l10n.t('traits.loadError').replaceAll('{error}', '$err'),
            ),
            data: (allTraits) {
              if (allTraits.isEmpty) {
                return Text(
                  context.l10n.t('traits.addOnConfigHint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                );
              }

              return TraitsChipSelector(
                selectedTraitIds: _selectedTraitIds,
                onToggle: (id, isSelected) {
                  setState(() {
                    isSelected
                        ? _selectedTraitIds.add(id)
                        : _selectedTraitIds.remove(id);
                  });
                },
              );
            },
          ),

          const SizedBox(height: 32),

          PrimaryButton(
            label: context.l10n.t('traits.saveTraits'),
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

void showEditTraitsBottomSheet({
  required BuildContext context,
  required List<int> initialTraitIds,
  required Future<void> Function(List<int>) onSave,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        EditTraitsBottomSheet(initialTraitIds: initialTraitIds, onSave: onSave),
  );
}
