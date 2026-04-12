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
      title: 'Refuges',
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
                      title: 'Delete refuge',
                      message:
                          'Are you sure you want to delete ${refuge.name}?',
                      isDestructive: true,
                      confirmText: 'Delete',
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
