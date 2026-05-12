import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/shifts/presentation/components/add_shift_tasks_bottomsheet.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shift_detail_shared.dart';

class ShiftTasksSection extends ConsumerWidget {
  final int shiftId;
  final ShiftDetail shiftDetail;
  final bool isManager;

  const ShiftTasksSection({
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
        SectionHeader(
          title: 'Tasks',
          tt: tt,
          padding: EdgeInsets.zero,
          trailing: isManager
              ? TextButton.icon(
                  onPressed: () {
                    showAddShiftTasksBottomSheet(
                      context: context,
                      onSave: (selectedIds) async {
                        await notifier.addTasksToShift(selectedIds);
                      },
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Task'),
                )
              : null,
        ),
        const SizedBox(height: 6),
        if (shiftDetail.shiftTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(
              'No tasks assigned to this shift yet.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: shiftDetail.shiftTasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final shiftTask = shiftDetail.shiftTasks[index];
              final isCompleted = shiftTask.status == ShiftTaskStatus.completed;

              return ManageListCard(
                title: shiftTask.task.title,
                leadingIcon: isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                isEven: index.isEven,

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shiftTask.task.description,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (shiftTask.animalId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Animal ID: ${shiftTask.animalId}',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),

                onTap: () {
                  // TODO: Handle what happens when tapping the task
                },
                onEdit: null,
                onDelete: isManager
                    ? () async {
                        final confirm = await ConfirmationDialog.show(
                          context: context,
                          title: 'Remove Task?',
                          message:
                              'Are you sure you want to remove this task from the shift?',
                          confirmText: 'Remove',
                          isDestructive: true,
                        );
                        if (confirm) {
                          notifier.removeTask(shiftTask.id);
                        }
                      }
                    : null,
              );
            },
          ),
      ],
    );
  }
}
