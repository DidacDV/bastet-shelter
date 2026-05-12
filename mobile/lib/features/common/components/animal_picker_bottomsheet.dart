import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalPickerBottomSheet extends ConsumerWidget {
  const AnimalPickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsProvider);
    final theme = Theme.of(context);

    return FormBottomSheet(
      title: 'Select Animal',
      actions: [],
      children: [
        Text(
          'Choose an animal to link to these tasks.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        animalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (animals) {
            if (animals.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Text('No animals found.'),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: animals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final animal = animals[index];

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.outline),
                  ),
                  tileColor: AppColors.surface,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryTint,
                    backgroundImage: animal.imageUrl != null
                        ? NetworkImage(animal.imageUrl!)
                        : null,
                    child: animal.imageUrl == null
                        ? const Icon(Icons.pets, color: AppColors.primary)
                        : null,
                  ),
                  title: Text(
                    animal.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    animal.refugeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => Navigator.pop(context, animal),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

Future<dynamic> showAnimalPickerBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const AnimalPickerBottomSheet(),
  );
}
