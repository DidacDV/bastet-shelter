import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/components/add_vet_visit_dialog.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/components/next_visit_card.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/components/vet_visits_history_table.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VetInfoTab extends ConsumerWidget {
  const VetInfoTab({super.key, this.isManager = true, required this.animalId});

  final bool isManager;
  final int animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetVisitsAsync = ref.watch(vetVisitsProvider(animalId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isManager)
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
              data: (visits) =>
                  _VetVisitsContent(visits: visits, animalId: animalId),
            ),
          ),
      ],
    );
  }
}

class _VetVisitsContent extends StatelessWidget {
  const _VetVisitsContent({required this.visits, required this.animalId});

  final List<VetVisit> visits;
  final int animalId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);

    final nextVisit =
        (visits.where((v) => v.visitDate.isAfter(now)).toList()
              ..sort((a, b) => a.visitDate.compareTo(b.visitDate)))
            .firstOrNull;

    final pastVisits = visits.where((v) => !v.visitDate.isAfter(now)).toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppConstants.tabsPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SectionHeader(
                    icon: Icons.next_plan_outlined,
                    label: 'Next visit',
                  ),
                  FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AddVetVisitDialog(animalId: animalId),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Plan visit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (nextVisit != null)
                NextVisitCard(visit: nextVisit)
              else
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 4),
                  child: Text(
                    'No upcoming vet visits planned.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              _SectionHeader(
                icon: Icons.history_rounded,
                label: 'Vet Visits History',
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    'Tap on a visit to view details or edit.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        VetVisitsHistoryTable(pastVisits: pastVisits),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
