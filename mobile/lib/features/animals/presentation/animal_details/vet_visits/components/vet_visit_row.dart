import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VetVisitRow extends StatelessWidget {
  final VetVisit visit;

  const VetVisitRow({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              DateFormat('dd/MM/yyyy').format(visit.visitDate),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            flex: 4,
            child: Text(
              _localizedType(context, visit.visitType),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            flex: 4,
            child: Text(
              visit.clinicName,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
