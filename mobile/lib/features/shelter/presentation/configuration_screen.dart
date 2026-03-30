import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/label_value.dart';
import 'package:bastetshelter/features/common/components/section_card.dart';
import 'package:bastetshelter/features/shelter/presentation/components/edit_shelter_modal.dart';
import 'package:bastetshelter/features/shelter/presentation/components/refuge_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/providers/shelter_notifier.dart';

import 'components/add_refuge_modal.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);

    return shelterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(e.toString(), style: const TextStyle(color: Colors.red)),
      ),
      data: (shelter) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              title: 'Shelter Info',
              icon: Icons.pets,
              trailingAction: IconButton(
                icon: const Icon(Icons.edit),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => EditShelterModal(
                    currentName: shelter.name,
                    currentProvinceId: shelter.province.id,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelValue(label: 'Name', value: shelter.name),
                  const SizedBox(height: 12),
                  LabelValue(label: 'Location', value: shelter.province.name),
                  const Divider(height: 32),
                  LabelValue(
                    label: 'Volunteer Code',
                    value: shelter.volunteerCode ?? 'Not available',
                  ),
                  const SizedBox(height: 12),
                  LabelValue(
                    label: 'Manager Code',
                    value: shelter.managerCode ?? 'Not available',
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => ref
                              .read(shelterProvider.notifier)
                              .resetVolunteerCode(),
                          child: const Text(
                            'Reset Vol. Code',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => ref
                              .read(shelterProvider.notifier)
                              .resetManagerCode(),
                          child: const Text(
                            'Reset Mgr. Code',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SectionCard(
              title: 'Refuges',
              icon: Icons.holiday_village,
              trailingAction: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const RefugeModal(),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (shelter.refuges.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'No refuges added yet.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...shelter.refuges.map(
                      (refuge) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RefugeListItem(
                          name: refuge.name,
                          location: refuge.province.name,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => RefugeModal(
                                refugeId: refuge.id,
                                initialName: refuge.name,
                                initialProvinceId: refuge.province.id,
                              ),
                            );
                          },
                          onDelete: () async {
                            final confirm = await ConfirmationDialog.show(
                              context: context,
                              title: "Delete refuge",
                              message:
                                  "Are you sure you want to delete ${refuge.name}?",
                              isDestructive: true,
                              confirmText: "Delete",
                            );
                            if (confirm) {
                              await ref
                                  .read(shelterProvider.notifier)
                                  .deleteRefuge(refuge.id);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
