import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/components/dosage_unit_dropdown.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/components/treatment_frequency_dropdown.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/info_row.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:bastetshelter/providers/medical_treatments/medical_treatment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TreatmentDetailBottomSheet extends ConsumerStatefulWidget {
  final MedicalTreatment treatment;
  final int animalId;
  final bool canEdit;

  const TreatmentDetailBottomSheet({
    super.key,
    required this.treatment,
    required this.animalId,
    this.canEdit = false,
  });

  @override
  ConsumerState<TreatmentDetailBottomSheet> createState() =>
      TreatmentDetailBottomSheetState();
}

class TreatmentDetailBottomSheetState
    extends ConsumerState<TreatmentDetailBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dosageController;

  late MedicineFrequency _frequency;
  late DosageUnit _dosageUnit;
  bool _loading = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _frequency = widget.treatment.frequency;
    _dosageUnit = widget.treatment.dosageUnit;
    _dosageController = TextEditingController(
      text: widget.treatment.dosage.toStringAsFixed(
        widget.treatment.dosage.truncateToDouble() == widget.treatment.dosage
            ? 0
            : 1,
      ),
    );
  }

  @override
  void dispose() {
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final updated = widget.treatment.copyWith(
      dosage: double.parse(_dosageController.text),
      dosageUnit: _dosageUnit,
      frequency: _frequency,
    );

    await ref
        .read(medicalTreatmentsProvider(widget.animalId).notifier)
        .updateTreatment(widget.treatment.id, updated);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: context.l10n.t('medical.deleteTreatment'),
      message: context.l10n.t('medical.deleteTreatmentMessage'),
      confirmText: context.l10n.t('profile.delete'),
      isDestructive: true,
    );

    if (confirmed != true) return;
    setState(() => _deleting = true);

    await ref
        .read(medicalTreatmentsProvider(widget.animalId).notifier)
        .deleteTreatment(widget.treatment.id);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormBottomSheet(
      title: widget.treatment.medicineName,
      actions: widget.canEdit
          ? [
              PrimaryButton(
                label: context.l10n.t('common.saveChanges'),
                isLoading: _loading,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _deleting ? null : _delete,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: _deleting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.t('medical.deleteTreatment')),
              ),
            ]
          : [
              PrimaryButton(
                label: context.l10n.t('common.close'),
                onPressed: () => Navigator.of(context).pop(),
                isLoading: _loading,
              ),
            ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('medical.dosage'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _dosageController,
                      label: context.l10n.t('medical.amount'),
                      readOnly: !widget.canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return context.l10n.t('common.required');
                        }
                        if (double.tryParse(v) == null) {
                          return context.l10n.t('common.invalidNumber');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  IgnorePointer(
                    ignoring: !widget.canEdit,
                    child: Opacity(
                      opacity: widget.canEdit ? 1.0 : 0.6,
                      child: DosageUnitDropdown(
                        initialItem: _dosageUnit,
                        onChanged: (u) =>
                            setState(() => _dosageUnit = u ?? _dosageUnit),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                context.l10n.t('medical.frequency'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              IgnorePointer(
                ignoring: !widget.canEdit,
                child: Opacity(
                  opacity: widget.canEdit ? 1.0 : 0.6,
                  child: FrequencyDropdown(
                    initialItem: _frequency,
                    onChanged: (f) =>
                        setState(() => _frequency = f ?? _frequency),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              InfoRow(
                label: context.l10n.t('medical.startDate'),
                value: _formatDate(widget.treatment.startDate),
              ),
              if (widget.treatment.endDate != null)
                InfoRow(
                  label: context.l10n.t('medical.endDate'),
                  value: _formatDate(widget.treatment.endDate!),
                ),
              InfoRow(
                label: context.l10n.t('medical.lastStatusUpdate'),
                value: _formatDate(widget.treatment.statusUpdatedAt),
              ),
              if (widget.treatment.statusLastUpdatedByName != null)
                InfoRow(
                  label: context.l10n.t('medical.statusLastUpdatedBy'),
                  value: widget.treatment.statusLastUpdatedByName!,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

Future<void> showTreatmentDetailBottomSheet({
  required BuildContext context,
  required MedicalTreatment treatment,
  required int animalId,
  bool canEdit = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => TreatmentDetailBottomSheet(
      treatment: treatment,
      animalId: animalId,
      canEdit: canEdit,
    ),
  );
}
