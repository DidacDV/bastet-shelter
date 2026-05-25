import 'package:bastetshelter/core/localization/app_localizations.dart';
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
      title: context.l10n.t('shelter.info'),
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
          LabelValue(label: context.l10n.t('common.name'), value: shelter.name),
          const SizedBox(height: 12),
          LabelValue(
            label: context.l10n.t('auth.email'),
            value: shelter.email ?? context.l10n.t('common.notProvided'),
          ),
          const SizedBox(height: 12),
          LabelValue(
            label: context.l10n.t('common.location'),
            value: shelter.province.name,
          ),
          const Divider(height: 32),
          LabelValue(
            label: context.l10n.t('shelter.volunteerCode'),
            value:
                shelter.volunteerCode ?? context.l10n.t('common.notAvailable'),
          ),
          const SizedBox(height: 12),
          LabelValue(
            label: context.l10n.t('shelter.managerCode'),
            value: shelter.managerCode ?? context.l10n.t('common.notAvailable'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () =>
                      ref.read(shelterProvider.notifier).resetVolunteerCode(),
                  child: Text(
                    context.l10n.t('shelter.resetVolunteerCode'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () =>
                      ref.read(shelterProvider.notifier).resetManagerCode(),
                  child: Text(
                    context.l10n.t('shelter.resetManagerCode'),
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
