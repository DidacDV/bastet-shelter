import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shift_detail_shared.dart';

class ShiftParticipantsSection extends ConsumerWidget {
  final int shiftId;
  final ShiftDetail shiftDetail;
  final bool isManager;

  const ShiftParticipantsSection({
    super.key,
    required this.shiftId,
    required this.shiftDetail,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(shiftDetailProvider(shiftId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Participants', tt: tt),
        Card(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: EditableRow(
              icon: Icons.people_outline,
              label: 'Capacity',
              value: shiftDetail.maxParticipants != null
                  ? '${shiftDetail.currentParticipants} / ${shiftDetail.maxParticipants}'
                  : '${shiftDetail.currentParticipants} (No limit)',
              canEdit: isManager,
              onEdit: () async {
                final controller = TextEditingController(
                  text: shiftDetail.maxParticipants?.toString() ?? '',
                );

                final newLimit = await showDialog<int?>(
                  context: context,
                  builder: (context) => AlertDialog(
                    titleTextStyle: Theme.of(context).textTheme.titleLarge,
                    titlePadding: const EdgeInsets.fromLTRB(28, 32, 28, 12),
                    contentPadding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                    actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    title: const Text('Edit Capacity Limit'),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: "Leave blank for no limit",
                      ),
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom().copyWith(
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                              onPressed: () => Navigator.pop(
                                context,
                                int.tryParse(controller.text),
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                if (newLimit != null) {
                  notifier.updateShift(maxParticipants: newLimit);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
