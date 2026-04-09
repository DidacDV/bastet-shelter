import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
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
              visit.visitType.label,
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
}
