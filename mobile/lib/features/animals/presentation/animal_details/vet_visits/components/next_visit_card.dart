import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/components/vet_visit_bottom_sheet.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextVisitCard extends StatelessWidget {
  final VetVisit visit;
  final bool canEdit;

  const NextVisitCard({super.key, required this.visit, this.canEdit = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: canEdit
          ? () => VetVisitBottomSheet.show(
              context: context,
              visit: visit,
              animalId: visit.animalId,
              isManager: true,
            )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryTint.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              //DATE
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMM').format(visit.visitDate).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd').format(visit.visitDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            //INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedType(context, visit.visitType),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n
                              .t('common.locationValue')
                              .replaceAll('{location}', visit.clinicName),
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedType(BuildContext context, VetVisitType type) =>
      switch (type) {
        VetVisitType.generalCheckup => context.l10n.t('vet.typeGeneralCheckup'),
        VetVisitType.vaccine => context.l10n.t('vet.typeVaccine'),
        VetVisitType.surgery => context.l10n.t('vet.typeSurgery'),
        VetVisitType.dental => context.l10n.t('vet.typeDental'),
        VetVisitType.emergency => context.l10n.t('vet.typeEmergency'),
        VetVisitType.other => context.l10n.t('vet.typeOther'),
      };
}
