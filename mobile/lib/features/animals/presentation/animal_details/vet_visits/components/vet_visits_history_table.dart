import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/components/vet_visit_row.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/common/components/table/app_table.dart';
import 'package:bastetshelter/features/common/components/table/app_table_header.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';

class VetVisitsHistoryTable extends StatelessWidget {
  final List<VetVisit> pastVisits;

  const VetVisitsHistoryTable({super.key, required this.pastVisits});

  @override
  Widget build(BuildContext context) {
    if (pastVisits.isEmpty) {
      return Expanded(
        child: AppEmptyState(
          icon: Icons.hourglass_empty,
          title: context.l10n.t('vet.noPastVisits'),
          message: context.l10n.t('vet.noPastVisitsMessage'),
        ),
      );
    }

    return Expanded(
      child: AppTable(
        itemCount: pastVisits.length,
        header: AppTableHeader(
          columns: [
            AppTableColumn(
              label: context.l10n.t('common.date').toUpperCase(),
              flex: 4,
              textAlign: TextAlign.center,
            ),
            AppTableColumn(
              label: context.l10n.t('vet.reason').toUpperCase(),
              flex: 4,
              textAlign: TextAlign.center,
            ),
            AppTableColumn(
              label: context.l10n.t('vet.clinic').toUpperCase(),
              flex: 4,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        rowBuilder: (context, index) => VetVisitRow(visit: pastVisits[index]),
      ),
    );
  }
}
