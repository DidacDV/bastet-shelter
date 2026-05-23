import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/components/vet_visit_type_dropdown.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart'; // Added AppTextField
import 'package:bastetshelter/features/common/components/fields/date_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddVetVisitBottomSheet extends ConsumerStatefulWidget {
  final int animalId;

  const AddVetVisitBottomSheet({super.key, required this.animalId});

  @override
  ConsumerState<AddVetVisitBottomSheet> createState() =>
      _AddVetVisitBottomSheetState();
}

class _AddVetVisitBottomSheetState
    extends ConsumerState<AddVetVisitBottomSheet> {
  final _clinicController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  VetVisitType _selectedType = VetVisitType.generalCheckup;
  bool _loading = false;

  @override
  void dispose() {
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final clinic = _clinicController.text.trim();
    if (clinic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('vet.enterClinicName'))),
      );
      return;
    }

    setState(() => _loading = true);

    final newVisit = VetVisit(
      id: 0,
      animalId: widget.animalId,
      visitDate: _selectedDate,
      visitType: _selectedType,
      clinicName: clinic,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref
        .read(vetVisitsProvider(widget.animalId).notifier)
        .addVisit(newVisit);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormBottomSheet(
      title: context.l10n.t('vet.newVisit'),
      leading: const Icon(
        Icons.local_hospital_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      actions: [
        PrimaryButton(
          label: context.l10n.t('vet.saveVisit'),
          isLoading: _loading,
          onPressed: _save,
        ),
      ],
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
                    context.l10n.t('common.date'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DateField(
                    label: '',
                    value: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDate = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.t('vet.visitType'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  VetVisitTypeDropdown(
                    initialItem: _selectedType,
                    onChanged: (t) =>
                        setState(() => _selectedType = t ?? _selectedType),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        AppTextField(
          controller: _clinicController,
          label: context.l10n.t('vet.clinicName'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),

        AppTextField(
          controller: _notesController,
          label: context.l10n.t('common.notesOptional'),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

Future<void> showAddVetVisitBottomSheet({
  required BuildContext context,
  required int animalId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (_) => AddVetVisitBottomSheet(animalId: animalId),
  );
}
