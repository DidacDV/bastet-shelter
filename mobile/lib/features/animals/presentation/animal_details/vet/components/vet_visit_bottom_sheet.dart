import 'package:bastetshelter/features/animals/presentation/animal_details/vet/components/vet_visit_type_dropdown.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VetVisitBottomSheet extends ConsumerStatefulWidget {
  const VetVisitBottomSheet({
    super.key,
    required this.visit,
    required this.animalId,
    this.isManager = false,
  });

  final VetVisit visit;
  final int animalId;
  final bool isManager;

  static Future<void> show({
    required BuildContext context,
    required VetVisit visit,
    required int animalId,
    bool isManager = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VetVisitBottomSheet(
        visit: visit,
        animalId: animalId,
        isManager: isManager,
      ),
    );
  }

  @override
  ConsumerState<VetVisitBottomSheet> createState() =>
      _VetVisitBottomSheetState();
}

class _VetVisitBottomSheetState extends ConsumerState<VetVisitBottomSheet> {
  late DateTime _visitDate;
  late VetVisitType _visitType;
  late String _clinicName;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _visitDate = widget.visit.visitDate;
    _visitType = widget.visit.visitType;
    _clinicName = widget.visit.clinicName;
  }

  String get _formattedDate => DateFormat('dd MMM yyyy').format(_visitDate);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  void _editClinic() {
    final controller = TextEditingController(text: _clinicName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Clinic'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Clinic name'),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) {
                      setState(() => _clinicName = value);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final nw = widget.visit.copyWith(
      visitDate: _visitDate,
      visitType: _visitType,
      clinicName: _clinicName,
    );

    await ref
        .read(vetVisitsProvider(widget.animalId).notifier)
        .updateVisit(widget.visit.id, nw);
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete visit',
      message:
          'Are you sure you want to delete this vet visit? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    await ref
        .read(vetVisitsProvider(widget.animalId).notifier)
        .deleteVisit(widget.visit.id);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEdit = widget.isManager;

    return FormBottomSheet(
      title: 'Vet Visit',
      actions: [
        if (canEdit) ...[
          PrimaryButton(
            label: 'Save Changes',
            isLoading: _isSaving,
            onPressed: _save,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Delete visit'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ],
      children: [
        EditableField(
          label: 'Date',
          value: _formattedDate,
          canEdit: canEdit,
          onEdit: _pickDate,
        ),
        const SizedBox(height: 20),

        if (canEdit) ...[
          Text(
            'Visit Type',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          VetVisitTypeDropdown(
            initialItem: _visitType,
            onChanged: (t) => setState(() => _visitType = t ?? _visitType),
          ),
        ] else
          EditableField(
            label: 'Visit Type',
            value: _visitType.label,
            canEdit: false,
          ),
        const SizedBox(height: 20),

        EditableField(
          label: 'Clinic',
          value: _clinicName,
          canEdit: canEdit,
          onEdit: _editClinic,
        ),

        if (widget.visit.notes?.isNotEmpty == true) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Notes',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.visit.notes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
