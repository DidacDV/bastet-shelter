import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/components/dosage_unit_dropdown.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/components/medicine_dropdown.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/components/treatment_frequency_dropdown.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/fields/date_field.dart';
import 'package:bastetshelter/features/common/components/layout/api_error_widget.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/medical/data/models/medicine_model.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:bastetshelter/providers/medical_treatments/medical_treatment_provider.dart';
import 'package:bastetshelter/providers/medicine/medicine_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTreatmentBottomSheet extends ConsumerStatefulWidget {
  final int animalId;

  const AddTreatmentBottomSheet({super.key, required this.animalId});

  @override
  ConsumerState<AddTreatmentBottomSheet> createState() =>
      _AddTreatmentBottomSheetState();
}

class _AddTreatmentBottomSheetState
    extends ConsumerState<AddTreatmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dosageController = TextEditingController();

  Medicine? _selectedMedicine;
  MedicineFrequency _frequency = MedicineFrequency.daily;
  DosageUnit _dosageUnit = DosageUnit.units;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _loading = false;

  @override
  void dispose() {
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a medicine')));
      return;
    }

    final dateError = Validators.validateDateRange(_startDate, _endDate);
    if (dateError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dateError)));
      return;
    }

    setState(() => _loading = true);

    final treatment = MedicalTreatment(
      id: 0,
      animalId: widget.animalId,
      medicineId: _selectedMedicine!.id,
      medicineName: _selectedMedicine!.name,
      frequency: _frequency,
      status: MedicineStatus.pending,
      statusUpdatedAt: DateTime.now(),
      startDate: _startDate,
      endDate: _endDate,
      dosage: double.parse(_dosageController.text),
      dosageUnit: _dosageUnit,
    );

    await ref
        .read(medicalTreatmentsProvider(widget.animalId).notifier)
        .addTreatment(treatment);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicinesAsync = ref.watch(medicinesProvider);

    return FormBottomSheet(
      title: 'New Treatment',
      actions: [
        PrimaryButton(
          label: 'Add treatment',
          isLoading: _loading,
          onPressed: _save,
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        medicinesAsync.when(
                          data: (medicines) => MedicineDropdown(
                            items: medicines,
                            onChanged: (m) =>
                                setState(() => _selectedMedicine = m),
                          ),
                          error: (e, _) => ApiErrorWidget(
                            error: e,
                            onRetry: () => ref.invalidate(medicinesProvider),
                          ),
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Frequency',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FrequencyDropdown(
                          initialItem: _frequency,
                          onChanged: (f) =>
                              setState(() => _frequency = f ?? _frequency),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Dosage',
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
                      label: 'Amount',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) => Validators.validatePositiveNumber(
                        v,
                        fieldName: 'dosage',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DosageUnitDropdown(
                    initialItem: _dosageUnit,
                    onChanged: (u) =>
                        setState(() => _dosageUnit = u ?? _dosageUnit),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Dates
              Text(
                'Duration',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DateField(
                      label: 'Start date',
                      value: _startDate,
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                      onChanged: (d) {
                        if (d != null) setState(() => _startDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateField(
                      label: 'End date',
                      value: _endDate,
                      required: false,
                      firstDate: _startDate,
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                      onChanged: (d) => setState(() => _endDate = d),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> showAddTreatmentBottomSheet({
  required BuildContext context,
  required int animalId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AddTreatmentBottomSheet(animalId: animalId),
  );
}
