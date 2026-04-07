import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
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
        ],
      ),
    );
  }
}
