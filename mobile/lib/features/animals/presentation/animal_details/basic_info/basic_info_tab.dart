import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/basic_info/components/animal_traits_display.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/basic_info/components/edit_traits_bottomsheet.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/dropdowns/refuge_dropdown.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicInfoTab extends ConsumerWidget {
  final int animalId;
  final bool isManager;

  const BasicInfoTab({
    super.key,
    required this.animalId,
    this.isManager = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animal = ref
        .watch(animalDetailProvider(animalId))
        .whenOrNull(data: (d) => d);
    if (animal == null) return const SizedBox.shrink();

    final shelterAsync = ref.watch(shelterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditableField(
            label: "Breed",
            value: animal.breed,
            canEdit: isManager,
            onEdit: () => showEditBottomSheet(
              context: context,
              label: "Breed",
              initialValue: animal.breed,
              onSave: (newValue) async {
                await ref
                    .read(animalsProvider.notifier)
                    .updateAnimal(animalId: animalId, breed: newValue);
                ref.invalidate(animalDetailProvider(animalId));
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          EditableField(
            label: "Description",
            value: animal.description,
            canEdit: isManager,
            onEdit: () => showEditBottomSheet(
              context: context,
              label: "Description",
              initialValue: animal.description,
              keyboardType: TextInputType.multiline,
              onSave: (newValue) async {
                await ref
                    .read(animalsProvider.notifier)
                    .updateAnimal(animalId: animalId, description: newValue);
                ref.invalidate(animalDetailProvider(animalId));
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          AnimalTraitsDisplay(
            animalTraitIds: animal.traits.map((t) => t.id).toList(),
            canEdit: isManager,
            onEdit: () {
              showEditTraitsBottomSheet(
                context: context,
                initialTraitIds: animal.traits.map((t) => t.id).toList(),
                onSave: (newTraitIds) async {
                  await ref
                      .read(animalsProvider.notifier)
                      .updateAnimal(animalId: animal.id, traitIds: newTraitIds);
                },
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Text(
            'REFUGE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          shelterAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text(e.toString()),
            data: (shelter) => RefugeDropdown(
              showLabel: false,
              items: shelter.refuges
                  .map((r) => RefugeItem(id: r.id, name: r.name))
                  .toList(),
              initialItem: animal.refugeId,
              onChanged: (v) async {
                if (v == null) return;
                await ref
                    .read(animalsProvider.notifier)
                    .updateAnimal(animalId: animalId, refugeId: v);
                ref.invalidate(animalDetailProvider(animalId));
              },
            ),
          ),
          if (isManager) ...[
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await ConfirmationDialog.show(
                    context: context,
                    title: 'Delete Animal',
                    message:
                        'Are you sure you want to delete the record for "${animal.name}"? This action cannot be undone.',
                    isDestructive: true,
                    confirmText: 'Delete',
                  );
                  if (confirm == true) {
                    await ref
                        .read(animalsProvider.notifier)
                        .deleteAnimal(animalId);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text(
                  'Delete Animal Record',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
