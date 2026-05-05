import 'package:bastetshelter/features/common/components/fields/label_value.dart';
import 'package:bastetshelter/features/common/components/section_card.dart';
import 'package:bastetshelter/features/shelter/data/shelter_model.dart';
import 'package:bastetshelter/features/shelter/presentation/components/edit_shelter_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';

class ShelterInfoCard extends ConsumerWidget {
  final Shelter shelter;

  const ShelterInfoCard({super.key, required this.shelter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Shelter Info',
      icon: Icons.pets,
      trailingAction: IconButton(
        icon: const Icon(Icons.edit),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => EditShelterModal(
            currentName: shelter.name,
            currentProvinceId: shelter.province.id,
            currentEmail: shelter.email,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelValue(label: 'Name', value: shelter.name),
          const SizedBox(height: 12),
          LabelValue(label: 'Email', value: shelter.email ?? 'Not provided'),
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
                  onPressed: () =>
                      ref.read(shelterProvider.notifier).resetVolunteerCode(),
                  child: const Text(
                    'Reset Vol. Code',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () =>
                      ref.read(shelterProvider.notifier).resetManagerCode(),
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
    );
  }
}
