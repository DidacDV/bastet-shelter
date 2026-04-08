import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical/components/add_vet_visit_dialog.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical/components/vet_visit_row.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
              Text('Vet Visits History', style: theme.textTheme.titleLarge),
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
              if (vetVisits.isEmpty) {
                return AppEmptyState(
                  icon: Icons.hourglass_empty,
                  title: "No past vet visits",
                  message: "You have not done any vet visits yet.",
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount:
                    vetVisits.length +
                    headerOverflow, //we add headerOverflow positions to include the header
                separatorBuilder: (_, index) => index == 0
                    ? const SizedBox(height: 8)
                    : const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) return VetVisitHeader();

                  final visit = vetVisits[index - headerOverflow];
                  return VetVisitRow(visit: visit);
                },
              );
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
