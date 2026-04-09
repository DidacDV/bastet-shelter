import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet/components/add_vet_visit_dialog.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet/components/next_visit_card.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet/components/vet_visits_history_table.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
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
              data: (visits) => _VetVisitsContent(visits: visits),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: _AddVisitButton(animalId: animalId),
        ),
      ],
    );
  }
}

class _AddVisitButton extends StatelessWidget {
  const _AddVisitButton({required this.animalId});

  final int animalId;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => AddVetVisitDialog(animalId: animalId),
      ),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add Vet Visit'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        minimumSize: const Size.fromHeight(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _VetVisitsContent extends StatelessWidget {
  const _VetVisitsContent({required this.visits});

  final List<VetVisit> visits;

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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nextVisit != null) ...[
                _SectionHeader(
                  icon: Icons.next_plan_outlined,
                  label: 'Next visit',
                ),
                const SizedBox(height: 8),
                NextVisitCard(visit: nextVisit),
                const SizedBox(height: 24),
              ],
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
