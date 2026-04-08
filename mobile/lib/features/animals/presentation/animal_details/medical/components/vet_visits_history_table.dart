import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical/components/vet_visit_row.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';

class VetVisitsHistoryTable extends StatelessWidget {
  final List<VetVisit> pastVisits;

  const VetVisitsHistoryTable({super.key, required this.pastVisits});

  @override
  Widget build(BuildContext context) {
    const int headerOverflow = 1;

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
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scrollbar(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pastVisits.length + headerOverflow,
              separatorBuilder: (_, index) => index == 0
                  ? const Divider(
                      height: 16,
                      thickness: 1,
                      color: AppColors.divider,
                    )
                  : Divider(
                      height: 16,
                      thickness: 0.5,
                      color: AppColors.divider.withValues(alpha: 0.5),
                    ),
              itemBuilder: (context, index) {
                if (index == 0) return const VetVisitHeader();

                final visit = pastVisits[index - headerOverflow];
                return VetVisitRow(visit: visit);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class VetVisitHeader extends StatelessWidget {
  const VetVisitHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'DATE',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'REASON',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'CLINIC',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }
}
