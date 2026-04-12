import 'package:bastetshelter/features/animals/presentation/animal_details/vet/components/vet_visit_row.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/common/components/table/app_table.dart';
import 'package:bastetshelter/features/common/components/table/app_table_header.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';

class VetVisitsHistoryTable extends StatelessWidget {
  final List<VetVisit> pastVisits;

  const VetVisitsHistoryTable({super.key, required this.pastVisits});

  @override
  Widget build(BuildContext context) {
    if (pastVisits.isEmpty) {
      return const Expanded(
        child: AppEmptyState(
          icon: Icons.hourglass_empty,
          title: "No past vet visits",
          message: "You have not done any vet visits yet.",
        ),
      );
    }

    return Expanded(
      child: AppTable(
        itemCount: pastVisits.length,
        header: const AppTableHeader(
          columns: [
            AppTableColumn(label: 'DATE', flex: 4, textAlign: TextAlign.center),
            AppTableColumn(
              label: 'REASON',
              flex: 4,
              textAlign: TextAlign.center,
            ),
            AppTableColumn(
              label: 'CLINIC',
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
