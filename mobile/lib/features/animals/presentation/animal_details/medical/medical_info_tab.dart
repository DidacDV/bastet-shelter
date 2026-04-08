import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical/components/add_vet_visit_dialog.dart';
import 'package:bastetshelter/features/medical/presentation/manage_medicines_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalInfoTab extends ConsumerWidget {
  final bool isManager;
  final int animalId;

  const MedicalInfoTab({
    super.key,
    this.isManager = true,
    required this.animalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
          Text('Vet Visits History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
