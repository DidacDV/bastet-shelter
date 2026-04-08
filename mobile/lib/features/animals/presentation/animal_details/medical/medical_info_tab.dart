import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical/components/add_vet_visit_dialog.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical/components/vet_visits_history_table.dart';
import 'package:bastetshelter/features/medical/presentation/manage_medicines_screen.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalInfoTab extends ConsumerWidget {
  final bool isManager;
  final int animalId;

  final int headerOverflow = 1;

  const MedicalInfoTab({
    super.key,
    this.isManager = true,
    required this.animalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetVisitsAsync = ref.watch(vetVisitsProvider(animalId));
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isManager)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AddVetVisitDialog(animalId: animalId),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Vet Visit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const ManageMedicinesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.medical_services_rounded),
                    tooltip: 'Manage Shelter Medicines',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text('Vet Visits History', style: theme.textTheme.titleLarge),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '(Click on a visit to see notes)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: vetVisitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Could not load vet visits.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            data: (vetVisits) {
              final pastVisits = vetVisits
                  .where((v) => v.visitDate.isBefore(DateTime.now()))
                  .toList();
              return VetVisitsHistoryTable(pastVisits: pastVisits);
            },
          ),
        ),
      ],
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
