import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/fields/date_field.dart';
import 'package:bastetshelter/features/medical/data/models/vet_visit_model.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddVetVisitDialog extends ConsumerStatefulWidget {
  final int animalId;

  const AddVetVisitDialog({super.key, required this.animalId});

  @override
  ConsumerState<AddVetVisitDialog> createState() => _AddVetVisitDialogState();
}

class _AddVetVisitDialogState extends ConsumerState<AddVetVisitDialog> {
  final _clinicController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  VetVisitType _selectedType = VetVisitType.generalCheckup;

  @override
  void dispose() {
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text('New Vet Visit', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: DateField(
                    label: 'Date',
                    value: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedDate = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<VetVisitType>(
                    initialValue: _selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Visit Type',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items: VetVisitType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _clinicController,
              decoration: const InputDecoration(
                labelText: 'Clinic Name',
                hintText: 'e.g. VetRubiCanoriol',
                prefixIcon: Icon(Icons.storefront_rounded, size: 20),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              maxLines: 3,
              minLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add details about the visit...',
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final clinic = _clinicController.text.trim();
                      if (clinic.isNotEmpty) {
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

                        ref
                            .read(vetVisitsProvider(widget.animalId).notifier)
                            .addVisit(newVisit);
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
      ),
    );
  }
}
