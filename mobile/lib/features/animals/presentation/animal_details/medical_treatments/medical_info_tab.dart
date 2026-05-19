import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/theme.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/components/view_treatment_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/common/components/section_badge.dart';
import 'package:bastetshelter/features/common/components/table/app_table.dart';
import 'package:bastetshelter/features/common/components/table/app_table_header.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:bastetshelter/providers/medical_treatments/medical_treatment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/create_treatment_bottom_sheet.dart'
    show showAddTreatmentBottomSheet;

class MedicalTreatmentsTab extends ConsumerWidget {
  final bool isManager;
  final int animalId;

  const MedicalTreatmentsTab({
    super.key,
    this.isManager = true,
    required this.animalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentsAsync = ref.watch(medicalTreatmentsProvider(animalId));
    final theme = Theme.of(context);

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.vaccines_rounded,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.t('medical.activeTreatments'),
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  if (isManager)
                    FilledButton.icon(
                      onPressed: () => showAddTreatmentBottomSheet(
                        context: context,
                        animalId: animalId,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(context.l10n.t('common.add')),
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    context.l10n.t('medical.tableHint'),
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

        Expanded(
          child: treatmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                context.l10n.t('medical.loadTreatmentsError'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            data: (treatments) {
              if (treatments.isEmpty) {
                return AppEmptyState(
                  icon: Icons.medication_rounded,
                  title: context.l10n.t('medical.noActiveTreatments'),
                  message: context.l10n.t('medical.noActiveTreatmentsMessage'),
                );
              }

              return AppTable(
                itemCount: treatments.length,
                header: AppTableHeader(
                  columns: [
                    AppTableColumn(
                      label: context.l10n.t('medical.medicineColumn'),
                      flex: 4,
                    ),
                    AppTableColumn(
                      label: context.l10n.t('medical.dosageColumn'),
                      flex: 3,
                    ),
                    AppTableColumn(
                      label: context.l10n.t('medical.statusColumn'),
                      flex: 3,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                rowBuilder: (context, index) => _TreatmentRow(
                  treatment: treatments[index],
                  animalId: animalId,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TreatmentRow extends ConsumerWidget {
  final MedicalTreatment treatment;
  final int animalId;

  const _TreatmentRow({required this.treatment, required this.animalId});

  String getDosageString(BuildContext context) =>
      '${treatment.dosage.toStringAsFixed(treatment.dosage.truncateToDouble() == treatment.dosage ? 0 : 1)}'
      ' ${_localizedUnit(context, treatment.dosageUnit)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => showTreatmentDetailBottomSheet(
        context: context,
        treatment: treatment,
        animalId: animalId,
      ),
      onDoubleTap: () {
        final newStatus = treatment.status == MedicineStatus.given
            ? MedicineStatus.pending
            : MedicineStatus.given;

        ref
            .read(medicalTreatmentsProvider(animalId).notifier)
            .toggleStatus(treatment.id, newStatus);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                treatment.medicineName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Expanded(
              flex: 3,
              child: Text(
                getDosageString(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: SectionBadge(
                  label: _localizedStatus(
                    context,
                    treatment.status,
                  ).toUpperCase(),
                  color: treatment.status == MedicineStatus.given
                      ? AppColors.primary
                      : theme.colorScheme.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedStatus(BuildContext context, MedicineStatus status) =>
      switch (status) {
        MedicineStatus.given => context.l10n.t('medical.statusGiven'),
        MedicineStatus.pending => context.l10n.t('medical.statusPending'),
      };

  String _localizedUnit(BuildContext context, DosageUnit unit) =>
      switch (unit) {
        DosageUnit.mg => context.l10n.t('medical.unitMg'),
        DosageUnit.ml => context.l10n.t('medical.unitMl'),
        DosageUnit.drops => context.l10n.t('medical.unitDrops'),
        DosageUnit.units => context.l10n.t('medical.unitUnits'),
      };
}
