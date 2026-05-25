import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/section_card.dart';
import 'package:bastetshelter/features/shelter/data/shelter_model.dart';
import 'package:bastetshelter/features/shelter/presentation/components/refuge_list_item.dart';
import 'package:bastetshelter/features/shelter/presentation/components/add_refuge_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';

class RefugesCard extends ConsumerWidget {
  final Shelter shelter;

  const RefugesCard({super.key, required this.shelter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: context.l10n.t('shelter.refuges'),
      icon: Icons.holiday_village,
      trailingAction: IconButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const RefugeModal(),
        ),
        icon: const Icon(Icons.add_circle_outline),
        iconSize: 28,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (shelter.refuges.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                context.l10n.t('shelter.noRefugesAdded'),
                style: const TextStyle(
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
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => RefugeModal(
                      refugeId: refuge.id,
                      initialName: refuge.name,
                      initialProvinceId: refuge.province.id,
                    ),
                  ),
                  onDelete: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: context.l10n.t('shelter.deleteRefuge'),
                      message: context.l10n
                          .t('shelter.deleteRefugeMessage')
                          .replaceAll('{refuge}', refuge.name),
                      isDestructive: true,
                      confirmText: context.l10n.t('profile.delete'),
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
    );
  }
}
