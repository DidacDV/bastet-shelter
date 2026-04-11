import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/fields/label_value.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

//TODO: REFACTOR
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
  late String _reason;
  late String _clinicName;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _visitDate = widget.visit.visitDate;
    _reason = widget.visit.visitType.toString();
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

  void _editField({
    required String label,
    required String initialValue,
    required void Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label),
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
                      onSave(value);
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text('Vet Visit', style: theme.textTheme.titleLarge),
              ),
              if (canEdit)
                IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: theme.colorScheme.error,
                  tooltip: 'Delete visit',
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Date
          EditableField(
            label: 'Date',
            value: _formattedDate,
            canEdit: canEdit,
            onEdit: _pickDate,
          ),
          const SizedBox(height: 16),

          // Reason
          EditableField(
            label: 'Reason',
            value: _reason,
            canEdit: canEdit,
            onEdit: () => _editField(
              label: 'Reason',
              initialValue: _reason,
              onSave: (v) => setState(() => _reason = v),
            ),
          ),
          const SizedBox(height: 16),

          // Vet name
          EditableField(
            label: 'Clinic',
            value: _clinicName,
            canEdit: canEdit,
            onEdit: () => _editField(
              label: 'Clinic',
              initialValue: _clinicName,
              onSave: (v) => setState(() => _clinicName = v),
            ),
          ),

          // Notes (read-only, shown only if present)
          if (widget.visit.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            LabelValue(label: 'Notes', value: widget.visit.notes!),
          ],

          if (canEdit) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
